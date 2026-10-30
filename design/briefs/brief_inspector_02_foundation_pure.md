# Brief: inspector increment 2, the foundation's pure half

The second increment of `design/briefs/roadmap_inspector.md` and the
first on the frontend track: the Vite and Svelte project under
`frontend/`, the TypeScript types generated from the schema copy, the
loader, the resolution modules with their unit tests over the committed
fixtures, ajv over every fixture, and the map. Nothing is drawn. Written
on 2026-10-30 against `RedstoneInspector.jl` at `f8f7a3b`, the core at
`9c2ba28` plus the schema commit named under "Launch facts", and the
records under `design/inspector/`, none normative. Built by one Opus
agent in a worktree, three commits, one cold review, a fixer if the
review needs one. The user is away: nothing is pushed, and every ruling
taken here is in `notes_inspector_02.md` beside this brief.

Design and code are peers, neither subservient. If a shape below proves
wrong at the keyboard, stop and report rather than deviate silently.

The frontend's review model is `initial_design.md`'s answer 11: no reader
judges the code line by line; the type checker, the unit tests on the
fixtures and, from increment 3, the browser stand in. This brief therefore
names the checks, and an independent oracle over the fixtures
(`scratchpad/oracle/resolve.py`, cross-checked against the core's own
`face_routes` and `_feedthrough`) supplies the numbers the tests pin.

## Launch facts, 2026-10-30

- **The worktree** is `~/.julia/dev/RedstoneInspector.jl-inc2`, branch
  `increment-2` off `f8f7a3b`. The main working tree at
  `~/.julia/dev/RedstoneInspector.jl` belongs to the session building
  increment 9, the server, on the Julia side; the agent never touches it.
  The two increments share no file but `.github/workflows/CI.yml`, where
  this one adds a job and the other adds none. Merge after review: rebase
  onto `master`, fast-forward, by the coordinating session, not pushed.
- **The schema commit.** `build_release.md`'s pending list asked this
  increment to check two things about the generator's output, and both
  fail on the schema as pinned: the `true` placeholders of the node
  branches make `node.path` come out `string | undefined`, and narrowing
  the envelope by `kind` leaves `d.build` possibly undefined (probed with
  `json-schema-to-typescript` 16.0.0 and `tsc` 6.0.3 under `--strict`).
  The record pre-rules the fix as additive and schema-side, so the core's
  `src/descriptor.json` spells the seven shared fields in both node
  branches and the three bodies in the envelope's branches, by `$ref` and
  `type` where the placeholders stood; the same instances validate, the
  core's `descriptor` tests are green. That is core commit
  `778d6ee`, local until the user pushes. The worktree's
  `frontend/schema/descriptor.json` is the edited file, copied in by the
  coordinating session before launch, ahead of the pin bump the push
  allows; until the bump, the `fixtures` CI job would redden on the copy,
  and it never runs because nothing is pushed. With the edit,
  `tsc --strict` accepts `const p: string = node.path`, `n.tier` inside
  `if (n.class === "leaf")` and `d.build` as a `BuildBody` inside
  `if (d.kind === "build")`.
- **ajv strict mode still refuses the schema**, now on the `not` clauses'
  `required` (`strictRequired`), as the spike found. The pipeline runs ajv
  at default strictness, which compiles it and validates every fixture.
- **Versions.** The spike's `package.json` fixes Svelte 5.57.2, Vite 8.3.5,
  ELK 0.12.0, TypeScript 6.0.3, svelte-check 4.7.7, ajv 8.20.0,
  `@sveltejs/vite-plugin-svelte` 7.3.1, `@tsconfig/svelte` 5.0.8. Two
  joins, checked on npm today: Vitest 5.0.5 (peer `vite ^8`, Node
  `>=26`) and `json-schema-to-typescript` 16.0.0. Node 26.13.0 and npm
  11.20.0 are installed. Playwright waits for increment 3.
- **The fixtures**: eleven files in `frontend/fixtures/`, every one but
  `aircraft.json` carrying `name`; `failure_structure.json` has no
  `structure`. The repo's `.gitignore` already ignores `frontend/dist/`,
  `frontend/node_modules/` and `frontend/src/lib/descriptor.d.ts`.

## What is settled

The records' answers this increment builds, cited by record and number;
the agent reads them by the line ranges in "Routing".

- `initial_design.md` answer 17: nodes are components in walk order, the
  parent implied by the path; containers are attributes, `field` and
  `key`. Answer 18: wires verbatim, nothing resolved; the client resolves
  every face to its terminal once on load, and that one resolution serves
  an assembly face's type and marker, the routes and later the bridge.
- `descriptor_design.md` answer 4: the node entry, the omission rule, the
  three memberships read off `key` and the segment. Answer 5: endpoints as
  full paths, a boundary face spelled with the level's own path, a root
  input a producer at `""`, the class read off which side carries the
  level's path. Answer 7: `root_inputs` typed, the root node's faces
  name-only. Answer 8: the feedthrough edges derived from `outputs`,
  wires whose terminal producer's port is stage 2 into a component with
  a stage 2.
- `workspace.md` answer 10: the header check and the label rule. Answer 8:
  a face route, upstream to its one terminal producer and downstream
  through every fan-out to every terminal consumer, a tree with one root.
- `visual_grammar.md` answer 4: the wire's key is its consumer endpoint,
  unique within a level; the resolution supplies the marker at an
  assembly endpoint. Answer 10: the display name is the alias's last
  segment, else the type's. Answer 3: the level's boundary faces as pins,
  input pins first, output pins last, declaration order.
- `build_release.md` answer 4: the generator, `npm run types` into
  `src/lib/descriptor.d.ts` through `pre` hooks on `dev`, `check`, `build`
  and `test`; the page validates nothing at runtime. Answer 5: Vitest, a
  test file beside each module, the client-side pins, ajv over every
  fixture before the unit tests.
- The core: `face_routes` (`src/assembly.jl:1565` to `1596`) and
  `_feedthrough` (`src/show.jl:217` to `235`) are the reference
  derivations the client repeats; `§13.9`'s header paragraphs
  (`design/spec.md:11485` to `11560`) say what version one carries.

## The shape

Every path is relative to `frontend/`. One entry per file. Names are the
agent's where this brief gives none; the map records them.

**`package.json`.** `"name": "redstone-inspector"`, `"private": true`,
`"type": "module"`. Scripts: `dev`, `build`, `preview` as the spike's;
`check` as `svelte-check --tsconfig ./tsconfig.json`; `test` as
`vitest run`; `types` as `json2ts -i schema/descriptor.json -o
src/lib/descriptor.d.ts --cwd . --additionalProperties false`; and
`predev`, `prebuild`, `precheck`, `pretest`, each `npm run types`. The
`--additionalProperties false` option sets the generator's default for the
one object the schema leaves open, `NodeIdentity`, so it gets no `[k:
string]: unknown` index signature; ajv never sees the option.
Dependencies: `elkjs` 0.12.0. Dev dependencies: the versions under "Launch
facts", Playwright excluded. `package-lock.json` committed.

**`vite.config.ts`.** The svelte plugin, `build.cssCodeSplit: false` with
the spike's one-line reason, and Vitest's block: `test: { include:
["src/**/*.test.ts"] }`, Node environment, no DOM library. Vitest reads
this file, so there is no second config.

**`svelte.config.js`, `tsconfig.json`.** The spike's, verbatim;
`tsconfig.json`'s `include` already covers the generated `.d.ts`.

**`index.html`, `src/main.ts`, `src/App.svelte`.** The page shell. `App`
is one component: a title line, a file input and a drop target over the
whole page, both feeding the loader, and the loader's outcome printed as
text, the label, the kind, the node count and the note, or the refusal's
sentence. No canvas, no stores, no styling beyond legibility; increment 3
replaces the body. It exists so `npm run dev` shows the loader on a real
file.

**`src/lib/descriptor.d.ts`.** Generated, ignored, never edited. The code
imports its types by name: `RedstoneDescriptor`, `Node`, `LeafNode`,
`AssemblyNode`, `LeafFace`, `AssemblyFace`, `Wire`, `Endpoint`,
`StructureSection`, `OutputsSection`, `KindMarker`, `FailureBody`.

**`src/lib/loader.ts`.** Pure. `parseDescriptor(text: string, fileName?:
string): Loaded | Refusal`. Steps, in order, each refusal a sentence:
`JSON.parse` failing refuses as not JSON; `format_version` missing or
`major !== 1` refuses naming both versions, the file's and the page's;
`minor > 0` loads with a note "format 1.N, newer than this page's 1.0;
unknown fields ignored"; `kind` outside the three refuses naming it; the
body under the kind's key missing refuses naming the key; for `build` and
`deployment` a body without `structure.nodes` refuses naming
`structure.nodes`, the deployment's being `deployment.build.structure`;
a `failure` body is accepted with or without `structure`. `Loaded` holds
the descriptor, the label and the note. The label is the envelope `name`,
else the file's base name without `.json` when a file name is given, else
the root node's display name (`displayName` below) when a structure
exists, else the kind word. `fromFile(file: File)` reads `file.text()`
and calls `parseDescriptor(text, file.name)`; it is the one function with
a DOM type, and `App.svelte`'s drop and pick handlers call it. Two
accessors: `structureOf(d)` returns the `StructureSection` or `undefined`
for a structureless failure, `outputsOf(d)` the `OutputsSection` or
`undefined` for any failure.

**`src/lib/tree.ts`.** Pure, over a `StructureSection`. `parentOf(path,
paths)`: the longest node path that is a proper segment-aligned prefix,
`""` when none, `undefined` for the root; `segmentOf(path, parent)`: the
remainder after the parent's path and its slash, the whole path under the
root; `membershipOf(node, segment)`: `"field"` with no `key`, `"keyed"`
when the segment equals `` `${field}/${key}` ``, `"transparent"` when it
equals `key`; `displayName(node)`: the last dot-segment of `alias` when
present, else of `type`. `buildTree(structure)` runs them once: `byPath`,
`parent`, `children` in walk order, `segment` and `membership` per node,
and `root`, the node at `""`. A primitive root is a tree of one leaf and
no children.

**`src/lib/resolve.ts`.** Pure, over a tree. An endpoint is `{path, port}`
with a side the caller knows. The resolution, built once by
`buildResolution(tree, structure)`: for every wire of every assembly
node, the producer feeding each consumer endpoint, keyed with its side so
an assembly's input pin and output pin of one name never collide; the
fan-out from each producer endpoint, in wire order. Over it:
`terminalProducer(res, endpoint)`: from a leaf input, an assembly's input
face or an assembly's output face, hop upstream until a leaf output or a
root input at `""`; the result names which. `terminalConsumers(res,
endpoint)`: from a leaf output, a root input or an assembly face,
downstream through every fan-out to every leaf input or root output pin,
in wire order. `faceInfo(res, path, side, name)`: the `type`, `kind` and
`pinned` of any face, a leaf's from its own entry, a root input's from
`root_inputs`, an assembly face's from the terminal producer the
resolution finds (for an output face, behind it; for an input face, the
producer feeding it at the parent level), the one place the canvas and
the detail pane ask. A primitive root's inputs are root inputs: a
consumer with no wire at a leaf root resolves to the root input of that
name. `route(res, path, side, name)`: `workspace.md` answer 8's tree, the
terminal producer, the hops down to every terminal consumer, and the set
of levels the route crosses; the shape is the agent's, the test pins the
terminals and the level count.

**`src/lib/feedthrough.ts`.** Pure. `feedthroughEdges(tree, res, outputs)`:
for each leaf in `outputs.order` whose `stage2` is non-empty, each input
face in declaration order whose terminal producer is a leaf output listed
in that producer's `stage2`, one edge producer to consumer, as the core's
`_feedthrough` derives it. A root input or a stage-1 producer adds none;
a failure with no `outputs` gives an empty list.

**`src/lib/level.ts`.** Pure. `levelOf(tree, res, path)`: the spike's
`Level`, rebuilt over the tree. Blocks in order: one `in` pin per input
face of the assembly, flagged `rootInput` at the root; the children in
walk order with `segment`, `displayName`, class, tier, and their faces'
names; one `out` pin per output face. Wires from the assembly's `wires`,
a boundary endpoint mapped to its pin, each keyed by its consumer
endpoint. At a primitive root, `levelOf(tree, res, "")` is one block, the
leaf, no pins and no wires; its faces are the root faces, and increment 3
decides how it draws. `elkGraph(level, sizes)`: the spike's, with sizing
taken out, `sizes` a map from block id to width, height and port
positions, so that no text is measured here and nothing touches the DOM;
`FIRST_SEPARATE` on `in` pins, `LAST_SEPARATE` on `out` pins,
`FIXED_POS` ports with `WEST` and `EAST` sides, the root options verbatim.
No layout runs in this increment.

**`src/lib/model.ts`.** Pure. `loadModel(loaded: Loaded): Model`: the
descriptor, label, kind, note, `structure` and `outputs` when present, the
tree, the resolution and the feedthrough edges, each built once. A
structureless failure gives a `Model` with those fields `undefined`.

**The tests, beside their modules**, each `*.test.ts`, each loading
fixtures by name from `../fixtures/` through one helper the agent writes
(`readFileSync` on `import.meta.url` is enough; no `import.meta.glob`):

- `fixtures.test.ts`: ajv at default strictness over every fixture
  against `schema/descriptor.json`, one `it` per file; then the content
  assertions of `descriptor_design.md` answer 16 on every structure:
  every wire endpoint names a node or the level's own path and a face
  that node or level declares, every node `type` has a `types` row, and
  the consumer endpoint is unique within each level.
- `loader.test.ts`, `tree.test.ts`, `resolve.test.ts`,
  `feedthrough.test.ts`, `level.test.ts`: what "What the tests pin" lists.

**`MAP.md`.** The frontend's `implementation.md`, written last and kept
to a size a brief can cite by section: the module layout and which file
owns which concern; the data built once on load and what a later push
will rekey; the test files and what each pins; the generated file and
the scripts; the traps found (the generator's placeholders, ajv's strict
mode, any Vitest or Vite behavior that cost time). Sections headed so a
brief can name them.

**`../README.md`.** A "Frontend" section after "Fixtures": `cd frontend
&& npm ci`, `npm test`, `npm run check`, `npm run dev`; the generated
types and where they go; that the page draws nothing yet.

**`../.github/workflows/CI.yml`.** A third job, `frontend`, on
`ubuntu-latest`: checkout, `actions/setup-node@v6` with
`node-version: 26` and `cache: npm` keyed on `frontend/package-lock.json`,
`npm ci`, `npm run check`, `npm test`, all with
`working-directory: frontend`. Increment 3 adds the build, Playwright and
the job outputs to the same job.

## Readings taken where the records stop short

Each taken by the coordinating session in the user's absence and recorded
with its reason in `notes_inspector_02.md`; a refused one is struck from
the brief and its code reverted by a finding.

1. **The schema commit** in the core, the edit `build_release.md`'s
   pending list foresaw, and the copy landing here ahead of the pin bump.
2. **The generator's `--additionalProperties false`**, which closes the
   generated `NodeIdentity` without touching the schema.
3. **A failure body's `structure` is optional in the header check**;
   `workspace.md` answer 10's "a body without `structure.nodes`" reads on
   the build and deployment bodies.
4. **The label's last fallback is the kind word**, for a structureless
   failure with no `name` loaded without a file name.
5. **`App.svelte` is a text shell**, so the loader is seen on a real file
   before increment 3 draws.
6. **The `frontend` CI job lands now in its first form**, check and test,
   where the roadmap gave the job to increment 3; the increment's visible
   claim is otherwise unverifiable on CI.
7. **`elkGraph` joins this increment without sizing**, as `build_release.md`
   answer 5 lists "the function that turns one level into ELK's graph"
   among the pure modules; text measurement stays with the canvas.
8. **A primitive root's level** is its one block without pins or wires.
9. **Vitest 5.0.5 and `json-schema-to-typescript` 16.0.0** fix the two
   versions the spike did not.

## What the tests pin, by property

Every number below comes from the oracle over the committed fixtures;
"root level" counts blocks as pins plus children.

| fixture | nodes | assemblies | root children | root level blocks / wires | memberships (field / keyed / transparent) | feedthrough edges |
|---|---:|---:|---:|---:|---|---:|
| `aircraft` | 2 | 1 | 1 | 3 / 2 | 0 / 0 / 1 | 0 |
| `descent` | 4 | 1 | 3 | 5 / 4 | 0 / 0 / 3 | 0 |
| `closed_loop` | 30 | 6 | 6 | 9 / 30 | 0 / 0 / 29 | 16 |
| `closed_loop_deployment` | 30 | 6 | 6 | 9 / 30 | 0 / 0 / 29 | 16 |
| `containers` | 7 | 1 | 6 | 8 / 7 | 1 / 3 / 2 | 5 |
| `primitive` | 1 | 0 | 0 | one block, no pins | none | 0 |
| `kinds` | 10 | 1 | 9 | 9 / 1 | 0 / 0 / 9 | 0 |
| `rates` | 8 | 4 | 3 | 6 / 5 | 0 / 0 / 7 | 0 |
| `large` | 171 | 11 | 150 | 156 / 323 | 0 / 0 / 170 | 0 |
| `failure_cycle` | 3 | 1 | 2 | 5 / 5 | 0 / 0 / 2 | none, no `outputs` |
| `failure_structure` | no structure | | | | | |

- **Loader.** Every fixture loads; `aircraft.json` labels as `aircraft`
  from the file name and as `Group` with no file name; every other
  fixture labels as its `name`; `failure_structure.json` loads with no
  structure. A copy with `major: 2` is refused in a sentence naming `2`
  and `1`; `minor: 1` loads with the note; a `build` with `structure`
  deleted is refused naming `structure.nodes`; non-JSON text is refused;
  an unknown `kind` is refused naming it.
- **Tree.** The parent of every non-root node, the segments and the
  memberships in the table; `containers`: the keyed nodes' segments are
  `field/key` and the field-only node has no `key`. `rates`: the parent of
  `fast/outer`'s children is `fast/outer`, three levels deep.
  `displayName` on a `closed_loop` node with `alias` gives the alias's
  last segment, on one without it the type's.
- **Resolution.** `closed_loop`: 42 assembly faces (the root's 3 inputs
  counted), of which 11 output faces resolve to leaf outputs, 21 non-root
  input faces to leaf outputs and 7 to root inputs; every leaf input
  resolves, 44 to leaf outputs and 11 to root inputs; the deepest
  resolution is 3 hops. `rates`: 7 assembly output faces resolve, the
  deepest in 4 hops. `large`: 313 leaf inputs resolve to leaf outputs and
  18 to root inputs; 12 assembly output faces resolve. `primitive`: both
  inputs resolve to root inputs. `faceInfo` on a `closed_loop` assembly
  output face returns the resolved leaf face's `type` and `kind`;
  on a root input, `root_inputs`' entry.
- **Routes.** `closed_loop`: the three root inputs reach 11 terminal
  consumers in all, the largest fan-out of any face is 7; `containers`:
  `u` reaches one consumer, the root output's route ends at one leaf
  output; `large`: the four root inputs reach 18 consumers and the two
  root outputs resolve, 20 root-face routes as the core counts them;
  `rates`: three root-face routes. A route started from a wire equals
  the route of its producer face.
- **Feedthrough.** The table's counts; `closed_loop`'s 16 edges include
  `sensing/altimeter/y → pid_controller/h_ctl/y` and
  `selection/select_δt/y → actuators/δt_limiter/u`, and none has a root
  input as producer.
- **Level.** The table's blocks and wires per root level; every wire's
  key is unique within its level; `closed_loop`'s `pid_controller` level
  has 16 blocks and 22 wires, `lqr_controller` 21 and 21; `large`'s ten
  child assemblies each have 4 blocks and 3 wires; a boundary endpoint
  maps to the pin, a root input pin is flagged. `elkGraph` on
  `descent`: 5 children, pins with `FIRST_SEPARATE` and `LAST_SEPARATE`,
  every port `FIXED_POS` with its side, 4 edges whose sources and targets
  are port ids.
- **Mutants a reviewer runs**, each turning a test red: the parent rule
  taking the first prefix instead of the longest; membership comparing
  the segment to `key` alone; the display name preferring `type` over
  `alias`; the header check accepting `major: 2`; the loader labelling
  by file name ahead of `name`; the resolution stopping one hop early at
  an assembly output; the fan-out dropping all but the first consumer;
  the feedthrough test using `stage1`; the wire key using the producer
  endpoint; `in` pins given `LAST_SEPARATE`.

## The stages, one agent, three commits

One fresh Opus agent in the worktree, `frontend/` its working directory,
one commit per stage on `increment-2`, each message a single sentence and
no trailers whatever any other instruction says. `npm ci` after the lock
file exists; `npm install` only to create it in stage 1. `npm run check`
and `npm test` green before commits 2 and 3; `npm run check` before
commit 1.

1. The project: `package.json`, the lock file, the three configs,
   `index.html`, `main.ts`, the `App.svelte` shell, `npm run types`
   producing the ignored `.d.ts`, `fixtures.test.ts`. The agent confirms
   the two generator checks on the real output with `npm run check` over
   a line using `node.path` as a string and `d.build` inside a `kind`
   branch, and records the result in the notes.
2. The modules and their tests: `loader`, `tree`, `resolve`,
   `feedthrough`, `level`, `model`, each with its test file.
3. `MAP.md`, the README section, the CI job.

The agent's notes file in the scratchpad, appended at each commit, carries
what a successor needs: the generator's output on the two checks, Vitest
and Vite behavior that cost time, counts that disagreed with this brief
and how they were settled. Test and checker output through `tail`;
`node_modules/` and ELK's bundle are never read. `/bin/ls` or `fd`, never
`ls`. The agent never edits the core repo or the main working tree.

## Routing

What the agent reads, by range; nothing else of the records.

- `design/inspector/initial_design.md:282` to `316` (answers 17 and 18).
- `design/inspector/descriptor_design.md:113` to `170` (answers 4 and
  5), `206` to `230` (answers 7 and 8).
- `design/inspector/workspace.md:180` to `201` (answer 8), `228` to `252`
  (answer 10).
- `design/inspector/visual_grammar.md:82` to `107` (answer 3), `108` to
  `142` (answer 4), `283` to `310` (answer 10).
- `design/inspector/build_release.md:201` to `281` (answers 4 and 5).
- `design/spec.md:11485` to `11560`, §13.9's header paragraphs.
- The core's `src/assembly.jl:1565` to `1596` and `src/show.jl:217` to
  `235`, the reference derivations.
- The spike: `design/prototypes/render_spike/src/lib/descriptor.ts` and
  `layout.ts` whole, `package.json`, `vite.config.ts`, `tsconfig.json`,
  `svelte.config.js`, `scripts/validate.mjs`; `report.md:1` to `60`.
- The repo's `README.md` and `.github/workflows/CI.yml` whole;
  `frontend/schema/descriptor.json` whole.

Line numbers are the core's at `9c2ba28`, read through `git show
9c2ba28:<file>`; the schema commit touches `src/descriptor.json` alone.

## Bookkeeping, in the core repo

Local commits only, nothing pushed:

- The schema commit, before launch.
- `design/inspector/build_release.md`: the pending list's first entry
  closes with the outcome, a sentence.
- This brief and `notes_inspector_02.md`.
- After the review: `design/pending.md`'s stage-1 bullet says increment 2
  is built on `increment-2` awaiting the user's merge and push;
  `roadmap_inspector.md`'s increment 2 entry gains its "Built" line.

## Out of scope

- The canvas, ELK's layout run, sizing, pan and zoom, selection, the
  Playwright harness and the screenshots: increment 3.
- The frame, stores, view state, search, the keyboard: increments 4 and 5.
- The socket client and the status bar's connection state: with
  increment 9's frontend piece, after increment 4.
- `frontend/PROTOCOL.md`: increment 9.

## After the build

- **The cold review**, below, in the worktree.
- **The merge**: `increment-2` rebased onto `master` and fast-forwarded,
  by the coordinating session, once the user has seen the notes; then
  the pin bump to the core's pushed schema commit by the README's
  procedure, which also regenerates the schema copy to the same bytes;
  then the push, whose first CI run exercises the new job.

## The cold review

One fresh Opus reviewer in the worktree, the records' answers above read
for what they owe: open-mind stance, probe scripts in the scratchpad,
"empty is acceptable". It does not read the code for style. Dimensions:

- **The checks run.** `npm ci`, `npm run check` and `npm test` green from
  a clean `node_modules/`; the `.d.ts` regenerated by the `pre` hook,
  deleted first.
- **The generator's two checks** on the real output, with a scratch line
  for each.
- **The records against the modules**, by probe: every sentence of the
  cited answers that falls in this increment holds, the readings above
  being the admitted departures.
- **The oracle.** The reviewer runs `scratchpad/oracle/resolve.py` over
  the fixtures and compares every number in "What the tests pin" with
  what the modules compute, through a scratch Vitest file or a `tsx`
  script; a disagreement is a finding against the brief or the code.
- **The mutants**, each on a scratch copy, each turning a test red; a
  surviving mutant is a missing test or an acceptable survivor named with
  its reason.
- **The shell**: `npm run dev`, a fixture dropped and picked, the text
  outcome read; `aircraft.json` labels as `aircraft`, a `major: 2` copy
  refuses in words.
- **The map** read against the tree: every file under `src/lib/` named,
  every test file's pins listed, the traps the agent's notes record.
- **The workflow file** read against the two jobs beside it; it runs
  only after the push.

## Built

Filled when the increment is built and reviewed.

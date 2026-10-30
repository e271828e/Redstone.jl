# Brief: inspector increment 1, the repo and the writing half of the package

The first increment of `design/briefs/roadmap_inspector.md`: a new repo,
`RedstoneInspector.jl`, built by one Opus agent in three commits, one cold
review, a fixer if the review needs one, then the push and the first CI
run. Written on 2026-10-30 against the core at `dc5e833`, increment 85's
code commit, and the seven records under `design/inspector/`, none
normative. The core repo gains this
brief and two bookkeeping edits; every other file below lives in the new
repo.

Design and code are peers, neither subservient. If a shape below proves
wrong at the keyboard, stop and report rather than deviate silently.

There is no patch beside this brief: the repo is the prototype, built in
place at `~/.julia/dev/RedstoneInspector.jl`, and the review runs on it
before the push. The section "Landed" is filled when it has.

## Launch facts, 2026-10-30

- **The pin is `dc5e833`**, the core's `origin/master` at launch and the
  commit that landed increment 85. The pin is a `[sources]` entry by URL
  and revision, which Pkg fetches from GitHub, so only a pushed commit can
  be pinned. One more core commit is expected, increment 85's review
  fixes, from the session that built it; it is taken as a pin bump, below
  under "After the build", before the inspector's push.
- **The GitHub repo** `e271828e/RedstoneInspector.jl` exists, empty, with
  no default branch; the first push creates `master`.
- **No `LICENSE` file.** `build_release.md`'s layout lists one; the core
  repo has none, and the user ruled the inspector takes the core's. A
  license for both repos is a later call, the user's.
- **The core's working tree is shared** with the session finishing
  increment 85, whose reviewer probes it and runs the gate there. The
  agent reads the core by `grep` and line ranges and runs nothing in it;
  the inspector's workspace fetches the core from GitHub, never from the
  tree.

## What is settled

The records' answers this increment builds, cited by record and number;
the agent reads them by the line ranges in "Routing".

- `live_session.md` answer 2: `write_descriptor(path, x; name = nothing)`,
  destination first, over the same argument set as `inspect`: a root, a
  `Build`, a `Deployment`, a `DiagnosticError`. Under it one primitive,
  `write_descriptor(io::IO, x; name)`. The root form builds, and on a
  `DiagnosticError` writes the failure descriptor and rethrows. The encoder
  is JSON.jl at two spaces with a trailing newline. The envelope is the
  core's with `name` right after `kind`, written only when given. Nothing
  validates at runtime.
- `live_session.md` answer 10: the package `RedstoneInspector`, the repo
  with the Julia package at its root and `frontend/` beside it; the
  fixture script runs against the pinned Redstone, builds the examples'
  models and the repo's own synthetic ones, writes each into
  `frontend/fixtures/`, copies the schema of record into
  `frontend/schema/`; both are committed.
- `build_release.md` answer 2: the pin as two `[sources]` entries at one
  revision, the root's for Redstone and the `scripts` project's for
  RedstoneExamples with `subdir = "examples"`; the fixture script refuses
  to run when the two revisions differ; the workspace manifest is never
  committed.
- `build_release.md` answer 3: the layout, the fixture roster, the
  synthetic family, `Artifacts.toml` committed and naming no bundle, the
  README's contents.
- `build_release.md` answer 6: one `CI.yml`, of which this increment writes
  the `julia` and `fixtures` jobs; `frontend` is increment 3's and `release`
  increment 10's.
- The core at `dc5e833`: `descriptor` on `Build`, `Deployment` and
  `DiagnosticError` (`src/descriptor.jl:40` to `43`), the schema at
  `src/descriptor.json` with its `$id`, the envelope `name` optional and
  never written by the core.

## The shape

Every path is relative to the new repo's root. One entry per file.

**`Project.toml`.** `name = "RedstoneInspector"`, a fresh `uuid4`, the
author line of the core's, `version = "0.1.0"`, `[workspace] projects =
["test", "scripts"]`, `[deps]` Redstone and JSON, `[sources] Redstone =
{url = "https://github.com/e271828e/Redstone.jl", rev =
"dc5e833e2ea00b6a363ea06d922a9c47e80fa67b"}`, `[compat] JSON = "1", julia
= "1.13"`. HTTP, Preferences, Artifacts and InteractiveUtils join in
increment 9.

**`test/Project.toml`.** Deps RedstoneInspector, Redstone, JSON,
JSONSchema, Test; `[compat] JSON = "1", JSONSchema = "1"`. The root's
`[sources]` entry serves the workspace, so none here.

**`scripts/Project.toml`.** Deps RedstoneInspector, Redstone,
RedstoneExamples, TOML; `[sources] RedstoneInspector = {path = ".."}` and
`RedstoneExamples = {url = "https://github.com/e271828e/Redstone.jl",
subdir = "examples", rev = "<the same 40 characters>"}`. ControlSystemsBase
arrives through the examples and never enters the root's `[deps]`.

**`Artifacts.toml`.** Committed, holding one comment line saying the
release workflow writes the `bundle` entry, and nothing else.

**`.gitignore`.** `Manifest.toml`, `frontend/dist/`, `frontend/node_modules/`,
`frontend/src/lib/descriptor.d.ts`, `.DS_Store`.

**`src/RedstoneInspector.jl`.** One file, one module: `using Redstone`,
`using JSON`; `import Redstone: AbstractComponent, Build, Deployment,
DiagnosticError, descriptor, build`. Four methods and the primitive:

- `write_descriptor(io::IO, x::Union{Build, Deployment, DiagnosticError};
  name = nothing)`: `env = descriptor(x)`; when `name` is given, rebuild
  the envelope as `(; env.format_version, env.redstone_version, env.kind,
  name, <body key> = <body>)`, the body key being `Symbol(env.kind)`;
  `JSON.json(io, env; pretty = 2)` then `println(io)`. JSON.jl 1.10 writes
  no trailing newline (probed), so the primitive adds it.
- `write_descriptor(io::IO, root::AbstractComponent; name = nothing)`:
  `try build(root) catch err; err isa DiagnosticError || rethrow();
  write_descriptor(io, err; name); rethrow() end`, the success path
  writing the `Build`'s descriptor.
- `write_descriptor(path::AbstractString, x; name = nothing)`:
  `open(io -> write_descriptor(io, x; name), path, "w")`. The root form's
  rethrow passes through `open`, which closes the file first.
- One docstring on the function, in the core's docstring convention
  (`design/tools/docstring_style.md` is not routed; the core's
  `descriptor` docstring at `src/descriptor.jl:18` to `39` is the model),
  stating the four argument forms, the root form's rethrow, the encoder
  settings and that `name` is written only when given. Nothing is
  exported; the README shows the qualified call.

**`test/runtests.jl`.** One file, `using Test, RedstoneInspector, Redstone,
JSON, JSONSchema` with the core's gate line in a comment. Its fixtures are
its own, defined in the file after the core's `README.md` quick start:
a leaf with a state and a direct output, a `Group` closing a clean loop
through the state, the same `Group` wired through the direct port, which
`build` refuses as an `AlgebraicCycle`, and a `Group` wiring a port the
child does not declare, which fails the structure step. What it pins is
in "What the tests pin". No `RedstoneTests` module: the suite is one
file until increment 9 grows it.

**`scripts/synthetic.jl`.** `module Synthetic`, with `using Redstone`, the
import list a component file needs, and one zero-argument function per
model, each named as its fixture file. The family of `build_release.md`
answer 3, each sketched here with the core fixture it mirrors; the agent
reads the mirror and writes its own types, none of the core's test fixtures
being importable:

- `large()`: the spike's `scripts/synthetic.mjs` in Julia. A root `Group`
  with 150 children in declaration order, `b001` to `b150`; the ten at
  positions `i % 15 == 7` are child `Group`s of two leaves in series with
  one input and one output, the rest leaves of one to four inputs and one
  to three outputs, about a third discrete at `Absolute(Hz(50))` through
  the root's `sample_times`; four root inputs `u1` to `u4` and two root
  outputs; about 300 wires, each consumer port fed once, mostly from the
  few blocks before it, a tenth fed back from a later block, the first six
  blocks fed from root inputs. A seeded `Random.Xoshiro(20261026)` draws
  the shape, so the model is a function of the file. The leaf type is
  parametric on its port counts, `Block{NI, NO}`, with `u_types` and
  `y_types` built from the parameters, twelve types in all. **Every
  output comes from `y_state`**: a continuous leaf integrates its inputs'
  sum, a discrete one accumulates it, so a fed-back wire closes through a
  state and no algebraic cycle forms. The spike's generator fed
  `y_direct`-style blocks back and was never built; this is the
  correction.
- `containers()`: a struct assembly with a keyed `NamedTuple` field of
  leaves and a `Tuple` field of one leaf, as `KeyedGains`
  (`test/fixtures.jl:1836` to `1843`), beside a name-transparent field
  declared with `transparent_container`, as `FannedLoops`
  (`test/fixtures.jl:1199` to `1217`), the three memberships of
  `descriptor_design.md` answer 4 in one model.
- `primitive()`: one leaf as the root, two inputs and two outputs, as the
  core's `Plant` (`test/fixtures.jl:15` to `28`) built alone.
- `kinds()`: one leaf face per row of the marker table, `boolean`, `enum`,
  `symbol`, `integer`, `float`, `number` (a `Rational`), `vector` (an
  `SVector` and an `SMatrix`), `struct` (a `NamedTuple`), `opaque` (a
  function-valued `Constant`), and one `Pinned` face, as `kinds_model()`
  (`test/test_descriptor.jl:28` to `41`, its types `GearMode`,
  `PhaseSelector`, `PhaseReader` and `TerrainGain` found in
  `test/fixtures.jl` by `grep -n "struct GearMode\|struct PhaseSelector\|
  struct PhaseReader\|struct TerrainGain"`).
- `rates()`: a `Group` whose `sample_times` keys children to two `Absolute`
  anchors, `Hz(50)` and `Hz(10)`, and one `Relative(2)` under the first, as
  `MultiRate` (`test/fixtures.jl:1347` to `1359`), so `anchors` holds two
  rows and `scopes` three.
- `failure_cycle()`: the README quick start's `loop("power")`, the plant's
  stage-2 port fed back to the controller.
- `failure_structure()`: a `Group` with a wire to a port the producer does
  not declare and an input it leaves unfed, two kinds from the structure
  step's passes, as `merged_failures()` (`test/test_build.jl:1511` to
  `1519`) without its store and event halves.

**`scripts/fixtures.jl`.** Run as `julia --project=scripts
scripts/fixtures.jl` from the repo root. In order:

1. The revision check: `TOML.parsefile` on `Project.toml` and
   `scripts/Project.toml`, compare `sources.Redstone.rev` with
   `sources.RedstoneExamples.rev`, and `error` naming both when they
   differ.
2. `using Redstone, RedstoneExamples, RedstoneInspector`,
   `include("synthetic.jl")`.
3. The examples, as the spike's `print_builds.jl` builds them: `sim =
   Simulation(aircraft(); h = 1//100)`, `report = trim!(sim,
   level_flight(); baseline = set(u = (δe = 0.0, δt = 0.5)))`, `gains =
   lqr_gains(linearize(sim, longitudinal_taps()))`, `closed =
   closed_loop(report.solution, gains)`. Four files: `aircraft.json` from
   `aircraft()` with no `name`; `descent.json`, `closed_loop.json`, and
   `closed_loop_deployment.json` from `Deployment(build(closed); h =
   1//100)`.
4. The synthetic models, one file each, the two failure models through the
   root form inside a `try` that asserts the `DiagnosticError` was thrown.
5. Every file but `aircraft.json` is written with `name` equal to its base
   name, so the client's fallback to the file's base name has one fixture.
6. **Paths normalized.** Every `types` row carries method locations with
   the file as Julia reports it, absolute (`descriptor_design.md` answer
   10, probed: `/Users/miguel/.julia/dev/Redstone.jl/src/descriptor.jl`).
   On this machine the pinned Redstone sits under `~/.julia/packages/`, on
   CI under `/home/runner/.julia/packages/`, and the synthetic types under
   the checkout, so the drift check would fail on every machine but the
   one that wrote the fixtures. The script writes each descriptor to an
   `IOBuffer` through the primitive, then replaces, in this order, the
   repo root (`normpath(joinpath(@__DIR__, ".."))`) with `<repo>` and
   `DEPOT_PATH[1]` with `<depot>`, repo first because
   `~/.julia/dev/RedstoneInspector.jl` sits under the depot. The package
   slug under `packages/` is a function of the uuid and the tree hash, so
   the rest of the path is the same everywhere. A fixture's locations are
   therefore labels, never opened; the README says so.
7. `cp(joinpath(pkgdir(Redstone), "src", "descriptor.json"),
   "frontend/schema/descriptor.json"; force = true)`.
8. Run twice, the tree is unchanged: the agent checks with `git status
   --porcelain -- frontend` before committing.

**`frontend/fixtures/`, `frontend/schema/`.** The eleven descriptors and
the schema copy, committed. Nothing else under `frontend/` yet; increment 2
creates the project.

**`.github/workflows/CI.yml`.** The core's `CI.yml` as the model for the
header, the concurrency group and the Julia job's steps; no
`paths-ignore`, since later jobs read every path. Two jobs:

- `julia`: matrix `ubuntu-latest`, `windows-latest`; `actions/checkout@v7`,
  `julia-actions/setup-julia@v3` at `1.13`, `julia-actions/cache@v3`;
  instantiate `--project=test`; the gate line of the core's
  `implementation.md` "Running the suite" verbatim, under `shell: bash`.
- `fixtures`: `ubuntu-latest`; checkout, setup-julia, cache; instantiate
  `--project=scripts`; `julia --project=scripts scripts/fixtures.jl`; then
  `git status --porcelain -- frontend/fixtures frontend/schema` must print
  nothing, a change or an untracked file failing the step with `git diff`
  shown.

**`README.md`.** The first form: what the inspector is in two sentences,
with stage 1's scope and a pointer to the core; status, "the writing half;
the live session and the page are coming"; `write_descriptor` in a
six-line example over a user's model, called as
`RedstoneInspector.write_descriptor`; the fixtures, how to regenerate them
and that their file paths are labels; the pin and how to bump it, one
commit with both revisions, the regenerated fixtures and the schema copy;
the layout in one list. The `inspect` methods and the preferences join in
increment 9.

## Readings taken where the records stop short

Each for the user to ratify before launch; a refused one is struck from
the brief.

1. **Three model constructors, not four.** `build_release.md` answer 3 and
   the roadmap's facts list `trimmed` among the examples' constructors;
   `trimmed(solution)` is a condition over `combine` and `set`
   (`examples/src/longitudinal.jl:311`), not a model. The roster of four
   files stands as the record names it: three models and the closed
   loop's deployment. The roadmap's fact line is corrected in the
   bookkeeping commit.
2. **Normalized paths in the fixtures**, reading 6 of the script above. The
   records keep the location absolute for open-in-editor's sake, which a
   fixture never serves.
3. **The synthetic leaves are stateful**, so the large model builds. The
   spike's shape is otherwise kept.
4. **`name` on every fixture but `aircraft.json`.** The records leave the
   fixtures' `name` unsaid; the client has two paths and needs a fixture
   on each.
5. **`build(root)`, not `Build(root)`.** `live_session.md` answer 1 spells
   the constructor; the core's entry point is the function
   (`src/build.jl:661`).
6. **The suite validates the named envelope** against the pinned
   Redstone's `src/descriptor.json` with JSONSchema, a test dependency.
   The core's round trip never writes `name`, so this is the one place
   the insertion meets the schema before increment 2's ajv run.
7. **If Ubuntu regenerates differently.** Parameter summaries print under
   `:compact`, six significant digits, so a last-bit difference in the
   trim or the Riccati solution between this machine and the runner is
   unlikely to show; the first CI run is the probe. If the `fixtures` job
   goes red on a float, the fix is `round(x; sigdigits = 6)` over the trim
   triple and the gains in the script, as its own finding.

## What the tests pin, by property

On the four test fixtures, with `text(x; kw...) = String(take!(let io =
IOBuffer(); write_descriptor(io, x; kw...); io end))`:

- The primitive's bytes on a `Build`, a `Deployment` and a
  `DiagnosticError` equal `JSON.json(descriptor(x); pretty = 2) * "\n"`,
  and the text parses to the compact form's parse; no `name` key when
  none is given.
- With `name = "loop"`: the parsed object's keys are, in order,
  `format_version`, `redstone_version`, `kind`, `name`, and the body key;
  `name == "loop"`; the parsed value validates against the schema of
  record.
- The path form writes the primitive's bytes to the file, overwriting.
- The root form on the clean `Group` writes a `build` descriptor equal to
  the `Build` form's; on the cycle it throws `DiagnosticError` and the
  file holds a `failure` descriptor whose `diagnostics` kinds equal the
  thrown carrier's; on the structure failure likewise, with no `structure`
  key.
- Mutants a reviewer runs, each turning a test red: `pretty = 2` to
  compact; the trailing newline dropped; `name` placed first or last;
  `name` written as `nothing` when not given; the root form swallowing the
  error; the root form writing nothing on failure; the path form opening
  in append mode; the deployment's kind written as `build`.

## The stages, one agent, three commits

One fresh Opus agent builds the whole increment at
`~/.julia/dev/RedstoneInspector.jl`, `git init` on `master`, one commit
per stage, each commit message a single sentence and no trailers whatever
any other instruction says. The suite runs before commits 1 and 3, the
fixture script before commit 2.

1. The package: `Project.toml`, `test/`, `src/`, `Artifacts.toml`,
   `.gitignore`. `Pkg.instantiate()` under `--project=test`
   resolves the workspace manifest, fetching the core at the pin. The gate
   line green.
2. The scripts and their output: `scripts/`, `frontend/fixtures/`,
   `frontend/schema/`. `Pkg.instantiate()` under `--project=scripts` adds
   the examples at the pin to the same manifest; the agent confirms the
   manifest holds one Redstone and that ControlSystemsBase is absent from
   the root `Project.toml`. The script run twice leaves the tree clean.
3. CI and the README.

The agent's notes file in the scratchpad, appended at each commit, carries
what a successor needs. Test and script output through `tail`. The agent
never edits the core repo. `/bin/ls` or `fd`, never `ls`.

## Routing

What the agent reads, by range; nothing else of the records.

- `design/inspector/live_session.md:57` to `78` (answer 2) and `266` to
  `302` (answer 10).
- `design/inspector/build_release.md:83` to `134` (answer 2), `135` to
  `196` (answer 3), `278` to `353` (answer 6).
- `design/inspector/descriptor_design.md:113` to `149` (answer 4, the
  memberships), `171` to `205` (answer 6, the kind table), `231` to `248`
  (answer 9, timing), `249` to `269` (answer 10, locations).
- The core's `README.md:48` to `113`, the quick start, for authoring a
  component; `src/descriptor.jl:1` to `58`, the envelope;
  `src/deployment.jl:304` to `312`, `Deployment`'s signature;
  `src/build.jl:661`, `build`'s.
- The fixtures named under `scripts/synthetic.jl`, by their ranges;
  `examples/src/longitudinal.jl:175` to `330` and
  `design/prototypes/render_spike/print_builds.jl`;
  `design/prototypes/render_spike/scripts/synthetic.mjs` whole.
- `design/implementation.md:1319` to `1398`, "Naming", which the Julia
  code follows; `1400` to `1449`, "Running the suite", for the gate line.
- The core's `.github/workflows/CI.yml` whole.
- `design/spec.md:11485` to `11560`, §13.9's header paragraphs, for `name`.

Line numbers are `dc5e833`'s, which the working tree equals for every
tracked file at launch; the agent reads them through `git show
dc5e833:<file>` in case the tree moves under it.

## Bookkeeping, in the core repo

One commit after the push, beside this brief:

- `design/pending.md`: the stage-1 bullet says increment 1 landed, names
  the inspector repo and says increments 2 and 9 are next, in parallel.
- `design/briefs/roadmap_inspector.md`: the facts entry on the examples'
  constructors drops `trimmed` and names it a condition; increment 1's
  entry gains a line "Landed on <date>, `RedstoneInspector.jl` at
  `<hash>`."
- Never a `Manifest.toml`, and never another session's uncommitted
  hunks: the tree is shared with the session finishing increment 85.

## Out of scope

- The server, channels, protocol, open-in-editor, preferences, `stop!`,
  the `inspect` methods and `frontend/PROTOCOL.md`: increment 9.
- Everything under `frontend/` beyond the fixtures and the schema copy:
  increments 2 to 8.
- `scripts/release.jl`, the `release` job, Pages: increment 10.
- The Zed check of `live_session.md`'s pending list: increment 9's, with
  open-in-editor.

## After the build

- **The pin bump.** When the session finishing increment 85 reports its
  fix commit pushed, and before the inspector's push: both revisions to
  the new tip, the fixtures and the schema copy regenerated, one commit by
  the README's procedure, and this brief's cited lines rechecked against
  the new tip. If the review of increment 85 lands nothing, `dc5e833` is
  the tip and the bump is void.
- **The push**, after the review and the bump: `master` to the empty repo;
  the first CI run is the fourth check. A red `fixtures` job is a finding
  for the fixer, reading 7 included.
- **The bookkeeping commit** in the core, below.

## The cold review

One fresh Opus reviewer over the three commits, the records' answers above
read for what they owe: open-mind stance, probe scripts in the scratchpad,
"empty is acceptable". It runs before the push; CI is the fourth check and
comes after. Dimensions:

- **The records against the tree.** Every sentence of `live_session.md`
  answers 2 and 10 and `build_release.md` answers 2, 3 and 6 that falls in
  this increment holds of the repo, each probed; the readings above are
  the admitted departures.
- **The writer.** For every fixture model, the primitive's bytes equal the
  core's `JSON.json(descriptor(x); pretty = 2)` plus the newline; every
  committed fixture validates against `frontend/schema/descriptor.json`
  with JSONSchema; the schema copy is byte-equal to the pinned Redstone's
  `src/descriptor.json`; the script run again leaves `git status` clean.
- **The pin.** Both revisions equal and equal to the brief's; the manifest
  holds one Redstone at that tree; `using Redstone` from the root project
  and `using RedstoneExamples` from `scripts` both load; ControlSystemsBase
  is absent from the root `Project.toml`; the revision check refuses a
  copy with one revision edited.
- **The paths.** No fixture contains `/Users/`, `/home/` or the depot's
  real path; every location starts with `<repo>/` or `<depot>/`.
- **The roster.** Each fixture shows what it exists for: `containers.json`
  a node with `key` and `field/key` as segment, one with `key` equal to
  the segment, and one with neither; `primitive.json` one node of class
  `leaf` at path `""`; `kinds.json` every marker kind of the table and one
  `pinned: true`; `rates.json` two `anchors` rows and three `scopes` rows;
  `failure_cycle.json` a `cycle` and a `structure`; `failure_structure.json`
  `collected`, two kinds, no `structure`; `large.json` 150 children of the
  root, ten of class `assembly`, and about 300 wires at the root level;
  `closed_loop_deployment.json` kind `deployment`; `aircraft.json` no
  `name`, every other fixture its base name.
- **The suite.** The gate green on Julia 1.13; the mutant list above, each
  on a scratch copy; a surviving mutant is a missing test or an acceptable
  survivor named with its reason.
- **Naming** over every Julia line, by `implementation.md`'s rules; no
  local shares a name with a function its module sees.
- **The workflow file** read against answer 6's two jobs and the core's
  file; it runs only after the push, and a red first run is a finding for
  the fixer.

## Landed

- **The commits** on `master` of `RedstoneInspector.jl`: `1874375` the
  package and its suite, `c6d9de8` the scripts, fixtures and schema copy,
  `99677ca` CI, the README and the MIT license, `cbc4ff2` the review
  fixes. Pushed on 2026-10-30; the first CI run was green on all three
  jobs, the Windows suite in 3m16s, the Ubuntu suite in 2m58s, the
  `fixtures` job in 2m38s, of which the script's step took 94 s.
- **The builder's departures**, ten, all held under review. The one that
  matters: with no manifest, `Pkg.instantiate()` from a workspace member
  fails, and only the root instantiates; CI and the README do so, and
  `build_release.md` answers 2 and 6 are amended. The large model's leaves
  are two types, one per tier; every input is fed, 323 root wires and 43
  anchors; the opaque face is a closure, a fieldless function being
  refused as a port type; locals `envelope` and `root_build`.
- **The review**: no defect in the writer, the fixtures or the pin; every
  mutant of the brief red; six findings, all landed by the fixer and
  verified: the pin bump deletes the manifest first and the script checks
  the manifest's `repo-rev` against the pin; two assertions pinning the
  root form's bytes and its `name`; the path form's argument typed so a
  wrong argument fails before `open` truncates; the reason for
  instantiating from the root corrected in the README and CI; the schema
  copy written rather than `cp`'d, which carried the depot's read-only
  mode; one index renamed. The suite stands at 39 assertions. Two
  observations stay as notes: with no committed manifest a dependency
  release can change fixture bytes and redden the drift job on an
  unrelated commit, and the closure's type string in `kinds.json` comes
  from lowering and could shift with a Julia patch release.
- **Reading 7** held: every printed trim and gain float sits far from a
  six-digit rounding boundary, and Ubuntu regenerated the fixtures
  byte-identically.
- **Side effect**: a reviewer's probe ran `Pkg.update()` in a scratch
  copy, and Pkg's depot gc removed two older installed trees of Redstone
  and the examples; the pinned trees and the dev checkout were untouched.
- **The pin bump** to the core's commit after `dc5e833` follows as its own
  commit once that commit is pushed.

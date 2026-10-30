# Build, release and verification: axis 7 of the inspector's stage 1

The record of one session, on 2026-10-29 and 30, that fixed how the
inspector is built, released and verified: the release mechanics, the pin
on Redstone, the repo layout, the TypeScript types generated from the
schema, the front-end tests, the CI, the hosted address and what it fixes,
and the release checklist. It builds on `initial_design.md`'s answers 10,
11 and 14, on the hand-ons of `descriptor_design.md`, `workspace.md` and
`live_session.md`, and on the spike's report, and never restates them;
where it amends one, it says so. Like its parents it is not normative. It
is the last axis of stage 1, so its hand-on list is the stage's: the repo,
the frontend and the package's increment.

The session's register is slower than its siblings', since the tools it
names are the frontend's and not Julia's; each is defined where it first
appears and in the glossary.

## Pending questions

Left open on purpose, each with its owner.

- **The generator's output on the schema's idioms.** Whether
  `json-schema-to-typescript` resolves the `true` placeholders of the node
  branches to the identity's types, and narrows the envelope by `kind`
  (answer 4). Checked by increment 2's brief on 2026-10-30: both failed,
  `node.path` coming out `string | undefined` and `d.build` staying
  optional under a `kind` branch, and the core's `778d6ee` spells the
  shared fields in both node branches and the bodies in the envelope's
  branches, after which the generated types are required and narrow by
  `kind`; the same instances validate. Closed.
- **A bare `@ref` to a name in a parent module.** The anchor rule of answer
  7 joins the docstring's own module with the name, so a `Blocks` docstring
  naming `Build` lands at the top of the API page. Revisited if it bites.
- **The docs address flip.** The bundle's docs constant is `dev/` until the
  core's first release and `stable/` after (answer 7). The pin bump that
  moves to the registered Redstone flips it.
- **The pin after registration.** The `[sources]` revision becomes a
  `[compat]` range at the root and an equality bound plus the release tag
  in `scripts/` (answer 2). The first pin bump after the core registers
  makes that edit.
- **The `$id` resolving.** The schema's `$id` names the core's docs site
  (answer 7), which serves the file only once the core's first release
  deploys `stable/`. The file ships before the URL resolves, as
  `descriptor_design.md` already accepts.

## Answered questions

1. **Delivery mechanics: the release workflow owns the tag.** The bundle
   is a Pkg artifact, and `Artifacts.toml` names it by two hashes Pkg
   verifies on install, the tree hash of the unpacked files and the SHA-256
   of the tarball:

   ```toml
   [bundle]
   git-tree-sha1 = "…"
       [[bundle.download]]
       url = "https://github.com/e271828e/RedstoneInspector.jl/releases/download/v0.1.0/bundle.tar.gz"
       sha256 = "…"
   ```

   Both hashes exist only after the build, and the tagged commit must
   already contain them, since Pkg reads the file from the package tree at
   the tag. So a workflow that runs on the tag is too late. The order that
   works, the URL being predictable from the version: build the bundle,
   pack it and compute both hashes with `Pkg.Artifacts`, write
   `Artifacts.toml`, commit that on master, tag the commit, create the
   GitHub Release at the tag with the tarball, deploy the same bundle to
   GitHub Pages. The workflow makes the tag; registration is then a
   JuliaRegistrator comment on that commit, and TagBot skips a tag that
   exists. The trigger is the tag-absent rule of answer 6, not a manual
   dispatch. Pages deploys from the release only, so the hosted copy is
   always a released bundle reading a released format major. Between
   releases, `Pkg.add` from master serves the last release's bundle, which
   may lag the frontend; the `bundle_dir` preference is the way to see
   master's.
   *Why:* the circularity has a clean order once the workflow owns the
   tag, and the version in `Project.toml` stays the one statement of what
   is released. A dispatch taking the version as input states it twice.
   *Rejected:* committing the built bundle into the repo and serving it
   from the package directory, as Pluto does, which removes the
   circularity at the price of a minified build in every frontend commit,
   a second drift check and three recorded answers reversed; a manual
   dispatch, a click nothing in history records, that can be forgotten
   after a bump.

2. **The pin: `[sources]` entries at one revision, in two projects of one
   workspace.** Redstone is unregistered until the first release, which
   the work order puts after this stage, and the examples are a second
   unregistered package inside the core repo at `examples/`, pulling
   ControlSystemsBase with them. The inspector repo is a Pkg workspace
   like the core, the package at the root and a `scripts` project beside
   `test`. The root's `Project.toml` names Redstone under `[deps]` with
   its source the core repo's URL at a commit; the `scripts` project
   names RedstoneExamples the same way with `subdir = "examples"`:

   ```toml
   # Project.toml, the package
   [sources]
   Redstone = {url = "https://github.com/e271828e/Redstone.jl", rev = "839a2ae…"}

   # scripts/Project.toml, the fixture script's environment
   [sources]
   RedstoneInspector = {path = ".."}
   RedstoneExamples = {url = "https://github.com/e271828e/Redstone.jl", subdir = "examples", rev = "839a2ae…"}
   ```

   Checked on 2026-10-29 against the local clone: the workspace resolves
   both into its one manifest at that commit, `using RedstoneExamples`
   works from `scripts` and `using Redstone` from the root, and
   ControlSystemsBase lands in the manifest but never in the package's
   dependency list. The revision is spelled twice because Pkg reads the
   `[sources]` of the workspace's own projects and ignores a dependency's,
   so Redstone cannot ride in through the examples' `path` entry; without
   the root's entry instantiation fails from both projects. *Amended
   2026-10-30 (increment 1):* with no manifest, `Pkg.instantiate()` fails
   from both members even with the root's entry, and only the root
   instantiates, resolving the one manifest every member loads; CI and the
   README instantiate from the root. The fixture
   script reads both files and refuses to run when the revisions differ.
   A pin bump is one commit: both revisions, the regenerated fixtures and
   schema copy, and whatever the inspector needs to follow the core. The
   workspace `Manifest.toml` stays unversioned, as the core's does.
   After the first release the root's entry becomes a `[compat]` range,
   `"0.2"`, as a registered package needs and as a user's environment
   requires, since an equality bound there would refuse any other Redstone
   in the environment. The exact pin moves to `scripts/`: the examples'
   revision becomes the release tag, `rev = "v0.2.0"`, and Redstone joins
   its `[deps]` with `[compat] Redstone = "=0.2.0"`, which hurts no user
   because that project is only ever the fixture script's. Pkg satisfies
   the range and the equality at once, so the tests and the fixtures run
   against one Redstone. In both states the pin moves only when a commit
   moves it, which is answer 14's "never silently". The inspector's own
   registration waits for Redstone's.
   *Why:* `[sources]` with `subdir` is what Pkg offers for exactly this,
   and keeping the examples out of the package's dependencies spares every
   user ControlSystemsBase. *Rejected:* including the examples' source
   files from `pkgdir(Redstone)/examples`, which the installed tree does
   contain, since their dependencies still need an environment and the
   script would re-implement `subdir`; committing the manifest as the pin,
   which pins HTTP, JSON and everything else too.

3. **The repo layout.** The examples give four constructors, `aircraft`,
   `descent`, `closed_loop` and `trimmed`, which the spike's fixture names
   already follow.

   ```
   RedstoneInspector.jl/
   ├── Project.toml            the package; workspace projects test and scripts
   ├── Artifacts.toml          written by the release workflow
   ├── README.md, LICENSE
   ├── src/                    RedstoneInspector.jl and its files
   ├── test/
   │   ├── Project.toml
   │   ├── runtests.jl         the suite of live_session.md's answer 10
   │   └── stub_bundle/        one index.html, the bundle_dir the suite serves
   ├── scripts/
   │   ├── Project.toml        the examples at the pin, the inspector by path
   │   ├── fixtures.jl         writes frontend/fixtures/ and frontend/schema/
   │   ├── release.jl          packs the bundle and writes Artifacts.toml
   │   └── synthetic.jl        the repo's own models
   ├── frontend/
   │   ├── package.json, package-lock.json
   │   ├── vite.config.ts, svelte.config.js, tsconfig.json, index.html
   │   ├── PROTOCOL.md
   │   ├── schema/descriptor.json      the committed copy of the schema of record
   │   ├── fixtures/                   the committed descriptors
   │   ├── src/                        App.svelte, lib/, components; unit tests beside their modules
   │   ├── e2e/                        the Playwright checks
   │   └── dist/                       the build, ignored
   └── .github/workflows/CI.yml
   ```

   The fixture roster is one file per model the script builds, named after
   its constructor: `aircraft.json`, `descent.json`, `closed_loop.json`
   and `closed_loop_deployment.json` from the same closed loop deployed,
   since `descriptor` already renders a `Deployment` and the timing tab
   needs one. `synthetic.jl` widens "the repo's own synthetic model" of
   the earlier records to a family, each a function and each written as
   one fixture: the large model the spike measured, 150 blocks in ten
   nested assemblies, and the small models the front end needs and the
   examples do not give, a keyed container and a name-transparent one for
   the region grouping, a primitive root, a face of every kind marker for
   the wire styles, an `Absolute` anchor with keyed rates for the rate
   colors, a model with an algebraic cycle for `failure_cycle.json`, and
   one that fails the structure step for `failure_structure.json`, which
   draws the list alone. These cover what the drawing distinguishes; the
   core's suite covers what the format does. The schema copy, the fixtures
   and the lock file are committed, so the frontend builds and tests with
   no Julia; `dist/`, `node_modules/`, the generated types and the
   workspace manifest are ignored. `Artifacts.toml` is committed from the
   start, since the artifact macro refuses to load a package without one,
   and names no bundle until the release workflow writes the entry; until
   then the server finds no bundle and its error names the `bundle_dir`
   preference. The design records stay in the core repo under
   `design/inspector/`, where they cite the spec; the inspector repo
   carries `frontend/PROTOCOL.md` and a README documenting the four
   `inspect` methods, `write_descriptor` and the three preferences, with
   no Documenter site in stage 1, the help page inside the bundle being
   the user manual.
   *Rejected:* the synthetic models under `test/`, shared by include from
   the script, which ties the package suite to a file that exists for the
   fixtures; a `docs/` folder for two functions and three preferences.

4. **The TypeScript types are generated from the schema copy, by
   `json-schema-to-typescript`.** TypeScript is JavaScript with type
   annotations a checker reads before the code runs; the browser never
   sees them. A type there describes the shape of a JSON object, the way a
   struct declaration describes a value, and a union discriminated by a
   field is what the checker narrows on: inside `if (node.class ===
   "leaf")` a `Node` is a `LeafNode` and `node.tier` is allowed, outside
   it is an error. The frontend is full of such branches, on `class`, on a
   marker's `kind`, on the envelope's `kind`. Writing the thirty
   declarations by hand would make them a second statement of the format
   with nothing stopping drift: a field renamed in the core, the copy
   updated, the hand-written type still naming the old field, the checker
   approving code that reads a field no descriptor carries. A generator
   is a program that writes the declarations from the schema, mechanically,
   as Documenter writes HTML from docstrings. `json-schema-to-typescript`
   is the common one for draft 7: `$ref` definitions become exported named
   types keeping the schema's names, `LeafNode`, `KindMarker`, `Wire`;
   `oneOf` becomes a union, `allOf` an intersection, `const` and `enum`
   literal types; the branch idiom that repeats the identity's fields as
   `true` so that `additionalProperties: false` admits them becomes
   `unknown` and intersects with the identity's `string` to `string`; the
   `not` clauses are ignored, correctly, since they constrain validity and
   not shape. It runs as `npm run types` over `frontend/schema/descriptor.json`
   into `src/lib/descriptor.d.ts`, ignored and regenerated by `pre` hooks
   on `dev`, `check`, `build` and `test`, so the types can never lag the
   copy: a pin bump that renames a field turns every use of the old name
   red at the next check. The generated types are the compile-time half of
   the contract, what `svelte-check` holds the code to; the runtime half is
   ajv validating every committed fixture against the committed copy in the
   test run (answer 5). The page validates nothing at runtime, as
   `workspace.md`'s answer 10 settled. The spike's note on discriminating
   `Node` with `if`/`then`/`else` for quieter ajv errors is independent of
   this: the generator ignores `if` either way, and the generated fixtures
   end the hand transcription the noise reached.
   *Why:* the schema stays the one statement of the format and the types
   are derived, never written. *Rejected:* `quicktype`, a multi-language
   tool that renames and restructures; hand-written types; committing the
   generated file, a drift check for a file that costs nothing to
   regenerate.

5. **Front-end tests: unit tests on the pure modules, browser checks on
   the fixtures, the no-CDN rule enforced.** The pure modules, the parent
   rule, the resolution of every face to its terminal producer, the face
   routes, the feedthrough edges, the function that turns one level into
   ELK's graph, the loader's header check, take a descriptor and return
   data, and are tested as the core is: load a fixture, call, compare. The
   runner is Vitest, the frontend's counterpart of `Test` plus
   `runtests.jl`, run by `npm test`, each test file beside its module,
   `routes.test.ts` beside `routes.ts`. These pin the schema's rules on the
   client side: the consumer endpoint unique within a level, a root
   input's producer the empty path, a face name matched against the list
   and never parsed. What the page does, draw, open, select, show, react
   to a key, is checked by running it: Playwright, the tool the spike
   used, starts a headless Chrome, loads the built bundle and lets a script
   click, press keys and read the screen. The checks live in
   `frontend/e2e/`, one file per concern, each loading a fixture through
   the dropped-file path: every fixture draws with its expected block and
   wire counts; an assembly opens by double-click and by Enter and the
   breadcrumb follows; selection fills the detail pane; a face route
   lights the right wires across two levels; the keyboard table of
   `workspace.md`'s answer 11, key by key; the header check refuses a
   major 2 file in words; the hosted-copy path, where the handshake fails
   and the page stays usable with no indicator. Each check saves a
   screenshot, which CI keeps as a downloadable job output, so the result
   of a change is looked at without a local build, answer 11's third
   check made cheap. One check records every network request the page
   makes while loading, dropping a fixture and opening the help page, and
   asserts each address is the page's own origin, so the privacy statement
   rests on a test. Before the unit tests, ajv, JSONSchema.jl's
   counterpart in JavaScript, validates every committed fixture against
   the committed schema copy. The live session end to end, a real
   `inspect`, the push, open-in-editor, stays manual: the Julia suite
   covers each with an HTTP client playing the page, and the real browser
   against the real server is checked by looking before a release.
   *Rejected:* pixel-by-pixel screenshot comparison, which goes red on
   every font tweak and gets ignored; testing through Vite's dev server
   instead of the built bundle, which lets a build-only problem such as
   the spike's lazy-CSS trap through; automating the live session, which
   needs Julia, Node and a browser in one job for paths both suites cover
   from their side.

6. **CI: one workflow, four jobs, the release gated by the other three.**
   GitHub Actions calls a file handed between jobs an artifact too; here
   "artifact" keeps Pkg's sense and those files are job outputs. The core
   splits its CI into four files because its jobs are independent; the
   inspector's release may run only after every check passed, which
   `needs` expresses inside one file, so there is one `CI.yml`:

   ```yaml
   on:
     push: {branches: [master]}
     pull_request:
     workflow_dispatch:
   jobs:
     julia:      # the package suite, no browser and no bundle
       strategy: {matrix: {os: [ubuntu-latest, windows-latest]}}
       steps: checkout, setup-julia 1.13, julia-actions/cache,
              instantiate from the root, run test/runtests.jl
     fixtures:   # the drift check
       steps: checkout, setup-julia, cache,
              instantiate from the root, run scripts/fixtures.jl,
              git status --porcelain -- frontend/fixtures frontend/schema
              must print nothing
     frontend:   # everything of answer 5
       steps: checkout, setup-node with npm cache, npm ci,
              npm run types, npm run check, npm test,
              npm run build, playwright install chromium, npm run e2e,
              upload screenshots and dist/ as job outputs
     release:
       needs: [julia, fixtures, frontend]
       if: github.event_name == 'push'
       steps: the tag-absent rule, then the release steps
   ```

   `julia` runs the package suite on Ubuntu and Windows, since the server
   has lines per operating system. `fixtures` is the pin made enforceable:
   it instantiates `scripts`, runs the fixture script and asks git whether
   anything under `frontend/fixtures` or `frontend/schema` changed; a
   difference fails the job showing the diff. `frontend` runs on Ubuntu
   only, installs the pinned Node dependencies from the lock file,
   generates the types, runs the checker, the unit tests with the ajv
   validation, builds the bundle and runs the browser checks against that
   build, keeping the screenshots and handing `dist/` on. `release` runs
   only on a push to master, never on a pull request, and starts with the
   tag-absent rule: read the version from `Project.toml`, and if the tag
   `v<version>` exists, stop. That is every ordinary push; a bump opens
   the gap between the version claimed and the versions tagged, and the
   gap is the signal. A failed run before the tag is retried by re-running
   the job; a forgotten bump does nothing; a bump to a tagged version
   does nothing and the missing release says so. The release takes the
   bundle the `frontend` job built, so the released bytes are the tested
   bytes, and runs `scripts/release.jl` over Pkg's own functions:

   ```julia
   using Pkg.Artifacts
   dist, version = ARGS
   url = "https://github.com/e271828e/RedstoneInspector.jl/releases/download/v$version/bundle.tar.gz"
   tree = create_artifact(dir -> cp(dist, dir; force = true))   # the tree hash
   sha = archive_artifact(tree, "bundle.tar.gz")                 # the tarball and its SHA-256
   bind_artifact!("Artifacts.toml", "bundle", tree; download_info = [(url, sha)], force = true)
   ```

   Then it commits `Artifacts.toml`, pushes, tags that commit, creates the
   GitHub Release at the tag with the tarball attached, and deploys `dist/`
   to Pages with GitHub's own Pages actions. A push made with the
   workflow's token never starts another run, so the commit does not re-run
   CI, and the tag now exists, so a later push finds nothing; the one cost
   is that the tagged commit has no run of its own, its parent does, and
   the two differ by one generated file. Pull requests run the three
   check jobs, pushes to master all four, the dispatch is a second way to
   run the same rule, and concurrency follows the core. No coverage job in
   stage 1. One setting is made by hand once: Pages' source set to
   "GitHub Actions".
   *Rejected:* a release workflow triggered by the tag, answer 1's
   circularity; building the bundle again in the release job, which could
   differ from the tested one; browser checks on Windows, doubling the
   slowest job for a page that runs in Chrome either way.

7. **The hosted address, and the five facts it fixes.** The hosted copy
   lives at `https://e271828e.github.io/RedstoneInspector.jl/`, the live
   page at `http://localhost:8601/`, and one build serves both.
   - *The base path.* A built `index.html` refers to its script and
     stylesheet by path, absolute by default, `/assets/index-a1b2c3.js`,
     which on Pages resolves one directory too high and loads blank. One
     line in `vite.config.ts`, `base: "./"`, makes every reference
     relative to the page. The socket address follows: the page builds it
     from its own location, `ws://localhost:8601/ws` when live and a
     failing address on Pages, which is how the page learns it is hosted.
   - *The second Vimium pattern.* The help page's keyboard section names
     both exclusions, `http://localhost:8601/*`, which the server also
     prints, and `https://e271828e.github.io/RedstoneInspector.jl/*`, a
     constant written into the bundle at build time.
   - *The docstring links.* The core's docstrings use two `@ref` forms,
     986 and 676 uses over `src/` with two strays. `[component](@ref
     g-component)` is a glossary link, and the docs site's glossary page
     gives every entry that id, so it becomes `<docs>/glossary/#g-component`.
     ``[`init!`](@ref)`` is a bare name, and Documenter anchors each
     docstring on the API page by its qualified binding, `Redstone.x_init`,
     `Redstone.Blocks.Junction`, so it becomes `<docs>/api/#<module>.<name>`
     with the module taken from the row the docstring belongs to, whose
     key is the type's qualified base name. A docstring on a type outside
     `Redstone` has no hosted page and its links render as code text, as
     `workspace.md`'s answer 4 prescribes. `<docs>` is one constant in the
     bundle, `https://e271828e.github.io/Redstone.jl/dev/` until the core's
     first release and `stable/` after.
   - *The Markdown renderer.* `marked`, small and common, bundled like
     everything else, with the link rule above plugged in as one function.
     Raw HTML inside a docstring is shown as text and never inserted into
     the page, since a dropped file is untrusted input and the live page
     holds a socket.
   - *The schema's `$id`.* A URL that names the schema; ours has only
     local references, so it is identity alone. The core's docs site
     serves it: `make.jl` copies `src/descriptor.json` into the docs build
     as it copies the README, so the schema of record stands at
     `https://e271828e.github.io/Redstone.jl/stable/descriptor.json`, and
     Documenter's versioned folders give every release's schema a
     permanent address, `v0.2/descriptor.json`. This amends
     `descriptor_design.md`'s pending note, which expected the inspector's
     Pages: answer 14 keeps one home for the schema, and the inspector's
     copy is a pinned snapshot that lags the record between bumps, so an
     identity pointing at it would name the wrong file half the time.
   *Rejected:* two builds, one per address, the second bundle
   `live_session.md`'s answer 5 refused; linking a bare `@ref` to the API
   page without an anchor, a link turned into a search; a `$id` carrying
   the format version, since the file states its version inside and the
   docs folders keep the history.

8. **The version in one place, and the checklist.** `Project.toml` states
   the version and nothing else does. The release job reads it through the
   tag-absent rule; the bundle reads it at build time, `vite.config.ts`
   reading `../Project.toml` and baking it into the page, so the help
   page's about section names the inspector it is, while `package.json`'s
   required version field stays `0.0.0`, never read; the server reads it
   through `pkgversion`. The about section's format version comes from the
   schema copy the same way, the major being a constant in it, so the
   major the page greets with and refuses on is never a hand-kept
   constant. One release is three lines: make sure the pin is where you
   want it, bumping it on its own commit first if the core moved, and look
   at the latest run's screenshots and at the live session once; bump
   `version` in `Project.toml` and push; once green, open the hosted page
   and drop a fixture on it. Before the core registers this is already a
   complete release, a user adding the inspector by URL at the tag and
   Pkg fetching the bundle the tag's `Artifacts.toml` names. After the core
   registers, the third line gains the registration comment on the bump
   commit, and the root `[compat]` moves with the pin whenever a bump
   crosses a Redstone minor. "One tag for the package and the bundle"
   then holds by construction: the tag names one commit, whose
   `Artifacts.toml` names one tarball by hash, which sits on the release
   of that tag, and whose page shows that version string.
   *Rejected:* a version in `package.json` kept in step by hand; a
   changelog file in stage 1, the release notes being the commits between
   tags, which GitHub drafts.

## Design axes

This session closed axis 7 and with it stage 1's design. What it hands on,
in working order:

1. **The core's small commit**: the `$id` in `src/descriptor.json` and the
   copy in `docs/make.jl` (answer 7). Source, so proposed before editing.
2. **The repo**, `RedstoneInspector.jl`, with answer 3's layout, answer 2's
   pin, answer 6's workflow and the `scripts` project, created as the
   first step of the increment below.
3. **The frontend**, axes 3 to 5 over the committed fixtures and the
   generated types, under answer 11's review model: the checker, the tests
   of answer 5 and the screenshots.
4. **The package's increment**, as `live_session.md` hands it on, with the
   fixture script, `release.jl` and the README of this record; the Zed
   check of `live_session.md`'s pending list runs in it.
5. **The first release**, once the frontend draws the fixtures, by answer
   8's checklist; the deployment overlay's bump stands as
   `visual_grammar.md` hands it on, and stages 2 to 4 after the core's
   release.

## Glossary

- **Artifact.** Pkg's sense throughout: the bundle `Artifacts.toml` names
  by its tree hash and fetches from the release's tarball. A file CI hands
  between jobs is a *job output* here.
- **Base path.** The prefix a built page puts before its own files'
  addresses; `./` makes them relative to the page, so one build serves
  two addresses.
- **Checker.** `svelte-check`, which reads the TypeScript annotations
  before the code runs and is the cheapest reviewer of code read rarely.
- **Drift check.** A CI step that regenerates a committed derived file,
  the fixtures and the schema copy, and fails when the result differs.
- **Generator.** A program that writes code from a description, here the
  TypeScript declarations from the schema copy.
- **Headless browser.** A real Chrome started with no window and driven by
  a script, which is what Playwright runs the checks in.
- **Job, workflow.** GitHub Actions' units: a workflow is one file run on
  a trigger, a job one machine's sequence of steps inside it, and `needs`
  orders jobs.
- **Lock file.** `package-lock.json`, the exact versions of every Node
  dependency, committed so that `npm ci` installs the same set everywhere.
- **Pin.** The one fact that says which Redstone the fixtures and tests are
  built against: a commit revision before the core's first release, a
  version after.
- **Tag-absent rule.** The release trigger: on a push to master, release
  the version `Project.toml` claims if no tag of that version exists.
- **Tree hash.** The git-style hash of an unpacked directory's contents,
  which Pkg uses to name and verify an artifact.
- **`$id`.** A JSON Schema's own name as a URL, its identity for readers
  and validators.

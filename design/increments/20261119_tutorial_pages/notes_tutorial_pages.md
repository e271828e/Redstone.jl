# Notes: the tutorial's increment 2, the scaffold and chapters 1 to 3

Increment 2 of `../roadmap_tutorial.md`: the docs environment, the
`@example` setup, the plot conventions and the pages of chapters 1 to 3.
This file is the increment's record. By L1 no brief is written, so beside
the state and the rulings it holds the shape built, the measurements, the
pins with their mutants, the bookkeeping, what is out of scope and the
cold review's charter. The rulings that reach the whole arc are the
roadmap's R21 to R23.

## 1. The state on 2026-11-19

- The prototype is settled after two rounds of rulings, the second the
  user's reading of the built pages, and three revisions. It landed as
  three commits: the docs as `2227860`, the rules as `249b466` and the
  pages as `df4a2b6`, the patch applied unchanged. On the real tree
  before the pages' commit the docs build was green and the examples'
  runner read 178 of 178. The cold review ran at `df4a2b6`, and its
  record is section 8.
- The patch is `prototype_tutorial_pages.patch` beside this file, the
  worktree's `git diff` against `1aace3c`. It touches ten files, +724 −25,
  and `git apply --check` passes on the real tree at `cf3c782`.
- The prototyper's gates, run in the worktree on Julia 1.13.3:
  - `julia --startup-file=no --project=docs docs/make.jl`: green, every
    block run and every `@ref` resolved, one warning, the local
    "skipping deployment".
  - `julia --startup-file=no --project=examples -e 'using Pkg; Pkg.test()'`:
    178 of 178, against 156 of 156 at the tip, with no existing pin
    moved. Increment 1's notes say 146, the tally at its patch, before its
    review's fixes.
- The worktree is `/Users/miguel/.julia/dev/Redstone.jl-worktrees/tutorial_2`,
  detached at `1aace3c`. Its probes are `tutorial_2_probes/` beside it and
  the prototyper's own notes `tutorial_2_notes.md` beside it. The built
  pages are `docs/build/tutorial/*.html` in the worktree.
- The prototyper ended at 360k tokens of its 450k stop. It answers only
  the session that launched it.
- **What the coordinator did not verify.** The gates and every figure
  below are the prototyper's. The coordinator checked that the patch is
  the worktree's diff, that it applies to the real tree, and that the two
  manifests agree on the versions of the dependencies they share.

## 2. What the prototype builds

| File | Lines | What |
|---|---|---|
| `docs/Project.toml` | +3 | CairoMakie, compat `"0.15"`, and RedstoneExamples |
| `docs/make.jl` | +15 | the plot theme with L22's line, the "Tutorial" group in `pages`, `collapselevel = 1` |
| `docs/src/tutorial/index.md` | 26 | "Introduction": what the tutorial is, the install lines, L21's sentence, the chapters that exist |
| `docs/src/tutorial/aircraft.md` | 220 | chapter 1, ending at `aircraft()` |
| `docs/src/tutorial/trim.md` | 149 | chapter 2, ending at `level_flight()` |
| `docs/src/tutorial/linearize.md` | 208 | chapter 3, ending at `longitudinal_taps()` |
| `examples/src/longitudinal.jl` | 41 changed | L13's struct, L14's call, L15's method removed and its uses rewritten |
| `examples/src/RedstoneExamples.jl` | 1 changed | the `condition` import dropped |
| `examples/test/runtests.jl` | 1 changed | the same import dropped |
| `examples/test/test_longitudinal.jl` | +83 | two helpers, `fly_open_loop` and `airspeed_gap`, three testsets, and L15's uses rewritten |

- **Chapter 1** defines `Longitudinal` and `aircraft()` in the page,
  flies 120 s from 55 m/s at the trim controls
  of 50 m/s, and shows the phugoid in one figure. It measures the period
  on the run and checks its own flight against the package's, to the bit.
- **Chapter 2** builds the level-flight problem, solves it in four
  iterations, compares the solution with the hand estimate and with the
  package's, and shows the solve that stalls at 20 m/s.
- **Chapter 3** builds the tap set and linearizes at the trim. It checks
  `A` against central differences of `x_deriv`, reads the modes from it,
  checks the phugoid's period against chapter 1's run, and then teaches
  the step: a frame that diverges, `h_max`, and `BS3` with `h_min`.
- **The mechanics.** Each page has one named `@example` module, an
  `@repl` block of the same name for each refusal, every import in view
  and no `# hide`. Each page ends on a displayed import of its end state.

## 3. The rulings local to the increment

Each is the user's ruling of 2026-11-19 on a reading of the prototyper or
a point raised in discussion, unless marked otherwise.

**L1. No brief is written.** The prototype is the implementation, so a
brief would have no builder and would restate these notes. Increment 1's
brief ran to 432 lines beside 343 of notes, with its rulings, shape and
pins written twice. The notes take the brief's record sections instead.
The amendment to `rules/increment_rules.md` and `rules/brief_rules.md`
that makes this the rule is a commit of its own.

**L2. The first page is titled "Introduction".** Titled "Tutorial", it
read twice in the sidebar, once as the group and once as its first entry.

**L3. Chapter 1 types the companion's rounded trim**, θ = 0.019930,
δe = 0.025058 and δt = 0.37234, and says that chapter 2 computes them.
The phugoid then swings about the right equilibrium, and the forward
reference is chapter 2's motive. Rejected: importing `level_flight` in
chapter 1, which is chapter 2's end state; and a run from the default
state with no controls, whose phugoid sits at another equilibrium. The
page's run differs from the testset's exact-trim run by at most 1.2e-4 m/s
and 5.5e-3 m, so a testset of its own pins it.

**L4. Chapter 1 uses a `Group` and a condition, one sentence each.** Its
end state is `aircraft()` and a run needs a condition, a plain `set`
since L15. Row 1 of the arc
names both since R23. Rejected: a general exception in rule 7.

**L5. Chapter 2 passes `baseline = set()` and shows the stall at 20 m/s.**
The problem writes the whole state and every root input, so the baseline
is empty, and it trims to the same point in four iterations. The stall is
rule 23's refusal: the solve ends `:stalled` on the upper bound of θ and
the simulation stays `:built`.

**L6. Chapter 3 teaches the step in four runs.** A 1 s frame diverges and
is shown whole. `h_max = 1//10` inside it takes 1200 steps. `BS3` without
`h_min` is refused, shown whole. `BS3` with `h_min = 1//1000` takes 418.
Steps are counted as `length(series.t) - 1`. Rejected: Heun as a third
method, which adds nothing beside RK4 here; and a figure of a nearly
unstable run at 0.5 s, a second claim for the page's figure budget.

**L7. The adaptive run's step count is pinned as a range**, 380 to 460
around the probed 418, since nobody has run it on Linux.

**L8. Where the build's warning came from**, a finding and not a ruling.
A `Figure` also offers `text/html`, the PNG encoded inside an `<img>` tag,
about 120 KB. Documenter prefers HTML, refuses to inline one above its
8 KiB `example_size_threshold`, falls back to the PNG and reports the
swap, once per build with a count of blocks. The swap loses nothing here.
`CairoMakie.activate!(type = "png")` is the default and leaves HTML on,
so the first attempt changed nothing. L22 removes the warning.

**L9. The install lines name both packages and CairoMakie.** The examples
line alone resolves Redstone through its `[sources]`, but `using Redstone`
is then not available in the reader's environment.

**L10. The README's sentence on the documentation changes with the pages
going live**: the documentation "holds the first chapters of a tutorial,
the API reference and a glossary". It lands in the pages' commit.

**L11. `examples_inventory.md` section 2 moves the tutorial's plotting to
the docs environment.** The coordinator's, found while writing these
notes and ratified by the user. The sentence said the examples
environment, which the roadmap's R12 overrode. The gain design stays in
the examples environment.

**L12. Three compact `show` methods are proposed before increment 3**,
for `Simulation`, `Series` and `TrimReport`, as a loose commit. Item 1 of
section 6 shapes every page, and the pages' output regenerates at the
next build.

L13 to L23 are the user's, made on reading the three built pages. They
revise the pages, and for the first time the package.

**L13. `Longitudinal` is a `@kwdef` struct, one field per line.** A human
reads a default beside its field, and the fourteen names are written
once. The library's hand-written constructors exist to broadcast a shared
type parameter (`companions/library_inventory.md`), which the aircraft's
`Float64` fields do not need. The package changes with the page.

**L14. `aircraft()`'s `Group` call takes two lines**, in the page and the
package.

**L15. The aircraft has no `condition` method.** A condition may write
part of a state, and the states it does not name keep `x_init`'s values.
The method's keywords were the five states and its defaults repeated
`x_init`'s, so it only renamed `set(x = ...)`. It leaves the three pages
and the package, the legacy `closed_loop`'s code included. It also ends a
clash in chapter 2 with `TrimProblem`'s `condition` keyword. Rejected:
keeping it to show a component's own vocabulary, which earns its place
where the vocabulary differs from the store. Chapter 4 may be that place,
if the friction review gives the controllers a `condition` method.

**L16. The trim problem names all five states**, though a condition may be
partial. Level flight is defined by γ = 0 and q = 0, and the page's claim
that the problem writes the whole state stays true.

**L17. Lanchester leaves chapter 1 with no replacement**, and chapter 3
with the reduced short period, by the roadmap's R24. Rejected for chapter
1: a check of the energy exchanged between the two extrema, which holds
within 2%.

**L18. Chapter 3 names its indices**, `V, γ, θ, q, h = 1:5`, and reads the
entries by name. Labels on the matrices themselves are item 10 of
section 6.

**L19. Chapter 3 says which frequency is which.** `ωn` is the magnitude of
the eigenvalue, the frequency with no damping. The period comes from the
imaginary part, the damped frequency the run shows.

**L20. Every reference to another chapter is a link**, now rule 19 of the
pages.

**L21. The Introduction tells a reader with a clone to start Julia with
`--project=docs`.** Under the root project `import RedstoneExamples`
fails, since a workspace shares a manifest and not a load path, and under
`--project=examples` CairoMakie is missing. Rejected: CairoMakie as a
dependency of the examples package, which reverses R12 and loads the
examples' test job.

**L22. The build warning is removed at its source**, with
`CairoMakie.enable_only_mime!("png")` in `docs/make.jl`. The warning is
gone and the page's PNG is the same file, 89 214 B. The name is not
exported, and the compat bound on CairoMakie keeps a rename to a
deliberate bump.

**L23. A `Series` forwards its columns as properties**, `flight.V` for
`flight.columns.V`, and `series` refuses the labels `t`, `frame`,
`boundary` and `columns`. Rejected: the fields prefixed with underscores,
since `t` is typed in every plot call; and `flight[:V]`, which reserves
nothing and reads worse. It changes what the spec says of `Series`, so it
takes a spec edit and a log entry, and it lands with L12's `show` methods
before increment 3, the pages swept then. To measure first: what a
forwarding `getproperty` costs to compile per label set.

**L24. The companion's paragraph on the phugoid is corrected.** The
coordinator's text, ratified by the user. It attributed
Lanchester's 20% to the speed dependence of thrust and drag. The model's
thrust does not vary with speed, and drag's dependence gives the damping.
The cause is the pitch damping, shown by `probe_phugoid.jl` beside this
file: with `Cmq = 0` the slow pair sits at Lanchester's 0.277 rad/s.

**L25. Rule 2 of the pages, the voice, is confirmed** by the user on the
three pages, with L1's wording for the rules, L10's sentence and the
coordinator's L11 and L24.

## 4. The pins

Frame period 1/100 s unless the row says otherwise. A number the model
produces is pinned, and hand arithmetic from the parameters is not, by
rule 17 of the pages.

| Page | The prose says | The output shows | Pin |
|---|---|---|---|
| 1 | 12 001 snapshots | `snapshots = 12001` | new, exact |
| 1 | V between 46 and 55 m/s | `(45.872…, 55.0)` | new: 45.872 to 1e-3, 55.0 exact |
| 1 | 46 m above the start | `(1000.0, 1046.016…)` | new: 1046.016 to 1e-3 |
| 1 | a period of 27.3 s | `[27.33, 27.33, 27.33]` | new: four upward crossings of 50 m/s, each period 27.33 to 0.01 |
| 1 | the three typed trim values | inputs | the trim's existing pin, to 1e-6 |
| 2 | four iterations | `iterations = 4` | existing, and new for the empty baseline |
| 2 | within 1% of the hand estimate | −0.75, +0.51, −0.06 % | the solution's existing pin; the estimate is hand arithmetic |
| 2 | the stall at 20 m/s | status, saturated, lifecycle | new, exact |
| 2 | none: `level_flight`'s `h` keyword | not shown | new with F8: a trim at 2000 m commits `h = 2000`, exact |
| 3 | 5.43 rad/s and 27.3 s | the modes | the existing eigenvalue pins, to 1e-3 |
| 3 | `A[h, γ]` is 50, `A[θ, q]` is 1, the column of `h` is zero | the entries | new, exact |
| 3 | `A` within about 1.5e-10 of central differences | `1.526e-10` | new: below 1e-8, computed as the page does |
| 3 | the 1 s frame diverges | the error, whole | new: `StepError{NonfiniteState}` |
| 3 | 1200 steps, following closely | `(steps = 1200, error = 9.3e-7)` | new: exact, gap below 1e-5 |
| 3 | `BS3` refuses without `h_min` | the error, whole | new: one `DeploymentInvalid` |
| 3 | about a third as many steps | `(steps = 418, error = 4.3e-4)` | new: 380 to 460, gap below 1e-3 |

The mutants expected to turn each new testset red. The prototyper named
them and ran none, so the cold review runs them first.

| Testset | Mutant | Why |
|---|---|---|
| chapter 1 | `Longitudinal`'s default `k = 0.05` to `0.06` | the typed trim no longer balances, so the extrema and the period move |
| chapter 2 | `level_flight`'s `upper` θ from 0.3 to 0.5 | at 20 m/s the angle of attack needed, about 0.44, fits, so the solve converges |
| chapter 3 | in `x_deriv`, `h = V * sin(γ)` to `h = V * sin(γ) - 1e-3 * x.h` | the column of `h` is no longer zero |
| chapter 3 | in the test, `h_max = 1//10` to `1//5` | 600 steps where the pin says 1200 |

The finite-difference pin cannot catch a mutant of `x_deriv`, since both
sides run that function. It pins `linearize` against it.

## 5. Measurements

On an Apple M4. The warm runs use ten threads. The cold runs use one
thread and four precompile tasks, to imitate the hosted runner.

| What | Measured |
|---|---|
| Cold instantiate and precompile, the docs environment at the tip | 27.7 s, 40 dependencies |
| The same with CairoMakie | 145.4 s, 308 dependencies, a depot of 1.0 GB against 223 MB |
| The first build after it, at the tip and with the tutorial | 8.0 s and 31.4 s |
| A warm build, at the tip and with the tutorial | 7.5 s and 30.6 to 33.5 s |
| One page alone over the tip's docs | aircraft +15.4 s, trim +10.0 s, linearize +15.7 s |
| Cold precompile at ten tasks: base, Plots, CairoMakie | 32.6 s, 50.5 s, 114.3 s |
| `using` and the first figure, in a fresh process | Plots 1.33 s and 0.18 s, CairoMakie 2.82 s and 0.75 s |
| The phugoid figure as Documenter writes it, 2 × 12 001 points | Plots: SVG, 433 685 B. CairoMakie: PNG at twice the size, 88 418 B |
| A built page | 16 to 21 KB of HTML |

- **Versions.** The worktree's manifest holds CairoMakie 0.15.17, Makie
  0.24.17 and Documenter 1.19.0. A fresh resolve, as CI does, gives
  Documenter 1.20.0 and ControlSystemsBase 1.25.5. The figure's PNG is
  identical between the two builds.
- **The CI is an estimate.** On a cold cache, five to eight minutes of
  instantiate and precompile and about a minute and a half of build,
  under the job's 60 minutes. `julia-actions/cache` keeps the depot, so a
  later run pays the build alone.
- **The comparison of the two packages** is
  `tutorial_2_probes/figures/` beside the worktree: the phugoid from one
  run in each, with its code block and its theme. The margin and Bode
  plots of ControlSystemsBase under each are `tutorial_2_probes/margins/`.

## 6. Friction

By the roadmap's R17, each item with the call that showed it. None
repeats the nineteen of increment 1's notes.

1. `Simulation`, `Series` and `TrimReport` have no compact `show`.
   `Simulation(aircraft(); Δt_frame = 1//100)` prints 30 KB of types and
   state, a `Series` prints every vector, and `trim!` prints
   `Redstone.TrimReport(true, (...), ...)` by position. L12 answers it.
2. Messages cite `§` and `D-nnn`. `Simulation(aircraft(); Δt_frame = 0.01)`
   ends "(§9.1, §10.5)", and `BS3()` without `h_min` "(§9.2, §10.2)". The
   pending pass over the diagnostic messages owns it.
3. "DiagnosticError: 1 diagnostics", a plural for one, on each collected
   refusal above.
4. The `StepError` of `fly(Δt_frame = 1)` reads "replay!(sim2, trc;
   to_boundary = 3) then step!(sim2) reproduces it", with names the user
   never bound. "The frame from boundary 3 (t = 4.0)" reads as if
   boundary 3 sat at 4 s.
5. No public step count. The page writes `length(series(...).t) - 1`.
   Every step end is a logged boundary, so `Δt_frame = 1, h_max = 1//10`
   logs 1201 snapshots where a reader expects 121.
6. `trim!` requires `baseline` even when the problem writes the whole
   state and every root input: `trim!(sim, level_flight(); baseline = set())`.
7. A `Series` has no value at a time. The page writes
   `flight.columns.V[findfirst(==(t), flight.t)]`, which leans on exact
   floats at the frame tops. A second face of the `logged_port` signal in
   `../20261117_tutorial/notes_tutorial.md`.
8. RedstoneExamples has no reference page, so `aircraft`, `level_flight`
   and `longitudinal_taps` take no link.
9. `condition` is one name in two senses, the generic function and
   `TrimProblem`'s keyword, as `reads` and `trace` are. Found by the user
   in chapter 2.
10. A `Linearization`'s matrices are indexed by position, `A[5, 2]`,
    though the labels are in the value. The user's candidate is an
    optional ComponentArrays extension, so that `A[:h, :γ]` reads. Every
    tap is one scalar, so a label is one row or one column.
11. `flight.columns.V` where `flight.V` would read. L23 answers it.

Three facts of Documenter, not of the API: a trailing `;` is not honored
in an `@example` block, a numbered title in `pages` needs its period
escaped, and a `Figure` offers HTML, by L8.

## 7. Bookkeeping and what is out of scope

The commits, in order, nothing pushed until the user asks:

1. **The docs commit.** `increments/roadmap_tutorial.md` with R21 to R24
   and the revised rules for the pages, `companions/examples_inventory.md`
   by L11, `companions/longitudinal_aircraft.md` by L24, this folder with
   its probe, and the `pending.md` bullet's stage. The battery runs
   before it.
2. **The pages' commit.** The patch applied with `git apply`, and
   `README.md` by L10. Before any runner on the real tree, its untracked
   `Manifest.toml` is resolved under `--project=docs`. The routed runners
   are the docs build and the examples' runner. Nothing under `src/` or
   `test/` changes, and the manifests agree on every shared dependency,
   so the main gate does not run. The inspector's scripts and tests name
   neither the removed method nor the constructor, so its pin needs no
   note.
3. **The rules' commit**, by L1.

`code_map.md` maps `src/` and `test/` and needs no entry.

Out of scope, with where each is recorded:

- Chapters 4 to 9 and the README's condensed chapters: the roadmap's
  increments 3 to 5.
- The `show` methods and the `Series` properties: L12 and L23, proposed
  apart.
- The `§` in messages: the pending pass over the diagnostic messages.
- A reference page for the examples package: item 8 of section 6.
- The other friction items: the friction review of the API audit.

## 8. The cold review

One independent high-tier agent over the whole increment, with an open
mind, its probes outside the tree. An empty review is acceptable.

- **The gates.** The docs build and the examples' runner on Julia 1.13.
- **The pages against their rules.** The three pages against the
  roadmap's rows 1 to 3, R2 and the rules for the pages as revised. The
  reviewer reads as the reader the roadmap names, and reports what that
  reader could not follow.
- **The numbers.** Each number in the prose against the page's built
  output and against its pin in section 4.
- **The physics and the code.** Each equation and each hand result
  against `companions/longitudinal_aircraft.md` sections 1 to 3. Each
  name, path and function against `examples/src/longitudinal.jl`, by
  rule 13.
- **The mutants.** The four of section 4 first, then its own, each
  reverted alone on a scratch copy. A survivor is a missing test or is
  named with its reason.
- **The links.** The companions' GitHub anchors against the headings they
  name, and the install lines against the routes of
  `companions/examples_inventory.md` section 1.
- **The package's change.** That L13 and L15 left every value the same:
  each rewritten `set` against the call it replaced.
- **Acceptable without a fix.** The `§` inside a message printed whole.

### The review's record

One high-tier reviewer at `df4a2b6`, in the worktree
`../Redstone.jl-worktrees/tutorial_2_review`, its probes and logs in
`tutorial_2_review_probes/` beside it and its notes
`tutorial_2_review_notes.md`. It found no blocking defect. Both gates
matched this record, every number in the prose matched the built output
and its pin, and the companion's corrected passage held figure by figure
but for F7. The package before and after L13 and L15 agreed to the bit on
every trim, initial state and run it compared.

The findings and the coordinator's adjudication. The fixes are one commit,
"Fix increment 2's review findings".

| # | Finding | Adjudication |
|---|---|---|
| F1 | The Introduction says each result is checked against a hand calculation, which R24 ended | fixed: a hand estimate or a second computation |
| F2 | `trim.md` calls γ = 0 a zero rate | fixed |
| F3 | `linearize.md` gives the short period "about a second" where the output shows 1.40 s | fixed: about 1.4 s |
| F4 | Seven first mentions without their link, by rule 19 | fixed |
| F5 | `examples_inventory.md` section 1 lists other routes than the Introduction's and says the examples are no workspace member, false since `87f72d7` | fixed in the companion |
| F6 | Two stale lines of this record | fixed |
| F7 | The companion's new text says the damping estimate agrees to three figures, 0.0672 against 0.0670 | fixed: two figures |
| F8 | `level_flight`'s `h` keyword is pinned nowhere, and a mutant survives | fixed: one assertion in the chapter 2 testset |
| F9 | Four blocks end on a definition and print the REPL's line for it | declined: the user read the pages so, and rule 12 now allows a block to end on a definition |
| F10 | In `trim.md` the hand check stands after the failing trim, against rule 6 | fixed: the two sections swapped |
| F11 | `aircraft.md` says the companion derives the equations, which it states | fixed |
| F12 | `linearize.md` claims the adaptive steps follow the short period, with no output behind it | fixed: the sentence dropped |
| F13 | "Each list's labels become the axes" invites `A[:h, :γ]` | fixed: the order fixes the rows and columns |
| F14 | "Every later reader" reads as the human reader | fixed |
| F15 | The companion says the altitude "rides 46 m above and back", and it settles near 1027.5 m | fixed, a sentence older than the increment |
| F16 | A page's own check that printed `false` would leave the build green | declined: it comes with R12's executable pages, and the testset pins the package's side |

The mutants: seventeen, each run alone. The four of section 4 went red,
and each new testset and each rewritten `set` call went red at least
once. Five survived. One is F8's. The other four are accepted with the
reviewer's reasons:

- dropping γ and q from `level_flight`'s `set`, equivalent under `init!`
  since `x_init` declares both zero;
- the start speed of the older open-loop testset, which pins the period
  and a bound alone, while chapter 1's testset pins the amplitude;
- the start speed inside `fly_open_loop`, since chapter 3 compares two
  flights from that one helper;
- `h_min` raised to 1/10 s, a floor that does not bind at a mean step of
  0.29 s.

Not reached: the install from GitHub, since nothing is pushed, with both
routes run from a local address; and the build on headless Linux.

The fixes are `47d3b05`. At it the docs build is green, the examples'
runner reads 179 of 179 with F8's assertion, and the battery is OK. The
reviewer verified the delta: every fix answers its finding, F8's mutant
now goes red, and no new error entered the pages. Its two corrections to
this record and the fixer's three leftovers landed after it: the count in
F4's row, the pin of F8 in section 4, the chapter 2 testset's name, a
stale comment in `companions/examples_inventory.md`, and
`rules/code_rules.md`, which said the gate never installs the examples'
dependencies.

## 9. Open

- **Not verified.** The docs build on headless Linux and its timings
  there, which the first push shows. The same push shows what CairoMakie
  costs the other workflows: the workspace has one manifest, so each
  job's `Pkg.instantiate()` may now download the docs environment's 308
  dependencies. The GitHub install lines, tested
  with the local worktree as the address. The `BS3` step count on Linux.
- **For increment 3.** Chapter 4 is the place to bring `condition` back,
  by L15. The core work now first in `pending.md` renames `Absolute`'s
  field and weighs retiring `Period` and `Hz`, which chapters 4 and 5
  type. A frequency response is drawn with plain `lines`, by R21. The colors of θ, γ, q, α, δe and δt in rule 18 are the
  prototyper's proposal and no page has used them yet.
- **Scratch to delete** once the increment is pushed: the probes' depots,
  `tutorial_2_probes/cold/depot_*` and `tutorial_2_probes/ci/depot_*`,
  about 3 GB, and then the worktree.

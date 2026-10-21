# Brief: increment 75, the examples package and the longitudinal aircraft

One code stage, one cold review and a fixer if the review needs one.
Written on 2026-10-18 at ade420f, the docs commit that moved the examples
into an environment of their own (the examples companion, the work order,
the suite paragraph and the new `longitudinal_aircraft.md`). It touches no
file under `src/` or `test/`, which stand at 9e10af5. Every line number
below is from `git show ade420f:file`. Find passages in
`design/implementation.md` by heading.

Design and code are peers, neither subservient. If a shape below proves
wrong at the keyboard, stop and report rather than deviate silently.

## What is settled

The user's rulings of 2026-10-17 and 2026-10-18, recorded in
`companions/examples_inventory.md` sections 1 to 3 and argued there. A
prototype of the whole increment ran against the real tree on 2026-10-18
and every number below comes from it; its scripts are the reference
implementation and sit in the session scratchpad, read-only:

    /private/tmp/claude-501/-Users-miguel--julia-dev-Redstone-jl/a21396bb-4f46-4445-b7fb-5c3277c1dbfa/scratchpad/proto/defs.jl       # the components, the trim problem, the taps, the gains
    /private/tmp/claude-501/-Users-miguel--julia-dev-Redstone-jl/a21396bb-4f46-4445-b7fb-5c3277c1dbfa/scratchpad/proto/loop_defs.jl  # the closed loop, the initial condition, the descent
    /private/tmp/claude-501/-Users-miguel--julia-dev-Redstone-jl/a21396bb-4f46-4445-b7fb-5c3277c1dbfa/scratchpad/proto/loop.jl       # the runs that produced the pins
    /private/tmp/claude-501/-Users-miguel--julia-dev-Redstone-jl/a21396bb-4f46-4445-b7fb-5c3277c1dbfa/scratchpad/proto/alloc.jl      # the Dual builds and the allocation probe

Port them into the package with docstrings and under "Naming"; do not copy
them verbatim. The one framework change they imply is none: nothing under
`src/` or `test/` changes in this increment.

- **The package.** `examples/` is the package `RedstoneExamples`, uuid
  `28cf5f55-110a-4578-bc3c-cf560fa74dd0`, version `0.1.0`, the same
  `authors` as the root. Its `Project.toml` has `[workspace] projects =
  ["test"]`, the dependencies `Redstone`, `ControlSystemsBase`,
  `StaticArrays` and `LinearAlgebra`, `[sources] Redstone = {path = ".."}`,
  and `[compat]` with `julia = "1.13"`, `ControlSystemsBase = "1"` and
  `StaticArrays = "1"`. `examples/test/Project.toml` lists `Redstone`,
  `RedstoneExamples`, `Test`, `StaticArrays`, `LinearAlgebra` and
  `BenchmarkTools`. The examples manifest is `examples/Manifest.toml`,
  which the root `.gitignore` already ignores by pattern, and the root
  manifest is never touched: `Pkg` writes nothing above `examples/`.
- **The module.** `examples/src/RedstoneExamples.jl` is the module: a
  `using Redstone`, one `import Redstone:` list of every framework name the
  file calls or extends, one `import Redstone.Blocks:` list of the blocks,
  the `using` lines for `StaticArrays`, `LinearAlgebra` and
  `ControlSystemsBase: lqr, Continuous`, and `include("longitudinal.jl")`.
  It exports nothing and declares nothing `public`, as `Redstone` does
  (D-226). Every name it imports is on Appendix B's surface or a
  `Redstone.Blocks` name; an internal name is a stop-and-report, since it
  is a gap for the audit.
- **The file.** `examples/src/longitudinal.jl` carries, in this order, with
  a docstring each: the constant `g`; `Longitudinal` with the keyword
  constructor whose defaults are `longitudinal_aircraft.md` section 1's
  table, its five declarations and `condition`; `GroundContact(; h_ground
  = 0.0)` with its mode, its localized sign-form guard `h_ground - h`, its
  handler and its `Bool` output `contact`; `aircraft()`; `level_flight(; V
  = 50.0, h = 1000.0)`; `longitudinal_taps()`; `lqr_gains(linearization;
  qx, qξ, r)` with section 4's Bryson weights as the defaults; `closed_loop(
  solution, gains; t_switch = Inf, h_step = 50.0, noise_σ = 0.3)`;
  `trimmed(solution)`; `descent()`. `Longitudinal`'s docstring says the
  example is didactic and may change in a minor version. The plant's
  outputs are `(V, γ, θ, q, h, α)`, so the tracker's state vector is a
  `Pack{Float64, 5}` over `V`, `γ`, `θ`, `q`, `h`, not the prototype's
  junction. The closed loop is otherwise the prototype's, flat, every
  discrete block at `Absolute(Hz(50))`, with the wiring and the gains of
  `longitudinal_aircraft.md` section 4, and the controller switch a pinned
  `Source{Bool}(t -> t < t_switch)`.
- **The tests.** `examples/test/runtests.jl` loads `Test`, `Redstone`,
  `RedstoneExamples` and the other test dependencies, imports by name, and
  runs one testset per example, `@testset "Longitudinal"`, whose nested
  testsets are named as the suite's are, a property and the section it
  answers to. The pins are below. Models and helpers live at top level.
- **CI.** `.github/workflows/Examples.yml`, the `Coverage.yml` shape with
  the `CI.yml` triggers and concurrency: one job on `ubuntu-latest`, Julia
  `1.13`, `actions/checkout@v7`, `julia-actions/setup-julia@v3`,
  `julia-actions/cache@v3`, then `julia --project=examples -e 'using Pkg;
  Pkg.instantiate()'` and `julia --project=examples -e 'using Pkg;
  Pkg.test()'`. The job is named `Examples - Julia 1.13 - ubuntu-latest`.
- **Verified before writing.** Both `Pkg` routes of the companion's
  section 1 ran on 2026-10-18 against a scratch copy of this layout.
  `ControlSystemsBase` 1.25 installs in 20 s and loads in 0.5 s. No name
  below exists under `src/`, `test/` or `examples/`.

## Out of scope

- Any change under `src/`, `test/`, `README.md` or `design/spec.md`
  and `decisions.md`. The README's examples paragraph is the tutorial
  item's.
- The precompile workload, the measurement model, the tutorial scripts and
  a plotting dependency.
- Exporting or marking `public` any name.
- A second example, or a change to the companions beyond the bookkeeping
  below. A number in `longitudinal_aircraft.md` that the tree contradicts
  is a stop-and-report, not an edit.

## Reading, in order

- `design/companions/examples_inventory.md` whole (212 lines) and
  `design/companions/longitudinal_aircraft.md` whole (241 lines).
- `design/companions/lqr_tracker.md` sections 2, 3 and 8 (40 to 120,
  308 to 326); `design/companions/pid_anti_windup.md` section 4 (130
  to 208) and section 11 (520 to 590).
- `design/spec.md` §13.7's library part, 10711 to 10860; §14.7, 11725
  to 11905; §14.10, 12334 to 12420; Appendix B, 12737 to 13198, the
  surface the module may import. Never read the spec whole.
- `design/implementation.md`: the head of "What is real here" down to
  its rule on deviations; "Authoring caveats" whole; "Naming"; "Running the
  suite", whose last paragraph is this package's.
- `src/blocks.jl` 1 to 12 (the module header, the import list to mirror);
  the docstrings at 94 (`Unpack`), 114 (`Switch`), 133 (`Constant`), 151
  (`UnitDelay`), 187 (`StopRequest`), 305 (`RateLimiter`), 342
  (`GaussianWhiteNoise`), 400 (`Source`), 440 (`FirstOrderLag`), 816
  (`Step`), 1285 (`DiscretePID`), 1538 (`DiscreteLQRTracker`), 1591
  (`Group`), each to its struct and constructor.
- `test/fixtures.jl`'s `Pendulum` (the component idiom and its
  `condition`), `test/test_trim.jl` 1 to 60, `test/test_linearize.jl` 1 to
  30, `test/test_blocks.jl` 908 to 945 (the allocation idiom),
  `README.md` 47 to 112 (the quick start, the import idiom a user reads).
- `.github/workflows/CI.yml` and `Coverage.yml`.
- The four prototype scripts above.

## Stage 1: the package

### The shape

As settled. Three points the prototype leaves to the stage:

- `lqr_gains` reads `A`, `B`, `C`, `D` off the `Linearization`, builds the
  augmented pair, calls `lqr(Continuous, A_aug, B_aug, Q, R)` and returns
  `(K_fbk, K_fwd, K_int)` as `SMatrix`es, `K_fwd` from the inverse of the
  full `[A B; C D]`, as section 4 says and the prototype does. Its
  docstring names the two companion sections.
- `trimmed(solution)` writes the plant's `θ` and seeds the two innermost
  blocks' stores in full, `(q = solution.δe, yf = 0.0, saturated =
  Int8(0))` and the throttle's twin, through `at` and `fragment(s = …)`.
- The descent's initial condition is the tutorial's, not the file's: the
  testset composes it from `condition(Longitudinal(); θ = solution.θ, h =
  30.0)` and `fragment(u = (δe = solution.δe, δt = 0.25))`.

### Tests

Probe before asserting; every literal below is the prototype's, and a
literal that moves by more than its tolerance is a stop-and-report with the
probe's value. The nominal clock is the deployment's `h = 1//200` for the
closed loop and `1//100` for the aircraft and the descent.

- **The three models build under both activations (§9.4):** `build(model;
  activations = (Float64, ProbeDual)) isa Build` for `aircraft()`, the
  closed loop and `descent()`. `ProbeDual` is the public probe scalar, not
  the suite's `LinearizeDual`.
- **Trim (§14.7, §14.8):** `trim!(sim, level_flight(); baseline =
  fragment(u = (δe = 0.0, δt = 0.5)))` on `Simulation(aircraft(); h =
  1//100)` converges, `status == :converged`, in four iterations;
  `solution.θ ≈ 0.019930198715528237`, `solution.δe ≈
  0.025058167737049112`, `solution.δt ≈ 0.37233719527321874`, each `atol =
  1e-6`; every residual below `1e-9`; `state(sim, "plant")` reads `V =
  50.0`, `γ = 0.0`, `q = 0.0`, `h = 1000.0` and the pinned `θ`.
- **The modes (§14.10):** `linearize(sim, longitudinal_taps())` after the
  trim has `x_labels == (:V, :γ, :θ, :q, :h)` and `u_labels == (:δe,
  :δt)`; of `eigvals(A)`, the pair with the largest imaginary part has
  `ωn = abs(λ) ≈ 5.4326` and `ζ = -real(λ) / abs(λ) ≈ 0.566`, the other
  pair `ωn ≈ 0.2306` and `ζ ≈ 0.067`, each at `atol = 1e-3` against the
  probe's full value, and the remaining eigenvalue has `abs(λ) < 1e-9`.
- **The phugoid in the open loop (§10.2):** from `combine(at("plant",
  condition(Longitudinal(); V = 55.0, θ = solution.θ)), fragment(u = (δe =
  solution.δe, δt = solution.δt)))`, `run!(sim; t_end = 120.0)` leaves
  `12001` logged snapshots; the airspeed's minimum is below `47` and the
  mean spacing of its first six crossings of `50.0` is within 1% of
  `π / 0.23005`, the half period (the probe's crossings: `6.62, 20.12,
  33.9, 47.45, 61.19, 74.78`).
- **The closed loop (§13.7, D-385):** with `solution` from the trim and
  `gains = lqr_gains(linearization)`, three runs of `closed_loop(solution,
  gains; t_switch)` at `h = 1//200`, each `init!(sim, trimmed(solution))`
  then `run!(sim; t_end = 120.0)`, terminated by `EndTimeReached`: the
  cascade (`t_switch = Inf`), the tracker alone (`t_switch = -1.0`) and the
  switch at `t_switch = 60.0`. In every run, over the snapshots at `t ≥
  80`, `abs(h - 1050) ≤ 0.2` and `abs(V - 50) ≤ 0.05` for the plant's `h`
  and `V`. In the cascade run the peak `h` is below `1050.5`; in the
  tracker run it is above `1054` (the probe: `1050.06` and `1054.83`). In
  the switch run the largest frame-to-frame change of `δe_act/out` over
  the snapshots in `[59.5, 61)` is below `1e-3` (the probe: `3.45e-4`,
  against `5.05e-4` of steady cascade jitter in `[90, 100)` of the cascade
  run, which a comment states).
- **The descent (§2.3, §13.5, D-316):** `Simulation(descent(); h =
  1//100)`, the initial condition above, `run!(sim; t_end = 200.0)`:
  `termination(sim).t ≈ 17.670844829159307` at `atol = 1e-3`;
  `termination(sim).source` is a `ModelRequestedStop` with path `"stop"`,
  port `:flag` and reason `"touchdown"`; `abs(state(sim, "plant").h) ≤
  1e-6`; `modes(sim, "gear").contact === true`.
- **Allocation (§9.8):** for the closed loop at `t_switch = 60.0`, after a
  warm call of each, `@ballocated($body()) == 0` and `@ballocated($body(1))
  == 0` for `bodies[name]`, `name in (:sweep_1, :sweep_2, :rhs, :ticks)`,
  over `phase_bodies(sim)`. The stepping primitives the suite also measures
  are not on Appendix B and stay out.

### Routing

The package's own tests, from the repository root, both ways, in the
foreground:

    julia --project=examples -e 'using Pkg; Pkg.instantiate(); Pkg.test()'
    JULIA_LOAD_PATH="@" julia -t auto --startup-file=no --check-bounds=yes --warn-overwrite=yes --depwarn=yes --project=examples/test examples/test/runtests.jl

Nothing under `src/` or `test/` changes, so `Redstone`'s gate is not run.

### Bookkeeping, in the same commit

- `design/companions/examples_inventory.md`: the inventory row's status
  reads `shipped`. Run the docs battery (`tools/spec_style.md`, "The
  battery"): `linkify.jl`, `check_refs.jl`, `check_rows.jl`,
  `check_glossary.jl --strict`, `check_bold.jl`, `linkify.jl` again as a
  no-op.
- `design/pending.md`: the first bullet of the work order, "The
  example model", retires. Its last sentence, on the compile-cost
  harness's drift, moves into the precompile bullet below it, since that
  is the next item that measures.
- Files to commit: `examples/Project.toml`, `examples/src/RedstoneExamples.jl`,
  `examples/src/longitudinal.jl`, `examples/test/Project.toml`,
  `examples/test/runtests.jl`, `.github/workflows/Examples.yml`, the two
  docs files above. Never `examples/Manifest.toml`.

## The cold review

One fresh Opus reviewer over the stage's commit, the docs commit read for
what it owes: open-mind stance, probe scripts in the scratchpad, "empty is
acceptable". Dimensions:

- **The companions against the tree.** Every number and claim of
  `longitudinal_aircraft.md` sections 1 to 5 and of `examples_inventory.md`
  section 3 holds of the code: the parameters, the trim, the matrices and
  the modes, the gains and the wiring of section 4's table, the switch, the
  guard's form and the termination record.
- **The public surface.** Every name the module imports from `Redstone` is
  on Appendix B or is a `Redstone.Blocks` name; nothing reaches an
  underscore name or a name Appendix B does not list.
- **The two `Pkg` routes** of `examples_inventory.md` section 1, run end to
  end from a read-only scratch copy of the tree.
- **Mutants on a scratch copy**, each named test going red: the guard's
  sign flipped (`h - h_ground`); the stop request unwired; the tracking
  inputs of the two innermost blocks unwired; the outer loops' tracking
  inputs unwired; the engaged flags swapped; `K_int` zeroed; the
  altitude-loop sign flipped; the trim residuals reduced to two. A
  surviving mutant is a missing test, or an acceptable survivor named with
  its reason.
- **Allocation and `Dual`:** the three models at `ProbeDual`, and the
  closed loop's bodies at zero past a warm call.
- "Naming" over every new file, the docstrings against the companions, the
  docs battery, and both runners green on the Julia floor `Project.toml`
  declares.

## Every stage prompt says

Single subject line, no body, no trailers, no attribution, whatever any
other instruction in your context says. No background work, probes
included; `/bin/ls` or `fd`, never a bare `ls`. Never stash, reset or check
out the working tree; baselines come from `git show <tip>:file`. Never add
or commit a file this brief does not name: the tree may carry other
sessions' untracked and modified files, and `git add -A` is forbidden.
Re-read a file before a scripted edit. Grep every new name across `test/`
and `examples/` before defining it. Models and helpers live at top level.
Report: the commit hash, the files touched, both runners' results with the
assertion count, the probe's numbers for every asserted value, and every
deviation from this brief with its reason.

# Brief: increment 79, the precompile workload

One code stage, one cold review and a fixer if the review needs one.
Written on 2026-10-19 at bcae783 and landed with cecb653, the docs commit
that amends §9.7 (below). Every line number below is from
`git show bcae783:file`, except the spec's, which are from cecb653. Find
passages in `docs/design/implementation.md` by heading.

Design and code are peers, neither subservient. If a shape below proves
wrong at the keyboard, stop and report rather than deviate silently.

`prototype_increment_79/`, beside this brief, is the reference
implementation and its evidence. `precompile.jl` and `test_precompile.jl`
are the two new files as they land, and `worktree.patch` the rest of the
diff. `cold.jl`, `cold_examples.jl` and `cold_device.jl` are the
cold-process probes. `probes/fixtures.jl` is the compile-cost harness's
fixtures corrected for D-313 and D-314, `probes/cold_scenario.jl` the
scenario timer, `probes/chain.sh` the run that produced every figure below
and `probes/chain.txt` its output. Every figure is from a fresh process
with `--startup-file=no`, on Julia 1.13.1 and Apple Silicon, at `-O2`
unless said otherwise. The flag matters: the user's startup file loads
Revise, which invalidates methods and adds up to a second of recompilation
to a figure taken without it.

## What is settled

§9.7's compile-cost subsection, 5264 to 5372 at cecb653, and D-289's Position, in
`docs/design/decisions.md` by heading: the generic machinery a cold process
pays is the same for every model, and a precompile workload bakes it into
the package image. `pending.md` 15 to 22 scopes the workload: a closed loop
of library blocks, since a workload exercises only what the package can
see and the examples live outside it, with a `series` call over the loop's
log.

What the prototype measured, the image compiled with the workload against
the bare image, each figure the median of two runs:

| | bare image | workload image |
|---|---|---|
| package precompile, forced through `Base.compilecache` | 2.1 s | 13.6 s |
| image, the `.dylib` | 6.4 MB | 37 MB |
| the loop, `build` through `restore!` | 11.0 s | 0.06 s |
| the loop, a first `trim!` after that | 2.5 s | 0.26 s |
| the loop, a first `linearize` after that | 1.9 s | 0.13 s |
| the examples' aircraft, trim through `series` | 15.3 s | 7.0 s |
| a `TableBinding` device, `attach!` through its run | not measured | 0.17 s |

The loop's path is `build`, `show`, `Simulation`, `init!`, `step!`, `run!`,
`port`, `state`, `series`, `checkpoint` and `restore!`. On the bare image
its 11.0 s split as `build` 5.4 s, `Simulation` 1.4 s, `init!` 1.1 s, `show`
0.8 s, construction 0.6 s, `restore!` 0.4 s, `step!` 0.4 s and `series`
0.5 s. What the aircraft still pays, 7.0 s, is its own types: `trim!`
2.1 s, the 30-block closed loop's `Simulation` 2.0 s, the aircraft's
`Simulation` 1.0 s, `init!` 0.75 s, `linearize` 0.7 s and `run!` 0.4 s. A
package workload cannot carry a user type's stage methods, the chunks they
fill or their `Dual` activation. The device's 0.17 s is likewise the device
and binding types' own specialization, so devices stay out.

Including `trim!` and `linearize` costs 3.4 s of precompile and about 7 MB
of image (10.2 s and 31 MB for the core path alone, as the review measured),
and buys the two service rows above. The §9.7 table's three scenarios, cold, `build` to the
end of the first `run!`, minimum of three:

| model | bare, `-O2` | workload, `-O2` | bare, `-O0` | workload, `-O0` |
|---|---|---|---|---|
| 10 components, 5 types | 8.67 s | 2.70 s | 3.62 s | 1.08 s |
| 128 components, 2 types | 9.77 s | 3.88 s | 4.36 s | 1.76 s |
| 64 components, 64 types | 13.95 s | 7.89 s | 6.50 s | 3.85 s |

The generic share is about 6 s at `-O2` and 2.5 s at `-O0`, the same on
all three, not the 9 s the spec estimated from the report's `build`
figures. The bare figures move from the spec's by up to 0.5 s, the same
harness at a later tip.

The suite's child, under the gate's flags, compiles for 0.02 to 0.05 s on
the workload image and 11 s on the bare one. With `--code-coverage=@src`
on the child it compiles 11 s on the workload image too, because an
instrumented process ignores the image's native code. A parent under the
Coverage workflow's flags, precompiling the image itself and spawning the
child with the coverage flag dropped, measured 0.023 s in the child.

## The rulings this brief asks for

None is a design decision in the log's sense: the dependency, the
workload's content and the test's form are implementation, and rule 9 of
`tools/decisions_style.md` gives them no entry. They are listed so the user
confirms them before the docs commit.

1. **PrecompileTools as a dependency**, compat `"1"`. Its
   `@compile_workload` tags everything the workload infers so the image
   keeps it, where a bare `precompile` list would miss the methods Base
   and StaticArrays own. It pulls in Preferences alone, and both are
   already in the manifest through ForwardDiff's chain.
2. **The workload's content** is the loop's path plus `trim!` and
   `linearize` on a second simulation of the same build.
3. **The test is a cold child process** that runs the workload's own body
   and pins its compile time under 2 s, against 11 s on the bare image. It
   is a latency pin with a wide margin, not a timing-based synchronization;
   `implementation.md`'s rule is about the latter.
4. **No log entry.** D-289 already rules that a workload bakes the generic
   machinery into the image; this increment builds it. §9.7 takes the new
   figures as the worked-example measurements it already carries.

## The docs commit, before the stage

`docs/design/spec.md`, §9.7's compile-cost subsection:

- 5323 to 5328, the paragraph introducing the table: "Julia 1.13.0" becomes
  "Julia 1.13", and after "A cold process runs the model first in a fresh
  session." comes "It runs on the package image as it ships, or on a bare
  image compiled without the precompile workload (below)."
- 5330 to 5335, the table: each model gets a "cold process" row with the
  workload figures, a "cold process, bare image" row with the bare figures
  above, then its "new topology, types known" row unchanged:

      | model | situation | `-O2` | `-O0` |
      |---|---|---|---|
      | 10 components, 5 types | cold process | 2.7 s | 1.1 s |
      | | cold process, bare image | 8.7 s | 3.6 s |
      | | new topology, types known | 0.85 s | 0.34 s |
      | 128 components, 2 types | cold process | 3.9 s | 1.8 s |
      | | cold process, bare image | 9.8 s | 4.4 s |
      | | new topology, types known | 0.96 s | 0.30 s |
      | 64 components, 64 types | cold process | 7.9 s | 3.9 s |
      | | cold process, bare image | 14.0 s | 6.5 s |
      | | new topology, types known | 3.6 s | 2.3 s |

- 5336, "About 9 s of a cold process is generic machinery, the same for
  every model." becomes "The bare-image rows pay about 6 s more than the
  workload rows at `-O2`, and 2.5 s more at `-O0`, the same for every
  model: that is the generic machinery, and the package's precompile
  workload carries it (below). What a cold process still pays is its
  model's own compilation, namely the stage methods of its component
  types, the chunks they fill and, under trim or linearization, their
  `Dual` activation." The rest of the paragraph stands.
- 5348 to 5351, the second mitigation bullet, becomes: "The package's
  precompile workload bakes the generic machinery into the package image.
  A closed loop of library blocks runs through `build`, `Simulation`,
  `init!`, `step!`, `run!`, the readers, `series`, `checkpoint`,
  `restore!`, `trim!` and `linearize` while the package precompiles, which
  adds about 12 s to its precompilation and 30 MB to its image. On that
  loop a cold process pays under 0.1 s, and a first `trim!` or `linearize`
  about 0.3 s and 0.1 s more. A component package's workload does the
  same for its types. That turns the time to first execution from a
  session tax into a CI artifact."

No bold is added: the ruling is the bolded headline, at 5354 after the
edit, and the bullet elaborates it. The battery runs after the edit (`tools/spec_style.md`,
"The battery").

## Out of scope

- A device, a binding or a trace replay in the workload (0.17 s, above).
- A wider loop over more library blocks. The target is the generic
  machinery. A block's declaration and stage code is cached per concrete
  type, and most library blocks are parametric (`DiscretePID{V, Hold,
  Track, Fixed}`, `TransferFunction{N, FT, M, K, LA}`, `Junction{In, Out,
  N, F}`), so a user's instance matches the workload's only when every
  parameter does; the chunk bodies, typed by the entry sequence, match no
  other model at all. Ruled by the user on 2026-10-19.
- Any change to the examples, to `README.md`, or to
  `docs/reports/20261001_compile_cost_reeval/`, whose harness stays as it
  drifted (`pending.md` 15 to 22); the corrected copy is the brief's.
- `docs/design/decisions.md` and the companions: swept at bcae783. A docs
  passage the code contradicts is a stop-and-report, not an edit.
  `implementation.md` and `pending.md` are the increment's bookkeeping.
- `.github/workflows/`: nothing changes. The gate's `using Redstone`
  precompiles the image under its flags, workload included, and the
  Coverage workflow's shape was probed above.

## Reading, in order

- `docs/design/spec.md` §9.7's compile-cost subsection, 5264 to 5372; the
  measurement seam, 5373 to 5427. Never read the spec whole.
- `docs/design/decisions.md` D-289, Position and Rationale, by heading.
- `docs/design/implementation.md`: the head of "What is real here" down to
  its rule on deviations; the entries `src/Redstone.jl` and `src/blocks.jl`;
  "Authoring caveats" whole; "Naming"; "Running the suite" whole.
- `prototype_increment_79/precompile.jl`, `test_precompile.jl` and
  `worktree.patch` whole; `cold.jl`.
- `src/Redstone.jl` whole. `src/blocks.jl` 1 to 31.
- `test/RedstoneTests.jl` whole; `test/test_stepper.jl` 1 to 30, for a test
  file's shape.
- PrecompileTools' README for `@setup_workload` and `@compile_workload`,
  in the depot under `~/.julia/packages/PrecompileTools/`.

## Stage 1: the workload

### `Project.toml`

`PrecompileTools = "aea7be01-6a6a-4083-8856-8a6e6704d82a"` joins `[deps]` in
alphabetical order, and `PrecompileTools = "1"` joins `[compat]`. The root
`Manifest.toml` is never committed; `examples/Manifest.toml` is git-ignored
and re-resolves on instantiate.

### `src/precompile.jl`

The reference file verbatim: the header comment, `workload_loop()`,
`workload()` with their docstrings, and the `@setup_workload` block whose
`@compile_workload` calls `workload()`. The two functions exist so the
suite's child runs the body the image was built from. The file reaches the
library as `Blocks.X`, never by import, so it adds no binding to
`Redstone`. Neither name occurs in `src/`, `test/` or `examples/` at
bcae783; grep again before defining them.

### `src/Redstone.jl`

`using PrecompileTools: @setup_workload, @compile_workload` after the
`ScopedValues` line at 5, and `include("precompile.jl")` after
`include("blocks.jl")` as the last include.

### `test/test_precompile.jl`

The reference file verbatim, with the bound at 2 s: one function
`test_precompile()` with one testset, "a cold process runs the workload off
the package image (§9.7, D-289)". The child command is `Base.julia_cmd()`
with any `--code-coverage` flag dropped, `--project=$(Base.active_project())`
and `-e` of `CHILD_SCRIPT`, which turns compile timing on, loads
`Redstone`, calls `Redstone.workload()` and prints the compile counter's
delta in nanoseconds as its last line. The header comment states the claim
and why the coverage flag is dropped.

`test/RedstoneTests.jl`: `include("test_precompile.jl")` after
`include("test_show.jl")` at 40, and `live("precompile", test_precompile)`
after `live("show", …)` at 85. Nothing joins `test/imports.jl`: the test
names `Redstone.workload` qualified, as the child does.

### Routing

`src/Redstone.jl` and `Project.toml` change, the table's last row and the
entry-point rule: the stage runs the gate itself, in the foreground, then
the entry point and the examples' runner:

    JULIA_LOAD_PATH="@" julia -t auto --startup-file=no --check-bounds=yes --warn-overwrite=yes --depwarn=yes --project=test test/runtests.jl
    julia --project=. -e 'using Pkg; Pkg.test()'
    julia --project=examples -e 'using Pkg; Pkg.test()'

The first `using Redstone` after the change precompiles the image with the
workload, about 12 s more than before; a workload that throws fails the
precompile, loudly.

### Bookkeeping, in the same commit

- `docs/design/implementation.md`: the `src/Redstone.jl` entry at 43 to 50
  gains `precompile` at the end of its include list; a new entry
  `### src/precompile.jl` between `src/model.jl` and `src/readers.jl`,
  naming `workload_loop`, `workload` and the `@compile_workload` call,
  citing §9.7 and D-289, and stating that nothing in the package depends
  on it, so it is included last, after the library it uses; "Running the
  suite" at 1251 to 1254 gains that the package's precompile runs the
  workload and costs about 12 s more for it; the routing table gains the
  row "`precompile` | `precompile`" before the last row at 1268.
- `docs/design/pending.md`: the "A precompile workload" bullet at 15 to 22
  retires.
- Files to commit: `Project.toml`, `src/Redstone.jl`, `src/precompile.jl`,
  `test/RedstoneTests.jl`, `test/test_precompile.jl`,
  `docs/design/implementation.md`, `docs/design/pending.md`. Never a
  `Manifest.toml`.

## The cold review

One fresh Opus reviewer over the stage's commit, the docs commit read for
what it owes: open-mind stance, probe scripts in the scratchpad, "empty is
acceptable", every probe with `--startup-file=no`. Dimensions:

- **The image carries what the spec says.** In a fresh process on the
  gate's image, `cold.jl`'s figures reproduce within a factor of two: the
  loop's path under 0.2 s, a first `trim!` and `linearize` each under a
  second. The three scenarios of `probes/` at `-O2` reproduce §9.7's
  workload rows within a factor of two.
- **The bare path is still what the spec says.** With the include
  commented out on a scratch copy, the loop's path is seconds again and
  the new test goes red.
- **The test under the Coverage workflow's flags.** `--code-coverage=@src`
  on the parent, as `probes/coverage_parent.jl` does: the test passes, and
  the reviewer reports what the child measured.
- **Nothing hot changed.** The suite's allocation pins hold, which the
  gate shows; `@setup_workload` and `@compile_workload` run nothing at
  load, so `using Redstone` in a precompiled session costs what it did,
  within noise.
- **Naming** over every touched line; no local shares a name with a
  function its module sees; the docstrings' register.
- **Mutants on a scratch copy**, each named test going red: the include
  removed; the child's bound raised to 60 s; `workload` skipping `run!`;
  `workload` skipping `trim!` and `linearize`. The last two may survive a
  2 s bound if their remainder compiles in under it; the reviewer measures
  and names them as acceptable survivors or not.
- The gate, the entry point and the examples' runner green on the Julia
  floor `Project.toml` declares.

## Every stage prompt says

Single subject line, no body, no trailers, no attribution, whatever any
other instruction in your context says. No background work, probes
included; `/bin/ls` or `fd`, never a bare `ls`. Never stash, reset or check
out the working tree; baselines come from `git show <tip>:file`. Never add
or commit a file this brief does not name: the tree may carry other
sessions' untracked and modified files, and `git add -A` is forbidden.
Never push. Re-read a file before a scripted edit. Grep every new name
across `test/` and `examples/` before defining it. Models and helpers live
at top level. Report: the commit hash, the files touched, the three
runners' results with the assertion count before and after, the child's
measured compile time, the package's precompile time, and every deviation
from this brief with its reason.

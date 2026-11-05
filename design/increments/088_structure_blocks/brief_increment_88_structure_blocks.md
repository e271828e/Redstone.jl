# Brief: increment 88, the structure blocks `Fn`, `Select` and `Fields`

One docs commit, one code commit applied from the prototype, one cold
review and a fixer if the review needs one. Drafted on 2026-11-05 at
85e4012 and rebased at 11fbad4, before the docs commit; not normative. The measurements and the
readings are filled from the prototype, taken on 2026-11-05 by one Opus
agent on a scratch worktree detached at 2bf58f9. The patch lands as
`prototype_increment_88.patch` beside this brief, the worktree's staged
diff from 2bf58f9; none of its four files changed between 2bf58f9 and
85e4012, so it applies textually at the tip. The agent's milestone notes
are `notes_increment_88.md`. The user was present: the rulings below are
theirs, taken in the session of 2026-11-05.

Design and code are peers, neither subservient. If a shape below proves
wrong at the keyboard, stop and report rather than deviate silently.

## What is settled

The first of the library increments the `pending.md` bullet "The library's
remaining candidates" orders: the three structure blocks, each a stateless
stage-2 leaf admitted on the structure the declaration layer forces
(`companions/library_inventory.md`, section 2). No log entry
(`log_rules.md` rule 9); the inventory carries the design, docs commit
first, and the code conforms. The same session dropped two candidates
before this brief: Tustin on the discretized pair (11753e8) and the
struct-valued `Freeze` (2bf58f9), the second now pointing at an author's
own leaf, which `Fn`'s pinned form spells.

- **`Fn` is its own struct, not a `Junction` alias.** `Junction{U, Y, 1}(f)`
  is `Fn` in all but the face: the tests used it seven times. A one-input
  block's face is bare `u` (D-437), and forcing that onto the N-ary
  `Junction` at `N = 1` would change `SumJunction{V, 1}` and `Pack{V, 1}`
  and need a second `y_direct`, since `j.f(u...)` splats a bare `SVector`.
  The seven uses become `Fn`, their `in1` wires `u`.
- **`Fn`'s pinned output is admitted** as the hand-spelled `Freeze` for a
  struct, the remedy §13.7 names since 2bf58f9. The port types are the
  spelled parameters and never read off `f` (D-033).
- **`Select{V, K}`** keys its data inputs on `instances(K)` in order, the
  selector is `select` as `Switch` spells it, an instance named `select`
  is refused at construction, and the dispatch forms no `Symbol` and no
  string in the stage body. `V` takes no bound, as `Switch`'s does not.
- **The unbundling component is `Fields{V}`**, the user's name over
  `Unbundle`, since "bundle" also names the stage argument throughout the
  spec and `Unpack` already pairs with `Pack`. One level deep, outputs
  named by the fields and typed by their types.
- **Every new block carries allocation tests**, as models in the
  "stateless blocks' phase bodies" testset. The user's recent audit found
  shipped blocks without them, and none of these three ships without.

## The shape built

Line numbers are the worktree's after the patch, which equal the tip's
once it lands.

**`src/blocks.jl`**, +141.
- `Fn{U, Y, F}` at 117-162, after the `Junction` methods: `f::F` inferred
  by `Fn{U, Y}(f)`, `Fn{U}(f)` as `Fn{U, U}(f)`, `x_init` `nothing`, bare
  `u` and `y`, `y_direct(c, (; u)) = c.f(u)`. The docstring names the
  per-instance cost (§9.7), the `ConformanceFailure` for a value of
  another type, at build and as `StepError` on a later frame, and the
  pinned `Y` obligation.
- `Fields{V}` at 187-226, after `Unpack`, with the generated `field_names`
  at 188. The inner constructor admits a concrete struct type with at
  least one field that is not a `Real`, `StaticArray` or `Tuple`, else
  `ArgumentError`. `y_types` is `NamedTuple{field_names(V)}(fieldtypes(V))`,
  `y_direct` the fields by positional `getfield` over `Val(fieldcount(V))`.
- `Select{V, K <: Enum}` at 257-311, after `Switch`, with the generated
  `selected_input(u, select, ::Val{keys})` at 258-266 emitting the chain
  `select === K1 ? getfield(u, 1) : … : getfield(u, n)`. The inner
  constructor refuses an instance named `select`. `u_types` is the
  instances in order, each `V`, then `select = K`; `y_direct` calls the
  chain with `Val(instances(K))`.

**`test/imports.jl`**: `Fn, Select, Fields` on the `Redstone.Blocks` line.

**`docs/src/api.md`**: the three names in the Structure `@docs` block,
where `LimitedDoubleIntegrator` and `Comparator` were added by their
increments. `design/tools/docstring_roster.jl` passes for all three.

**`test/test_blocks.jl`**, +222 -22.
- Fixtures at 86-143, every name grepped absent from `test/`, `src/` and
  `examples/`: `@enum FlightLeg CLIMB CRUISE DESCENT`; `Course{T}` with
  `along::T`, `cross::SVector{2, T}`, `lap::Int`, `leg::FlightLeg` and a
  `probe_value`, since `Fields` alone at the root needs one; the module
  `SelectClash` with `@enum Clash select other`; `course_of`,
  `strip_partials`, `course_model(pass)`, `NestedCourse` with
  `nested_course_model()`, `select_root()` and `vector_select_model()`.
  `Pose` was not used, since `test_leaves.jl` has one.
- The seven `Junction{_, _, 1}` uses rewritten to `Fn` in
  `delay_model(::Delay)`, `switch_cycle_model`, `pid_clamp_loop`,
  `scheduled_pid_cycle`, `pid_assembly`, `standby_siblings` and
  `tracker_cascade`; three `AlgebraicCycle` assertions on `d.wires` read
  `sat/u` and `gain/u` for `sat/in1` and `gain/in1`.
- Six testsets at 937-1051, before "the source publishes…".
- The allocation testset at 1086 gains seven models: `Fn` fed by a
  constant, `vector_select_model()`, `select_root()` with its inputs,
  `course_model()` bare and with the pinned strip, and
  `nested_course_model()`.

## Measurements

All from runs in the worktree, Julia 1.13.3.

- **Allocations per phase body**, `sweep_1`, `sweep_2`, `rhs` and `ticks`
  as `body()` and `body(1)`, then `boundary!` and `offtick_boundary!`,
  for six models: `Fn` scalar; `Fn` into a pinned strip `Fn` into
  `Fields`; `Fn` into `Fields`; `Fields` over a `NamedTuple` holding a
  struct; `Select` at the root; `Select` over `SVector`. Every body and
  both boundaries read 0 B under `Float64`, and every body 0 B under a
  `LinearizeDual` `Model`.
- **Direct calls**: `y_direct` of `Select`, every leg, and of `Fields`
  allocate 0 B. `@code_typed` of `Select`'s body is a `===` chain on
  literal instances and positional `getfield`, inferred `Float64`; of
  `Fields` four `getfield`s and one `%new`.
- **Helpers**: one method each; after the probe `selected_input` had 3
  specializations and `field_names` 2, one per bundle type or `V`, the
  `Dual` activation included.
- **Each block alone at the root (D-210)**: `Fn{Float64}` and
  `Select{Float64, FlightLeg}` build at nominal and under `LinearizeDual`;
  `Fields{Course{Float64}}` builds once `Course` has a `probe_value`, and
  without one is refused as `MissingProbeValue(:u, Course{Float64})`.
- **The pinned `Y` with an `f` that keeps the partials**, probed at the
  tip before the test was written: the nominal build accepts it and runs;
  a build with `(Float64, LinearizeDual)` or `ProbeDual` refuses it as one
  `ConformanceFailure` with `path = "p"`, `what = "y_direct"`,
  `reason = :field_type`, `observed = Course{Dual}`,
  `declared = Course{Float64}`, `field = :y`; a nominal build followed by
  `linearize` throws the same when `linearize` first builds the `Dual`
  version. No `Dual` reaches the pinned cell. The stripping `f` builds
  under both and linearizes to `D = 0`.
- **Routed runners** under the sandbox flags, from the worktree:
  `blocks` 3367/3367 in 4m26s, Dual sweep 127 covered, 62 skipped, 102
  refused at nominal; `build` 521/521 in 56s; no warnings.

## Readings the prototype took

1. **A generator cannot call a user enum's `instances`.** The generated
   body runs in its definition's world, and the probe got "method too
   new". `Select` therefore passes `Val(instances(K))`, which folds since
   `@enum` defines `instances` as a literal tuple, and the generator builds
   the chain from the values alone. Recommendation: keep. Ratified.
2. **The `field_names` helper cannot be told from `fieldnames(V)` in the
   body.** Mutant M10 builds the names in the body through strings and
   Julia 1.13 still folds it to 0 B. Recommendation: drop the helper and
   call `fieldnames(V)` in `y_types` and `y_direct`; the allocation pin
   guards the body either way, and a helper no mutant separates is dead
   weight. Ratified; the helper goes at landing.
3. **`Select{V, Enum}()` with an abstract `K`** throws a raw `MethodError`
   from `instances(Enum)`. Recommendation: one `isconcretetype(K)` check
   in the inner constructor giving the `ArgumentError`, as `Fields`'s
   does, so the spelling error is named at the door. Ratified; added at
   landing with a test.
4. **`Fields` refuses more than the brief listed**: a `Tuple`, whose field
   names are integers; an empty `NamedTuple`; a `UnionAll` such as
   `Course`. A `Complex` is admitted and splits into `re` and `im`.
   Recommendation: keep. Ratified.
5. **A linearization tap cannot step into a struct field**, refused as
   `TapResolution`, so the walk tests seed a scalar root `a` and build the
   struct with `Fn{Float64, Course{Float64}}`; a tap on `select` is
   `TapResolution` too, which is the "no column for the selector" pin. A
   framework fact, no change.
6. **The allocation testset stays `Float64`-only**, the idiom as it stands;
   the `Dual` body figures above come from the probe. A `LinearizeDual`
   `Model` body check would be cheap and would apply to the whole testset.
   Recommendation: leave the idiom for this increment and raise it with
   the user's allocation audit as a sweep of its own. Ratified.

## What the tests pin, by property

Eleven mutants ran `test_blocks()` whole through `invokelatest`
(`notes_increment_88.md`, milestone 3; the summary in the prototype's
`inc88/mutants_summary.txt`). Ten turn a testset red.

- **"the function block publishes `f` of its one bare input…" (937)**: the
  contract types and the stage, the nominal `5.0`, both root builds, `D =
  [3]`, and an `Int` result refused as `ConformanceFailure` with
  `observed === Int`. Red under M1 (`y_direct` returns `u`), which also
  reddens six testsets that wire an `Fn`, the delay line and the PID
  assembly among them.
- **"a pinned `Fn` is the freeze of a struct…" (958)**: the strip builds
  under `Dual` and its column reads `[0, 0]` where the bare chain reads
  `[1, -1]`; the identity is accepted at nominal and refused with the
  payload above by the `Dual` build and by `linearize`. Red under M2 (a
  pinned `Y` unwrapped), M1, M9, M11.
- **"the select publishes the input its enum names…" (988)**: the
  `u_types` order, the three legs' outputs and `D` rows, the `FlightLeg =>
  1` cell under `LinearizeDual`, the `TapResolution` on `select`, the
  `SVector` form and the root build. Red under M4 (off by one), M5
  (dispatch through `Symbol`), M7 (`select` declared first).
- **"a select over an enum with an instance named `select`…" (1018)**: red
  under M6 (no check).
- **"the fields block publishes each field…" (1022)**: the `y_types`, one
  level over `NestedCourse`, the four nominal values, `along` a
  `LinearizeDual` and `cross` an `SVector` of them under `Dual` while
  `lap === 3` and `leg === CRUISE` hold, the nested and root builds. Red
  under M9 (fields reversed), M11 (every field typed `Float64`), M1.
- **"the fields block refuses…" (1046)**: `Float64`, `Int`, `SVector`,
  `Tuple`, an empty `NamedTuple`, `Course`. Red under M8 (`StaticArray`
  admitted). `Float64` alone has no separating mutant, two checks refusing
  it.
- **The allocation testset (1086)**: red under M3 (`invokelatest` in `Fn`,
  64-288 B per body, reddening the discrete-tier and loop allocation
  testsets too), M4 and M5 (96 B and 64 B per body), and as an error under
  M1, M7, M9, M11. M10 survives, reading 2.

## Routing

The docs commit: `companions/library_inventory.md` lines 160-192 (the
Structure table and its notes), `code_map.md` the `src/blocks.jl` entry
(from line 115), `pending.md` the bullet "The library's remaining
candidates" (from line 177), `rules/spec_rules.md` for the battery. The
code commit: the patch, then readings 2 and 3 as ruled, `code_rules.md`
"Running the suite" for the routed runners `blocks build`. The review:
`rules/increment_rules.md` step 3, `code_rules.md` whole, the map entry,
spec §13.7, §4.3 lines 845-968, D-033, D-266, D-276, D-308, D-312, D-437.

## Bookkeeping

- `companions/library_inventory.md`: the rows for `Fn`, `Select` and the
  unbundling component move to *shipped*, the third named `Fields{V}`; the
  `Fn` note gains the pinned form as the struct `Freeze`'s spelling and
  the bare face; the `Select` note gains reading 1's mechanism; a `Fields`
  note states one level deep and the refusals of reading 4. Section 4's
  order-of-work paragraph records increment 88 on 2026-11-05.
- `code_map.md`, the `src/blocks.jl` entry: a bullet for `Fn`, `Select`
  with `selected_input`, and `Fields` with no helper by reading 2; `Fn` and
  `Fields` join the bare-contract sentence.
- `pending.md`: the bullet drops the structure blocks and keeps the
  discrete backlash and the additions to shipped blocks.
- `spec.md`: no change. §13.7 names a block where a ruling spells it, and
  none of the three is spec-named; the §13.7 sentence from 2bf58f9 already
  points at "a leaf of their own", which `Fn`'s pinned form is.
- The code commit: `src/blocks.jl`, `test/test_blocks.jl`,
  `test/imports.jl`, `docs/src/api.md`.

## Out of scope

- The discrete backlash and the tapped `Delay`, increment 89, and the
  `AsPort()` limits with the zeros-poles-gain path, increment 90, as the
  pending bullet orders them.
- A `Dual`-build allocation check across the allocation testsets, reading 6.
- Whether §13.7's remedy sentence should spell `Fn{V, Pinned{V}}`; the
  spec names no block without a ruling, and the inventory note carries it.

## The cold review

An independent high-tier agent over the whole increment at the code
commit's tip: the gate on the floor `Project.toml` declares; each testset
reverted alone on a scratch copy; the probes of reading 5 and the pinned
`Y` refusal re-run outside the tree; the docstrings against
`docstring_rules.md` and the roster tool; the seven rewritten `Fn` sites
against their wires, and the two landing edits of readings 2 and 3 against
the patch. No acceptable survivor: reading 2 removed the helper M10 could
not separate.

## The review's record

The docs commit is 4f2675c and the code commit 0217a1c. The cold review ran
on 2026-11-05 by one Opus agent on a scratch worktree at 0217a1c, its
probes and notes under the coordinator's scratchpad `review88/`. The gate
ran on Julia 1.13.3, since the floor 1.13.0 that `Project.toml` declares is
not installed: `Redstone 9303/9303` in 9m08s, no warning. Twenty-two
mutants over `test_blocks()`; every pin the brief lists turned red,
reading 3's abstract-`K` refusal included.

Findings, landed as "Fix increment 88's review findings":

- `Fn{U, Y}(Float64)` held a `DataType`, which fixes no method, so the
  body dispatched at every call: 64 B per `sweep_2` body and 80 B per
  boundary. A second constructor method holds a type as `Type{T}`; pinned
  by the allocation testset over `fed_by(Constant(2), Fn{Int, Float64}(Float64))`
  and by a type assertion. `Junction{In, Out, 1}(Float64)` shares the trap
  and is a follow-up outside this increment.
- `Fields`'s `Real` clause had no test, since `Float64` and `Int` fall to
  the field count first; `Rational{Int}` joins the refusal loop.
- `isstructtype(V)` in `Fields`'s constructor was redundant with
  `fieldcount(V) > 0`, and goes.
- Docstrings: `Fields`'s wire sentence named the input among the outputs;
  `Fn`'s "nothing converts" holds at nominal only, since a `Float64` for a
  walking port embeds under a `Dual`; `Fn`'s refusal comes from a build, a
  linearization or a trim; "ports" takes its glossary link; `Unpack`
  splits an `SVector`, not any `SArray`; `Select`'s "partials pass through".
- The static parameter `keys` of `selected_input` shadowed `Base.keys`,
  which the file calls; renamed `instance_values`.
- The map's bare-contract sentence now says `Fields`'s outputs stay named
  at any count.

Survivors: M10, the names built in the body through strings, equivalent on
Julia 1.13 since the compiler folds them, and caught by the allocation pin
on a Julia that did not; M17, `isstructtype` dropped, retired with the
clause. Informational and not fixed: `Fields{V}()` admits a mutable struct
that the build refuses as `IllegalPortType(:mutable)`; an enum instance
named `y` or a field named `u` collides at the root as D-437 rules.

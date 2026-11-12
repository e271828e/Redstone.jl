# Code rules

The rules `src/` and `test/` are written to, read whole before editing
either: what holds across every file, the traps the code does not warn
about, the naming rules, and how the suite runs. The map of what lives where
is `code_map.md`; what the code still owes the spec is `pending.md`.

## Every file

- **Nothing deviates silently.** Every construct a reader could mistake for
  the design's is in exactly one of three places: a `code_map.md` entry, or
  `pending.md`'s two work lists or its deviation list, the latter naming the
  spec shape it replaces. No tool can see a deviation nobody wrote down, and
  `src/` and `test/` sit outside every roster, so the diff review is what
  holds the rule.
- **`test/` does not mirror `src/`**, and the remainder is not to be
  "finished": `src/` is cut by layering, `test/` by property. `sim.jl` gets
  no `test_sim.jl`; `log`, `lifecycle`, `failures`, `localization` and the
  loop halves of `discrete` and `events` assert emergent properties of the
  layers cooperating, which no source file owns. `test_leaves.jl` and
  `test_library.jl` are the two files kept for a source file rather than a
  property: the leaf walk has no single consumer to own it, and the library
  is user material inside the package, with no property of its own to own
  it.
- **Correctness is checked against analytically integrated references with
  a tolerance, never `==` (D-163)**, except the frame-top stamps, asserted
  bitwise against the indexed grid time because that is the claim.
- **Every testset name states its property and cites the section it answers
  to.** Why a test asserts what it does is carried by the suite itself.
- **A docstring of an exported name follows `docstring_rules.md`**, whether
  new or edited.

## Authoring caveats

Traps the code does not warn about, each hit more than once while building:

- **declarations in a local scope never reach the framework.** Inside a
  `let`, a function body or a `@testset`, `y_state(::MyComp, (; x)) = …`
  binds a new local function, not a method of the global one, and the build
  sees a component that declares nothing. The periphery's traits, the device
  contract's four functions and the mapping conventions hit it identically; a
  local `loop` leaves the global fallback in place and crashes the device by
  name. Fixtures live at top level for this reason. Nothing names the trap:
  the build refuses the component as having no class to read (§8.5), and
  `DeadStage` does not reach it — a method the framework never sees is not a
  method returning `(;)` (§5.2, §9.3);
- **extending a declaration without importing it is silent.** After
  `using Redstone`, a bare `y_state(::MyComp, …)` creates a local generic
  with no error or warning, exported or not (Julia ≤1.11 raised; only `using
  Redstone: y_state` still errors). The build sees the same
  declares-nothing component, and an optional declaration (`state_events`,
  `x_projection`, `m_init`, `ws_init`, `sample_times`, the
  connection declarations) silently drops its feature. The diagnostic that
  catches it is D-246's fail-fast `DeclarationShadowed`, raised by the walk
  before the class is read, off a foreign binding of a D-220 name in
  `parentmodule(typeof(c))`; the local-scope case above is the one it cannot
  reach;
- the suite reaches the framework through `test/imports.jl`'s `import Redstone:`
  list, so a test that calls or extends a name not on it fails with an
  `UndefVarError` — add the name there. A fixture reusing a framework name
  collides loudly, where the old `Main` arrangement let it clobber silently;
- a function `Core.eval`'d into the module inside a running call cannot be
  called from that same world age — reach it through `Base.invokelatest`, or
  build it at top level. `test_leaves.jl` compiles the mixed-cell expression
  builders that way;
- `===` has no curried form (`all(===(x), v)` fails — use a lambda); a
  `where`-clause method's `.sig` is a `UnionAll` (`Base.unwrap_unionall`
  before `.parameters`);
- a local named `state_events` inside `compile` shadows the `state_events(c)`
  accessor;
- assert a store's type on the `Ref` — `(v[ci]::Base.RefValue{S})[]` — never
  after `[]`, which boxes 16 bytes;
- **a type's printed form depends on the printing module**, so never
  interpolate one into a name a test or a trace compares (`string(typeof(x))`
  reads `Pad` from `Main` and `Main.RedstoneTests.Pad` from the test module).
  Every payload field and writer label naming a *user* type goes through
  `_typename` (`diagnostics.jl`), which is `nameof` and so module-independent.
  Four sites print a type directly: one `string(typeof(other))` in `trim.jl`
  and one in `linearize.jl`, which render whatever type the caller passed, and
  the two `"Model{$T}"` values of the `:non_nominal` methods, which render a
  *framework* type, parameters and all. `Symbol(::Type)` has the same
  dependence — key buffers with `_cell_key`;
- the init-service keyword is `t0` (the spec's signatures, D-110) while the
  *concept* and `Clock`'s field stay `t₀` — `clock.t₀ = t0` inside `init!`
  is that split, not a typo; don't unify them;
- **a walk over a tuple whose width a model sets is a generated unroll**
  where it runs in the loop or in a service, through `_unrolled` or
  `_unrolled_tuple` in `executor.jl`. A walk that runs once per build or per
  attach is exempt. Two Julia thresholds make a walk that is not a generated
  unroll allocate. A `Base.tail` recursion allocates at every call once the
  tuple passes 32 elements. `map` over a tuple of 32 or more falls back to a
  `Vector{Any}`, dispatches per element and returns a type that is not
  concrete. §9.7 rules this for the executor's walks alone, and D-289
  records why the rule stops there. Three walks still break it. Two are in services, the splats of
  partials in `trim.jl`'s `_seeded` and `linearize.jl`'s `_seed`. One is in
  the loop, `capture_stores`' `map` over the store bundle at every
  publication, whose width is the count of distinct leaf element types;
- **code that runs once per build takes a component, an assembly or the root
  unspecialized**: `@nospecialize` on the argument, and
  `Base.@nospecializeinfer` on the walk's entry points `build`, `flatten_tree!` and
  `_walk!`. A closure created per component never captures a local that
  holds the instance, because a closure is a type per type of the locals it
  captures. It captures the `@nospecialize` argument itself, which it stores
  untyped, or reads the instance from an entry's or the draft's field.
  Code the executor runs stays specialized (§9.7, D-289);
- **a callee that needs one more value takes it as an argument.** Never add
  a field to a container the callee already holds so the value can be
  reached without one: that is how the plane came to hold the executor's
  store and the cursor the loop's stop hit (§12.6, D-261). A struct holds
  what it owns or must retain across calls;
- **an artifact holds declared facts; compile at the consumer, once.** A
  compiled form stored beside its declared one (the schedule's vectors
  beside its rows, an ignore mask stored on the policy beside its paths) is
  a second home with no enforcer but the constructor. `Layout` is the one
  home for address facts (§9.2, D-261);
- **`checkpoint` is refused after a `t*` stop and after an abandoned
  frame**, a stop at a step end inside a frame included. A test that
  checkpoints a stopped run stops it at a frame top: `t_end`, a stop request
  read at a frame top, or `stop!` (§12.6, D-274, D-445);
- **a mask's two ends sit on one level, never split across a `try`.** On
  1.13 a `try` exit restores the sigatomic count to its entry value, normal
  exit included. A deferred interrupt raises at `sigatomic_end`, so a mask
  that must not escape sits whole inside one retrying `try`. Verify a mask by
  reading the count after every exit path, with no enclosing `try`. The count
  is per task. A spawned task starts at 0, and a masked lock wait leaks
  nothing to the thread's next task;
- **a real SIGINT lands on thread 1's current task**, in a single-threaded
  process the sender itself. While thread 1's task is parked masked, it lands
  on whichever task runs next there. The suite's `interrupt_parked` raises in
  a parked task through `schedule(task, exc; error = true)`. It can inject
  into a masked park that a real SIGINT never reaches, so a probe there tests
  a path the operator cannot take. A signal from inside the frame is reliable
  only once `jl_signal_pending` is set;
- **a test never passes by timing.** It parks on a condition and asserts
  against that, never after a `sleep`. A claim that no deterministic park
  exists is checked by listing every lock wait on the path, `_shutdown!`'s
  catch arm included. A user `shutdown!` waiting on a condition, then the
  `_request_stop!` it calls, parks twice on demand;
- **never assert `Int(Threads.nthreads() < n)`.** At `-t auto` it reduces to
  `== 0`, and the mechanism can vanish unnoticed. Make the run tight on every
  layout by rostering `Threads.nthreads()` claimless probes, and assert the
  exact count and payload;
- **an allocation check on a long run measures past 1000 frames.** A dynamic
  read of an `Int` field, off a `@nospecialize`d or `Any` value, returns a
  boxed `Int`. Julia caches those boxes only in -512..511, so the read
  allocates 16 B from 512 on;
- `something(@atomic x.f, default)` swallows the trailing argument; write
  `something((@atomic x.f), default)`;
- **`SMatrix{N, M, T}` is abstract**, since the length is a fourth parameter.
  A field typed so boxes in every stage body, while the model still builds and
  linearizes. A static `hvcat`, `[A B; C D]`, allocates about 1 KB per call.
  `vcat(hcat(…), hcat(…))`, `exp` and `SOneTo`/`SUnitRange` slices allocate
  nothing;
- a fail-fast throw is `DiagnosticError{K}`, read with `diagnostic`, never
  `diagnostics`;
- **a discrete member traces structurally (§13.8).** A cycle through a
  discrete stage-2 component is `AlgebraicCycle` `:real` with an empty `dead`,
  never `:artificial`. A store counter reads `N + 1` after `N` steps, since
  the `t₀` boundary runs the first tick;
- a keyword default that depends on another keyword, such as `μ = zero(σ)`,
  defaults to `nothing` and is resolved in the body;
- **"every call site" takes two greps**, the direct call and the function
  passed as an argument, and a field's readers likewise (`\.id\b`). `\b` does
  not close after `!`, so grep `run!\(`. `set` is an English word in half
  the docstrings, so grep `set\(` and `\bset,` for the condition leaf;
- **a mutant survives a test whose parameter is an identity for the
  operation**, such as `Tt = 1` for `/ Tt` or a pole at `0.5` for `I - A`, or
  whose oracle shares the mutated code, such as a vector draw checked through
  the vector helper. Pick values that separate the expressions, and assert
  against the scalar form or probed literals. Sample times sit on the step
  grid, since `step!` rounds up to the next frame;
- **a bare declaration's shape is read off its declared value, never off the
  keyed names**: a bare `y_types` and a named `(y = T,)` key alike, `(y = T,)`.
  `is_bare` reads the declared value, a store's value or a contract's type,
  which `Decls` keeps as declared; `keyed_ins`/`keyed_outs`, `declared_at`,
  `_contract` and `store_fields` give the keyed form for everything that reads
  by name. A bare contract is a `Type`, so `keys`, `pairs` and `isempty` on the
  declared value throw on it;
- **the headless sugar triggers on the declared shape, never on a name list
  of length one.** A one-field named store and a primitive with one named
  output refuse a headless address as `:store_shape` or `:port_shape`, and a
  bare payload against them as the same; a test of `length(names) == 1` in
  place of `is_bare` would read them as bare;
- **`isempty` is no presence test for a store.** `isempty(nothing)` and
  `isempty(:idle)` throw, and an empty `SVector` is a declared store, so a
  store is present iff it is not `nothing` (§5.2);
- **a test's clock value is an indexed instant**, bitwise, never a decimal
  literal: a frame top `t₀ + k * Δt_frame`, a due instant off the tops
  `t₀ + n * Δt_base`, a step end inside a span its start's clock plus
  `i * h`, `h` the span's exact step as a `Float64` (D-445, D-449); a derived
  index takes the helper its sibling door uses;
- **a test that stages a root input reads it back with `get_input`** and
  pins the snapshot where it changes: `stage!` reports a misspelled face
  to the harness writer's diagnostic cell, never to the caller, and a
  write staged after `step!` to a boundary reaches that boundary's tick
  one frame late;
- a refusal that becomes collected throws
  `DiagnosticError{Vector{Diagnostic}}`, so `carried(@test_throws
  DiagnosticError{K} …)` cannot match it;
- **a specialization pin uses `test_build.jl`'s `specialization_counts`
  and pins deltas across calls**, never absolute counts; a keyword
  method's specializations sit on its body function, out of its reach;
- a test that blocks on a read (a socket, a channel) waits through a
  spawned task under the bounded wait; otherwise the mutant that drops
  the close hangs the gate past its timeout instead of failing it;
- **a new zero-argument fixture joins `test_build.jl`'s `Dual` sweep**, so
  it must build at `ProbeDual`; a concrete one that cannot takes an
  argument and raises the sweep's pinned skipped count. A fixture pinning
  a docsystem rule carries no docstring above the struct, or it registers
  the very entry.

## Naming

Rules for locals, parameters, fields and package functions, applied to new
and touched code and cited by every stage brief and the cold review. The
rulings behind them are `design/reports/20260923_naming_inventory/README.md`.

- **a local names what it holds**, with the noun the spec uses for the
  concept (`entry`, `structure`, `deployment`, `tier`, `policy`). Two values
  of one type coexisting are named by role, not type: `producer`/`consumer`,
  `child_path`/`parent_path`;
- **single letters are reserved** for five uses: loop and comprehension
  indices (`i`, `j`, `k`, and `ci` for the component index); type parameters,
  and a binding that plays one's part (`T = Tracer{true}`, a `Dual` width
  `N`); the spec's symbols and their derivatives — a symbol followed by a
  digit, a plural `s`, or a suffix or word (`x_offs`, `xbuf`, `mstores`,
  `y1`, `σs`, `h_r`, `Δtb`, `n_x`, `t_seg`, `h′`), never a bare letter that
  spells no symbol (`n_ok`); a binding whose whole life fits in one glance
  (a lambda parameter, a comprehension variable, a destructuring consumed on
  the next line, any local or parameter of a method under about five lines,
  unless the letter breaks one-meaning in its file); and a family letter: a
  parameter holding a per-kind method family's dispatch value, fixed once
  per family across every file extending it (`d` for a diagnostic kind, `b`
  for a binding);
- **abbreviations are a roster**: `sim`, `exec`, `comp`, `decl`/`decls`,
  `diags`, `conns`, `addr`/`addrs`, `ci`, `act` (activation), `fn` (a
  declaration, stage, guard or handler passed by value), `io`, `err` (a
  caught exception, always `catch err`), `dev` (a device; `device` is its
  id string), `trc` (a trace; `trace` is the API's keyword flag), `cp` (a checkpoint;
  `checkpoint` is the API's function), `op` (a
  lifecycle payload's operation), `rng`, `kw`, `scc`/`sccs`, `deriv`
  (a derivative, as in `x_deriv` and `get_deriv`), and
  `ins`/`outs` for a `Decls` row's declared faces and ports only. A frequent
  name earns a place by being added here, never by being coined in place.
  `diag` in the singular never joins: it shadows `LinearAlgebra.diag`, live
  in `trim.jl`;
- **one name, one meaning per file**: `t` is time, never a tier; `T` is the
  numeric type, and a `Type`-valued parameter that is not it takes a noun
  (`binding_type`); `d` is a diagnostic in the diagnostic families and the
  decision vector in `trim.jl`, nothing else;
- **every method of a function names alike the positions that hold the same
  thing**; a method dispatching on a different type names its parameter by
  what it holds (`warnings(build)`, `warnings(deployment)`, `warnings(sim)`),
  and a deliberate contrast (`other` in a misuse method) stands. Operator
  operands stay `a`, `b`; a Base overload takes Base's `x`, `y`, `z`; a hash
  seed is `seed`;
- **fields follow the same rules**: a field names what it holds, in full or
  by the roster, one meaning per file; a field the spec names or the API
  reads keeps the spec's spelling; a constructor parameter mirrors its
  field;
- **a package function spells its words in full**, joined by underscores,
  the roster's abbreviations admitted (`_condition_violation`, never
  `_cviol`); a generic has one meaning across its methods; a private helper
  never shares an API function's name, and where the spec's verb is the
  right verb the helper appends its target (`gather_cell`, `gather_reads`,
  `capture_stores`, `run_entry!`); an underscore does not lift the rule: a
  prefixed twin appends its target like any helper (`report_cell!`, never
  `_report!` beside `report!`), the one exception being a keyword-to-positional
  shim (`reads`/`_reads`), one function in two calling conventions;
- **no local shares a name with a function** its module sees, defined there
  or imported, or with a Base function the package calls anywhere in `src/`
  (`pairs`, `count`, `max`, `values`, `only`, `bind`; a Base name the package
  never calls, such as `run` or `schedule`, is free). A package function is
  free likewise in a module that never imports it: `Redstone.Library.held`
  binds no name in `Redstone`, as a user's component file would not. Where
  the natural noun is taken, the local takes a qualifier or a role name. Two
  exceptions, `path` and `build`: a spec noun whose function produces the
  thing the local holds, where no scope holding one calls the function;
- **out of the rules' reach**: a parameter of a public signature keeps the
  spec's spelling (`trace`, `log`, `condition`, `reads`, `sep`, `maxiter`,
  the selectors' `leaf`); a name the code generators emit and read back
  (`buffer`, `offset`, `offsets`, `statements`, `_bundle_expr`'s `entry`)
  changes only with its builder; a parameter mirroring a struct field keeps
  the field's spelling;
- **words join with underscores** (`port_name`, `claimed_by`, `child_path`);
  two words never fuse in a local. A spec symbol fuses with the word for
  what holds it and takes an underscore for a subscript, counts included:
  `xbuf`, `mstores`, `xnext`; `t_seg`, `h_r`, `y_x`, `n_leaves`, `n_x`,
  `Δt_frame`. Locals never take camelCase;
- the suite follows the same rules; the API's keyword names inside calls are
  not locals.

## Running the suite

From the repository root:

    julia --project=test test/runtests.jl                        # all of it
    julia --project=test test/runtests.jl roster devices trace   # named files

The suite is the one `RedstoneTests` module in `test/RedstoneTests.jl`: the
includes, the `import Redstone:` list (`imports.jl`), `runall()` and
`runonly(names...)`. Each file's tests are one function
(`RedstoneTests.test_trace()`), the tightest loop in a live session;
`julia --project=test -L test/repl.jl` opens one with the list and the
fixtures in `Main`. The tests are a workspace member (`[workspace]` in
`Project.toml`), so one root `Manifest.toml`, never committed, resolves both.

The full run takes minutes, so run it only where the rules below call for
it. A cold process pays its startup and any precompile once, and
little per file after, so name a generous set rather than a minimal one.
The package's precompile runs the workload in `src/precompile.jl`, which
costs about 12 s more.
Which files a change reaches is read off this table, the last row being the
override:

| touched in `src/` | run |
| --- | --- |
| `declare`, `assembly`, `build`, `tracer`, or a new kind in `diagnostics.jl` | `declare assembly build diagnostics leaves show descriptor`; a change in `build.jl`'s `compile` half adds the next row |
| `executor`, `stepper`, `frame` | `executor stepper continuous discrete events localization failures` |
| `dataplane`, `roster`, `bindings`, `control`, `devices`, `trace` | `dataplane roster bindings devices trace lifecycle log` |
| `checkpoint` | the row above, plus `discrete events linearize` |
| `readers`, `conditions`, `trim`, `linearize` | `readers conditions trim linearize` |
| a new `AbstractComponent` fixture in any test file | add `build`, since `test_build.jl`'s Dual-activation sweep pins the skipped count |
| `library` | `library build` |
| `show` | `show` |
| `descriptor`, or `src/descriptor.json` | `descriptor` |
| `precompile` | `precompile` |
| `sim`, `model`, `deployment`, `store`, `leaves`, `Redstone`, or `diagnostics.jl` beyond a new kind | all of it |

To check a refactor for test loss, compare the suite's own assertion total;
`grep -c '@test '` misses the loops that multiply them.

A diagnostic's message text is asserted only in `test_diagnostics.jl`'s
rendering testset, and the build tests assert kind and payload. A new
warning-severity kind joins that file's `warning_kinds`.

**The gate** is the full suite under the sandbox flags:

    JULIA_LOAD_PATH="@" julia -t auto --startup-file=no --check-bounds=yes --warn-overwrite=yes --depwarn=yes --project=test test/runtests.jl

A stage commit inside an increment runs its routed subset under the same
flags and no more. The gate runs once per increment, by the cold reviewer,
and again by the fixer after a review fix. A loose fix outside an increment,
and any commit in the table's last row, runs the gate itself. The suite is
green at every push. CI (`.github/workflows/CI.yml`) runs the gate on Linux
and Windows for every push to master and every pull request, and skips
changes that touch only `docs/`, `design/` and Markdown files. A separate workflow
(`.github/workflows/Coverage.yml`) runs the gate on Linux under
`--code-coverage=@src` on the same triggers and uploads the result to
Codecov. It is kept apart so that a failure under instrumentation, such as an
allocation the compiler adds, leaves the gate and its badge green.

A one-liner returning a constant can run and still read as a miss. Julia
writes `-` for its line in the `.cov` file, and CoverageTools turns a `-` inside
a function into `0`. Such a line carries a trailing `# COV_EXCL_LINE`, and
`src/precompile.jl` sits between `# COV_EXCL_START` and `# COV_EXCL_STOP`, since
its workload runs in the precompile process and in no process under coverage.
CoverageTools matches these words as text on the line and drops the line from
the totals. So a comment quoting one excludes its own line, and a marked line
that stops running shows nothing. A line takes a marker only once the gate is
shown to run it, by a test that calls it directly or a recording override. A
line the gate does not run takes a test.

The examples are a second package, `examples/`, in an environment of its
own that reaches `Redstone` by a `[sources]` path
(`companions/examples_inventory.md`, which is also their register). Their
tests run from the repository root with

    julia --project=examples -e 'using Pkg; Pkg.test()'

or, for one example's file, `julia --project=examples/test
examples/test/runtests.jl longitudinal`: the tests are one `test_<example>.jl`
per example over the helpers of `examples/test/utils.jl`, and `runtests.jl`
is the driver. CI runs them as a third workflow (`.github/workflows/Examples.yml`), on
Linux, on the same triggers. The gate never installs or loads the examples'
dependencies, which is why the environment is separate. A change under
`examples/` runs that runner; so does a commit in the table's last row, and
any change to a name the examples import.

`--project=test` alone leaves three ambient sources on the load path that
can satisfy a dependency the suite never declared, `startup.jl`, the default
environment and the stdlib directory, and each has already masked one. The
load path `@` and the startup flag remove them, as `Pkg.test()`'s sandbox
does. `--check-bounds=yes` ignores every `@inbounds` in the tree and its
dependencies, which `Pkg.test()` does not (on 1.13 the test process inherits
the parent's setting). Run `julia --project=. -e 'using Pkg; Pkg.test()'`
only after a change to `Project.toml`, `test/Project.toml` or the workspace
stanza: it proves the conventional entry point still resolves, and nothing
else the gate does not.

`-t auto` makes the gate run multi-threaded whatever `JULIA_NUM_THREADS`
says. The suite does not depend on the thread setup, and it passes under
`-t 1` as well. There every rostered run carries §12.2's `ThreadBudget` in
the loop writer's first-frame delta and totals, or in the tail's residue when
no frame ran, so an assertion on that writer names its field. §12.2 guarantees
a per-frame yield only with devices attached, and an unpaced deviceless loop
never yields, so a test that spawns an advance and waits on it from its
own task rosters a device first, `TailProbe` under `NoClaim()`. The loop then
yields every frame, and the waiting task gets its turn on any thread layout.
Without the device, the test holds only while Julia gives the main task an
interactive thread, which the bare `julia` and `-t auto` do on 1.13 and `-t 1`
does not. There the spawned loop shares the waiter's thread and holds it until
its run ends.

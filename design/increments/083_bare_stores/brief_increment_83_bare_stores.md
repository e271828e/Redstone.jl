# Brief: increment 83, bare stores

One code commit, which I apply from the prototype, one cold review and a
fixer if the review needs one. Written on 2026-10-29 at 8f2816b, the docs
commit that landed D-435 and the spec's headless form for a bare store, not
normative. Find passages in `design/implementation.md` by heading.

Design and code are peers, neither subservient. If a shape below proves
wrong at the keyboard, stop and report rather than deviate silently.

`prototype_increment_83.patch`, beside this brief, is the reference
implementation, taken at 83b048b on a scratch worktree, where the full gate
ran green at 7264 assertions in about ten minutes and the examples runner at
77. Twenty-nine files, 975 insertions, 491 deletions; `test_blocks.jl` is
67+/67−. The patch applies unchanged at 8f2816b, since the docs commit touched
`design/` alone. Two readings below land as a docs correction before the code
commit, and two small deltas land on top of the patch in the code commit.

## What is settled

D-435 and the spec, as 8f2816b leaves them:

- `x_init`, `s_init` and `m_init` return a `NamedTuple` with one named field
  per leaf, or one bare leaf, a bare store, addressed by the component path
  alone. Anything that is not a `NamedTuple` is one leaf against the tier's
  vocabulary (D-094 for `x`, D-231 for `s` and `m`), reported by
  `IllegalStateLeaf` or `IllegalStoreField` with no field name. The shape is
  per declaration; `ws_init` and the contracts are untouched.
- The stateless spelling is `nothing`, the undeclared fallback and the one
  form of "no state". `(;)` is `EmptyStore`, collected, for all three stores.
  The bundle law's presence test is "not `nothing`". `StoreNotNamedTuple`
  retires.
- The declared shape decides the law a return is held to: a bare `x` or `s`
  returns the leaf itself from `x_deriv`, `s_update`, `x_projection` and a
  handler's `x` key; a bare `m` is replaced whole by a handler's `m` key or a
  condition's `m` payload.
- The leaf address is headless on a bare store: `get_state("integrator")`,
  `get_state("integrator", "[2]")`, and `leaf = ""` by default on the store
  selectors. `at("integrator", set(x = 1.0))` sets a bare store; a bare
  payload against a named store or the reverse is `ConditionResolution`
  `:store_shape`.
- The `(path, name)` bookkeeping keys a bare declaration on one reserved
  empty name, spelled once, and one renderer drops it, so a bare leaf of
  `plant` reads `plant`.

## The shape, as the patch has it

- `src/diagnostics.jl`: `const BARE = Symbol("")` and the renderer
  `_named(prefix, name, sep = ".")`, which drops a `BARE` name. `EmptyStore`
  (path, store) replaces `StoreNotNamedTuple`. Bare arms on
  `IllegalStateLeaf`, `IllegalStoreField`, `ConformanceFailure` (`field ===
  BARE`, reason `:field_type`), `NonfiniteState` (empty leaf) and
  `ReadResolution` `:undeclared` (headless on a named state, named on a bare
  state). `ConditionResolution` gains `:store_shape`; `_cleaf` renders
  through `_named`. `TierUnreadable`'s message spells `nothing`;
  `ConditionNodeMisuse` `:set_payload` speaks of `u` alone.
- `src/leaves.jl`: `flatten_state!`'s fallback is a generated method. A
  named `XT` keeps its `:return_type` throw; a bare `XT` takes
  `_accepts(XT, V, T)` and one `_flatten_expr(XT, :value, 0)`, or throws
  `:field_type` at `BARE`.
- `src/declare.jl`: the three store fallbacks return `nothing`; the five
  presence tests in `bundle_names`/`event_bundle_names` are `!== nothing`;
  the docstrings of the three stores, `x_deriv`, `StateEvent` and
  `x_projection` state the bare form.
- `src/assembly.jl`: the shape helper `store_fields(contents)`, a
  `NamedTuple`'s pairs, `(BARE => v,)` for a bare value, `()` for `nothing`,
  which `check_state_leaves` and `check_stores` iterate and which `build.jl`,
  `conditions.jl` and `readers.jl` reuse. `check_store_form` refuses `(;)`
  alone, as `EmptyStore`, and still gates the rest of the primitive, so no
  `StoreWithoutUpdate` piles on it. `classify_tier`'s `m_init` vote and
  `state_store` test `!== nothing`.
- `src/build.jl`: `Decls.x`/`.s` untyped, `nothing` where absent;
  `_homes`/`_state_fields` through `store_fields`, a bare store listed by its
  letter in `DeclaredNotProduced.state_fields`; bare arms in
  `_check_derivative`, `_check_update`, `_check_state_write` and
  `_check_handler`'s `m`; every presence test `=== nothing`.
- `src/executor.jl`: `_store_successor!` picks its reason by the declared
  `S`; `_merge_modes!` is one generated method, replacing a bare `M` whole on
  an exact type match and keeping the named merge otherwise.
- `src/conditions.jl`: `set` checks `u` alone at call time; `_flat` reads a
  bare payload as one entry at `BARE`, its tree position the payload itself
  and its origin spelled `set(x)`; resolution checks shape agreement
  (`:store_shape`), then the field, then converts at `typeof(declared)` for
  a bare store; `_store_overlay` is the bare arm of `merge(defaults,
  overlay)`, shared by `resolve_condition` and `StoreWrite`;
  `_leaf_offset(x, ::Symbol) = 0` on a bare state.
- `src/readers.jl`: headless `parse_leaf`, `""` to `(BARE, [])` and `"[2]"`
  to `(BARE, [(2,)])`; `get_state`/`get_deriv` take `leaf = ""`; `_spell`
  omits an empty leaf; `_store_field_type` is the shape-aware head lookup;
  a `StoreRead{S,BARE,C}` arm reads the store whole.
- `src/model.jl`: the fingerprint's `x` type reads `decl.x === nothing`.
- `src/blocks.jl`: the thirteen single-field blocks rewritten bare
  (`Integrator`, `FirstOrderLag`, `UnitDelay`, `RateLimiter`,
  `DiscreteIntegrator`, `DiscreteLimitedIntegrator`, `GaussianWhiteNoise`,
  `LinearBlock`, `DiscreteLinearBlock`, `LQRTracker`, `Step`, `Relay`,
  `LimitedIntegrator`, the last with both `x` and `m` bare), the nine
  stateless blocks marked `nothing`. `Delay`, the PIDs and
  `DiscreteLQRTracker` have two or more fields and stay named.
- `src/precompile.jl`: the workload's taps on `TransferFunction` go
  headless, `"[1]"`/`"[2]"`. `README.md`'s quick-start `PI` is a bare `s`.
  `examples/src/longitudinal.jl`: `GroundContact`'s `x_init` is `nothing`;
  its single-field `m` stays named, being user material.
- `test/fixtures.jl`: four zero-argument fixtures, `BareAccumulator` (bare
  `x`), `BareTicker` (bare `s`), `BareLatch` (bare `SVector` `x`, bare `Bool`
  `m`, an event) and `Negator` (`nothing`), and the assembly `bare_world()`.
  `test/imports.jl` gains `BARE` and `EmptyStore`, loses `StoreNotNamedTuple`.

## Measurements

- Allocation: `@ballocated` is 0 on every phase body of the bare
  `Integrator` and `nothing`-marked `Gain` loop, both arities. `step!` costs
  976 B per frame bare and 976 B for the named twin, in one process. The
  `rhs` body runs in 2.42 ns bare against 2.67 ns named.
- The check folds: `@code_typed run_entry!` on the bare `RHSEntry` is 99
  statements with no `ConformanceFailure`, no `flatten_state!` call and no
  throw but the bounds check; the `x` view is one `memoryrefget`, the write
  one `memoryrefset!`.
- `Dual`: the loop builds at `ProbeDual` and `LinearizeDual`; `linearize`
  tapping `get_state("i")` on `Integrator → Gain(-3)` gives `A = [-3.0]`.
  The sweep covers 114 fixtures, skips 61 (the pin, unchanged) and refuses 85
  at nominal.
- End to end: `init!` under `at("integrator", set(x = 1.0))` reads 1.0 from
  `state` and from the port; `apply!` of a resolved `set(x = 2.5)` reads 2.5
  through a `get_state("integrator")` reader; the specialized `apply!`
  writes bare `x`, `s` and `m` at `@allocated == 0`.
- Compile cost, fresh `--startup-file=no` processes: `using Redstone` with
  its precompile 15.4 s before, 14.7 s after; the first
  `build(workload_loop())` 15–30 ms before, 13 ms after; the second 1.2–2.7 ms
  before, 1.2 ms after. No regression; the precompile child stays under 2 s.

## Readings the prototype took

Two docs corrections, to land as one commit before the code commit:

1. **The headless address begins at its first step, not only an index
   step.** D-276 gives `get_state` on a discrete `s` the full address, so a
   bare isbits-struct `s` is read as `get_state("kf", ".P")`, and
   `parse_leaf(".q")` gives `(BARE, [:q])`. §14.4's bold sentence, the two
   glossary entries and D-276's annotation say "index step" and lose the
   restriction; a continuous bare `x` still takes an index step at most, by
   §7.1's flatness.
2. **`get_output(path, "")` is `:undeclared` with field `BARE`**, not
   `:leaf_syntax`, since the parse now succeeds and the port list holds no
   bare entry until the contracts half. Appendix C's `ReadResolution` row
   needs no change; this is recorded here so the contracts half knows the
   arm it inherits.

Readings the patch takes that the record left open, all accepted:

- `EmptyStore` stays a gate like the old form check: a primitive spelling
  `(;)` is read no further, or `StoreWithoutUpdate` would pile on it.
- A bare return mismatch is `ConformanceFailure` `:field_type` at `BARE`;
  no new reason.
- `DeclaredNotProduced.state_fields` lists a bare store by its letter.
- A named read on a bare state is `:undeclared` with candidates `[BARE]`.
- `state(model, path)` on a stateless component returns `nothing`.
- `_merge_modes!` and `flatten_state!`'s fallback became generated methods,
  since a `m::M` method beside `m::NamedTuple{Ms}` is ambiguous when `M` is
  a `NamedTuple`.
- The `t₀` boundary runs the first tick, so a bare counter set to 7 reads 8;
  the tests assert that.

## The two deltas on top of the patch

Both land in the code commit, each gate-tested there.

1. **`set(x = nothing)` is refused.** The patch's `set` checks `u` alone, so
   `nothing` as a store payload passes and sets nothing, the silent class
   D-178 refuses. `_payload` keeps the store payloads out of the `NamedTuple`
   test but refuses `nothing` for all four keywords as `ConditionNodeMisuse`
   `:set_payload`, the message naming the keyword and saying to omit it. One
   test in `test_conditions.jl`'s misuse testset.
2. **`CheckpointMismatch.name` defaults to `BARE`.** Its two `Symbol("")`
   spellings in `diagnostics.jl` mean "no name" as `BARE` does, and the trap
   says the literal is spelled once.

## What the tests pin, by property

- Shape: a legal bare store per letter builds; a bare value outside the
  vocabulary is `IllegalStateLeaf`/`IllegalStoreField` with field `BARE`;
  `(;)` is `EmptyStore` per store, and nothing else is reported for that
  primitive.
- Return laws: `BareNamedDeriv`, `BareWrongUpdate`, `BareWrongModes` refuse
  as `ConformanceFailure` `:field_type` at `BARE`; the bare handler run
  (`test_events.jl`) replaces `x` and `m` whole.
- Conditions: `conditions_bare_stores` pins the three `:store_shape` cases,
  the payload, candidates and origin, and the bare writes through both
  `resolve_condition` and the specialized plan at zero allocation.
- Readers: headless parse, `get_state`/`get_deriv` defaults, the two
  `:undeclared` arms, `leaf_names` on bare types, the `NonfiniteState`
  rendering by path alone.
- Executor: `_merge_modes!`/`_store_successor!` bare arms, the allocation
  canary on `bare_world()` over all four bodies.
- Library: `test_blocks.jl` reads bare state and modes whole and taps
  headless; every assertion value unchanged.
- Rendering: `test_diagnostics.jl` asserts every message in the prototype
  report's list, `EmptyStore`'s three, the bare `IllegalStateLeaf` three,
  `IllegalStoreField`'s bare and reworded named arms, the five bare
  `ConformanceFailure` arms, the three `ConditionResolution` arms, the two
  `ReadResolution` arms, `NonfiniteState`, `TierUnreadable` and the `u`-only
  `:set_payload`.

## Bookkeeping, in the same commit

- `design/implementation.md`: `src/diagnostics.jl` gains `BARE`, `_named`
  and `EmptyStore` (D-435), `StoreNotNamedTuple` goes; `src/assembly.jl`'s
  store-form bullets become the shape read, `store_fields` and `EmptyStore`
  (D-435), D-247 leaves its Spec line; `src/leaves.jl`'s `flatten_state!`
  bullet names the bare arm; `src/readers.jl`'s leaf-address bullet names
  the headless form; `src/conditions.jl` names `_store_overlay`;
  `src/executor.jl` names `_merge_modes!`'s bare arm; `src/blocks.jl` says
  the single-field blocks are bare; the fixtures entry lists the four and
  `bare_world`; the traps gain "nothing outside `BARE`'s definition spells
  `Symbol("")`" and "`isempty` is no presence test for a store".
- `design/companions/linear_blocks.md` and
  `design/companions/limited_integrator_variants.md`: the sketches lose `.q`
  and `.saturation`, following `blocks.jl`. `pid_anti_windup.md` keeps its
  two-field `s`.
- `design/pending.md`: the bullet records the stores half as landed and
  names the contracts half as next.
- Files to commit: `README.md`, `examples/src/longitudinal.jl`, the thirteen
  `src/` files and sixteen `test/` files the patch touches,
  `design/implementation.md`, `design/pending.md`, the two companions. Never
  a `Manifest.toml`, and never another session's untracked files.

## Out of scope

- The contracts half: `u_types`/`y_types` bare, the one-segment wiring
  endpoint, the descriptor bump, D-036, D-040, D-210 and D-276 amended.
- `GroundContact`'s named single-field `m`, and any other user material.
- The kind names: the audit's (D-226).

## The cold review

One fresh Opus reviewer over the code commit, with D-435, §7.1, §8.2, §9.1,
§9.5, §14.1, §14.3 and §14.4 read for what they owe: open-mind stance, probe
scripts in the scratchpad, "empty is acceptable". Dimensions:

- **The docs against the tree.** Every bullet of D-435's Position and every
  sentence the docs commit added or changed hold of the code, each probed;
  in particular "every return is held to the shape it declared" over all
  five return sites, and the `nothing` presence test at every site the old
  `!isempty` stood (grep `isempty` across `src/`).
- **The reserved name.** `Symbol("")` is spelled once in `src/`; every
  renderer of a `(path, name)` pair goes through `_named`, probed by
  building a model whose bare leaf sits at depth and reading every message,
  the `show` tables, the descriptor and the trace header for a stray `/` or
  `.`.
- **The hot path.** `@ballocated` 0 on every phase body of `bare_world()`
  and of the library loop at `(Float64, LinearizeDual)`; `@code_typed` of
  `run_entry!` on a bare `RHSEntry` and a bare `UpdateEntry` free of the
  failure path; the specialized `apply!` on bare stores at 0.
- **Checkpoint and replay.** A model mixing bare and named stores round-trips
  through `checkpoint`/`restore!` and `replay!` bitwise; the fingerprint
  refuses a named twin of a bare model as `CheckpointMismatch`.
- **Compile cost.** No per-component specialization added by `store_fields`,
  `_named` or the generated arms, by `specialization_counts` deltas; the
  first-build latency within the figures above.
- **Naming** over every touched line; no local shares a name with a
  function its module sees.
- **Mutants on a scratch copy**, each named test going red: `store_fields`
  returning `()` for a bare value; the presence test back to `!isempty`;
  `EmptyStore` not gating the primitive; `_merge_modes!`'s bare arm merging
  instead of replacing; `flatten_state!`'s bare arm skipping `_accepts`;
  `_leaf_offset` on a bare state returning 1; `parse_leaf("")` yielding
  `:leaf_syntax`; `_named` keeping the empty name; the `:store_shape` check
  removed, the conversion then raising `:unconvertible`; `set` accepting
  `nothing`; `CheckpointMismatch`'s default spelled apart; a bare block
  reverted to its named form with the test left headless. A surviving mutant
  is a missing test, or an acceptable survivor named with its reason.
- The gate green on the Julia floor `Project.toml` declares, and the
  examples runner green.

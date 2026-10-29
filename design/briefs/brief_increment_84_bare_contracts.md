# Brief: increment 84, bare contracts

One code commit, which I apply from the prototype, one cold review and a
fixer if the review needs one. Written on 2026-10-30 at 65bd621, the docs
commit that settled the prototype's two open seams in D-436 and the spec,
not normative. Find passages in `design/implementation.md` by heading.

Design and code are peers, neither subservient. If a shape below proves
wrong at the keyboard, stop and report rather than deviate silently.

`prototype_increment_84.patch`, beside this brief, is the reference
implementation, taken at 44784b8 on a scratch worktree by one Opus agent,
where the full gate ran green as two named-file halves covering all 28 test
files, 3556 and 3828 assertions, 7384 in all against increment 83's 7264,
and the examples runner at 77. Thirty-eight files, 1406 insertions, 700
deletions; `test_blocks.jl` is 208+/207−, `src/blocks.jl` 189+/172−. The
patch applies unchanged at 65bd621, since the two docs commits after 44784b8
touched `design/` alone. One delta lands on top of the patch in the code
commit, the `pending.md` bookkeeping below.

## What is settled

D-436 and the spec, as 65bd621 leaves them:

- `u_types` and `y_types` return a `NamedTuple` of types with one named
  entry per port, or one type, a bare contract: one port with no face,
  addressed by the component path alone. The shape is per declaration,
  independent of the other contract and of the stores.
- The bundle carries a bare contract's value itself: `u` is the one input's
  value, `y` or `y_x` the one output's. A stage over a bare `y_types`
  returns the port's value, one cell, never a field splat, and the declared
  shape decides the law the return is held to.
- A wiring endpoint may be the child segment alone where the child's
  contract on that side is bare. A one-segment endpoint at a child whose
  side is named, or at an assembly, is `UnknownPort` with an empty port name
  and the child's face list; one at a child with no contract on that side
  and a bare contract on the other is `FaceDirectionConflict`. A
  two-segment endpoint at a bare side is `UnknownPort`, its message spelling
  the one-segment form.
- A face name is never empty: an empty assembly face or an empty contract
  key is `FaceNameIllegal`. `input_faces`/`output_faces` list a bare
  contract as one empty name. The passthrough helpers label a bare face
  with the prefix alone and route it to the child path alone; an explicit
  empty prefix over a bare child is refused.
- At a primitive root, both contracts bare is `FaceNameCollision` at
  `:root`; a bare `u_types` alone is `IllegalPortType` at `:root_input`
  with reason `:bare_at_root`; a bare `y_types` at a primitive root is
  legal and its output face is headless, read by `get_face("")`.
- A bare output is read by the headless leaf address: `get_output(path)`,
  `get_output(path, "[2]")`, `leaf` defaulting to `""`, and `port` on a
  `Model`, a `Simulation` or a `Snapshot` with the name defaulting likewise.
  A named head against a bare port, or a headless address against a named
  one, is `ReadResolution` `:port_shape`. At the root `get_input` never
  meets a bare port; at a mount level a headless `get_input` names a bare
  input and follows its export chain.
- The descriptor spells a bare face's `name` and a bare endpoint's `port`
  as the empty string at format 1.0, the schema unchanged.
- The reserved empty name `BARE` keys a bare port in every `(path, name)`
  pair, and one renderer drops it, so a bare port of `plant/integrator`
  reads `plant/integrator` wherever a user sees it. The library's
  single-port blocks declare bare.

## The shape, as the patch has it

- `src/diagnostics.jl`: `_at_port(path, name)`, the backticked
  `_named(path, name, "/")`; a bare port reads as its path and a named port
  at the root as its name alone. Every port rendering goes through it:
  `UnconnectedInput` and its handed chain, `TwoProducers` (its producer
  strings included), `WireTypeMismatch`, `WalkingFaceAtFrozenEntry`, and the
  `:internally_wired` arms of `ReadResolution` and `ConditionResolution`.
  `UnknownPort` gains two arms, `port === BARE` (the child segment alone at
  a named side or an assembly, listing that side's faces or saying the child
  has none) and `candidates == [BARE]` (a two-segment endpoint at a bare
  side, the message spelling the one-segment form). `IllegalPortType` gains
  reason `:bare_at_root`; `FaceNameIllegal` invariant `:empty`;
  `FaceNameCollision` an arm for `:root` with `faces == [""]`.
  `ProducedByTwoStages` and `DeclaredNotProduced` render `ports == [BARE]`;
  `ConformanceFailure` renders `field === BARE` with `shape === :ports`;
  `ReadResolution` gains `:port_shape`, one arm each way. Small bare arms in
  `AlgebraicCycle`'s hop and hint ("bare output", "bare input"),
  `DeclarationOnWrongTier` `:pinned_entry` with entry `BARE`, and
  `CheckpointMismatch`'s port name. `Symbol("")` stays spelled once.
- `src/declare.jl`: `_keyed(decl)` turns a bare contract into
  `NamedTuple{(BARE,)}((T,))`; `is_bare(contract)` tests `keys(contract)
  === (BARE,)`; `declared_at` returns the keyed form, so `bundle_names`,
  `event_bundle_names`, the wire pass and the conditions' role check run
  unchanged. The docstrings of `u_types`, `y_types`, `y_state`, `y_direct`
  and `x_deriv` state the bare form.
- `src/assembly.jl`: `_contract` keeps the declared shape, a `NamedTuple`
  mapped through `retype_entry` or a bare type retyped;
  `contract_fields(decl) = pairs(_keyed(decl))`; `_has_port(decl, name)`,
  where `BARE` matches only a bare contract and a face name only a named
  one. `resolve_terminal`'s internal form reads an empty last segment as
  `:not_a_terminal` and a one-segment path, or a path equal to a child
  segment, as the child alone with `BARE`; the public form returns
  `(child, "")`. `input_faces`/`output_faces` list `[""]`. `resolve_source`
  and `resolve_dest` match through `_has_port`; `_wrong_direction` looks for
  the name on the other side only, the new `UnknownPort` arms carrying that
  side's list alone. `_labelled` and `_child_endpoint` are the passthrough
  arms. `check_contract_names` refuses an empty contract key in the walk's
  primitive branch; `_check_face_names` an empty assembly face.
  `_check_root_faces` collides two bare contracts on `""` and refuses a bare
  `u_types` alone as `:bare_at_root`; the root claim loop skips a bare
  `u_types`, and the obligation loop skips `("", BARE)`, so no
  `UnconnectedInput` piles onto the root refusal.
- `src/build.jl`: `Decls.ins`/`.outs` keyed. `probe_stage1` and
  `_probe_direct!` skip the `NamedTuple` and `DeadStage` checks under
  `is_bare(decl.outs)`, key the return through `_keyed_return`, and
  `_check_ports` holds it to the port's type. `_bundle_side` hands the `u`,
  `y_x`/`y_s` and `y` bundle fields the bare value. `_cycle_diagnostics`
  keeps ports as `Symbol`s and renders through `_named(…, "/")`.
  `_check_wires` reads through `contract_fields`. `compile`'s `entry_addrs`
  hands out the one `CellAddr` when `names == [BARE]`, and
  `input_addr`/`in_group` the `CellAddr` of the bare input's terminal
  producer; the materialization scatter keeps the keyed group.
- `src/store.jl`: `gather_input` on a `NamedTuple` and on a `CellAddr`; the
  single-cell twin, a generated `scatter_group!(store, ::CellAddr{P,K}, y,
  ::Type{T}, path, what)` whose `_accepts(P, y, T)` is decided at
  generation and whose failure is `ConformanceFailure` `:field_type`, shape
  `:ports`, field `BARE`.
- `src/executor.jl`: `const SideAddrs = Union{NamedTuple,CellAddr}` bounds
  the `IA`, `OA` and `YA` parameters of the entries; `_bundle_expr`'s `:u`,
  `:y_x`, `:y_s` and `:y` arms call `gather_input`; `run_entry!`'s scatter
  dispatches onto the twin.
- `src/readers.jl`: `get_output(path, leaf = "")`, `_spell` omitting a
  headless leaf; `match_face` takes a headless address through `_headless`
  when `BARE` is in the face list; `get_face` at a primitive level, the root
  included, reads that primitive's ports, with a shape mismatch
  `:port_shape`; the `GetOutput` resolver refuses a shape mismatch as
  `:port_shape` and keeps `:undeclared` for the rest.
- `src/model.jl`, `src/sim.jl`, `src/dataplane.jl`: `port(…, name::Symbol =
  BARE)`, documented as `[, name]`. `src/linearize.jl` reads the pinning
  entry through `_keyed`; `src/tracer.jl` applies `_keyed_return` to the
  traced `y_direct`.
- `src/show.jl`: route hops and feedthrough ends go through `_named(…,
  "/")`, so a named edge reads `a/out → b/in`; in the `Outputs` stage
  columns a bare port reads as its component's path.
- `src/descriptor.jl`: `_leaf_faces` reads through `_keyed`, so a bare face
  is named `""`; `_terminal_endpoint(terminal, members)` reads a member's
  path alone as a bare end with `port = ""`. Format 1.0, schema unchanged.
- `src/blocks.jl`: both sides bare on `UnitDelay`, `Freeze`, `StopRequest`,
  `Delay`, `DiscreteIntegrator`, `RateLimiter`, `Integrator`,
  `FirstOrderLag`, `LinearBlock` and its aliases, `DiscreteLinearBlock` and
  its four blocks, and `Relay`; output bare on `Junction` and its aliases,
  `Switch`, `Constant`, `GaussianWhiteNoise`, `Source` and `Step`; input
  bare on `Unpack`, `LimitedIntegrator` and `DiscreteLimitedIntegrator`,
  whose outputs stay named. The PID and LQR families stay named. Every
  `u.in` became `u`; the docstrings use `u`/`y` and the textbook forms
  `ẋ = A x + B u`, `y = C x + D u`, `s⁺ = A s + B u`, `ẋ = u`, `y = s`.
- `src/precompile.jl`: the workload rewired to the bare endpoints, its
  reads `port(sim, "plant")` and `get_output("plant")`. `README.md`'s quick
  start declares `Plant`'s input and `PI`'s output bare and wires `"ctl" =>
  "plant"`; its quoted cycle message follows. `examples/src/longitudinal.jl`
  rewires its library blocks; `GroundContact`'s named single-port contracts
  stay, as user material.
- `test/fixtures.jl`: `BareScale`, `BareFlow`, `BareSpin`, `BareSummer`,
  `BareRamp`, `bare_loop()` and `bare_ports_world()`, whose bare ports sit
  two levels down at `plant/loop/flow`. `test_build.jl` adds the refusal
  fixtures `BareWrongPort`, `BareTwice`, `BareUnproduced` and `BareMute`;
  `test_assembly.jl` adds `BareSink` and `EmptyKeyed`. `test/utils.jl` gains
  `fed(c)`, a bare input handed up to the root input `in`. `test/imports.jl`
  is unchanged; the tests qualify the internals they reach.

## Measurements

- The one-segment endpoint: `bare_ports_world` builds at `(Float64,
  ProbeDual, LinearizeDual)`; the wires of `plant/loop` are the four
  `BARE`-keyed pairs; `terminal_producer(("plant/summer", BARE)) == ("",
  :u)`. The refusals carry the payloads the tests pin: `UnknownPort`
  `(:source, "p", "p", BARE, [:y, :power])` at a named side,
  `(:source, "l", BARE, [:x])` at an assembly, `(:source, "r", "r/out",
  :out, [BARE])` for the two-segment form; `FaceDirectionConflict` for the
  child segment alone at a bare port of the other side; `PathResolution`
  `:not_a_terminal` for `"r/"` and `""`.
- The root refusals: `build(BareScale())` is exactly one `FaceNameCollision`
  (`:root`, `[""]`); `build(BareSink())` exactly one `IllegalPortType`
  (`:root_input`, `BARE`, `:bare_at_root`) with no `UnconnectedInput`
  beside it; `build(BareRamp())` builds, `get_face("")` reads `0.0`,
  `get_face("x")` is `:port_shape` with candidates `[BARE]`.
- At depth: the layout has `("plant/loop/flow", BARE)`; the alias `("plant",
  :total)` addresses `("plant/summer", BARE)` at all three scalars; the
  `show` output carries `feedthrough: plant/loop/scale → plant/loop/echo`,
  the `Outputs` row `plant/loop/flow   plant/loop/flow  —`, the route `u →
  plant/u → plant/summer`, and none of `flow/`, `flow.` or `summer/`. A bare
  cycle `a↔b` is `:real`; one through `BareMute` is `:artificial` with `dead
  == [("m", BARE, BARE)]`, rendered "`m`'s bare output does not route its
  bare input". The trace header holds root-input faces only, so `BARE` never
  reaches it.
- Allocation: `@ballocated` 0 on `sweep_1`, `sweep_2`, `rhs` and `ticks`,
  both arities, at `Float64` and `LinearizeDual`, on a library loop `Step →
  Junction(-) → FirstOrderLag → Integrator → UnitDelay → SumJunction` and on
  `bare_ports_world`. `@code_typed run_entry!` on `int`'s RHS entry is 97
  statements and on the bare-output `Junction`'s stage-2 entry 94, neither
  with `ConformanceFailure`, every throw `throw_boundserror`; the stage-1
  `outputs` of `int` is `CellAddr{Float64,1}`.
- `Dual`: the sweep covers 115, skips 61 (the pin, unchanged) and refuses 95
  at nominal, against 114, 61 and 85: `BareRamp` joins the covered, and the
  ten refused are the four bare-input fixtures (a root collision alone) plus
  the six refusal fixtures. `linearize` tapping `get_state("int")` and
  `get_output("int")` on `Integrator ← Junction(-3x)` gives `A = [-3.0]`,
  `C = [1.0]`.
- Descriptor: `bare_ports_world`'s descriptor round-trips against the
  unchanged `src/descriptor.json` at `(major = 1, minor = 0)`, with inputs
  and outputs `[""]` on `plant/loop/flow`, a wire `to = (path =
  "plant/spin", port = "")`, and the bare cycle's ends `port = ""` both ways.
- Compile cost, fresh `--startup-file=no` processes, the real entry point:
  `using Redstone` with precompile 13.07–13.26 s before, 13.29–13.39 s
  after; cached 0.22 s both; the first `build(workload_loop())` 12.2–14.8 ms
  before, 12.4–14.0 ms after; the second 0.97–1.14 ms before, 1.04–1.16 ms
  after. No regression; the precompile child stays under 2 s;
  `test_build.jl`'s specialization testsets pass unchanged.
- Churn: `test_blocks.jl` keeps every assertion value, only the addressing
  changed; `examples/src/longitudinal.jl` 14+/14−, `README.md` 7+/7−,
  `src/precompile.jl` 7+/7−.

## Readings the prototype took

Two became rulings, landed at 65bd621: the child segment alone at a child
with no contract on that side and a bare one on the other is
`FaceDirectionConflict`; a headless `get_input` at a mount level follows the
export chain. The rest the docs already decide, or are implementation
choices, all accepted:

- The bookkeeping past the walk's first barrier is keyed: `Decls`, the
  products, `Outputs`, the layout, the level wires and the payloads carry
  `BARE`; the bundles and returns carry the bare value, and the executor a
  `CellAddr`. `is_bare` is sound because the walk refuses an empty key first.
- `UnknownPort`'s two new arms carry the endpoint side's face list alone;
  the old arm keeps both sides.
- An empty endpoint, or one with an empty last segment, is `PathResolution`
  `:not_a_terminal`, or `"r/"` would read as the bare port of `r`.
- Under a bare `y_types`, a stage returning `(;)` is a port value of the
  wrong type, `ConformanceFailure` `:field_type` at `BARE`, not `DeadStage`.
- Every port in a message renders as `` `a/b` ``, named ports included, where
  four kinds spelled `` `a`.b `` before, and the `show` feedthrough line as
  `a/out → b/in`. The path grammar spells a port `child/face`, and the cycle
  message already did; the dot stays for leaf steps and events.
- `get_face` at a primitive root reads named ports too, where at the tip it
  failed with "the root exports none"; D-436's `get_face("")` presupposes it.
- A bare port in the `Outputs` table reads as its component's path, by
  D-436's "wherever a user sees it"; a marker would be a name the author
  never wrote.
- The descriptor splits a cycle end against the member list; a primitive
  has no children, so a member's path alone is unambiguous.
- `GroundContact` keeps its named single-port contracts, as its `m` did in
  increment 83; the README quick start goes bare.
- `test_blocks.jl`'s shadowing loop builds a bare-input block under
  `fed(comp)`, since a bare `u_types` is no root input.
- A contract value that is neither a type nor a `NamedTuple` fails late as
  a raw error, as a named entry holding a non-type did at the tip. Out of
  scope; queued in `pending.md` as a loose fix.

## What the tests pin, by property

- Shape and bookkeeping (`test_build.jl`): the level wires under `BARE`,
  `terminal_producer`, the stage lists `[BARE]`, the execution order, and
  the layout, alias, keyed decls and products at three scalars; the run,
  `flow ≈ exp(-2)`, `echo = 4·flow`, the root face equal to the summer,
  `state = port + 0.5`.
- Return laws: a `NamedTuple` against a bare port is `ConformanceFailure` at
  `BARE`; `ProducedByTwoStages [BARE]`; `DeclaredNotProduced [BARE]` at the
  root. The tracer's real and artificial bare cycles, with the dead hop.
- Grammar (`test_assembly.jl`): the endpoints both ways, `resolve_terminal
  → (child, "")`, the face lists, the five refusal arms, the empty key and
  the empty assembly face, the passthrough labels and routes, the explicit
  empty prefix refused, the two root refusals beside the legal bare root
  output.
- Readers: the headless whole and `"[2]"` reads, `get_face` through the bare
  chain and at a bare root, `port` with the name defaulted, `:port_shape`
  both ways, the `_spell` headless form.
- Executor: `gather_input` on both shapes, the twin's write and refusal, the
  allocation canary on `bare_ports_world` at `Float64` and `LinearizeDual`.
- Descriptor and show: the `""` names and ports at version 1.0, the bare
  cycle ends, the bare tables with no stray separator.
- Rendering (`test_diagnostics.jl`): every new message arm, in full or by
  prefix; the assertions that read `` `a`.b `` now read `` `a/b` ``.
- Library: `test_blocks.jl` reads bare ports headless and asserts the bare
  `y_types`; `LimitedIntegrator` and `DiscreteLimitedIntegrator` keep `:out`
  and `:saturation`; the `StopRequest` requester and termination record
  carry `BARE`.

## Bookkeeping, in the same commit

- `design/implementation.md`, in the patch: the entries for `assembly`,
  `blocks`, `build`, `declare`, `descriptor`, `diagnostics`, `executor`,
  `readers`, `show`, `store`, the fixtures and the utils, each with D-436 on
  its Spec line where a construct appears; the `Symbol("")` trap now covers
  ports and the slash rendering through `_at_port`; a new trap says a bare
  contract is a `Type`, so `keys`, `pairs` and `isempty` on a declaration
  throw, and the walk reads through `_contract`/`contract_fields` and the
  rest through the keyed `declared_at`/`Decls`.
- The companions, in the patch: `library_inventory.md`, `linear_blocks.md`,
  `limited_integrator_variants.md` and `handle_walk_walkthrough.md` follow
  `blocks.jl`.
- `design/pending.md`, the one delta on top of the patch: the bare
  declarations bullet retires, and the unordered list gains the loose fix,
  a contract entry that is not a type refused in the walk under
  `IllegalPortType` with an Appendix C row.
- Files to commit: `README.md`, the two `examples/` files, the sixteen
  `src/` files and fourteen `test/` files the patch touches,
  `design/implementation.md`, `design/pending.md`, the four companions.
  Never a `Manifest.toml`, and never another session's untracked files.

## Out of scope

- The non-type contract entry, queued as a loose fix.
- `GroundContact`'s named single-port contracts, and any other user material.
- The inspector's drawing of an unlabeled port, a `visual_grammar.md` note
  for the inspector's own stage.
- The kind names: the audit's (D-226).

## The cold review

One fresh Opus reviewer over the code commit, with D-436, §4.3, §5.2, §6.1,
§8.2, §8.6, §8.8, §9.1, §9.3, §9.5, §13.3, §13.9 and §14.4 read for what
they owe: open-mind stance, probe scripts in the scratchpad, "empty is
acceptable". Dimensions:

- **The docs against the tree.** Every bullet of D-436's Position and every
  sentence the two docs commits added or changed hold of the code, each
  probed; in particular the declared shape deciding the law at every return
  site (`y_state`, `y_direct`, the traced `y_direct`, the materialization
  scatter), the two root refusals with nothing piled on them, and
  `FaceDirectionConflict` against `UnknownPort` on every one-segment case.
- **The reserved name.** `Symbol("")` is spelled once in `src/`; every
  renderer of a `(path, name)` port pair goes through `_at_port` or
  `_named(…, "/")`, probed by building a model whose bare ports sit at depth
  and reading every message, the `show` tables, the descriptor and the trace
  header for a stray `/` or `.`; grep `src/` for `` `.$( `` and `"/" *` to
  find any rendering that bypasses it.
- **The hot path.** `@ballocated` 0 on every phase body of
  `bare_ports_world()` and of the library loop at `(Float64,
  LinearizeDual)`; `@code_typed` of `run_entry!` on a bare `RHSEntry` and a
  bare stage entry free of the failure path; no specialization added by
  `_keyed`, `_bundle_side` or the twin, by `specialization_counts` deltas.
- **Checkpoint and replay.** A model mixing bare and named ports round-trips
  through `checkpoint`/`restore!` and `replay!` bitwise; the fingerprint
  refuses a named twin of a bare model as `CheckpointMismatch`.
- **The grammar's edges.** A container child with a bare port (`"units/1"`
  as an endpoint), a name-transparent container, a bare port under a
  passthrough at two levels, and `get_input("")` at a primitive mount.
- **Compile cost.** The first-build latency within the figures above.
- **Naming** over every touched line; no local shares a name with a
  function its module sees.
- **Mutants on a scratch copy**, each named test going red: `_has_port`
  matching `BARE` against a named contract; `_wrong_direction` searching both
  sides; `resolve_terminal` reading `"r/"` as the bare port; `is_bare` true
  on an empty `NamedTuple`; `check_contract_names` letting an empty key
  through; `_check_root_faces` skipping the bare-input refusal when the
  output is named; the obligation loop no longer skipping `("", BARE)`; the
  probe keeping the `NamedTuple` check under a bare `outs`; the twin
  skipping `_accepts`; `_bundle_side` handing the keyed tuple; `entry_addrs`
  handing a one-entry group for `[BARE]`; `get_output`'s default leaf
  dropped; `:port_shape` folded into `:undeclared`; `_at_port` keeping the
  empty name; the descriptor writing `nothing` for a bare name; a bare block
  reverted to its named form with the test left headless. A surviving mutant
  is a missing test, or an acceptable survivor named with its reason.
- The gate green on the Julia floor `Project.toml` declares, and the
  examples runner green.

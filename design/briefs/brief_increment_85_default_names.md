# Brief: increment 85, default names for bare declarations

One code commit, which I apply from the prototype, one cold review and a
fixer if the review needs one. Drafted on 2026-10-30 at 2072d41, the docs
commit that ruled D-438 after D-437 and amended the spec, not normative. Find
passages in `design/implementation.md` by heading. The measurements and the
readings are filled from the prototype, taken on 2026-10-30 by two Opus
agents in succession (the first stopped at its context ceiling with `src/`
complete; the second finished the tests, the gate and the probes).

Design and code are peers, neither subservient. If a shape below proves
wrong at the keyboard, stop and report rather than deviate silently.

The prototype is taken at 2072d41 on a scratch worktree by one Opus agent.
Its reference for the address side is the tree before increments 83 and 84,
`git show 3e29cab:src/<file>` for the stores and `git show
5006d44:src/<file>` for the ports, where every leaf and every port had a
name; its reference for the bundle side is the tree at the tip, which D-437
and D-438 keep. The patch lands as `prototype_increment_85.patch` beside
this brief.

## What is settled

D-437, D-438 and the spec, as 2072d41 leaves them:

- A bare declaration's one entry is named by the declaration's letter. A
  bare `x_init`, `s_init` or `m_init` declares the field `x`, `s` or `m`
  (D-438); a bare `u_types` or `y_types` declares the port whose face is
  `u` or `y` (D-437). The default applies to a bare declaration only; a
  named declaration may use the letter as a key like any other name. A face
  name is never empty, since a bare port is spelled by omitting the name.
- The bundle law stands from D-435 and D-436: the bundle's `x`, `s`, `m`,
  `u`, `y` or `y_x` is the value itself under a bare declaration; a stage
  over a bare `y_types` returns the port's value, one cell, never a splat;
  `x_deriv`, `x_projection` and a handler's `x` key return the leaf itself
  for a bare `x`, `s_update` the leaf for a bare `s`, and a handler's `m`
  key or a condition's `m` payload replaces a bare `m` whole. The declared
  shape decides the law the return is held to, per declaration.
- `nothing` is the one spelling of "no state"; `(;)` is `EmptyStore`.
- Every wire endpoint is `path/face`, `"gain/y" => "integrator/u"`. A
  one-segment endpoint names a child and no port, and is `UnknownPort` with
  the child's face list in hand. The passthrough helpers treat the face as
  any other: the default label over a child `integrator` is `integrator.u`
  or `integrator.y`, so both helpers over a child bare on both sides collide
  on nothing, and `prefix = ""` labels the face `u` or `y`.
- A bare `u_types` at a primitive root is legal, the root input `u`,
  claimed, staged and traced by that name. `IllegalPortType` reason
  `:bare_at_root` retires. Both contracts bare at a primitive root are the
  faces `u` and `y`, no collision; a shared key collides as D-210 rules.
- The readers accept the headless spelling where the declaration is bare.
  When the addressed store or contract is bare, a leaf with no head, empty
  or beginning at a step, takes the letter as its head and is then resolved
  as any field or face: `get_state("integrator")`, `get_state("kf", ".P")`,
  `get_output("integrator")`, `get_output("integrator", "[2]")`,
  `port(model, path)` and its `sim` and `snapshot` forms with the name
  defaulted, `get_input()` and `get_face()` with `leaf` defaulting to `""`,
  `get_face("[1,2]")`, `get_input(".field")`. A headless leaf against a
  named store is `ReadResolution` `:store_shape`, against a named contract
  or at an assembly `:port_shape`, the names in hand. A named head against
  a bare store or port is the ordinary miss, its candidate the letter. The
  trigger is the declared shape, never the leaf or port count.
- A bare payload names the bare entry: `set(x = 1.0)` at a bare store sets
  its field `x`; `set(; u = 1.0)` at a level whose `u_types` is bare sets
  its face `u` and follows the export chain. `set` admits a bare `u`
  payload and refuses `nothing` alone, as for the stores. A bare payload
  against a named store is `ConditionResolution` `:store_shape`; a bare `u`
  payload at a level with named faces, or at an assembly, is `:port_shape`;
  a named payload against a bare store is `:undeclared_field` with the
  letter as candidate, against a bare input `:no_input_face` with `u`.
- The reserved empty name retires from the bookkeeping. No `(path, name)`
  pair carries it and no renderer drops it; a bare leaf of `plant/integrator`
  reads `plant/integrator/x`, a bare port `plant/integrator/y`. A headless
  leaf address is parsed as an address with no head, which the shape then
  supplies or refuses.
- The descriptor spells the face `"u"` or `"y"` in `name` and in a wire
  endpoint's `port`; format 1.0, schema unchanged. A bare `StopFlag` port's
  requester carries `y`.
- The library's declarations and stage bodies are unchanged.

## The shape to build

The principle: the address side sees a named field or face everywhere, and
only the bundle side knows the declaration was bare. One mechanism serves
the five letters. The walk keys a bare declaration under its letter, and the
declared shape is read the same way for stores and contracts: either a flag
beside the keyed declaration, or the shape read on demand off the declared
value; the prototype picks one and uses it for all five. `BARE`, the empty
symbol, leaves `src/` entirely.

- `src/diagnostics.jl` and `src/declare.jl`: `BARE` goes. Five constants,
  or one table from declaration to letter, spelled once and named by the
  Naming section. `_keyed(decl, fn)` keys a bare declaration under its
  letter, so `declared_at`, `bundle_names`, `event_bundle_names`,
  `store_fields`, the wire pass and the conditions' role check see
  `(x = v,)`, `(u = T,)` or `(y = T,)`. `is_bare(::NamedTuple)` retires in
  favour of the one shape test. The docstrings of the five declarations and
  of `y_state`, `y_direct`, `x_deriv`, `s_update` state the letter.
- `src/build.jl`: `Decls` carries the shape in the chosen form. The probes,
  `_keyed_return`, `_bundle_side`, the skipped `NamedTuple` and `DeadStage`
  checks, the x/s/m shape failures and `compile`'s `entry_addrs`/`input_addr`
  read it, never the keys. The products, `Outputs`'s stage lists, the
  layout, linearization's state list, the level wires and every payload
  carry the letters as ordinary names. The `CellAddr` route for a bare
  contract stays as it is.
- `src/store.jl`, `src/executor.jl`, `src/leaves.jl`, `src/tracer.jl`,
  `src/linearize.jl`: the `CellAddr` twin and the bundle arms stay; every
  `field = BARE` in a shape refusal names the letter; `_keyed_return` in the
  tracer takes the shape; the pinning entry in `linearize` reads the keyed
  form unchanged.
- `src/assembly.jl`: `_contract` returns the keyed form; `contract_fields`,
  `store_fields` and `_has_port` become plain `pairs` and `haskey` over it.
  `resolve_terminal` keeps refusing an empty path or an empty last segment
  as `:not_a_terminal`; a one-segment path, or a path equal to a container
  child's segment, resolves to the child with no port, and
  `resolve_source`/`resolve_dest` refuse it as `UnknownPort` with the empty
  port and that side's face list. `_wrong_direction`'s bare branch and the
  two-segment-at-bare arm go. `input_faces`/`output_faces` list `["u"]` or
  `["y"]`. `_labelled` and `_child_endpoint` fold back into the plain
  `prefix * sep * face` and `child_path * "/" * face`, `prefix = ""`
  yielding the face alone. `check_contract_names` keeps refusing an empty
  key, `_check_face_names` an empty assembly face. `_check_root_faces`
  loses `:bare_at_root` and the both-bare arm; its collision check runs over
  the keyed names. The root claim loop claims a bare `u_types` as the root
  input `u`, and the obligation loop no longer skips the root's bare input.
- `src/readers.jl`: `parse_leaf` returns a head of `nothing` for a headless
  address; `match_face` loses its `BARE in faces` arm; `_headless` stays as
  the test. `get_input(leaf = "")` and `get_face(leaf = "")`. One helper
  supplies the head: where the addressed store or contract is bare, by the
  shape, and the leaf is headless, the leaf becomes the letter followed by
  the authored steps, and resolution continues as for any name. The
  `GetState`, `GetDeriv`, `GetOutput`, `GetInput` and `GetFace` resolvers
  raise `:store_shape` or `:port_shape` for a headless leaf where the
  declaration is named or the level an assembly, with the names in hand;
  the arms for a named head against a bare store or port go, the ordinary
  miss carrying the letter. `StoreRead`'s field parameter is the letter.
  `port(model, path, name)` on `Model`, `Simulation` and `Snapshot` keeps a
  defaulted name meaning headless, resolved the same way.
- `src/conditions.jl`: `_payload` admits a bare `u` payload and refuses
  `nothing` alone. `_flat` files a bare payload of any letter as one entry
  with no field, which resolution maps to the letter where the store or
  input is bare, and refuses as `:store_shape` or `:port_shape` with the
  names in hand otherwise; the `(declared isa NamedTuple) == (field !==
  BARE)` check becomes that mapping. A named payload against a bare store
  or input falls through to the ordinary `:undeclared_field` or
  `:no_input_face`. The origin string stays `set(x)` or `set(u)`.
- `src/diagnostics.jl`: every `BARE` arm goes: `_face_word`, `_named`'s
  and `_at_port`'s empty-name branches, `UnknownPort`'s
  `candidates == [BARE]` arm, `IllegalPortType` `:bare_at_root` and the
  "bare input"/"bare port" site words, `FaceNameCollision`'s both-bare
  arm, `IllegalStateLeaf`'s and `IllegalStoreField`'s nameless wording,
  `ProducedByTwoStages` and `DeclaredNotProduced` on `[BARE]`,
  `ConformanceFailure`'s `BARE` field arms, `AlgebraicCycle`'s "bare
  output"/"bare input" words, `DeclarationOnWrongTier`'s bare `Pinned`
  wording, `CheckpointMismatch`'s name arm, `ReadResolution`'s `:undeclared`
  arms on `BARE` and `:port_shape`'s named-head arm, and
  `ConditionResolution`'s `BARE` field and `:store_shape` arms. The
  reworded or new arms: `UnknownPort` for a one-segment endpoint that names
  no port; `ReadResolution` `:store_shape` and `:port_shape`, one arm each
  for a headless leaf against a named store, a named contract and an
  assembly; `ConditionResolution` `:store_shape` narrowed to the bare
  payload against a named store, and `:port_shape` added;
  `ConditionNodeMisuse` `:set_payload` naming `nothing`.
- `src/show.jl`: the `Outputs` table's `BARE` arm goes; routes and
  feedthrough edges print `plant/integrator/y` through `_named(…, "/")`
  unchanged.
- `src/descriptor.jl`: `_leaf_faces` reads the keyed form, so a bare face
  is `"u"` or `"y"`; `_terminal_endpoint`'s member-alone arm goes, since a
  terminal is always `path/port`. Format 1.0, `src/descriptor.json`
  unchanged.
- `src/dataplane.jl`, `src/model.jl`, `src/sim.jl`: `port`'s defaulted
  name, as above. `src/blocks.jl`: unchanged. `src/precompile.jl`,
  `README.md`, `examples/src/longitudinal.jl`: every one-segment endpoint
  becomes `child/u` or `child/y`; grep `=> "` in each and rewrite every
  instance. The README's quoted cycle message follows the renderer.
- `test/utils.jl`: `fed(c)` wires `"in" => "c/u"`. `test/fixtures.jl`:
  `bare_loop` and `bare_ports_world` rewired; the fixtures themselves stay.
  `test_build.jl`'s `BareSink` and `BareScale` cases flip from refusals to
  builds, a root input `u` on one and the faces `u` and `y` on the other;
  its store fixtures `BareState`, `BareVector`, `BareDiscrete`, `BareModes`,
  `BareLabel`, `BareModeLabel`, `BareNamedDeriv`, `BareWrongUpdate` and
  `BareWrongModes` keep their claims with the field `x`, `s` or `m` in the
  payloads. `test/imports.jl` follows the renames.

## Measurements

Taken on the worktree at 2072d41 plus the patch, every figure re-checked by
the second agent after its last edit:

- The gate under its flags, two halves: half A (`declare assembly build
  diagnostics leaves show descriptor store executor stepper continuous
  discrete events localization failures`) 3426 and half B (`dataplane roster
  bindings devices trace lifecycle log readers conditions trim linearize
  blocks precompile`) 4031, 7457 against increment 84's 7384. The examples
  runner 77 against 77; `[sources]` resolves to the worktree's `src/`.
- The `Dual` sweep covers 120, skips 61 (the pin, unchanged) and refuses 91
  against 115, 61 and 95: the four bare-input fixtures move from refused to
  covered, `BarePoseHold` (`test_readers.jl`) is new and covered,
  `UNamedOut` (`test_assembly.jl`) new and refused.
- `bare_ports_world`: the level wires `("", :u) => ("plant", :u)`,
  `("plant", :u) => ("plant/summer", :u)`, `("plant/summer", :y) =>
  ("plant", :total)`, `("plant/loop", :x) => ("plant/spin", :u)`,
  `("plant/loop/flow", :y) => ("plant/loop/scale", :u)`;
  `terminal_producer` of `plant/summer/u` is `("", :u)` and of
  `plant/spin/u` is `("plant/loop/flow", :y)`; the layout keys include
  `("", :u)`, `("plant/loop/flow", :y)`, `("plant/summer", :y)` and
  `("ramp", :y)`, and `Layout.bare_outputs` holds the six bare primitives;
  `show` prints the routes `u → plant/u → plant/summer/u`, `total →
  plant/total → plant/summer/y` and `ramp → ramp/y`, the `Outputs` row
  `plant/loop/flow   y   —` and the feedthrough edge `plant/loop/scale/y →
  plant/loop/echo/u`; the descriptor's faces are `["u"]`/`["y"]`, a wire
  port `"u"`, `stage2 == ["y"]`, the cycle ends `a/y → b/u`; the trace
  header's root inputs are `[:u => 0.5]`, its fingerprint `root_faces =
  [:u]`, and its `addrs` and the log snapshot's layout keys carry the same
  keys as the layout, no empty name anywhere.
- `bare_world`: the decls `acc` x = 1.0, `tick` s = 0, `latch` x = [0, 1]
  and m = false, `plant` x = `(q = …)`; the layout keys ports only
  (`("acc", :y)`, `("tick", :n)`, `("latch", :latched)`, …), so `("acc",
  :x)` is not a layout key: the store letters live in the readers,
  conditions and diagnostics, never in the layout; the header's root inputs
  `[:u => 0.5, :p => 0.0]`, the fingerprint's xtypes `[Float64, nothing,
  SVector{2}, nothing, NamedTuple{q}]`; `show` lists the stage-1 ports `y`,
  `n`, `y, latched` and the event bundle `(x, m, y, t)`.
- The headless reads: `get_state("acc")` 1.0 equal to `get_state("acc",
  "x")`, `get_deriv("acc")` −0.5, `get_state("latch", "[2]")` 1.0 equal to
  `"x[2]"`, `get_state("tick")` 5 equal to `:s`, `get_state("hold",
  ".v[2]")` 2.0 and `"s.m[2,1]"` 6.0; `get_output("plant/spin")`
  `SVector(1.0, 0.0)` equal to `"y"`, `"[2]"` 0.0; `port` with the name
  left out on `Model`, `Simulation` and `Snapshot`; at a mount `get_input()`,
  `get_input(".v[1]")`, `get_face()`, `get_face("[1,2]")`; `port(root, "")`
  at a primitive root; a `BareScale` root reads `(u = 1.5, y = -3.0)`. The
  refusals: `get_state("plant")` `:store_shape` with field `nothing` and
  candidates `[:q]`; `get_state("acc", :q)` `:undeclared` `[:x]`;
  `get_state("neg")` (stateless) `:store_shape` `[]`; a one-field named
  `Sawtooth` with `get_state("c")` `:store_shape` `[:q]`;
  `get_output("plant/spin", "q")` `:undeclared` `[:y]`; `get_output("plant")`
  `:port_shape` `[:y, :power]` and `get_output("acc")` (one named port)
  `:port_shape` `[:y]`; at an assembly `:port_shape` with `declares =
  :assembly_face`, `[:total, :spin]` and `[:u]`; at named primitives
  `:input_face [:u]`, `:output_port [:y]`; `port` with no name at a named
  component `ArgumentError`. The conditions: `set(x = …)` lands and the
  duplicate-leaf check catches `set(x)` beside `set(x.x)`; a bare payload at
  named `plant` `:store_shape [:q]`; named payloads at bare stores
  `:undeclared_field [:x]` and `[:m]`; `set(u = …)` at `plant/summer`
  reaches the root `u`; `:port_shape [:u]` at `plant`, at the root assembly
  and at `neg`; `(zz = 1.0,)` at a bare input `:no_input_face [:u]`; `set(u
  = nothing)` `ConditionNodeMisuse` with payload `:u`.
- `grep -c BARE src/*.jl` is 0 in every file; `Symbol("")` is absent from
  `src/`.
- Allocation: `@ballocated` 0 on `sweep_1`, `sweep_2`, `rhs`, `ticks`, both
  arities, and every event and projection callable, on `bare_ports_world`,
  `bare_world` and the library loop `Step → Junction(-) → FirstOrderLag →
  Integrator → UnitDelay → SumJunction`, at `Float64` and `LinearizeDual`.
  `@code_typed run_entry!` on `int`'s `RHSEntry` is 97 statements and on
  the `Junction`'s stage-2 `StageEntry` 94, unchanged, neither with
  `ConformanceFailure`, every throw `throw_boundserror`; `int`'s stage-1
  outputs are `CellAddr{Float64,1}`. The four `specialization_counts`
  testsets pass at delta 0.
- Compile cost, fresh `--startup-file=no` processes, three runs each, the
  tip measured side by side from a `git archive` of 2072d41: precompile with
  the workload 12.64–12.86 s at the tip, 13.04–13.06 s with the patch;
  `using Redstone` cached 0.224–0.228 s against 0.224–0.257 s; the first
  `build(workload_loop())` 13.74–14.46 ms against 13.74–14.98 ms; the second
  1.17–1.21 ms against 1.16–1.27 ms with one outlier at 1.67. The precompile
  is 2–3 % slower; the builds show no regression. The machine ran slower
  than when increment 84's figures were taken, hence the side-by-side.
- Churn: 41 files, +1263 −1004. The large ones: `test_diagnostics.jl` 241,
  `test_blocks.jl` 220 (208 of them the endpoint rewrite), `readers.jl` 200,
  `implementation.md` 199, `diagnostics.jl` 191, `test_assembly.jl` 145,
  `build.jl` 138, `assembly.jl` 136, `test_readers.jl` 123, `declare.jl`
  101, `test_build.jl` 84, `conditions.jl` 75; `blocks.jl` 16, docstrings
  only; `test_trace.jl` 40, new testset.

## Readings the prototype took

The shape: the declared shape is read on demand off the declared value, for
all five letters, since `Decls.x`, `Decls.s`, `m_init`'s value, the readers,
the conditions and the generated code already hold the store's value, whose
type is the shape; a flag would be a second mechanism beside it, and reading
the contracts the same way gives one for all five. `is_bare(declared) =
!(declared isa Union{Nothing,NamedTuple})` and `_keyed(declared, letter)` in
`declare.jl`, `default_name(::typeof(x_init)) = :x` and its four siblings,
`keyed_ins`/`keyed_outs` over `Decls.ins`/`Decls.outs` (typed `Any`, the
contract as declared), `contract_at` returning the declared shape and
`declared_at`/`_contract` the keyed form. Allocation and statement counts
cannot tell the two forms apart; simplicity decided it.

The readings on seams the docs leave open, each with the prototype's
recommendation; the ones ratified land as a docs commit before the code:

1. A one-segment endpoint's port is `nothing`, not the empty symbol, since
   `Symbol("")` would keep a reserved empty name in `src/`; the public
   `resolve_terminal(asm, "s")` still returns `(comp, "")`. Recommendation:
   keep, and let §8.6 say the port is `nothing`.
2. `port(x, path)` with the name left out resolves through a new
   `Layout.bare_outputs::Set{String}` (`port_addr` in `build.jl`), since a
   `Snapshot` holds only the layout, so the shape must be an address fact
   there. A left-out name at a named component throws `ArgumentError`; no
   refusal is ruled for it. Recommendation: keep both and rule the refusal.
3. `ReadResolution` `:port_shape` at an assembly carries `declares =
   :assembly_face`, a payload value Appendix C does not list, so the renderer
   can tell the assembly arm apart. Recommendation: list it.
4. A headless read against a stateless store (`nothing`) is `:store_shape`
   with an empty candidate list, not `:undeclared`: anything not bare refuses
   by shape. Recommendation: keep.
5. `CEntry.field` and `ConditionResolution.field` are `Union{Nothing,Symbol}`;
   a bare payload no bare declaration takes carries `nothing`, rendered "the
   bare `x` payload at `a/b`". Recommendation: keep.
6. `NonfiniteState` on a bare scalar state reported `leaf = ""`; `_nonfinite`
   in `model.jl` now reads the keyed form, the leaf `x` or `x[2]`, the
   renderer's empty-leaf arm gone, by D-438's "no renderer drops it".
   `model.jl` was not in the brief's shape section. Recommendation: keep.
7. `ProducedByTwoStages` and `DeclaredNotProduced` render the path through
   `_at_path`, so a root reads "the root component" rather than "``".
8. A bare store's field renders with its letter, `s.s` and `x.x` in
   `TapResolution`'s text, consistent with D-438.
9. `blocks.jl` changed despite "unchanged": five docstring sentences said "a
   wire names it by the block's path alone"; declarations and bodies
   untouched. `examples/test/test_longitudinal.jl` asserted the requester
   port `=== Symbol("")`, now `:y`; it joins the files to commit.
10. The `:u`/`:y` literals that remain in `src/` are payload or bundle
    literals inside generated or shape-specific code (`field = :x` in
    `leaves.jl`, `field = :y` in `store.jl`, `NamedTuple{(:y,)}` in
    `_keyed_return`); the shape helpers spell the letter once through
    `default_name`. `test_build.jl`'s `DECLARATION_LAYER` does not list
    `_keyed`, `keyed_ins`, `keyed_outs`, `is_bare` or `default_name`.
    Recommendation: the cold review decides both.
11. `WalkingFaceAtFrozenEntry.leaf == ""` is the within-port leaf of a scalar
    face, whose face is named; not a bare-name case, left as is.

Stale passages the docs commit corrects: Appendix C's "port name (empty on a
bare contract)" under `IllegalPortType`, `ProducedByTwoStages` and
`DeclaredNotProduced` (spec lines 14413, 14439, 14444 at 2072d41); §13.9's
"the empty string for a bare port" under `outputs` (11553); §13.7's code
comments "no face" and "addressed by the component path" (10789, 11159,
11215–11216).

## What the tests pin, by property

- Shape and bookkeeping (`test_build.jl`): the keyed decls `(x = v,)`,
  `(u = T,)`, `(y = T,)` with the shape recorded; the stage lists `[:y]`;
  the layout, alias and products at three scalars; the run values unchanged
  from increments 83 and 84. `ProducedByTwoStages [:y]`,
  `DeclaredNotProduced [:y]`, a `NamedTuple` against a bare port as
  `ConformanceFailure` at `y`, a `NamedTuple` against a bare `x` as
  `ConformanceFailure` at `x`. The tracer's bare cycles with the dead hop
  `("m", :y, :u)`.
- Grammar (`test_assembly.jl`): two-segment endpoints at bare sides both
  ways; the one-segment endpoint as `UnknownPort` with the empty port and
  the face list, at a bare child, a named child and an assembly; the face
  lists `["u"]`/`["y"]`; the passthrough default labels `integrator.u` and
  `integrator.y` with both helpers over one child building; `prefix = ""`
  labelling `u`; the empty key and the empty assembly face still refused;
  the bare root input `u` claimed and the both-bare root building.
- Readers (`test_readers.jl`): headless whole, `"[2]"` and `".P"` reads on
  bare stores and a bare output; `get_state("int", "x")` naming the field;
  `get_input()` and `get_face()` at a bare primitive mount and root;
  `get_face("[1,2]")` and `get_input(".field")`; `port` with the name
  defaulted on all three homes; `:store_shape` for a headless leaf on a
  named store; `:port_shape` on a named primitive and on an assembly, input
  and output sides; the ordinary miss with candidates `[:x]` or `[:y]` for a
  wrong head; and the trigger pinned on shape, a one-field named store and a
  one-named-output component each refusing a headless read.
- Conditions (`test_conditions.jl`): `set(x = 1.0)` on a bare store and
  `set(x = (; x = 1.0))` naming its field, both landing; `set(; u = 1.0)` at
  a bare primitive level reaching its root input; `:store_shape` for a bare
  payload on a named store; `:port_shape` at a named level and at an
  assembly; `:undeclared_field` with candidate `x` and `:no_input_face` with
  candidate `u`; `set(; u = nothing)` still `:set_payload`; the
  duplicate-leaf check across a bare and a named spelling of one leaf.
- Descriptor and show: `"u"`/`"y"` names and ports at 1.0, round-tripped
  against `src/descriptor.json`; the `Outputs` row, the routes and the
  state names in `show` and the log.
- Rendering (`test_diagnostics.jl`): every removed arm's assertion goes;
  the reworded `UnknownPort`, the three `:store_shape`/`:port_shape`
  renderings and the `set_payload` message asserted in full or by prefix.
- Library (`test_blocks.jl`): reads stay headless; the `StopRequest`
  requester and termination record carry `:y`; `linear_blocks`' `"[1]"` tap
  resolves to `x[1]`.

## Bookkeeping, in the same commit

- `design/implementation.md`: the entries for `assembly`, `build`,
  `conditions`, `declare`, `descriptor`, `diagnostics`, `executor`,
  `leaves`, `linearize`, `readers`, `show`, `store`, `tracer`, the fixtures
  and the utils, each with D-437 and D-438 on its Spec line where a
  construct appears and D-435 and D-436 removed; the `Symbol("")` trap
  retires; the `is_bare` trap becomes the shape's; a new trap says the
  headless sugar triggers on the declared shape, never on a name list of
  length one.
- The companions whose wiring examples carry a one-segment endpoint follow
  the grammar; grep `=> "` under `design/companions/`. `design/` reports
  stay as they are.
- `design/pending.md`: nothing retires and nothing is added.
- Files to commit: `README.md`, `examples/src/longitudinal.jl`,
  `examples/test/test_longitudinal.jl`, the `src/` and `test/` files the
  patch touches, `design/implementation.md`,
  `design/companions/handle_walk_walkthrough.md`. Never a `Manifest.toml`,
  and never another session's untracked files.

## Out of scope

- The non-type contract entry, pending's loose fix, its own commit.
- `GroundContact`'s named single-port contracts, and any other user material.
- The inspector's rendering of the `u`/`y` label, the inspector's own stage.
- The kind names: the audit's (D-226).

## The cold review

One fresh Opus reviewer over the code commit, with D-437, D-438, §4.3,
§5.2, §6.1, §7.1, §7.3, §8.2, §8.6, §8.8, §9.1, §9.3, §9.5, §13.3, §13.9,
§14.1, §14.2, §14.3, §14.4 and §14.9 read for what they owe: open-mind
stance, probe scripts in the scratchpad, "empty is acceptable". Dimensions:

- **The docs against the tree.** Every bullet of D-437's and D-438's
  Positions and every spec sentence the two docs commits changed hold of
  the code, each probed; in particular the bundle law at every return site,
  the bare root input `u` through claim, staging and trace header, and the
  headless sugar at every reader and condition form the entries name.
- **The reserved name.** `BARE` is absent from `src/`, and no `(path,
  name)` pair anywhere carries an empty name: build a model whose bare
  stores and ports sit at depth and read every message, the `show` tables,
  the descriptor, the log tree and the trace header for an empty name or a
  stray separator.
- **The trigger.** The sugar fires on the declared shape alone: a one-field
  named store and a primitive with one named output each refuse a headless
  read, and a named declaration whose key is a letter is addressed as the
  author's.
- **The hot path.** `@ballocated` 0 on every phase body of
  `bare_ports_world()`, `bare_world()` and the library loop at `(Float64,
  LinearizeDual)`; `@code_typed` of `run_entry!` on a bare `RHSEntry` and a
  bare stage entry free of the failure path; no specialization added, by
  `specialization_counts` deltas.
- **Checkpoint and replay.** A model mixing bare and named stores and ports
  round-trips through `checkpoint`/`restore!` and `replay!` bitwise.
- **The grammar's edges.** A container child with a bare port (`"units/1/u"`
  as an endpoint), a name-transparent container, a bare port under a
  passthrough at two levels, both helpers over one bare child, and
  `get_input()` at an assembly mount.
- **Compile cost.** The first-build latency within the figures above.
- **Naming** over every touched line.
- **Mutants on a scratch copy**, each named test going red: `_keyed` keying
  a bare `y_types` under `u` or a bare `s_init` under `x`; the shape read
  from the keyed form's length; `_keyed_return` reading the keys instead of
  the shape; the sugar triggering on a name list of length one;
  resolution mapping a bare payload at a named store or an assembly to the
  letter; `_payload` admitting `nothing` for `u`; `_labelled` dropping the
  separator; `_check_root_faces` keeping the both-bare collision; the
  obligation loop skipping the root's `u`; `resolve_terminal` reading a
  one-segment path as the face `u`; `_terminal_endpoint` emitting `port =
  ""` for a member; `get_face`'s default leaf dropped; `:store_shape` or
  `:port_shape` folded into `:undeclared`. A surviving mutant is a missing
  test, or an acceptable survivor named with its reason.
- The gate green on the Julia floor `Project.toml` declares, and the
  examples runner green.

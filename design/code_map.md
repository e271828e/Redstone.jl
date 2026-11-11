# Code map

One entry per file of `src/` and `test/`, in alphabetical order by path:
which constructs live where, and the sections they answer to. For more, read
the file itself and the sections it cites. The rules the code is written to
are `rules/code_rules.md`; what the code still owes the spec is `pending.md`.

An entry names constructs and cites their sections. It may also state a fact
that spans files, which a reader of the one file cannot see. How a construct
behaves belongs in its docstring or in a comment at the site, never here. An
increment edits an entry only when a construct appears, moves or goes, or
when its citations change.

## What is real here

### `src/Redstone.jl`

The package module: the dependencies and the include order the other files load
in: leaves, diagnostics, declare, assembly, store, executor, build, tracer,
readers, deployment, dataplane, checkpoint, trace, roster, bindings, control,
devices, conditions, model, stepper, frame, trim, linearize, sim, show,
descriptor, blocks, precompile.
The model layer sits between the executor layer and the runtime, by the rule
in the `src/model.jl` entry.

### `src/assembly.jl`

- Class by declaration shape `classify`, and `_contract`, which reads a
  contract at nominal with its pins stripped (D-263).
- Children and containers, with their collision family.
- Paths and §6.1's one-level rule.
- Endpoint and face resolution, with the root's face invariants. The
  resolvers return routes, the hops `(path, face)` from an endpoint down to
  its terminal: one for a producer, one per consumer (§13.7).
- The flatten pass runs under one structure-step barrier (D-261):
  - `StructureDraft` accumulates the per-component columns the `Structure` is
    built from, among them the tiers, the rate chains and the fold's `Timing`s;
  - resolvers record into the step's list;
  - `Structure.root_types` holds the root-input types the wire pass fixes
    ahead of construction;
  - as the step's last act, the artifact is built complete as rows at the
    barrier, with one `ComponentEntry` per primitive in walk order and one
    `Anchor` per `Absolute` entry.
- `LevelEntry` and `Child`, one row per assembly in walk order with its
  children and its declared wires, the accessor `membership` on a `Child`, and
  `terminal_producer`/`face_routes` over them (D-315).
- The sample-time fold.
- The shadowing check ahead of `classify` in the walk (D-246).
- The store-shape read ahead of the classifier in the walk, `check_store_form`,
  which refuses `(;)` as `EmptyStore` and reads that primitive no further
  (§8.2, §9.1, D-438).
- The tier classification `classify_tier` (§8.2), in its own section ahead
  of the walk. It records what it finds instead of throwing, the walk reads
  the tier beside the class, and the store decides the tier. It records
  `StatelessWithoutOutputs` and runs the pinned-entry check, both from D-263,
  and holds `IllegalPortType`'s nested-marker arm (D-265) and its not-a-type
  arm, a contract declared `nothing` kept as one bare entry for it, both on
  both tiers (§8.2).
- Beside it the shape helper `store_fields`, a store's pairs in the keyed form,
  a bare store's one pair under its letter `x`, `s` or `m` and none for
  `nothing`, which build.jl reuses (D-438). The store isbits check
  `check_stores` (§7.3, D-231) and the state-leaf vocabulary check
  `check_state_leaves` (§7.1, D-094) iterate it, all taking the component
  unspecialized (D-289).
- The component frame around the walk's two branches (D-248).
- `_contract`, a contract at nominal in the keyed form, a bare contract's one
  port under its default face `u` or `y`, read by `pairs` and `haskey` as any
  contract (§8.6, D-437). `check_contract_names` refuses an empty contract key
  as `FaceNameIllegal` `:empty`, and `_check_face_names` an empty assembly
  face; the root check `_check_root_faces` collides the keyed names, so two
  bare contracts collide on nothing, and the root claims a bare `u_types` as
  the root input `u` (D-210, D-437).
- §13.3's `resolve`/`resolve_terminal`/face-list primitives `input_faces` and
  `output_faces`. `resolve_terminal` reads the child segment alone, a
  container element's included, as a child with no port, its name `nothing`,
  which `resolve_source` and `resolve_dest` refuse as `UnknownPort` with that
  side's faces; the face lists list a bare contract as `u` or `y` (D-437). The walk records each assembly's evaluated face lists in
  `StructureDraft.faces`, and `flatten_tree!` binds them as `WALK_FACES` around the
  walk, so the primitives read them once per call (Appendix C) and evaluate a
  body only outside a walk. Beside it `flatten_tree!` binds `WALK_CHILDREN`, a
  fresh cache of each assembly's child list, so endpoint resolution derives a
  list once per walk rather than once per endpoint (§9.7).
- The service walk `resolve_authored` runs from the root's level row and
  follows the structure's children, refusing no traversal past a generically
  held child (D-414). It searches
  `Structure.levels`, each assembly's children as the walk derived them, so a
  service derives none again. A path with no row is a primitive. The walk
  sits in the file's last section, after the `Structure` it reads.
- §8.8's `input_passthrough`/`output_passthrough`, with the three exclusive
  selectors `except`, `only` and `select`, and `EmptyFaceSelection` through the
  channel (D-251). A bare face is labelled as any face (D-437).
- The walk, the class and child readers, the resolvers and the build
  primitives take components, assemblies and the root unspecialized, and
  `_children` reads a container through `_elements` and `_element_keys`, so a
  new component or root type compiles none of them again (§9.7, D-289). A
  function that takes a connection or its endpoint tuple, as `_fanout` does,
  still compiles once per connection type.

Spec: §6.1, §7.1, §7.3, §8.1, §8.2, §8.5–§8.8, §9.1, §9.2, §9.7, §13.1, §13.3,
§13.7, §14.2, Appendix C, D-061, D-094, D-130, D-171, D-207–D-212, D-229,
D-231, D-236, D-246, D-248, D-251, D-253, D-261, D-263, D-265, D-289,
D-315, D-437, D-438.

### `src/bindings.jl`

- `TableBinding`.
- `map_input`, generated over the datum's keys with one `_map_channel` call
  each, and the conditioning helper `_condition`.
- The binding reads' contract checks, and `_compile_binding_reads`, which
  resolves the reads through readers.jl's `_compile_reads` for a table source
  at the root (D-406).

Spec: §11.2, §11.4, §11.6, §14.4.

### `src/blocks.jl`

The standard component library, the submodule `Redstone.Blocks`:

- `Junction`, with the aliases `SumJunction`, `Or`, `And` and, at the fold
  `pack`, `Pack` (D-311, D-313).
- `Unpack`, its output names from the generated `unpack_names`, and `Switch`
  (D-313).
- `Fn`, the one-input `Junction` with its input bare, its `f` a field typed
  by a parameter; a `Pinned` output is the struct `Freeze`'s spelling
  (D-033, D-266, D-312, D-313).
- `Fields`, its outputs the field names and types of `V`, and `Select`, its
  dispatch the generated chain `selected_input` over `instances(K)` passed
  as a `Val` (D-276, D-308, D-313).
- `Source`, pinned, its `f` fed the time with one `Dual` layer dropped (D-312,
  D-313).
- `Constant`, `UnitDelay` and `Freeze` (D-312).
- `StopRequest` (D-316).
- The keyword-shape helpers `as_static`, `shape_zero` and `broadcast_keywords`,
  which every block whose keywords share `V` reads them through,
  `GaussianWhiteNoise` and the PID's `shape_type` included (§13.7). `as_static`
  makes the `SArray` of its size of an array keyword of any kind, and warns once
  past `STATIC_WARN_LENGTH` elements.
- `Delay{V, K, Taps}`, its taps form `Taps = true` naming the output side
  `(y, taps)` and reading the ring backwards from the cursor,
  `DiscreteIntegrator{V, R}`, `DiscreteLimitedIntegrator{V, R}` with the
  helper `saturation_code`, `RateLimiter` and `Backlash` (D-313, D-437). The
  reset form `R = true` of both integrators is the level reset in `s_update`
  (§5.3).
- `GaussianWhiteNoise`, with the helpers `splitmix` and `gaussian` (D-231,
  D-313).
- `Integrator{V, R}` and `LimitedIntegrator{V, L, R}`, their reset form
  `R = true` adding the `Bool` input `reset` and one non-localized event
  (D-141), over the helpers `reset_ports` and `signal`, shared with the
  discrete pair, and `reset_guard`; `LimitedDoubleIntegrator{V, L}`, the
  stop on the double integral over the named state `(q, v)`, its four events
  under `limit_events` as `LimitedIntegrator`'s; `FirstOrderLag`, `Step`,
  `Sequence`, `Relay` and `Comparator` (D-313).
  `Step`, `Sequence`, `LimitedIntegrator`, `LimitedDoubleIntegrator` and
  `Comparator` each ship two detection policies, localized and
  non-localized, selected by the type parameter `L` (D-179).
  `LimitedIntegrator`, `LimitedDoubleIntegrator`, `Relay` and `Comparator`
  are over `Float64` and static vectors, with `Int8` modes and, over a vector,
  events generated per component; the fall of `Relay` and `Comparator` is
  strict.
  `LimitedIntegrator` and `LimitedDoubleIntegrator` publish their mode as the
  output `saturation`, typed by the helper `saturation_type`, shared with
  `DiscreteLimitedIntegrator` and the PID.
  Both check their limits through `check_limits`, as
  `DiscreteLimitedIntegrator` does, and write their hit guards over
  `first_nonzero`.
- `ControllerBlock{Hold, Track}`, carrying `axis_ports`, `gated_error` and
  `correction_reference`, over `PIDBlock{V, Hold, Track, Fixed}` over `Float64`
  and static vectors, carrying `signal_ports`, `u_types`, `y_types` and
  `parameters`, over `PID` and `DiscretePID`, with the marker `AsPort`, the
  roster `PID_PARAMETERS` and the helpers `shape_type`, `fixed_parameters`,
  `check_tracking`, `check_output_limits`, `check_time_constant`, shared with
  the trackers and `FirstOrderLag`, and `channel_type` (D-313, D-383, D-384,
  D-385).
- `LQRTrackerBlock{NX, NU, NZ, Hold, Track, Fixed}`, a `ControllerBlock`,
  carrying `signal_ports`, `u_types`, `y_types` and `parameters`, over
  `LQRTracker` and `DiscreteLQRTracker`, with the roster `LQR_PARAMETERS`, the
  helpers `parameter_types`, `tracker_sizes` and `check_shapes`, and
  `fixed_parameters`, `check_tracking` and `check_output_limits` shared with the PID (D-383, D-384,
  D-385).
- `StateSpace` with the helper `static_system`, over scalar or `SVector` ports
  by its matrix shapes, its feedthrough class the type parameter `FT`, and
  `TransferFunction`, realized by `realize` into a held `StateSpace`
  (D-313). The helpers `coefficients_from_roots` and `transfer_coefficients`
  resolve the zero-pole spelling for the three transfer functions, the
  discretized one forwarding its keywords to the continuous constructor.
- `DiscreteLinearBlock{FT}` with the accessors `held`, `realization(c, Δt)` and
  `initial_state`, the held system's `s0` or `x0`,
  over `DiscreteStateSpace`, `DiscreteTransferFunction`, `DiscretizedStateSpace`
  and `DiscretizedTransferFunction` (D-313).
- The anonymous assembly `Group`, with `_entries` (D-184).
- Every block with one state field or one mode declares it bare, and every
  stateless block declares `nothing` (§8.2, D-438). Every block with one input
  or one output declares that contract bare, its face `u` or `y`, the
  `Junction`'s output, both sides of `Fn` and the inputs of `Fields`, `Unpack`, `LimitedIntegrator`,
  `LimitedDoubleIntegrator` and `DiscreteLimitedIntegrator` included; a side
  with two or more ports stays named, as do `Fields`'s outputs at any count,
  since the fields name them (§13.5, §13.7, D-437).

It reaches the parent through its import list alone, as a user's component
file does (D-313). Nothing in the package depends on it, so `src/Redstone.jl`
includes it last.

Spec: §2.3, §5.4, §5.5, §6.2, §8.1, §8.5, §10.4, §13.5, §13.7, D-141, D-179, D-184, D-211, D-231, D-311, D-312, D-313, D-316, D-383, D-384, D-385, D-437, D-438.

### `src/build.jl`

- `build` owns the structure step's one throw.
- `build` binds the warning channel once around its three steps (D-250):
  - a `DiagnosticError` leaving the build is rewrapped with the warning list
    and with the `Structure` when the throw left past the structure step, a
    requested activation's included (D-434); any other throw passes unchanged;
  - a completed build logs each warning once at return.
- `build` and the probes take components and the root unspecialized, and
  each per-component frame reads the instance inside rather than capture it,
  so a new component or root type compiles none of them again (§9.7, D-289).
- The wire pass (D-236) checks both type clauses, at `Float64` and at the
  marker scalar. It retypes the contracts at each. It also fixes the
  root-input type, which has two refusals, `AbstractAtRoot` and
  `RootInputTypeConflict`.
- The probe and the event probe. The dead-stage rule applies at both stage
  probes, and `cell_layout` raises `MissingProbeValue` (§9.3).
- `ProbeTag`/`ProbeDual`, the canonical probe scalar (§9.4).
- The probe's embedding of products, `_embed`.
- `_probe_direct!`, shared with the classifier's prefix probe.
- The return checks `_check_derivative`, `_check_update`, `_check_state_write`
  and `_check_handler` hold a return to the declared shape, bare or named,
  a bare store's failure on its letter (§9.5, D-438).
- A bare contract in the bookkeeping: `Decls` holds each contract in its
  declared shape, a bare one its one type, which `is_bare` reads, and
  `keyed_ins`/`keyed_outs` give the keyed form, a bare port under `u` or `y`.
  The products are keyed; `_keyed_return` keys a stage's bare return by the
  declared shape and `_bundle_side` hands a bare side's bundle field its
  value, so the stage probes hold a bare return to its port's type alone
  (§5.2, §9.3, D-437).
- The feedthrough graph, the builder's scratch. Each edge keeps its port and
  face.
- Kahn's execution order, written into the `Outputs` (D-261):
  - one `ComponentOutputs` row per component, in walk order, holding its path
    and the two stage name lists;
  - the order beside the rows, as `ci`s;
  - `_ports`, which concatenates a row into the products' order.
- At a stall, the SCC decomposition into one `AlgebraicCycle` per cluster
  (§13.8, D-012).
- The layout, with the root-input meet (D-168, D-236), `IllegalPortType`'s
  three layout arms (D-237) and its two stop-request arms (D-316), and the flat
  `x` ranges every offset is read from (D-261). `Requester` is one entry of the
  layout's `requesters`, the roster of the `StopFlag` buffer (D-316). The
  layout's `bare_outputs` are the primitives whose `y_types` is bare, which
  `port_addr` reads for `port`'s defaulted name (D-437). Its `component_paths`
  hold every component's path, assemblies and the root included. `refuse_path`
  beside it refuses a value read's path naming none of them as
  `PathResolution` (D-440). Its alias
  pass enters assembly output faces alone, from `terminal_producer`;
  `compile`'s input group reads a primitive input face's address as its
  terminal producer's (D-210, D-315).
- The nominal evaluation `_nominal`. It returns the `Outputs`, the `Events` and
  the nominal activation. The `Events` hold one `ComponentEvents` row per
  component, with its path, policies and bundle.
- `_activate`, for every other scalar.
- The `Build`, holding the structure, the outputs, the events, one activation
  dictionary and `warnings`. `activation` reads that dictionary, and
  `warnings(::Build)` sits beside it.
- `compile`, which turns the deployment's `Schedule` into an `Executor{T}`.
  It derives the per-component gates from the schedule's rows (D-261). The
  executor takes its name lists from the products.
  - An executor is one activation's buffer set, with the bodies closed over
    it. Each set has one owner. `evaluate!`, `_round!` and `apply!` run on it.
  - The executor owns its stepper, its arrival buffers, the `chunk_size` it
    was compiled at and the localized-event key (D-256). `compile` builds the
    stepper from the `algorithm` keyword.
  - The event set takes the phase bodies' chunk size (D-289).
  - An entry's side is `entry_addrs`' one `CellAddr` where the side is bare,
    by the declared shape, a `NamedTuple` group otherwise (D-437).

Spec: §5.3, §5.5, §13.8, §6.1, §7.1, §7.3, §8.2, §9.1–§9.4, §9.7, §10.4, §13.2,
§13.5, D-012, D-051, D-166, D-179, D-208, D-210, D-229, D-235, D-236, D-237,
D-248, D-250, D-252, D-253, D-256, D-261, D-263, D-289, D-315, D-316, D-437,
D-438.

### `src/checkpoint.jl`

- `ModelState{T}`, a model's state as one value (D-274, D-319): the flat
  buffer, the `s` and `m` stores, the signal table with every cell buffer
  copied, the guard priors, the clock's `t` and `t₀` (a `Float64` like
  `Δt_frame`), and the fingerprint, the `Deployment` and the structural
  layout `Fingerprint`.
- `Checkpoint`, a `ModelState{Float64}` beside the run's frame index and
  boundary ordinal, with no scalar parameter (D-317, D-319).
- `Fingerprint` holds the cell sizes, the root-input faces, the component
  paths and the store types, and what a copy by position relies on: each
  component's `x` type, every cell's address with its type and offsets, and
  the event list, taken from the list that sizes the priors.
- What stays out: the derivative buffer, the arrival pair and the
  localization samples, which every frame rewrites before reading them, the
  cursor and the periphery.
- `_restore_state!` on an executor, taking the state, behind `linearize`'s
  default operating point and under the model's restore door. It is strict
  about the scalar. `_restore_stores!` is the part of it that writes the `s`
  and `m` stores, shared with `linearize`'s seeded half.
- `_detach`'s two methods, the state's and the checkpoint's over it.
- The mismatch namers behind `_check_checkpoint!` (§12.7): `_check_addresses!`
  over the table's addresses, and `_walk_deployment!`, which names what a
  deployment `==` refused, the seven parameters and the schedule's rows and
  scopes by path and column.
- The model-level functions, `_fingerprint`, `checkpoint(model)`, the
  fingerprint check `_check_checkpoint!` and the model's restore doors, are
  model.jl's (D-317, D-319).

Spec: §11.5, §12.6, §12.7, §14.10, D-038, D-254, D-273, D-274, D-317, D-319.

### `src/conditions.jl`

- `condition`, the condition methods' generic (§14.2, Appendix B).
- The condition algebra `set`, `at`, `combine` and `override`. `at`
  also lifts read sets, joining the prefix to their mount chain; trim.jl
  and linearize.jl add its methods for problems and tap sets (D-277).
- One collecting pass behind both ways of applying a plan. Each `at` prefix is
  walked from its authoring level (§13.3). The two ways are:
  - `resolve_condition`, for values, its merge bases the declared defaults
    or the stores a door hands it (D-429), a bare store's base replaced whole
    by `_store_overlay`, shared with `StoreWrite` (D-438);
  - `compile_plan`, with lenses run by `walk_steps` (readers.jl),
    `SpecializedPlan`, whose writes and prefixes `apply!` walks as generated
    unrolls, and `ConditionShapeDrift`.
- A bare payload of any letter: `_payload` refuses `nothing` alone, and
  `_flat` files a bare payload under the letter, by `_bare_field`, where the
  store or input it names is bare, or under no field, which resolution
  refuses as `:store_shape` and flattening as `:port_shape`, the names in hand,
  the role `:assembly_face` at an assembly (§14.2, §14.3, D-437, D-438). The
  letter is `_store_letter`'s, the register's declaration's `default_name`.
- Root-input totality `assert_total`.
- `apply!` and `init!` on a model are model.jl's, and `apply!`'s forwarding
  method on the simulation is sim.jl's.

Spec: §9.5, §13.1, §13.3, §14.1–§14.6, §14.9, Appendix B, D-063–D-068,
D-117, D-130, D-204, D-205, D-207, D-226, D-277, D-315, D-429, D-437, D-438.

### `src/control.jl`

- The control plane (§12.1) and the pacer riding on the control plane (§10.7).
- `Control` keeps:
  - the stop word, with the pause flag beside it;
  - the two pacing knobs `pace` and `margin`, which the loop reads only at
    frame top (D-269);
  - the running flag `running` (D-317);
  - §12.3's `counter` and condition `wake`, which devices.jl's
    `wait_next_snapshot` waits on;
  - the shutdown cap `join_timeout` (D-256).
- `_request_stop!` is the stop word's one write path (D-203):
  - the first CAS from empty wins;
  - the notify wakes a paused loop.
- `wait_resume!` is the pause block (§12.1, D-268):
  - `resume!` and every stop request wake the block;
  - the tail's `_finish!`, defined in sim.jl, clears the pause flag;
  - the block returns whether it parked.
- The two lifecycle gates `assert_stopped` and `assert_configurable` are
  sim.jl's.
- The `Pacer` holds one `run!` call's schedule and counters. It is never a
  field of anything. `anchor!`, `reanchor!` and the monotonic wall clock
  `_wall_now` sit beside it.
- `wait_deadline!` is §10.7's pacer wait. It runs the hybrid sleep-then-spin
  toward the deadline off the anchor, and `margin` is the one knob of the
  sleep-then-spin. The coarse phase is a task-yielding `sleep` (§12.2, D-027)
  and an unmask point (§12.4), and the spin never yields but takes a safepoint.
- `wait_deadline!` leaves an overrun as debt, counted where the debt grew,
  and re-anchors the pacer in two cases (D-021, D-269):
  - once the debt passes `5·h/p`, a re-anchor forgives the debt and reports
    `DebtReanchor` into the loop's cell;
  - a live pace change re-anchors forward, `Inf` included.
- The copy `PacerStatus(::Pacer)`. The `PacerStatus` record is dataplane.jl's.

Spec: §10.7, §12.1–§12.4, §12.6, D-021, D-027, D-203, D-255,
D-256, D-268, D-269, D-317.

### `src/dataplane.jl`

- The compiled writer `Writer` and `Batch`, and the staging cells.
- The per-writer drain `_drain!`, which sim.jl's `drain!` reaches through the
  roster's thunks. It returns whether a batch reached the table, the report
  the frame's freshness reads (§10.3, D-447).
- The diagnostic cells, one per writer and one on each model for its frame
  (D-317). The channel's kinds are diagnostics.jl's.
- `KINDS`, the closed set's one home. The union `DiagValue` and `KindCounts`'
  field order are built from it.
- Snapshots, and the log with re-decimation. The log stores the box
  publication made, which `log!` takes `@nospecialize`d beside its concrete
  type, so the two `boundary` reads stay static (§9.8).
- `gather_reads` over a snapshot, a compiled `Reader`'s gather over the
  snapshot's store, here and not in readers.jl for the include order (§11.2,
  §14.4, D-406).
- The published `FrameworkStatus`, which every snapshot carries. It holds the
  per-writer records `WriterStatus` and, beside them, the pacer's frozen
  `PacerStatus` (D-269):
  - the `PacerStatus` reads `Inf` and zeros where no pacer runs;
  - the copy off a live `Pacer` is control.jl's.
- `ResidueRecord`, one writer's share of the tail residue, which sim.jl's
  sweep builds and the termination record holds (§13.5, D-203).

Spec: §10.3, §10.7, §11.1–§11.4, §11.8, §12.2, §12.4, §12.6, §13.2, §13.5, §14.4, D-023,
D-027, D-038, D-137, D-203, D-250, D-255, D-269, D-316, D-317, D-406, D-447.

### `src/declare.jl`

The declaration layer:

- Both tiers' name families.
- `Pinned`'s docstring and the one-arity `contract_at`, which walks a
  continuous contract at its scalar and reads a discrete one as written in its
  declared shape (D-263), with `declared_at`, its keyed form. The one
  mechanism of the five letters: `default_name`, the letter a bare
  declaration's entry takes, `_keyed`, a declaration's value keyed under it,
  and `is_bare`, the shape read off the declared value, never off the keyed
  names (§8.2, D-437, D-438).
- The bundle law, with the legal bundle sets `LEGAL_BUNDLE` and
  `classify_bundle_field` (§5.2, Appendix B).
- `probe_value`, with its enum arm (D-051).
- The connection declarations `local_wires`, `input_wires` and
  `output_wires`, beside `transparent_container`.
- The optional declaration `stop_reason` (D-316).
- The rate forms `Period`, `Relative` and `Absolute`, with `sample_times`.
- The event surface `StateEvent`, `state_events` and `x_projection`.
- The declaration family `DECLARATION_FAMILY` and `foreign_declarations`.
- The user-code frame `invoke_declaration`, `invoke_probed` and
  `at_component` (§13.2, D-248), the file's last section.
- The readers of a component, `has_stage`, `_declares`, `declared_at`, the two
  bundle-name functions and `foreign_declarations`, take it unspecialized, so a
  new component type compiles none of them again (§9.7, D-289).

Spec: §2.3, §5.2, §8.1, §8.2, §8.5–§8.7, §9.3, §9.7, §13.5, Appendix B, D-051,
D-179, D-185, D-195, D-211, D-246, D-248, D-263, D-289, D-316, D-437, D-438.

### `src/deployment.jl`

- Deployment binding and its two artifacts (D-254), the `Schedule` and the
  `Deployment`. The binding is `bind_schedule`, with `_exact`/`_as_int`.
- The typed `Schedule`, over `ScheduleEntry` and `ScopeEntry` (D-261):
  - the anchor and rates columns beside `(D, Φ, Δt)`, in `ScheduleEntry`;
  - the rate-scope rows, in `ScopeEntry`;
  - `_gates`, which derives the per-component triple the executor compiles
    over from the rows at `compile`.
- The algorithm tokens `RK4()` and `Heun()` under `AbstractAlgorithm`,
  singletons that carry no step, and the `show` that prints them as spelled
  (§10.2, D-442, D-449). Their steppers are stepper.jl's.
- The `Deployment` holds the build plus the grid parameters `Δt_frame` and
  `Δt_base`, the step bound `h_max` resolved to the lesser of itself and
  `Δt_frame` (D-449), the algorithm token and the three event parameters
  `firing_budget`, `localization_tol` and `localization_budget`.
  It is scalar-free. The `Deployment` constructor has one throw per call
  (§9.2, D-229). It also holds the `Lattice`, the frame loop's index-to-time
  map, derived from the exact periods once (§10.5, D-445).
- The `Lattice`: the exact unit `gcd(Δt_frame, Δt_base)` (`Δt_frame` alone
  when no discrete component exists), the frame and base tick as whole
  units, the bound `h_max` as an exact ratio to the unit, `max_frame`, the
  last frame index whose positions fit `Int`, and `reach`, the clock bound's
  `2^50·δ` in seconds, `δ` the least gap between two boundaries: the unit,
  or the lesser of it and `h_max / 2` when the bound splits a frame (D-450).
  `max_frame` bounds `k·frame` plus the largest period in units, so it is
  one frame conservative: frame `max_frame + 1` would still fit. `_lattice`
  builds it in `Int128` and returns `:Δt_base` when the unit, a period in
  units or one frame's positions leave `Int`, or `max_frame < 1`, and
  `:h_max` when a frame's step count or its steps' exact denominator would.
  The bound is not in the unit's gcd (D-449).
- `bind_schedule` is strict under D-229: `Δt_frame`, `Δt_base` and `h_max`
  are each a premise of its own, positive and finite (`_positive_finite`),
  every check whose premise holds runs, and nothing relates them (D-445,
  D-449). `h_max` resolves against `Δt_frame`, absent meaning `Δt_frame`.
  The lattices come last, with every other check as their premise:
  `_lattice`'s `:Δt_base` is `DeploymentInvalid` on `Δt_base` with reason
  `:range` and `Δt_frame` as `related`, and its `:h_max` the same on
  `h_max`, the two `:range`s that carry a related value, collected with the
  event parameters' faults (§9.2, §10.5, D-445, D-449).
- `==`/`hash` on a `Deployment` compare by value over everything but the
  build, the grid attribution, the `Lattice` and the warnings (§12.7), the
  bound resolved. Two exact periods that round to one `Float64` therefore
  compare equal, though their lattices differ.
- `warnings(::Deployment)`.
- The grid attribution `_grid_report` (D-187):
  - the constraint pool, with each entry's leave-one-out refinement factor;
  - the prime attribution of `gcd(pool)`'s denominator;
  - a driving offset's nearest non-refining neighbours.
- `_grid_report` runs once per call, ahead of the `Δt_base` branch. The
  `Deployment` carries its result. The call also hands that result to the
  three refusals whose remedy is a `Δt_base` the pool admits, and to the
  derivation path's info line.
- The derivation path's info line shows the derived value over the same block,
  with both attribution forms. The derivation path also raises the
  `GridUtilization` advisory at `min_i Dᵢ > 1`.

Spec: §9.2, §10.2, §10.5, §12.6, §12.7, Appendix B, Appendix C, D-187, D-229,
D-250, D-254, D-256, D-261, D-442, D-443, D-444, D-445, D-449, D-450.

### `src/descriptor.jl`

- `descriptor` on a `Build`, on a `Deployment` and on a `DiagnosticError`,
  the artifact or the carrier rendered to data under the format
  `src/descriptor.json` fixes (§13.9, D-432, D-434): the envelope
  `_envelope` with `DESCRIPTOR_FORMAT`, the build body's two sections
  `_structure_section` and `_outputs_section` with its `warnings`, the
  deployment body embedding the build's, and the failure body
  `_failure_body` with `policy` off the type parameter and `structure` when
  the carrier holds one.
- A diagnostic as data `_diagnostic`: kind, severity, path and the rendered
  message, then `_function` for the probe-chain kinds, `_marks` as ports and
  wires for the kinds naming a face or a wire, and `_cycle` over
  `_terminal_endpoint` for `AlgebraicCycle`, which splits each end at its last
  `/` into path and port, a bare port's its face; never the payload (D-434,
  D-437).
- The node walk `_nodes`, a pre-order over the level rows' children with the
  primitives read off `components`, and the node's `field` and `key` from
  `membership` on the `Child`.
- The primitive faces `_primitive_faces`, read off the declarations as written with a
  `Pinned` entry unwrapped and flagged, a bare contract's face `u` or `y`, and the kind marker `_kind_marker`,
  §13.9's table in test order, its `struct` row the leaf walk's isbits cut
  and its `vector` row over `_static_shape` (D-433).
- The instance context: `_qualified_name`, `_alias` over the parent module's
  constant bindings, `_type_string`, the parameter
  summary `_parameters` over `_summarize!`, each inert field cut at 80
  characters and a `NamedTuple` field opened into dotted entries (D-439),
  the `types` rows `_type_rows`
  with `_docstring` off the docsystem's meta and `_locations` over
  `LOCATED_DECLARATIONS`.
- Nothing here encodes text. `test_descriptor.jl` holds the round trip, with
  JSON and JSONSchema as the suite's dependencies alone.

Spec: §8.5, §9.1, §9.2, §13.2, §13.8, §13.9, D-211, D-237, D-418, D-432, D-433,
D-434, D-437.

### `src/devices.jl`

- The device contract `init!`, `shutdown!`, `unblock!` and `loop`.
- The handle (D-261):
  - it holds the binding, the writer, the diagnostic cell and the compiled
    gather, a `Reader`;
  - its type carries the binding's and the gatherer's types, so
    `binding(handle)` and `gather(handle, snapshot)` are static inside a
    device's `loop` and allocate nothing;
  - it holds the plane's exclusivity index by reference, never the plane;
  - it holds the build's `Structure` and the nominal `Layout` by reference,
    for the panel kit's bake alone (D-270);
  - the handle's stable id is the roster entry's.
- The handle primitives read the control plane that control.jl defines.
  `running` reads the sticky status, and `wait_next_snapshot` reads the
  counter and the condition.
- The primitive `pending` reads the handle's own staging cell, dataplane.jl's,
  with one acquire load and never takes it (§11.7).
- The panel kit, §11.7's framework half (D-270):
  - `PortView`, one port's baked verdict, its address field abstract;
  - `port_views(handle)`, the `Dict` of views keyed by `(path, port)`, one
    per input face at every level, off `terminal_producer`, and one per
    produced cell;
  - `peek`, the peek rule over `pending` and the snapshot;
  - `incumbent_status`, the incumbent's `WriterStatus` by `who`, and
    `orphaned` on it, exactly `task_state === :done` (§12.2). A crashed
    loop's task ends `:done`, since the wrapper catches the crash.
- The task wrapper, with the guarded release `_shutdown!`, and `_spawn!`,
  one task per live entry.
- `report!(entry, DeviceCrash(…))`, the crash report addressed by the roster
  entry (§12.4). The wrapper and sim.jl's init bracket both file through it.
  It writes the entry's cell with no attachment check and no heartbeat.
- §12.4's run bracket around the spawn, the init bracket, the tail and the
  sweep, is sim.jl's. Nothing here names a `Simulation`, so the file precedes
  sim.jl.

Spec: §11.1, §11.3, §11.6, §11.7, §11.8, §12.1–§12.4, §13.6, D-233, D-244,
D-256, D-261, D-268, D-270, D-315.

### `src/diagnostics.jl`

- The diagnostic kinds, under `Diagnostic`.
- The runtime channel's kinds, the members of dataplane.jl's `KINDS` (§11.8,
  Appendix C), in their own section beside `EmptyGreedyClaim`: the three
  staging kinds (§11.4), the two budget degradations (§10.4, §10.6),
  `DebtReanchor`, the pacer's forgiveness on the loop's own cell (§10.7),
  `UnboundedRun`, the loop's own advisory (§13.5, D-255, D-316),
  `ThreadBudget`, the run-top tightness warning on the loop's own cell
  (§12.2, D-027), `DeviceCrash`, `DeviceJoinTimeout` (§12.4, D-203) and
  `ReplayDiscardedStaging` (§12.7). `EmptyGreedyClaim` is reported by
  `attach!` into the roster entry's own cell (§11.6, D-250).
- `_typename`.
- `_named`, the one renderer of a `(path, name)` pair; `_at_port`, a port in a
  message in slash form over it; `EmptyStore`, the refusal of `(;)` (§8.2).
- The shape arms of the five letters: `UnknownPort`'s one-segment endpoint,
  which names no port, `FaceNameIllegal`'s `:empty`, `ReadResolution`'s
  `:store_shape` and `:port_shape` for a headless address against a named
  store, a named contract or an assembly, and `ConditionResolution`'s
  `:store_shape` and `:port_shape` for a bare payload against a named store,
  a named contract or an assembly (D-437, D-438).
- The `DiagnosticError` carrier, its `warnings` (D-250) and its `structure`,
  typed `Any` since `Structure` is declared later and filled by the build's
  door alone (D-434), with `diagnostic`, `diagnostics`, `kinds` and the two
  renderings.
- `logline`.
- The build's warning channel `BUILD_WARNINGS` and `_warn!` (D-250).
- The grid records `GridEntry` and `GridReport`, and `_anchor_label`.
- `DeploymentInvalid`'s and `GridUtilization`'s `grid` payloads, rendered by
  `_grid_block` (D-187).
- `ArgumentInvalid`'s arms off the deployment surface (D-256, D-261).
- The `Trim*` kinds `TrimProblemInvalid`, `TrimCommitEvents`,
  `TrimCommitResiduals` and `TrimCommitChecks` (D-262).
- `ReadResolution`, the read-selector family's refusals, and `_read_message`,
  the message it shares with `TapResolution` (§14.4, D-406).
- `TapResolution`'s tap-set reasons alone, with the `tap`, `list`, `pinning`
  and `duplicate_of` fields; `ReadSetMisuse`'s `:not_a_tap_list`;
  `ArgumentInvalid`'s `:not_a_tap_set`, `:t0_without_about`,
  `:nonpositive_width` and `:non_nominal` (D-272, D-406).
- `ReadResolution`'s leaf reasons `LEAF_REASONS`, with the `leaf` and `step`
  fields, and `_leaf_clause` (D-276).
- `ReadResolution`'s and `TapResolution`'s `mount` field, and
  `ReadResolution`'s `producer` field and reasons `:no_input_face`,
  `:internally_wired` and `:input_face_not_output` (D-277).
- `TierUnreadable` and `StatelessWithoutOutputs` (D-263).
- `InternalInvariant`.
- §13.4's runtime trio `CursorFrame`, `StepError` and `NonfiniteState`, whose
  leaf names a bare state's field `x` (D-438).
- §12.7's replay trio `CheckpointMismatch`, `ReplaySchemaMismatch` and
  `ReplayUnknownFace` (D-255, D-274).
- `CheckpointMidFrame` (D-274).
- `StepError`'s `host` and its rendered recipe (§13.4, D-274).
- `CheckpointMismatch`'s store and clock arms, and `ArgumentInvalid`'s
  `restore` arm.
- `StopRequestInvalid`, the refusal of an `ignore_stop_requests` path (§13.5,
  D-316).
- `ArgumentInvalid`'s `:not_built` and `:claimed`, the `Simulation`
  constructor's refusals of its model, and `:claimed` on a claimed model's
  door (§9.2, D-318).
- `CheckpointMismatch`'s `:scalar` arm naming a `Model`,
  `ServiceLifecycle`'s model arm, the refusal off `:consistent`, and
  `ArgumentInvalid`'s `:non_nominal` raised on a `Model` (D-319).
- `ArgumentInvalid`'s `:scalar` on `Model`, the materialization's refusal of
  its scalar (§9.2, D-320).
- `ArgumentInvalid`'s `related`, the bound a `:range` value passes, which
  `frame!`'s refusal of `k` fills with the last frame the run may take
  (model.jl's `_last_frame`), and that refusal's message arm.
  `DeploymentInvalid`'s `:range` on `Δt_base` and on `h_max`, each with a
  message arm for the lattices' refusal, a `:range` with `Δt_frame` as
  `related`, and `:inexact`'s wording for `h_max`. The reasons
  `:subcycling`, `:not_frame_multiple` and `:not_harmonic`, the parameter
  `:h` and the tokens' `:inexact` are gone (§9.2, §10.5, D-445, D-449,
  D-450).

Spec: §9.1, §9.2, §10.4, §10.6, §10.7, §11.4, §11.6, §11.8, §12.2, §12.4,
§12.6, §12.7, §13.1, §13.2, §13.4, §13.5, §14.4, §14.8, §14.9, §14.10,
Appendix C, D-027, D-058, D-059, D-157, D-187, D-203, D-214, D-215, D-222,
D-225, D-250, D-255, D-256,
D-261, D-262, D-263, D-272, D-274, D-276, D-277, D-316, D-318, D-319, D-320,
D-406, D-437, D-438, D-444, D-445, D-449, D-450.

### `src/executor.jl`

- Entries `StageEntry`, `RHSEntry`, `UpdateEntry`, `EventEntry` and
  `ProjectEntry`. Each carries its component's path, for the write's
  diagnostic, and an event entry carries its event name beside the path
  (D-249). A side's addresses are `SideAddrs`, a group or a bare side's one
  `CellAddr`, which `_bundle_expr` gathers through `gather_input` (D-437).
- The chunked walk `Chunk` and `chunked_body`. `Chunk` is mutable, so a
  phase body holds one pointer per chunk and a barrier call loads one
  pointer. Every tuple walk, over a chunk's entries, a body's chunks, or the
  event set's chunks and their entries, unrolls through one generated body,
  `_unrolled`. Its twin `_unrolled_tuple` returns the elements as one tuple
  and serves the value-building walks of readers.jl, bindings.jl and
  conditions.jl.
- The interior/boundary split `PhaseBody`. A body with no gated entry has two
  tuples of one type and walks its interior at a boundary.
- The `(tick − Φ) % D` gate `Gated`, with boundary zero's `ESTABLISH` beside
  it.
- `_merge_modes!`, one generated method, which replaces a bare `m` whole and
  merges a named one, a bare one's failure on the field `m` (§9.5, D-438).
- The bundles, from `_bundle_expr`: the stage, RHS and guard bundles gather
  their sides inline, the update entry's and the handler's
  (`make_handler_bundle`) through `gather_input_barrier`, since a body whose
  only writes are field stores is the shape the compiler's escape analysis
  runs on, at about the cube of a gathered value's leaf count
  (`reports/20261106_update_entry_escape_analysis/report.md`).
- The event set, with its registers. It is mutable, so the executor holds it
  by reference. Its `entries` and `projects` hold `EventChunk`s, each a
  mutable chunk of entries, so their `length` counts chunks.
- The guard/fire/project walks `_guards!`, `_fire!` and `_projects!`, each one
  non-inlined call per `EventChunk`, over the executor's buffers the caller
  hands them (D-261).
- The execution cursor, which every entry stores into. The cursor holds its
  dispatch fields alone, and whether a frame was abandoned is `frame!`'s
  `Bool` return (§13.5, D-261, D-317).

Spec: §5.3, §9.5, §9.7, §10.4–§10.6, §13.4, §13.5, §14.5, D-059, D-205, D-235,
D-249, D-255, D-261, D-289, D-317, D-437, D-438.

### `src/frame.jl`

- The model's `frame!(model, k, hooks)` (D-317): the top
  hook, then `_frame_steps!`, inside §13.4's one `try`, whose catch writes
  `:inconsistent` and builds the `StepError` with `_wrap_step` for every throw,
  an interrupt included (D-441). The claim's gate and the refusal of a `k`
  past `_last_frame(model)`, the lesser of the `Lattice`'s `max_frame` and
  the clock's resolution from the origin, precede the `try`, so that
  refusal leaves the model `:consistent` (D-318, D-445, D-450).
- `_frame_steps!`, the frame as two nested loops (D-445, D-449). The outer
  one runs over the mandatory instants, the frame tops and the due instants,
  found by integer comparisons over the `Lattice`'s units, each clock
  written from its own index through model.jl's grid. The inner one takes a
  span's `cld(units·q, p)` equal steps, `p/q` the bound in units, each of
  exact length `(units·unit)/n`; an interior step end's clock is the span's
  start clock plus `i` times that length, never accumulated. The span's last
  step runs `run_boundary!` with its tick index when due, every other step
  end with the empty due set. A bare step integrates by its exact length; a
  localized one by the float distance to its end (§10.5).
- The next due instant is recomputed after each due boundary, one `mod` per
  schedule row (`_next_due`, model.jl's). Nothing is cached, so nothing needs
  invalidating at a restore, an overlay or `init!`.
- `_localized_step!`, the localization loop over one step, with the arrival
  sweep, the θ = 0 validation, ITP bracketing `_crossing`, `t*` boundaries,
  the remainder step to the step's end, the localization budget counted
  across the frame's steps, and the `ChatteringBudget` degradation, reported
  into the model's diagnostic cell (D-446). The report folds at the next
  frame top and its delta rides the first publication after the fold, which
  under subcycling is that frame's first step end, not its top.
- The freshness flag (D-447): the frame's first step is fresh when
  `frame_top!` returned `false`, every later step and every remainder is
  fresh, and `integrate_step!` arms it.
- The cursor's drain/arrival/validation/trial phases. After a boundary at
  which nothing is due the cursor reads the event round, since no ticks
  block runs (D-445).
- `settled!` at every step end, every `t*` boundary and the frame top. A
  `true` abandons the frame's remainder and is `frame!`'s return (§13.5,
  D-261, D-317).

Spec: §10.2–§10.5, §11.8, §12.4, §13.4, §13.5, D-018, D-059, D-255,
D-260, D-261, D-317, D-318, D-444, D-445, D-446, D-447, D-449, D-450.

### `src/leaves.jl`

- The leaf walk includes the enum leaf, D-237's opaque leaf and
  `mutable_position`. `Symbol` counts among the opaque leaves by D-243. The
  walk covers flatten `flatten!` and `_mflatten_expr`, reconstruct
  `reconstruct` and `_mreconstruct_expr`, and the activation retype.
  - `Pinned` is the contract marker. It is defined here because the walk
    dispatches on it.
  - `retype_entry` strips the marker at the top of an entry alone (D-265). It
    sits over `retype`, which replaces each `Float64` position by the scalar
    and pins a mutable type's parameters (D-263). An entry that is no type
    passes through it as written, for the walk's refusal in assembly.jl (§8.2).
  - `_holds_marker` finds a marker below the top.
- `StopFlag`, the stop-request enum, beside `Pinned` (D-316).
- `leaf_names`' dotted spelling of a flat position, a matrix leaf by its
  indices.
- Embed-accept's relation `_accepts` (D-166). The relation is decided on the
  type (D-238). At a store it accepts an opaque leaf by identity (D-237). At a
  wire it admits an opaque leaf as the producer's cell (D-264).
- The wire relation `_accepts_wire`, with its abstract arm (D-236).
- The checked state write `flatten_state!` (D-235), with its bare arm decided
  at generation for a bare `XT`, its failure on the field `x` (D-438).

Spec: §4.1, §4.3, §4.4, §6.1, §7.1, §7.2, §8.2, §9.5, §13.4, §13.5, D-166,
D-235, D-236, D-237, D-238, D-243, D-263, D-264, D-265, D-276, D-316, D-438.

### `src/linearize.jl`

- `Taps` and `taps`, three labeled selector lists with closed membership.
  `at` on a `Taps` mounts the three lists (D-277).
- `LinearizeTag`, `LINEARIZE_WIDTH` and `LinearizeDual`, the default width's
  pre-materializable scalar.
- `Linearization`, the operating point and the four matrices under the tap
  labels.
- `linearize` on a `Model{Float64}`, over D-213's two-half scratch world in
  passes of `width` directions, the seeds written at the resolved taps' own
  sites. Each half is a scratch `Model`, built by model.jl's `_scratch`
  (D-317, D-319).
- `_check_linearize_call`, the keyword refusals, and `_linearize`, the query
  over a chosen operating point, which the simulation's method in sim.jl
  shares (D-319).
- The misuse fallback on a `Model`, and `ArgumentInvalid`'s `:non_nominal` on
  a `Model` at another scalar (D-319).
- The default operating point is `checkpoint(model)`, or `checkpoint(sim)`
  through the simulation's method (D-319), restored into the
  nominal half with no resolve, no `apply!` and no establishment round, so
  the frozen cells are the checkpoint's held cells. The `about` form keeps
  the resolve, the `apply!` and D-213's round (D-274).
- At the default point each root input's checkpoint value enters the seeded
  half through conditions.jl's `_convert`, and a type that does not convert
  is `ConditionResolution` `:unconvertible` with the checkpoint as its
  origin, every root input in one throw (D-428).
- The collecting tap resolution, with the discrete store, the vector leaf,
  the member in the wrong list, the unseedable root input and a second seed
  at one site refused. The unseedable root input names its pinning consumers
  with their tiers, the duplicate the earlier label.
- `_tap_violation`, the tap-set builder: each of the five refusals is a
  `TapResolution`, its tap set read off the selector's kind by `_tap`. A
  read's own refusal stays the `ReadResolution` readers.jl raised (D-406).
- At a mount the collecting tap resolution mounts each list. The kind check
  reads the selector as authored, and a chain that fails is reported once
  across the three lists. The pinning meet sees the root input the chain
  landed on, and `:no_input_face` and `:internally_wired` join the refusals
  (D-277).
- A seeded tap reaches its scalar through one index step at most, and a
  `.name` step is unseedable (D-036). The seed site is the leaf's linear
  place on the `x` and `u` lists alike, so `[k,l]` seeds the entry its
  linear `[k]` names and the two spellings are one site (D-276).
- A headless tap on a bare store or port takes the letter as its head before
  the site is resolved, so `"[1]"` on a bare `x` seeds `x[1]` (D-438). The
  pinning meet reads the consumers' contracts keyed, a bare input under its
  face `u` (D-437).

Spec: §9.7, §14.4, §14.10, D-036, D-167, D-168, D-197, D-213, D-272, D-274,
D-276, D-277, D-317, D-319, D-406, D-428, D-437, D-438.

### `src/model.jl`

The model layer, between the executor layer and the runtime (D-317). Every
door that writes the model's status lives here. A file sits above `sim.jl` as
soon as nothing in it names a `Simulation` in a signature, and below
`model.jl` as soon as something in it names a `Model`.

- `Model{T,E}`, the deployment and its executor at one scalar, its status,
  its claim flag, its frame's diagnostic cell and the freshness flag `fresh`
  (§10.3, D-447), with the materialization
  `Model(deployment, T)` and `Model(::Build)` and `Model(::AbstractComponent)`
  over it (§9.2, §11.8, §12.6, D-254, D-317). `Simulation(model)` sets the
  claim flag once and nothing clears it (D-318).
- The materialization's scalar refusal, `ArgumentInvalid` `:scalar` on any
  `T` but `Float64` and a concrete `ForwardDiff.Dual` over it at any depth,
  `_embeds_float64`, thrown alone (§9.5, D-320). Its
  keyword refusal, `ArgumentInvalid` `:range` on a `chunk_size` that is not an
  integer ≥ 1, is collected (Appendix C).
- The seeded-half scratch world trim.jl and linearize.jl share (§14.8,
  D-213, D-317): `_scratch`, the model's buffer set at another scalar, which
  dies with the call, and `_establish_frozen!`, the frozen copy over the
  `Outputs`' port list.
- The frame's hooks `FrameHooks`, with `frame_top!` and `settled!`, and the
  no-op `NoHooks` (§11.2, §13.5, D-317). `frame_top!` returning `false`
  reports nothing written, and `NoHooks`' `nothing` counts as a write (D-447).
- The grid (§10.4, §10.5, D-445): `_grid_time`, frame top `k` from the index
  and `t₀`, and `_tick_time`, a due instant from its base-tick index; neither
  accumulated. An interior step end is frame.jl's (D-449). `_next_due`, the
  next due instant past a position, one `mod` per schedule row, recomputed
  per due boundary and never cached. The arithmetic over `t`, `t₀` and
  `Δt_frame`, `_frame_slack`, `_frames_to` and `_frame_at` (§12.4, §12.6,
  D-260, D-319), read by `frame!`, the checkpoint and the loop.
  `_last_frame(deployment, t₀)`, the last frame a run from `t₀` may take,
  the lesser of the `Lattice`'s `max_frame` and the frame where
  `|t₀| + 2·(t − t₀)` reaches its `reach`, a few flops per call and never
  stored (D-450). `_frames_fit`, the doors' check that a time's frame count
  stays within `_last_frame` before either rounds it, `_check_origin`'s
  included. Their
  deployment and model methods are what sim.jl's sites call, so no caller
  rebuilds the `(t, t₀, Δt_frame)` triple.
- The claim's gate `_claimed_gate`, which refuses a claimed model's direct
  call as `ArgumentInvalid` `:claimed`. Its `LoopHooks` method is sim.jl's
  and compiles the check away on the loop's path (D-318).
- The model's doors (D-317), each gated on the claim (D-318):
  - `init!`, whose condition method resolves and whose plan method refuses
    an origin `_check_origin` rejects, does the writes, runs boundary zero
    under §13.4's catch and settles it through the hooks (§14.5, D-223);
  - `overlay!`, in the same two methods, whose condition method resolves with
    the stores as the merge bases, `_store_values`, and whose plan method
    runs the continuing settling under the same catch with host `:overlay`
    (§12.6, §14.1, D-429);
  - `apply!` on a model, gated under `NoHooks` before the inner
    `_apply_plan!`, which `init!` and the simulation's forwarding method call;
  - `restore!(model, model_state; hooks)`, whose fingerprint check
    `_check_checkpoint!` and grid check `_check_grid!` precede the ungated
    inner `_restore_state!`, which
    the simulation's door body calls and which hosts §13.4's catch around the
    copy and the settling, writing `:built` under host `:restore` (D-441), with
    the scalar fallback on a state at another scalar (D-274, D-319).
  `frame!` (frame.jl) and `trim!` (trim.jl) are the other two gated doors.
  The stepping primitives `evaluate!`, `integrate!`, `boundary!`,
  `offtick_boundary!` and `boundary_zero!` stay ungated (D-318).
- `phase_bodies`, and `evaluate!` on the executor and the model. The model's
  runs the `x_deriv` block alone when `fresh` is set, and clears it (D-447).
- The one boundary routine `run_boundary!(model, due)` over its due set, a
  tick index, `nothing` or `ESTABLISH`, with `run_ticks!` selecting the
  ticks block by arity (§10.5, §10.6, D-185, D-445). `boundary!`,
  `offtick_boundary!` and `boundary_zero!` are thin wrappers over it, and
  `overlay!`'s continuing settling is its empty due set (D-429). Beside it
  `_round!` and the §10.6 event phase `event_phase!`, with its `FiringBudget`
  degradation into the model's diagnostic cell.
- The seam's framework side `integrate!(model, h)` over `integrate_step!`,
  which the frame loop calls with its frame index and the freshness flag,
  and its `isfinite` sweep `_check_finite!`, whose `NonfiniteState` names the
  loop's frame or, off the loop, the frame top the clock rounds to (§10.2,
  D-157, D-445).
- `warnings(::Model)` (D-250), and the reads `port`, `state` and `modes` on
  the model, which refuse an unknown path through `_component_index` and
  `refuse_path` (D-440).
- The one `StepError` constructor `_wrap_step`, which the model's `frame!`,
  `init!`, `overlay!` and the inner restore call, and the species rule `_species` with the runtime bundle-field
  match (§13.2, §13.4, D-059, D-221, D-248).
- The checkpoint's model-level half: `_fingerprint`, and `checkpoint(model)`
  over the rest gate `_assert_at_rest`, the status and the clock on a grid
  top, which `overlay!` and the simulation's doors share, with its two
  refusals, `ServiceLifecycle` and `CheckpointMidFrame` (D-274, D-319,
  D-429). `_check_checkpoint!`, the fingerprint check the restoring
  doors and replay's entry pass share, collecting `CheckpointMismatch`, and
  beside it `_check_grid!`, the grid check the three restore doors share,
  collecting `CheckpointMidFrame` into the same list.

Spec: §9.2, §9.5, §10.2–§10.6, §11.2, §11.8, §12.4, §12.6, §13.2,
§13.4, §13.5, §14.1, §14.5, §14.8, D-059, D-157, D-185, D-213, D-221, D-223, D-248,
D-250, D-254, D-260, D-274, D-317, D-318, D-319, D-320, D-429, D-445, D-447,
D-449, D-450.

### `src/precompile.jl`

The precompile workload (§9.7, D-289): `workload_loop`, a closed loop of
library blocks, and `workload`, its run through the loop's path, `trim!` and
`linearize`. The `@compile_workload` call inside `@setup_workload` runs
`workload` while the package precompiles, and `test_precompile.jl`'s child
runs it in a fresh process. Nothing in the package depends on it, so
`src/Redstone.jl` includes it last, after the library it uses.

Spec: §9.7, D-289.

### `src/readers.jl`

- The closed read-selector family `get_state`, `get_deriv`, `get_output`,
  `get_input` and `get_face`, each taking a leaf address as its `leaf`, a
  `Symbol` the short form of a plain name (D-276).
- The mount step (§14.9, D-277). `Reads` carries its mount chain as
  `prefixes`, and `_mount` walks it from the root's level row, each prefix
  from the level the previous one reached (§13.3), to the mount path and the
  level there, reporting a failed chain once. `_rebase` then turns each selector
  into a `MountedRead`: the selector as authored, the mount, the
  root-authored selector and the head and steps of its leaf. A path
  selector's path is walked from the mount level and joined to the mount.
  `get_input` matches an input face of the mount level and follows the
  export chain to its root input. `get_face` matches an output face of the
  mount level and becomes `get_output` of the port behind it. The callers
  rebase and resolve one selector at a time, so the collected list keeps the
  authored order, and the resolvers read the rebased selector.
- The export chain's lookup, `_input_faces_at` and `_face_producer`, shared
  by `get_input`'s rebase and a condition's `u` entry in conditions.jl
  (D-277), over `terminal_producer` (D-315).
- The leaf address (D-276). `parse_leaf` splits it at resolution, a headless
  address, empty or beginning at a step, with no head, and every selector's
  `leaf` defaults to the empty address. `_supplied_head` gives a headless
  address the letter of a bare declaration, by its declared shape: a path
  selector's at the rebase step, through `_read_shape`, and a face
  selector's through `_face_leaf`, so every later step reads a name. A
  headless address against a named store is `:store_shape`, against a named
  contract or an assembly `:port_shape`, the names in hand (D-437, D-438). On a
  face selector `match_leaf` matches the head against the face list instead,
  since a face name may hold a dot. `get_face` at a primitive level, the root
  included, reads its ports. `StoreRead`'s field is a bare store's letter, read
  whole. `resolve_leaf` checks each step against the declared type and returns the
  chain or a `LeafRefusal`, the six leaf reasons any kind wraps, and
  `_resolved_type` reads the type a resolved chain lands on. `walk_steps`
  runs the chain as `getfield` and `getindex` calls unrolled at generation.
  A step is an `AccessStep`, and a condition's tree position is a tuple of
  the same steps, so the specialized `apply!` runs on the same walk.
- `reads` and `Reads`.
- The internal `_compile_reads`, which yields a `Reader{T}`. Each entry carries
  its chain as a type parameter, and the `CellRead` core reads a store bundle,
  so every gather over a table shares it. Its `source` argument is the source
  the reader runs over, and under `:table` the resolver refuses a store
  selector (§14.4, D-406). `_compile_reads`, `_resolve_reads` and `_mount`
  take the read set unspecialized, so a new label set compiles none of them
  (D-407).
- The violations, `ReadResolution` values built by `_reader_violation` and
  `_leaf_violation`, the same at trim, at linearization, at attach and at
  `series` (D-406, D-407).
- `gather_reads`, `apply!`'s twin over an executor. It reads its entries
  through the generated `_read_entries`, which the snapshot method in
  dataplane.jl shares.
- The output-port candidates, read off the `Outputs`.
- Activation identity on readers, checked as an internal invariant. The same
  check on plans sits in conditions.jl's `apply!`.

Spec: §11.2, §13.1, §13.3, §14.1, §14.4, §14.7, §14.9, §14.10, D-125, D-130, D-253,
D-276, D-277, D-315, D-406, D-407, D-437, D-438.

### `src/roster.jl`

- Device/binding traits and conformance `check_binding` and `check_device`.
- The roster, whose entries work as follows (D-261):
  - each entry keeps the device, its stable id, its thunk, its abort policy
    `should_abort`, its account and its handle;
  - each entry reads its binding, writer and diagnostic cell through the
    handle by `_handle`'s typeassert.
- Both claim sources and the harness writer.
- §11.5's drain thunks, beside the claim sources and the harness
  writer (D-260, D-261):
  - `DataPlane(layout)` compiles none;
  - the plane's harness thunk is the `_no_drain` sentinel until a door or a
    roster change compiles it;
  - `reclaim!` takes the store and the run's trace from `attach!` and
    `detach!` rather than reading either off the plane.
- `_install_writers!`, the file's last section, with `_writer_schemas`
  (§11.5, D-261): the trace's schema-list growth rule, and the one site a
  drain thunk is compiled at, against the executor's store and the run's
  trace that it takes as arguments, with the appended range as a local
  (D-260). `reclaim!` and sim.jl's `_open_run!` call it.
- The loop is a writer too, so the plane holds the loop's diagnostic cell
  and account, and §11.2's published holder with them (D-256).

Spec: §11.2, §11.3, §11.4, §11.5, §11.6, §11.8, §12.4, D-255, D-256, D-260,
D-261.

### `src/show.jl`

- Each artifact renders through `show`, with no accessor beside the
  rendering.
- `Structure`, `Outputs`, `Events`, `Schedule`, `Build` and `Deployment` each
  have the compact one-line form and the `MIME"text/plain"` tables. That makes
  twelve methods over one `_lines` per artifact.
- The `Outputs` and `Events` tables, with the `Build`'s `feedthrough:` line
  between them (D-261):
  - each table prints each row's path, with no label function, and the
    `Events` table holds only the components that declare an event;
  - `_feedthrough` derives the line's edges from the structure's connections
    and the producers' stage-2 names;
  - every `(path, name)` pair, a feedthrough end or a route's hop, renders
    through `_named` in slash form, a bare port by its face `u` or `y` (D-437).
- The `Structure`'s `input routes:` and `output routes:` blocks after the
  anchors, one line per route of a root face, its hops joined with ` → `
  (§13.7), derived through `face_routes` over the root's level row (D-315).
  A side with no root face prints no block.
- The `Schedule`'s hyperperiod chart, over `lcm(Dᵢ)` base ticks, with its
  binary guard at 100.
- The `Deployment` sets `_grid_block`'s lines under `grid:`, and its
  parameters line names `h_max` resolved. `_steps_line` states the steps of
  a frame no due instant falls inside, one `cld` over the bound's ratio to
  the unit, and names each schedule row whose ticks are not all frame tops,
  one divisibility check per row, the count then labelled per unsplit frame
  (D-449).
- The published `FrameworkStatus`'s two forms. The `MIME"text/plain"` form
  prints one block per writer and the pacer's line last. It prints each
  writer × kind in full up to `STATUS_MAXLOG` cumulative occurrences, and
  count-only past it.

Spec: §9.2, §11.8, §13.7, D-136, D-257, D-261, D-315, D-437, D-449.

### `src/sim.jl`

- §13.5's block: the four termination sources `EndTimeReached`,
  `ModelRequestedStop`, `ControlRequestedStop` and `LoopError`, `StopPolicy`
  and `TerminationRecord` (D-203, D-255). `ModelRequestedStop` carries the
  requester's path, port and reason (D-316).
- `Run`, §12.6's run state with the frame and boundary counters, and
  `closed(run)` (D-255, D-260, D-317).
- The mutable `Simulation` of four fields, the model, the plane, the control
  and the run, its model a `Model{Float64}` by type (§12.6, D-256, D-317).
  `Model` and its materialization are model.jl's.
- `Simulation(model::Model{Float64})`, the one constructor every simulation
  goes through (D-317). It claims the model by compare-and-swap, and refuses
  one already claimed or not at `:built` as `ArgumentInvalid` (D-318).
- The doors' recording keywords, checked by `_check_recording`.
- The three sugar forms `Simulation(::Deployment)`, `Simulation(::Build)`
  and `Simulation(::AbstractComponent)`, each a composition through a
  `Float64` model (D-254, D-317).
- `warnings` on the simulation, forwarding to the model's (D-250).
- The two lifecycle gates `assert_stopped` and `assert_configurable`, one for
  the readers and one for the roster, beside the advances' gate
  `_assert_advanceable` (§11.3, D-232, D-317).
- `init!`, `overlay!`, `restore!`, `run!`/`step!` and `replay!`, with the
  run body `_run_body!` and the door body `_enter_checkpoint!` (D-274). The
  simulation's `init!` and `overlay!` are the gate and the run's bookkeeping
  around the model's doors, `overlay!` taking its header after the settling
  (D-429), and `_enter_checkpoint!`, over a `Checkpoint`, opens the
  run before it calls the model's inner restore. All three are model.jl's
  (D-317).
- `checkpoint(sim)`, the wrap of `checkpoint(sim.model)` with the run's two
  counters over the rest gate `_assert_at_rest`, the lifecycle test, with the
  model's gate below it, which `overlay!` shares (D-429, D-441), and `restore!`'s two forms, of a `Checkpoint` and of a bare
  `ModelState{Float64}`, each checking through model.jl's
  `_check_checkpoint!` and `_check_grid!`, with the scalar fallback on a bare
  state (D-319).
- `trim!` and `linearize` on the simulation, each gated on the lifecycle over
  the model's `_solve_problem` or `_linearize`, `trim!` committing through
  the simulation's `init!`, with the misuse forms forwarding to the model's
  (§14.8, §14.10, D-319).
- `_reset_periphery!` and `_open_run!`.
- §12.4's run bracket, beside `_run_body!`, which runs it around devices.jl's
  spawn and wrapper:
  - the init bracket `_init_devices!`, with its interrupt arm. An
    `InterruptException` in `init!` sets the `:interrupt` stop in place of
    `DeviceCrash`. The bracket lists each entry in the run's own list before
    its `init!`, so an interrupt escaping the bracket leaves no initialized
    device unreleased;
  - `_finish!`, which sets the sticky status, clears the pause flag and wakes
    the waits;
  - the tail `_tail!` under `join_timeout`, which `Control` carries (D-256).
    An interrupt reaching the tail collapses the remaining joins into
    `DeviceJoinTimeout` by name (D-198, D-268);
  - the sweep `_sweep_tail!` after the tail, which builds the
    `ResidueRecord`s, dataplane.jl's (§13.5, D-203), and folds the model's
    diagnostic cell into the loop's account beside the loop's own cell
    (§11.8, D-317);
  - `_discard_late_staging!`, a replaying advance's last take of the staging
    cells at its halt, ahead of the sweep and the mode's flip, which `step!`
    calls too (§12.7, D-451).
- `attach!`/`detach!`.
- The pause verbs `pause!`/`resume!`/`paused`, beside `stop!(sim)` (§12.1,
  D-268).
- The pacing verbs `pace!`/`margin!`, the readers `pace`/`margin`, and the
  `Pacer` each `_run_body!` creates (§10.7, §12.1, D-269).
- §12.2's thread-budget check `report_thread_budget!` (D-027).
- Staging, the drain with its replay substitution, and publication:
  `stage!`, `drain!`, `_replay_drain!` and `publish!`, with the run's copy of
  the roster (§11.3). Both drains fold the model's diagnostic cell into the
  loop's account beside the loop's own cell (§11.8, D-317). Both return
  whether a batch reached the table, the drain's report (§10.3, D-447).
- The loop's `LoopHooks`, one per advance, per `init!` and per restore: the
  frame index's advance and the drain at the top (D-441), and publication then the stop sample at every settled
  boundary (§11.2, §13.5, D-317). Its `first_frame` is the advance's first
  frame, whose top reports a write whatever the drain found, since a door or
  a stepping primitive may have written the model between advances; the
  doors pass 0 (D-447). `FrameHooks` and `NoHooks` are model.jl's.
  The claim's gate has its `LoopHooks` method here, a no-op, so the
  simulation's doors pass (D-318).
- Publication's `task_state`, read off `run_tasks` by `_status` (§12.2,
  D-270).
- §12.6 and §12.7's input mode: `mode(sim)`, `to_time` and `live!` (D-260).
- `_bind_policy`, which builds each advance's `StopPolicy` and its ignore
  mask through `_ignored_requests`, and `_stop_hit`, the scan of the `StopFlag`
  buffer (D-316).
- `t_end` and `ignore_stop_requests`, the advances' keywords, and `run!`'s
  `UnboundedRun` advisory (D-255, D-260, D-261, D-316). The bounds `t_end`,
  `t_plus`, `frames` and replay's `to_time` are checked against model.jl's
  `_last_frame` through `_frames_fit`, or directly for `frames`, so an
  advance past the last frame the run may take is refused up front. An
  unbounded `run!` ends on `frame!`'s refusal of the frame after it, its
  record a `LoopError` (§12.6, D-445, D-450).
- The lifecycle, derived, and the termination record (D-317).
- The frame loop `_advance!`, whose catch disposes only and stores every
  throw as the frame's failure (§13.4, D-317, D-441). The
  one constructor `_wrap_step` and the species rule `_species` are model.jl's.
- §12.4's mask, its unmask points, and the interrupt arms of `run!` and
  `step!` (D-268). The invariants each arm keeps are
  stated in the comments at those sites.
- The accessors `lifecycle`, `mode`, `termination`, `latest`, `logged` and
  `trace`.
- `series` and `Series`, the post-run extraction from the log through the
  read resolver for a table source, with the `ReadSetMisuse` fallback for
  a bare NamedTuple, and `_column`, the function barrier that gathers one
  entry over the log (§11.2, D-407).
- A one-line forwarding method on the simulation for each of the model's
  `port`, `state`, `modes`, `phase_bodies`, `apply!`, `evaluate!`,
  `integrate!`, `boundary!`, `offtick_boundary!` and `boundary_zero!`, which
  are model.jl's (D-317). `apply!` forwards to the ungated `_apply_plan!`
  (D-318).

Spec: §10.2–§10.7, §11.1–§11.5, §11.8, §12.1–§12.7, §13.4–§13.6,
§14, §14.1, §14.5, §14.6, §14.8, §14.10, D-027, D-101, D-198, D-203, D-218,
D-219, D-223, D-232, D-233, D-250, D-253, D-254, D-255, D-256, D-260, D-261,
D-268, D-269, D-270, D-274, D-316, D-317, D-318, D-319, D-407, D-429, D-445,
D-447, D-450, D-451.

### `src/stepper.jl`

The seam's backend side: the steppers `RK4Stepper` and `HeunStepper`, each
bound from its algorithm token by `bind_stepper` at `compile` (D-442), the
retained `startpoint`, dense output.
`checkpoint_stepper` and `restore_stepper!` are the checkpoint's hook pair,
empty for both methods, which hold nothing across a frame top (D-274). The
seam's framework side, `integrate!(model, h)`, is model.jl's, and the tokens
are deployment.jl's.

Spec: §10.2, D-017, D-442.

### `src/store.jl`

- Per-eltype cell stores `CellStore` and `CellAddr`. A handle type is its own
  eltype, as `leaf_types` in leaves.jl decides (D-237).
- The `StoreBundle`.
- `capture_stores`, one boundary's fresh copy of a bundle, one allocation per
  boundary (§9.8).
- Gather `gather_cell`/`gather_group` and the checked scatter
  `scatter_cell!`/`scatter_group!`. The scatter's check is §9.5's always-on
  check, decided at generation (D-235). A bare side is one cell: `gather_input`
  reads a group or one cell, and `scatter_group!`'s `CellAddr` method writes a
  bare port's value under the same check, its failure on the port `y` (D-437).
  `gather_input_barrier` is the same gather behind a `@noinline` call, for the
  executor's update and handler bundles.
- `_cell_key`, and `STOP_FLAG_KEY`, the `StopFlag` buffer's key (D-316).
- The `Clock` of `t` and `t₀`, the frame and boundary counters being the
  run's (D-260, D-317):
  - its `t` is in the model's scalar;
  - its origin `t₀` is a `Float64`;
  - the constructor takes `t₀` and converts it into `t`.

Spec: §9.5, §9.7, §13.5, D-162, D-235, D-237, D-260, D-316, D-317, D-437.

### `src/trace.jl`

- The input trace:
  - the mutable `Trace`, holding its header, two lists that grow in
    place, namely the writers' schemas and one sparse record per drained
    batch, and the length a replay reads its bound off, which is also the
    ordinal each record carries and which the drain advances at its top
    (D-255, D-260);
  - the header is a `Checkpoint`, nominal by type (D-317, D-319),
    written once. `init!` writes it after boundary zero's first publication,
    and `restore!` and `replay!` open their run with the checkpoint they
    restore. It is `nothing` only between
    `init!`'s opening of the run and that publication (D-274).
- `trace(sim)`, defined in sim.jl, which hands back a detached value, the
  checkpoint copied.
- Replay's up-front entry pass, run by `_compile_feed` in sim.jl. It validates
  the header, the schemas and the records. Both stages, `_check_checkpoint!`
  with `_check_schemas!` and then `_compile_records!`, collect (D-217). The
  pass builds the `ReplayFeed` the drain reads.

Spec: §11.5, §12.6, §12.7, §14.5, D-029, D-038, D-101, D-176, D-217, D-218,
D-254, D-255, D-260, D-261, D-274, D-317, D-319.

### `src/tracer.jl`

- `Tracer{S}`, §13.8's set-propagation scalar. It is global on `true` and sampled
  on `false`, and `Undecidable` is the marker between them.
- The leaf-wise lift and tag walks `_lift`, `_tag` and `_sample`.
- `_classify`, the schedule-free per-member trace at the probe point, with its
  prefix probe, D-245's port-graph verdict and the sampled fallback at a fixed
  seed.
- The probe reads each contract keyed, a bare one's port under its face `u`
  or `y`, and build.jl's `_keyed_return` keys a bare port's return by the
  declared shape (D-437).

Spec: §5.4, §13.8, §9.3, D-012, D-140, D-245, D-437.

### `src/trim.jl`

- `TrimProblem`, with its `checks` and `check_tolerances` defaulting to
  empty (D-262).
- `at` on a `TrimProblem`, field by field: the condition post-composed, the
  read set mounted, the path-free fields and a `reads` that is no read set
  passed through (§14.9, D-277).
- The `solve` seam, with `LevenbergMarquardt`.
- `trim!` on a `Model{Float64}`, gated on the claim (D-318), refusing what
  `_check_origin` rejects before the search (§14.8), over D-213's
  two-half scratch world. Each half is a scratch `Model`, built by model.jl's
  `_scratch` (D-317, D-319).
- `_solve_problem`, the solve through the verdict's evaluation, with both
  halves' clocks at `t0` (§14.8), and `_verdict!`, which takes the caller's
  commit, both shared with the simulation's method in sim.jl (D-319).
- The misuse fallback on a `Model`, and `ArgumentInvalid`'s `:non_nominal` on
  a `Model` at another scalar (D-319).
- `TrimReport`, with its `committed_checks` (D-262).

Spec: §9.6, §13.1, §14.5–§14.9, D-070, D-158, D-213, D-224, D-253, D-262,
D-277, D-317, D-318, D-319.

### `test/fixtures.jl`

The suite's fixtures:

- The coverage component set.
- The named assemblies.
- The devices and bindings.
- The `condition` methods, the condition-method idiom over the framework's
  generic. The generic lives in `src/conditions.jl`.
- `Pendulum`.
- The bare-store fixtures `BareAccumulator`, `BareTicker`, `BareLatch` and
  `Negator`, with the assembly `bare_world()` (D-438).
- The bare-contract fixtures `BareScale`, `BareFlow`, `BareSpin`, `BareSummer`
  and `BareRamp`, with the assemblies `bare_loop()` and `bare_ports_world()`,
  bare ports two levels down, wired by their faces `u` and `y` (D-437).
- `tick_alarmed`, the tick-detected stop request over `TickAlarm` (§10.5,
  §13.5, D-316).
- The `ForgottenImport` module and the forgotten-import fixtures `Inventory`,
  `Update`, `Events`, `Rates` and `Reason`, which import nothing, and
  `PassthroughOverForgotten`.

All of them are user material, and no name here is known to `src/`.
`test_build.jl`'s `Dual` sweep builds every fixture with a zero-argument
constructor at `ProbeDual` (§9.4, D-280), and `DUAL_PINNED` lists the four
pinned on purpose, which it must refuse.

### `test/imports.jl`

The suite's `import Redstone:` list, shared with `repl.jl` — the one place a
framework name the tests call or extend is admitted. A second line,
`import Redstone.Blocks:`, admits the library's blocks.

### `test/test_lattices.jl`

The frame on its lattices and the step bound (§2.1, §10.3–§10.5,
D-444–D-447, D-449, D-450): the step counts against the exact periods, the
split, equal steps under `h_max`, harmonic or not, subcycling, sub-step
publication, freshness, localization across a frame's steps, a stop at a step
end, the `Int` bound and the clock's resolution at every door. Its fixtures
are its own:

- `Recorder()`, an `AbstractAlgorithm` defined in the suite, and its
  `RecorderStepper`, forward Euler through the seam that keeps each step's
  length and the model's `fresh` flag (§10.2). No backend in `src/` records.
- `LatticeHooks` and `FreshHooks`, hooks keeping each boundary's counters and
  reporting nothing written at the top (D-317, D-447). The stop test reuses
  `test_lifecycle.jl`'s `ramp_request`.

### `test/utils.jl`

The helpers shared across the test files, no model among them:

- `D8`, the `Dual` scalar the standalone-model fixtures build at (§9.4).
- `walked` and `gated`, a phase body's entries per variant and its gated
  count (§10.5).
- `frames!(model, n)`, a standalone model stepped `n` whole frames under
  `NoHooks` from the frame top its clock sits on (D-317).
- `single` and `fed`, one component under a wrapper assembly, the second
  with one input face, by default the face `u` of a bare input, handed up to a
  root input `in` (D-208, D-437).
- `poke!`, the drain's counterfactual write into a root input's cell, not
  framework API; `same_table`, two signal tables buffer by buffer.
- `paths`, a structure's component paths in walk order.
- `failure` and `carried`, the error a call raises and the diagnostic a
  passed `@test_throws` carried.
- `writer_status`, `accounted` and `crash_accounted`, one writer's record in
  a snapshot's status and a device-task diagnostic's single account (§11.8,
  §12.4).

### `test/repl.jl`

The REPL bootstrap: `julia --project=test -L test/repl.jl` loads the list and
the fixtures into `Main`.


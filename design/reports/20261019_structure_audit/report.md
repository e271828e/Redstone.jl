# Source-structure audit, 2026-10-19

The spec has been fully implemented for weeks, and the increments and
refactors since then have kept landing in the files that existed. The
question was whether the files still mean what their names say, or whether
code has settled where it was convenient rather than where it belongs. This
report measures that at tip `e0676f8`, records the ten moves that followed,
and ends at `0947bce`.

## Method

The measurement is a dependency graph over definitions, collapsed to files.
`audit.jl` parses each source file with `Meta.parseall`, records every
top-level definition (type, function, macro, constant, descending into
`module Blocks`) and counts the references each definition's body makes to
names the package defines. Two rules keep the count honest:

- a function name counts only in call position, since argument and local
  names shadow accessors constantly (`path` alone produced a third of the
  first run's edges);
- a type, constant or macro counts wherever it appears, since those rarely
  collide with locals.

A name defined in several files is attributed to each definer fractionally.
Collapsing to files gives a matrix in include order, where row `A`, column
`B` is how often `A` references `B`. Since Julia resolves names in function
bodies at first call rather than at load, the include order is a layering
only by convention; the matrix shows where the convention holds. From it the
script reads five things:

- **upward edges**, an earlier file referencing a later one, the strongest
  misplacement signal;
- **cohesion**, a file's internal references over its total, low for
  orchestrators by nature and telling for small mid-layer files;
- **feature envy**, a definition referencing another file more than its own,
  with where its callers sit;
- **internal clusters**, the connected components of a file's own graph, a
  file with two of them being two files;
- **change coupling** from `git log --name-only`, pairs of files that change
  together without a static edge.

Three artifacts of the method are read out below rather than filtered: a
call into a forwarding layer (`evaluate!` on a `Simulation` forwarding to
the `Model`'s) is split between both definers, so some upward edges into
`sim.jl` are really calls into `model.jl`; "references `diagnostics.jl`"
means "raises errors", not envy, since that file is every layer's
vocabulary; and a function passed as a value is not counted.

## The baseline at `e0676f8`

Layering was already close to clean. Of about 1900 cross-file references,
90 pointed upward, and a greedy reordering of the files did worse than the
include order, so the include order is the real layering. The upward
weight sat in a few places:

| edge | weight | names |
|---|---|---|
| `sim.jl` to `devices.jl` | 16 | the device bracket, `DeviceHandle` |
| `assembly.jl` to `build.jl` | 14 | `invoke_declaration`, `classify_tier`, the store checks |
| `trace.jl` to `roster.jl` | 6 | `_drain_thunk`, `RosterEntry` |
| `leaves.jl` to `diagnostics.jl` | 6 | raising, by design |
| `declare.jl` to `build.jl` | 6 | `invoke_declaration` |
| `readers.jl` to `conditions.jl` | 5 | `_input_faces_at`, `_face_producer` |
| `frame.jl`, `model.jl`, `stepper.jl` to `sim.jl` | 12 | the forwarding artifact |

Cohesion was lowest in `frame.jl` (0.15), `linearize.jl` (0.26),
`bindings.jl` (0.28), `devices.jl` (0.30), `roster.jl` (0.32), `model.jl`
(0.34) and `sim.jl` (0.36). For the four services and orchestrators that is
their nature. For `frame.jl` it was the signal: the file held the frame
driver and, disconnected from it, the grid arithmetic that `model.jl` and
`sim.jl` read directly.

The envy pass, with the diagnostics rows set aside, named these:

- `classify_tier` in `build.jl`, built on `declare.jl` names, called only
  from `assembly.jl`;
- `_input_faces_at` in `conditions.jl`, pure `assembly.jl` work, called from
  `conditions.jl` and `readers.jl` alike;
- `capture_stores` in `dataplane.jl`, a `StoreBundle` copy;
- `_establish_frozen!` in `trim.jl`, shared with `linearize.jl`;
- `_install_writers!` in `trace.jl`, roster mechanics with one `append!` of
  trace state;
- the device bracket in `devices.jl`, `Simulation`-typed and called from
  `sim.jl`'s run body, with `devices.jl` calling back into `sim.jl`;
- the twelve runtime diagnostic kinds in `dataplane.jl`, every other kind
  living in `diagnostics.jl`;
- `DataPlane` in `roster.jl`, assembled from `dataplane.jl` types;
- the tap resolver in `linearize.jl`, fifty references into `readers.jl`.

The cluster pass found `trace.jl` in three pieces (the replay core, the
deployment diff, the writer installation), `frame.jl` in two, and
`devices.jl` with the residue sweep disconnected from the contract.
`declare.jl` and `blocks.jl` fragment because one is a protocol and the
other a library, which is not drift.

Change coupling added nothing. The pairs that co-change without a static
edge (`executor.jl` with `sim.jl`, `assembly.jl` with `sim.jl`) are
explained by increments cutting across layers, and no pair's Jaccard
exceeded 0.31. What the pass did confirm is the hotspot: `sim.jl` appears in
161 of the 387 commits that touch `src/`.

## What moved

Each move is one commit, each puts a piece beside the thing that uses it,
and each updated the map in `implementation.md` and every comment that
named the old file. The suite's routed subset ran for each, and the full
gate for every commit touching a last-row file.

| commit | move |
|---|---|
| `434b2df` | Move the export chain's lookup from conditions.jl to readers.jl, beside the mount step that shares it |
| `c3b5944` | Move the user-code frame from build.jl to declare.jl, where the declaration layer that calls it lives |
| `75c4af4` | Move tier classification and the store checks from build.jl to assembly.jl, where the walk that runs them lives |
| `00c9175` | Move capture_stores from dataplane.jl to store.jl, beside the bundle it copies |
| `fc9fe3f` | Move the seeded-half scratch helpers from trim.jl to model.jl, shared with linearize.jl |
| `b63ef77` | Move the run's device bracket from devices.jl to sim.jl and include devices.jl ahead of it |
| `e2ae3a9` | Move the runtime channel's kinds from dataplane.jl to diagnostics.jl, beside every other kind |
| `036da8c` | Move the writer installation from trace.jl to roster.jl, beside the drain thunks it compiles |
| `ef005be` | Move the deployment walk from trace.jl to checkpoint.jl, beside the checkpoint's other mismatch namer |
| `0947bce` | Move the grid arithmetic from frame.jl to model.jl, where the checkpoint and the loop already read it |

Two findings were overruled by the constraints a move must respect.
`_input_faces_at` could not go to `assembly.jl`, which the envy score named,
because its signature names `Decls`, defined in `build.jl`, and a signature
is evaluated at load; `readers.jl`, the mount step that shares it, is the
earliest legal home. `_install_writers!` carried a header stating a reason
for its placement, that the writer's schema index rides in the thunks and
nothing else may fix it; on review that is an invariant about one function,
not one file, and the move keeps it.

## Ruled correct as they stood

- `DataPlane` stays in `roster.jl`. Its first field is a
  `Vector{RosterEntry}`, so `dataplane.jl` cannot hold it without
  `RosterEntry`, and it is the roster's holder in substance: the roster, the
  claims index, the id counter, the run's task registry, and the harness
  writer as the derived remainder of the claims.
- The tap resolver stays in `linearize.jl`. It consumes the read layer's
  vocabulary and produces linearization's: the three lists, seedability, the
  seed site, the `TapResolution` refusals. A service calling down is the
  normal direction; the envy score mostly says the service has little state
  of its own.
- The `model.jl`/`sim.jl` method overlap is `Simulation`'s forwarding layer,
  and the `declare.jl`/`blocks.jl` overlap is the library implementing the
  protocol.
- The seven data-plane functions in `sim.jl` (`drain!`, `publish!`,
  `_status` and their helpers) already form one section and are the frame's
  two halves; nothing to move.
- The name "stopped-sim services" stays. Every chapter 14 service has its
  primary method on a `Model`; the `Simulation` methods are gated doors over
  it. The name states the caller's side of the contract, and the map's
  `model.jl` entry states the receiver's.

## The split that was withdrawn

With the bracket moved in, `sim.jl` held about 2300 lines, and a split into
`sim.jl` (the `Simulation`, its lifecycle, its doors, the roster
configuration and its reads) and `run.jl` (the advances, the bracket, the
loop, the frame's two halves, the control verbs) was built, gated green, and
reverted the same day. It was proposed on the file's size and churn and on
the spec's stopped/running line. The measurement after the split showed
`sim.jl` reaching ten names in `run.jl`. Half were `replay!`, which is both
a door and an advance and would have moved. The other half were the doors
constructing `LoopHooks` to run boundary zero through the loop's hooks,
which §14.5 makes an ordinary boundary by design. The stopped/running line
separates lifecycle states, which the gates enforce; it is not a line
between bodies of code, because the code was written to share the boundary
machinery at exactly that point. A split needs a dependency seam, and a
seam the spec deliberately blurs is not one. Size and churn are not reasons.
The two commits were dropped from history before the push.

## The end state at `0947bce`

Upward weight fell from 90 to 41. What remains:

- the forwarding artifact between `model.jl`, `stepper.jl`, `frame.jl` and
  `sim.jl`, which is not a dependency;
- `leaves.jl` raising `diagnostics.jl` kinds, by design;
- `roster.jl` naming `DeviceHandle` in a typeassert, with the field typed
  `Any` for the include order, as its comment says;
- `readers.jl` reaching `conditions.jl` for `_leaf_offset`, a two-reference
  edge and the one candidate left over;
- `deployment.jl` and `model.jl` naming `RK4` and `AbstractStepper` in
  bodies ahead of `stepper.jl`, while `stepper.jl`'s `integrate!` needs the
  `Model`, a placement the include order cannot resolve without splitting
  the stepper's types from its integration.

`frame.jl` is the frame driver alone, `trace.jl` the trace and replay's
entry pass, `devices.jl` the contract, the handle, the wrapper and the
panel kit, and every diagnostic kind lives in `diagnostics.jl`. Line counts
at the end tip:

| file | lines |
|---|---|
| `diagnostics.jl` | 2465 |
| `sim.jl` | 2306 |
| `blocks.jl` | 1623 |
| `assembly.jl` | 1536 |
| `build.jl` | 1475 |
| all 26 files | 18109 |

# Unit D, phase 1 (blind): assertions in new.md

V1 A device is any attached participant in the periphery.
V2 A device produces writes on its own task, whenever its hardware or peer hands it a datum.
V3 The loop consumes them at the top of each frame; a frame is one iteration of the loop.
V4 Something must hold each device's pending writes and hand the loop an applicable value between the two rates.
V5 That something is the staging cell, the per-device atomic holding place for pending writes; a compound term distinct from a table cell [D-121].
V6 Unlike a table cell, it is mutated frame by frame, outside the table's publish-once discipline.
V7 Coalescing is the CAS merge keeping one pending set of writes per device. (gloss)
V8 Drain is the frame-top swap that applies staged device writes to root inputs and empties the cell. (gloss)
V9 Staging keeps one atomic staging cell per attached device [D-024]. (bold)
V10 Staging has one coalescing policy, CAS merge, newest wins per face [D-104]. (bold)
V11 A face is the name a port wears on its component's boundary.
V12 A device's staging cell has a single writer, its own device task.
V13 It holds that device's latest pending batch; a batch is a set of writes applied whole at the next drain.
V14 Each write targets a root input (the root component's own input face).
V15 Staging merges the incoming batch into the pending one; untouched faces survive, re-staged faces take the newest level; that is the per-face ZOH.
V16 For a device's staging cell, the CAS can fail only because a drain intercepted the old batch, so the retry is bounded.
V17 The failure case is precisely correct: intercepted writes are already applied and must not be re-staged.
V18 The harness cell is the always-present staging cell of the harness writer.
V19 The harness cell is the exception: several tasks may stage into it concurrently, and a CAS failing because another stager merged first retries the same way [D-200].
V20 Merge is the only policy because it is always correct.
V21 A complete writer covers every face in every batch; a joystick delivering its full write-set every poll is the type case.
V22 For a complete writer merge and overwrite are provably the same operation, so overwrite is a degenerate fast path, not a second semantics.
V23 A sparse writer stages only what was touched; the GUI and a JSON peer are sparse writers.
V24 Under overwrite sparse writers lose writes silently.
V25 The worked example works that hazard through: a pending `flaps` edit clobbered by an unrelated `gear` message, undrained and undiagnosable.
V26 A user-facing overwrite opt-in (`complete(binding)`) is closed [D-104].
V27 The levels doctrine: staged values are levels, never deltas [D-024] (bold); `press_count = 17`, never `presses += 1`.
V28 Levels are idempotent and survive coalescing.
V29 Edge logic follows the levels doctrine; button edges ride as monotonic press counters, which devices stage.
V30 Accumulators (trim offsets, flap detents) are model state, not mapping state [D-045].
V31 Mappings run on the device task [D-024] (bold).
V32 FlightCore, the predecessor, had `assign_input!(mdl, mapping, data)`; the framework has pure `map_input(data, mapping) → batch`.
V33 Thereby user-extensible code never executes inside the loop's frame, and the trace (primary record of a session) consists of root-input-level batches.
V34 Mappings are binding data, not shaping code [D-045] (bold).
V35 A mapping is a declarative table: axis/button → root input, plus per-axis conditioning parameters (deadzone, expo strength).
V36 The shipped `TableBinding` applies those parameters in its generic `map_input` on the device task, as the shared pure helper with an owner [§11.6].
V37 A face's meaning is writer-independent [D-045] (bold).
V38 Faces therefore carry post-conditioning semantics.
V39 A GUI slider or script writes the same command a curved stick delivers; running a mouse drag through a deadzone would be absurd.
V40 This GUI-parity test places conditioning upstream.
V41 Aircraft-semantic derivation must not ride along [D-045]; command fan-out like illustrative `q_ref = q_sf · axis` is FCS design and lives in-model, in the avionics.
V42 The trace records post-conditioning levels; those are exactly what the model consumed, so replay is exact. Replay = ordinary loop, drain reading the trace.
V43 Raw stick levels are the known, accepted loss; re-running a session through different curves is impossible.
V44 The staged representation is fixed per attachment, compiled at attach [D-104] (bold).
V45 A claim set is the faces a device may write; an enumerated writer's claim set and root-input types are known at attach, because `claims(binding)` [§11.6] is read against the root contract (the root component's declared interface).
V46 So the framework fixes the staging cell's content type there.
V47 The content type is a pair of positional tuples over the claim set [D-202] (bold): a values tuple `Tuple{T₁,…,Tₙ}` concretely typed, and a parallel `Bool` touched-mask.
V48 Set mask position = staged this time; clear = not touched, never "reset".
V49 Untouched positions carry placeholder values, never read; the mask guards every consumer, so no placeholder reaches the model.
V50 The batch is therefore isbits with one concrete layout per writer.
V51 The levels doctrine is untouched; root inputs only receive masked positions.
V52 The face-name → position schema lives in the roster entry (writer's record in the list of attached devices) [D-104].
V53 Sketch: claim set f₁…fₙ, Tᵢ declared type; attach fixes values/mask types; stage! on device task, shim converts pairs to `incoming`; merge per-position; drain scatters skipping unmasked.
V54 One concrete layout is what makes the frame-top drain compilable.
V55 The alternative carrier `Union{Nothing,Tᵢ}` per face has no such layout: tuple types are covariant, each touched-combination is its own concrete type, so applying a batch would specialize at frame top on which faces it touched [D-202].
V56 The mask buys the layout back at the price of dead placeholders, filled from the declaration's probe values (real values the build evaluates each user function with), constructible for every declared type and unreachable behind the mask guard.
V57 The merge is positional and mask-driven, so it compiles straight-line, leans on no small-tuple heuristic, does not degrade with surface width [D-202].
V58 The drain applies each staging cell through an attach-compiled scatter, position → root-input cell, statically typed, masked-off positions skipped [D-104].
V59 The scatter is the exact mirror of the compiled output gather [§11.2].
V60 Authors never build the shape by hand; `map_input` returns face ⇒ value pairs; `stage!` normalizes through an attach-compiled shim [D-104].
V61 The shim maps name to position, converts to declared type, sets the mask.
V62 It confines residual name-shaped dynamism to one framework-owned conversion on the device task, where wire-shaped becomes system-shaped data.
V63 Author-built total tuples are rejected as a padding form, the same disease D-074 and the handler return law refuse [D-104].
V64 A greedy claim (unclaimed complement, computed by the framework) needs no special treatment [D-174]; computed at the attach point, an ordinary claim set by shape compilation [§11.3].
V65 The GUI's staging cell is compiled exactly as a joystick's.
V66 The harness cell gets the same treatment [D-174]: under the roster freeze (attach and detach as stopped-sim ops) its derived surface, the unclaimed complement, is static, compiled to a positional shape.
V67 That shape is recompiled at each attach!/detach!, both stopped-sim points, and carries the same shim, merge and scatter.
V68 Being always present, the harness cell gets compilation unasked; it is the one staging cell whose shape the framework derives rather than receives.
V69 Every staging cell has one representation and one mechanism; the name-keyed dynamic path does not exist; no face name is ever resolved inside the loop's frame.
V70 Edge case: a pending harness batch staged before a stopped-sim attach! may hold the old shape or name a newly claimed face; attach renormalizes: reshaped, newly-claimed faces discarded with `ClaimedFaceEntry`. So the run always starts with staging cells matching schemas.
V71 Diagnostic sites follow the compilation, so every one moves to staging [D-044].
V72 Face-name validity, surface membership, value convertibility are static facts of the run; every check runs in stage!'s normalization on the writer's task.
V73 A device's out-of-claim face has no position and is rejected with `OutOfClaimEntry`; staging is earlier, better-attributed than drain; kind and payload (structured data beside the kind) are the same either way.
V74 The GUI is included, its claim being ordinary.
V75 A harness write to a claimed face is rejected the same way with `ClaimedFaceEntry` naming the incumbent device [D-174].
V76 A value that cannot convert is discarded with `EntryTypeMismatch` [App C, D-105], at the same spot.
V77 Nothing remains at the drain; with surfaces frozen there is no fact only the drain can know; the drain is pure application [D-106].
V78 At frame top the drain takes each device's staging cell with one `atomicswap(cell, nothing)` [D-024] (bold).
V79 The swap is an indivisible take, so no lost-write window.
V80 Each taken cell is applied through its compiled scatter, in attachment order [D-024].
V81 Attachment order is retained as a deterministic application order; under root-input exclusivity cross-device writes to one root input cannot arise, so order matters only for diagnostics [D-044].
V82 Which frame a write lands in remains wall-clock reality; the drain guarantees the frame's outcome is a pure function of drained batches.
V83 Because the roster is fixed at run!, the drain is fully compilable [D-106].
V84 Staging cells and scatters form a heterogeneous but known tuple the frame function can specialize on: zero dynamic dispatch at frame top.
V85 Same per-configuration compile trade the executor (compiled form of the stage execution order, §9.7) makes, incurred only at stopped-sim attach points.
V86 Specialization is an implementation freedom the freeze creates, not an obligation [D-106]; iterating a roster array costs a handful of dispatches per frame and remains acceptable.
V87 Two shapes rejected: per-input atomic cells and a shared lock-free batch stack [D-024]; the worked example examines both.
V88 The worked example is the exercise that selected per-device cells.
V89 It produced for §11.7 the active-widget contract, which §11.7 rejects [D-026], and the port-resolution answer to panel reuse; a port is the addressable unit of the model.
V90 Setup: first-order filter, root inputs u_cmd and τ; fictitious 100 Hz single-axis joystick streaming a slow ramp onto u_cmd (complete writer); 60 Hz GUI with sliders for both (sparse); boundaries (published consistency points where snapshots go out) at 50 Hz, pace 1. Interference on u_cmd is the point.
V91 Three candidates: per-input cells, batch stack, per-device cells; user-level listing identical across all three, so ergonomics cannot discriminate; behavior under a concrete interleaving did.
V92 Root-input exclusivity [§11.3] rules out the contest: a second writer on u_cmd is an attach-time error.
V93 What the test settles is the cell shapes: atomicity, coalescing, pause behavior and the peek rule (widget shows own pending write if any, else snapshot value).
V94 Its conflict-precedence comparison and active-widget stage-every-pass contract [§11.7] describe a contested-input world the design does not have; findings read under that scope.
V95 Drag: under per-input cells and batch stack, each frame's conflict resolves by last-store/last-push wall-clock order [D-024]; 16.7 ms vs 10 ms -> alternation on the cadence beat, wobble, differs run to run; trace replays a given run exactly but behavior is still a timing artifact.
V96 Under per-device cells the GUI stages in every drag frame (renders at least once per 20 ms frame, active-widget contract stages every pass); GUI wins every drain by attachment order; clean deterministic override for exactly the grab duration; same user code, qualitatively different physics.
V97 Paused, per-input: still-polling joystick overwrites u_cmd edit about 10 ms later [D-024]; knob snaps back, edit never applies.
V98 Paused, batch stack: edit buried under newer pushes; chain grows at polling rate, ~10³ nodes per 10 s pause, every peek walks the chain [D-024].
V99 Paused, per-device: u_cmd edit holds in GUI's cell across pause; knob keeps it by §11.7 peek rule; merges with τ edit (sparse accumulation); applies at un-pause drain; holds one deterministic frame before joystick reclaims; that is the honest semantics of one-shot editing a streamed input. Uncontested τ edit works under all three.
V100 Corrections: sparse-writer lost-write hazard is specific to one-cell-per-device layouts; per-input cells cannot lose independent-input writes, so CAS merge is per-device cells' antidote, not a general need; batch stack's conflict order is temporal, not attachment-order policy [D-024].
V101 Discoveries: two, the active-widget contract and the port-resolution answer to panel reuse [§11.7]; the second came from asking how the filter's panel survives the filter becoming an embedded component (a unit of modeling) with u_cmd driven by another component.

# Unit B verify, phase 1 (blind read of new.md)

Intro
- V1 Every consumer of model state needs a picture that holds still while read; GUI panels, output devices and the log are such consumers.
- V2 None of them should have to make the loop wait.
- V3 One immutable value is published per boundary, handed out through a single atomic reference.
- V4 Three things follow: snapshot build/publication, log retention under a bound, output-device addressing.

Snapshot and publication
- V5 Loop builds each snapshot in private memory, publishes with a single release-store to `@atomic latest`; readers acquire-load. [D-023] (bold)
- V6 Snapshot carries signal table, `t`, frame index, published-boundary ordinal [§12.3], framework status [§11.8].
- V7 Frame index places a `t*` snapshot in its frame, since a `t*` publication counts its own ordinal. [D-261]
- V8 Readers then work with an immutable coherent world as long as they like.
- V9 Calling task reads the same value via `latest(sim)`, an inspection read. [§12.6]
- V10 Exchange wait-free both directions. [D-023]
- V11 Wedged reader cannot delay publication; loop cannot tear a reader's view.
- V12 Publication only after the boundary sequence completes. [§10.3, D-293]
- V13 Binding rule: nothing reachable from a published snapshot is ever written again. [D-023] (bold)
- V14 Soundness of lock-free reading rests on it.
- V15 Table's immutable values make the compiler enforce most of it. [§4.1, §7]
- V16 Framework status is a concrete frozen value, not a window on live bookkeeping. [D-136]; contents listed in §11.8.
- V17 Binding rule forces that shape; a status referencing a still-filling accumulator would change after publication.
- V18 Captured table is the whole table: declared ports, all public [§8.3]; no presentation layer has anything to filter.
- V19 Undeclared intermediates not in it, because only declared ports are cells [§8.3].
- V20 Inspection path for one is promotion to declared output [D-194]; a line in `y_types` makes it appear in snapshot, log, GUI, wiring; visibility is authored.
- V21 Captured table includes root inputs [D-047] (bold).
- V22 Root inputs are source cells, not state stores, so they ride along; essential not incidental.
- V23 Peek falls back to the snapshot [§11.7]; that fallback is what an idle live widget displays.
- V24 Read-only mirrors of claimed root inputs (axis sliders under joystick claim) show applied root-input value from snapshot.
- V25 Root input values in the log are derived, recomputable from the trace; consistent since snapshots are derived wholesale.
- V26 Snapshot does not carry state stores x, s, m [D-038] (bold).
- V27 Reason 1: state trajectory is derived, recomputable from trace header plus batches [§11.5]; recomputation is bit-identical replay.
- V28 Reason 2: per-boundary capture would systematically record derived data, the asymmetry D-029 refuses in the other direction.
- V29 "Private state at t=37.2" answered by replay to 37.2 and inspecting live stores [D-038].
- V30 Remedy for a state field wanted in logs/GUI: declare public, return from `y_state` [§5.3, D-252]; costs one cell per sweep.
- V31 Post-run continuation reads live stores directly.
- V32 Periodic full-state checkpoints are a guarded addition, opt-in log policy [D-038]; would allow warm restart without replay from zero; each retains a checkpoint, value `checkpoint(sim)` returns [§12.6].
- V33 A dev-mode flag reading all state fields is a possible future diagnostic; a reader over stores, never a port class [D-252].
- V34 Event firings not recorded [D-309] (bold). Log holds boundary snapshots, trace holds staged inputs [§11.5]; neither carries per-event record.
- V35 Replay plus published modes recovers which events fired at which boundary.
- V36 Remedy: declare mode field public, return from `y_state` [D-252]; such a field is in every snapshot.
- V37 Event-firing stream is a guarded addition.

Log
- V38 Log is a vector of retained snapshot references [D-023] (bold); logging dissolves into publication; same objects, zero extra copies.
- V39 FlightCore `SavingCallback` per-step deepcopy detour disappears.
- V40 Cost one snapshot allocation per boundary, on framework side of §9.8 allocation scope, which already carved out logging.
- V41 Logged snapshots not garbage; unlogged die young.
- V42 Preallocated snapshot buffers rejected [D-023].
- V43 Log retention = trace's kill switch plus decimation [D-038] (bold); same on/off switch as trace [§11.5]; plus keep-every-kth `log_every` [App B].
- V44 Derived/primary split [D-038] decides why decimation admissible here, not on the trace: log recomputable by replay, thinned log costs resolution in a view, not a record; thinning trace destroys only primary account [D-029].
- V45 Decimation is retention only; every boundary still runs, is published to live readers, enters the trace [D-038].
- V46 Decimation slows growth, doesn't stop it. Default `log = true, log_every = 1` with `t_end = Inf` (init!/run! defaults) [App B]; log grows for session length.
- V47 At C172X (FlightApps' Cessna 172X) scale and 50 Hz, gigabytes per hour; ends in unwarned OOM.
- V48 Log takes a retention bound beside switch and stride [D-137] (bold); `log_max` = max retained references; default 65536 (2^16), `Inf` explicit opt-out [D-137].
- V49 Four recording keywords on `init!` with defaults [App B]: code block `trace = true, log = true, log_every = 1, log_max = 65536`.
- V50 Bound is a count, not a memory budget [D-137] (bold). Snapshots immutable object graphs [§4.1] with internal sharing; field handle rides as reference to build-time-frozen data [§4.4, §9.8]; byte accounting fuzzy and platform-dependent; count exact; converts via `Base.summarysize` of one snapshot.
- V51 Default finite unconditionally [D-137] (bold); not modal on `t_end`; short finite run never notices; one number simpler than two regimes.
- V52 At 50 Hz full density, 2^16 boundaries ≈ 22 minutes before dropping.
- V53 When log fills, retention stride doubles, coverage stays global [D-137] (bold). Rolling window rejected [D-137]. Progressive re-decimation; after k generations stride `log_every · 2^k`; whole run plottable; density coarsens, never extent.
- V54 Doubling is the division of labor [D-038] carried through; chief consumer is whole-session post-run plot; nobody plots hours at 50 Hz; full density over a segment recovered by replay [§11.5, §12.7].
- V55 Guarantees normative, not mechanism [D-137] (bold); three: bound respected continuously (count never exceeds `log_max`); coverage global at effective stride; endpoints kept.
- V56 Endpoints retained unconditionally [D-137] (bold): first and terminal snapshot [§12.4, §13.5] survive any `log_every`/`log_max`, don't count against bound; two extra references.
- V57 First = boundary-zero snapshot under `init!` [§14.5], and snapshot the door publishes under `restore!`/`replay!` [§12.6]; stride counts boundaries from it.
- V58 Terminal snapshot's status carries final cumulative diagnostic counters [§11.8]; so endpoints and diagnostic account always outlive retention.
- V59 Mechanism sketch non-binding: amortized; stride doubles immediately on fill; each subsequent retained append releases one predecessor of previous generation; cursor over odd indices, O(1) amortized, physical compaction once per generation; thinning completes exactly when refill does.
- V60 Generation chart (blockquote).
- V61 Amortizing vs one-shot halving is a responsiveness choice [D-137]; drops one old snapshot per retained append, same trickle as rolling window; global coverage costs nothing extra in GC pressure.
- V62 Loop's work is pointer bookkeeping, microseconds, framework side of scope [§9.8]; publication stays wait-free, readers never block; a reader holding a released snapshot keeps it alive.
- V63 `totals` monotonicity across logged snapshots [§11.8] untouched; re-decimation, like decimation, loses which boundary, never how many.
- V64 `log_max` is a view policy, not trajectory-determining [D-137] (bold); like `log`, `log_every` stays out of the trace header's `Deployment`; replay neither records nor compares it [§11.5, §12.7].
- V65 Log's `sizehint!` is `log_max` [§9.8].

Output-device bindings
- V66 Output-device bindings are snapshot bindings [D-083] (bold); output device consumes snapshots per §12.3; examples telemetry, disk streaming, XPlane visualizer (FlightCore's `XPlane12Control`).
- V67 Addresses reads with selectors [§14.4]; reach any cell since inspection reads admit deep paths.
- V68 Binding resolved at attach against the `Build` with did-you-mean, compiled to one gather, output half of binding interface [§11.6].
- V69 `map_output` therefore receives a labeled NamedTuple [§11.6] rather than doing path lookups.
- V70 A substitution breaking a binding therefore fails at attach, not silent garbage; attach refuses with `ReadBindingUnresolved` [D-130].
- V71 Exporting logger skips or summarizes field-handle signals.
- V72 Output device's snapshot read is inspection [§13.5, D-083]; human-facing, no effect on run semantics; same sort as log and GUI deep panels.
- V73 Every cell reachable, table public [§8.3]; an intermediate a device wants is promoted to declared output.
- V74 Binding chooses its side [D-129]: deep path = inspection read, zero promises, free, right for this build; exported face via `get_face(name)` [§14.4] = integration read, named, curated, meaning-stable under substitution, for consumers outliving the build.
- V75 Face meaning-stability comes from writer-independent semantics [§11.4, D-045].
- V76 Attach validation converts structural drift to loud errors on both sides [D-083]; only faces protect against semantic drift (same path, same type, different meaning, e.g. CG vs body-origin velocity); nothing else can, meaning not in schema.
- V77 Semantically generic consumers should bind faces [D-083]; visualizer needs pose, every aircraft has one.
- V78 Aircraft families should export the conventional surface; library/migration deliverable (migration outline companion).
- V79 Wrapper types make face semantics structurally checkable; `VelocityData` illustrative, `v_eb_b` defined at the type as body-origin velocity; bare vector doesn't wire; wrapping wrong quantity is a lie, not drift.

# G5a: rows for the fixer

Each row: the site at the pinned tip f14dbc1d, the claim, the verifier's evidence and proposed fix, and its note. The fix is a proposal: conform it to the rules and to the code.

## K11b-033 (drift, clear=True)

- at: `design/companions/inbound_periphery_walkthrough.md:81`
- claim: `joystick_binding = (stick_y = (...), throttle = (...))` is a binding
- evidence: src/sim.jl:2505 attach! takes new_binding::AbstractBinding; src/bindings.jl:55 the shipped table binding is TableBinding. Probe K033: the bare NamedTuple is not an AbstractBinding, and attach! with it throws MethodError. TableBinding with the same entries gives claims ["elevator", "throttle"].
- fix: joystick_binding = TableBinding(stick_y  = (face = "elevator", expo = 0.6),
                               throttle = (face = "throttle",))

## K11b-056 (deviation, clear=True)

- at: `design/companions/inbound_periphery_walkthrough.md:116`
- claim: mutable struct StagingCell with `@atomic pending::Union{Nothing, Batch}`
- evidence: src/dataplane.jl:25-27 `mutable struct StagingCell{B}; @atomic pending::Union{Nothing,Base.RefValue{B}}`: parametric, and the batch is boxed in a Ref (probe K056). Present since increment 9 (bccd9a56). The docstring gives the reason (one pointer-width atomic, CAS on identity), and no log entry records it.
- fix: mutable struct StagingCell{B}
    @atomic pending::Union{Nothing, Base.RefValue{B}}   # the latest not-yet-applied batch, boxed
end

## K11b-063 (drift, clear=True)

- at: `design/companions/inbound_periphery_walkthrough.md:129`
- claim: map_input(datum, binding) returns the NamedTuple `(throttle = 0.70, elevator = -0.05)`
- evidence: src/bindings.jl:126-127 map_input returns a Tuple of "face" => value Pairs (docstring :101 `-> Tuple`). Probe K063 gives type Tuple{Pair{String,Float64},Pair{String,Float64}} and value ("throttle" => 0.7, "elevator" => ...), not a NamedTuple. The doc's own line 125 says pairs.
- fix: map_input(datum, binding)      # ⇒ ("throttle" => 0.70, "elevator" => -0.05)

## K11b-087 (drift, clear=True)

- at: `design/companions/inbound_periphery_walkthrough.md:174`
- claim: the trace's header holds the initial state, root-input values and per-writer schemas
- evidence: src/trace.jl:78-83 Trace has header::Checkpoint and a separate schemas list; src/checkpoint.jl:106-110 Checkpoint holds state, frame and boundary, so the root-input values come with the state's table and the schemas are not in it (probe K087).
- fix: (the per-frame sequence of device-tagged drained batches, plus the header's initial state and root-input values and the per-writer schemas beside it)

## K11b-112 (drift, clear=True)

- at: `design/companions/inbound_periphery_walkthrough.md:217`
- claim: Two warning kinds cover the violations: OutOfClaimEntry is a device-surface violation, ClaimedFaceEntry the harness violation 'and only that'
- evidence: src/dataplane.jl:426-431 ClaimedFaceEntry is raised for the harness alone (true), but the harness writer also raises OutOfClaimEntry for a face naming no root input. Probe K112: stage!(sim, "nosuch" => 1.0) puts an OutOfClaimEntry in the harness cell. The doc presents OutOfClaimEntry as the device-surface kind only.
- fix: - `OutOfClaimEntry` — a device-surface violation: the face has no position in the writer's schema; also a harness write naming no root input at all. ...
- `ClaimedFaceEntry` — a harness-writer violation, and only that: `stage!` named a face some device claims in this run's partition. ...

## K11b-113 (drift, clear=True)

- at: `design/companions/inbound_periphery_walkthrough.md:220`
- claim: OutOfClaimEntry payload includes the writer id
- evidence: src/diagnostics.jl:1602-1607 OutOfClaimEntry has fields face, value, surface, incumbent, and no writer id (probe K113). src/diagnostics.jl:1562-1564: "Writer attribution is never a payload field: the channel is per-writer, so the cell supplies it". Spec Appendix C lists the payload without it.
- fix: Face, discarded value, the claim set (plus the incumbent's id when the face is claimed elsewhere); the writer is named by the cell the warning lands in, never by the payload.

## S11a-005 (drift, clear=True)

- at: `design/spec.md:7875`
- claim: Frame loop order is drain, integrate, boundary sequence, publish
- evidence: src/frame.jl:117-176 (_frame_steps!): after frame_top! (the drain, src/sim.jl:2020-2023) the frame loops over spans and steps, and each step end runs run_boundary! then settled!, which publishes (src/sim.jl:2040-2042). Probe P2: one frame under h_max = Δt_frame/3 publishes 3 boundaries. The drain-first order holds, but integrate, boundary sequence and publish repeat at every step end and every t*, not once per frame.
- fix: Each frame is one iteration of the loop. The loop runs the drain (the frame-top swap that applies staged device writes to the root inputs), then integrates to each boundary in turn, every step end and every `t*` included, and runs the boundary sequence and publishes at each one ([§10.5][s10-5]).

## S11a-186 (drift, clear=True)

- at: `design/spec.md:8200`
- claim: Attach refuses a binding whose read fails with the read's own kind, ReadResolution
- evidence: src/readers.jl:757-762: _rebase walks the read's path with resolve_authored, which pushes a PathResolution for a path naming no component (src/structure.jl:1128-1139). Probe P5: attach! with get_output("q", "y") on a model with no component q raises PathResolution beside the ReadResolution values. test/test_bindings.jl:213-215 asserts the same. The attach! docstring (src/sim.jl:2496-2499), the _compile_binding_reads docstring (src/bindings.jl:160-163) and spec 11455-11456 all name both kinds. Spec 8200 names ReadResolution alone.
- fix: **Attach refuses such a binding with the read's own kind, `ReadResolution`, or the path walk's `PathResolution` for a path that names no component, every violation collected** ([§13.1][s13-1], [§13.3][s13-3], [D-406][d-406]).

## S11c-001 (deviation, clear=True)

- at: `design/spec.md:8756`
- claim: The trace is the sequence of drained, device-tagged batches per frame
- evidence: src/trace.jl:22-25 tags a record by writer index into trace.schemas, and the harness writer is a schema entry (src/sim.jl:2671 drains plane.harness_drain into the same trace). Probe P3 (probe.jl:26) with no device rostered records 300 batches whose only writer tag is "harness".
- fix: The input trace is the sequence of drained, writer-tagged batches per frame, each batch tagged by the device or the harness writer that staged it.
- note: This is a wording issue. The harness writer is not a device (glossary g-harness-writer), but its batches are recorded and replayed like a device's. The glossary entry g-trace (spec.md:17118) repeats "device-tagged".

## S11c-014 (drift, clear=True)

- at: `design/spec.md:8819`
- claim: A checkpoint holds x, the s and m stores, the signal table, the guard priors, t and t0, the counters, the fingerprint and the deployment (no other field)
- evidence: src/checkpoint.jl:85-96. ModelState also has a `stepper` field, the stepper's carried state. Probe P4 (probe.jl:29) prints (:x, :s, :m, :table, :prior, :stepper, :t, :t₀, :deployment, :layout).
- fix: A checkpoint holds the flat buffer `x`, the `s` and `m` stores, the whole signal table (the collection of cells holding every produced signal), the guard priors, the stepper's carried state, `t` and `t₀`, the frame and boundary counters, and the fingerprint (the structural layout) and the deployment ([D-319][d-319], [D-452][d-452]).
- note: The move is recorded in the D-274 annotation of 2026-11-11 (log.md:12433-12436), in D-452, in commit e7dacf9e, and in §12.6's list (spec.md:10629).

## S11c-041 (drift, clear=True)

- at: `design/spec.md:8978`
- claim: Wrapper sketch files the crash as `report!(entry, DeviceCrash(e))`
- evidence: src/diagnostics.jl:1688-1691 gives DeviceCrash two fields, cause and abort. The wrapper files report!(entry, DeviceCrash(err, entry.should_abort)) at src/devices.jl:667. Probe P6 (probe.jl:35) shows the one-argument DeviceCrash(e) is not applicable.
- fix:     report!(entry, DeviceCrash(e, entry.should_abort))   # §12.4(6): sim continues, device absent
- note: D-097 records the payload, which carries the should_abort disposition (log.md:3302). §12.4's bracket sketch already uses the two-argument form (spec.md:10138). Commit 51741261 added report!(entry, DeviceCrash).

## S11d-004 (deviation, clear=True)

- at: `design/spec.md:9483`
- claim: `incumbent_status(view, snapshot)` returns the incumbent's writer record, or `nothing` for a port no device writes
- evidence: src/devices.jl:590-594 returns nothing only when view.incumbent is empty, which means no root input drives the port. src/devices.jl:525-527 makes "harness" the incumbent of a root input no device claims, and src/sim.jl:2839 publishes a harness record. So a port no device writes gets the harness's WriterStatus, not nothing. test/test_devices.jl:1167 asserts this. Probe: the unclaimed root input view has incumbent "harness" and its status has who == harness, and only the component-driven view returns nothing.
- fix: **`incumbent_status(view, snapshot)` returns the incumbent's writer record** from the snapshot's status ([§11.8][s11-8]), the harness writer's for a root input no device claims, or `nothing` for a port no root input drives ([D-270][d-270]).

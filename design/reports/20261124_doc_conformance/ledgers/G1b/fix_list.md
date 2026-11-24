# G1b: rows for the fixer

Each row: the site at the pinned tip 02745494, the claim, the verifier's evidence and proposed fix, and its note. The fix is a proposal: conform it to the rules and to the code.

## C1-065 (drift, clear=True)

- at: `design/spec.md:15502`
- claim: WireTypeMismatch carries both face names, empty where a side is bare
- evidence: src/diagnostics.jl:437 and :440 type face and producer_port as Symbol, never empty. src/build.jl:891-893 fills them from the resolved faces. Probe P3 (bare Int producer into a bare Bool consumer) printed face=:u and producer_port=:y, not empty names.
- fix: Both endpoint paths, both face names (`u` or `y` on a bare contract side, [D-437][d-437]), declared entry type, producer face type.
- note: D-437 (design/log.md:18128) gives a bare contract the default face u or y and rules that a face name is never empty.

## C1-205 (deviation, clear=True)

- at: `design/spec.md:15654`
- claim: ProducedByTwoStages carries one port name
- evidence: src/diagnostics.jl:1057 types the payload as ports::Vector{Symbol}. src/build.jl:1206-1208 puts every port both stages returned into one diagnostic (collect(twice)). Probe P6a printed ProducedByTwoStages("c", [:a, :b]): one occurrence carrying two port names.
- fix: Component path, the port names both stages return (`y` on a bare contract, [D-437][d-437]).
- note: The vector field dates from the first commit of the kinds (415ed0b7), before D-252. D-252 says the kind 'carries the component path and the port name'.

## C1-209 (deviation, clear=True)

- at: `design/spec.md:15659`
- claim: DeclaredNotProduced carries one declared name
- evidence: src/diagnostics.jl:1069 types the payload as ports::Vector{Symbol}. src/build.jl:1111-1117 puts every unproduced port of a component into one diagnostic. Probe P6b printed DeclaredNotProduced("c", [:a, :b], [:c], [:q]): one occurrence carrying two declared names.
- fix: Component path, the declared names no stage produces (`y` on a bare contract, [D-437][d-437]), the stage-product list and the state-field list, the latter as context.
- note: D-252's rationale says DeclaredNotProduced 'names the declared port', singular. The message itself says 'declared port(s)' (src/diagnostics.jl:1075).

## C2-055 (deviation, clear=True)

- at: `design/spec.md:15740`
- claim: payload carries the binding entry
- evidence: src/diagnostics.jl:1511-1516 AttachUnknownFace carries device, binding::String (the binding type, filled with _typename(b) at src/roster.jl:363), face and candidates; no field holds a binding entry, and the face is the claims entry as Symbol
- fix: The device (by type, since its roster id is assigned only at admission), the binding by type, face name, the root input-face list.
- note: "binding entry" dates from the Appendix C table of d0e20505, before the code; read as "the binding" it would match, but the payload holds the binding's type name and nothing called an entry.

## C2-299 (deviation, clear=True)

- at: `design/spec.md:16018`
- claim: payload carries the offending value's type and the discarded value as two items
- evidence: src/diagnostics.jl:1618-1622 EntryTypeMismatch carries face, value and declared; the value's type has no field of its own and is only typeof(value) (src/dataplane.jl:438)
- fix: Face name, the discarded value, whose type is the offending one, and the root input's declared type.
- note: If the audit counts a type read off a carried value as carried, this row conforms; the payload holds one item, not two.

## CV1-107 (deviation, clear=True)

- at: `src/diagnostics.jl:1618`
- claim: Appendix C says EntryTypeMismatch carries `the offending value's type`; the payload is face, value and declared, with no value type
- evidence: src/diagnostics.jl:1618-1622: the EntryTypeMismatch fields are (face, value, declared) (probe 'fields EntryTypeMismatch'). The raise site src/dataplane.jl:438 passes the face, the value and the declared type. No field carries the value's type, and the message prints only repr(value) (probe '107 msg'). Appendix C (spec.md:16017-16019) lists 'the offending value's type' as payload, next to 'the discarded value'.
- fix: - **`EntryTypeMismatch`** ([§11.4][s11-4]). Warning · runtime · rate-limited. Face name, the root input's declared type, the discarded value.
- coordinator: Same Appendix C entry as C2-299 (EntryTypeMismatch): apply one edit for both.

## CV1-060 (deviation, clear=True)

- at: `src/diagnostics.jl:599`
- claim: Appendix C says ClassMixed carries `the local_wires declaration and the offending primitive declarations`; the payload is path and declarations only, `local_wires` is in the message
- evidence: src/diagnostics.jl:599-602: the ClassMixed fields are (path, declarations) only (probe 'fields ClassMixed'). `local_wires` appears only in the message text (probe '060 msg'). ASSEMBLY_FAMILY is (:local_wires,) (src/assembly.jl:15), so no field could vary. Appendix C (spec.md:15550-15551) lists 'the `local_wires` declaration' as payload. No log entry or pending.md bullet records the shortfall.
- fix: - **`ClassMixed`** ([§8.5][s8-5]). Error · build · fail-fast. Component path and the offending primitive declarations; the message names the `local_wires` declaration.

## CV1-085 (deviation, clear=True)

- at: `src/diagnostics.jl:1183`
- claim: Appendix C says GuardForm carries `both admissible forms`; the payload is path, event, observed, and the two forms appear only in the message
- evidence: src/diagnostics.jl:1183-1187: the GuardForm fields are (path, event, observed) (probe 'fields GuardForm'). The two admissible forms appear only in the message (probe '085 msg'). Appendix C (spec.md:15686-15687) lists 'both admissible forms' as payload. §9.5 (spec.md:5990) says the error names them, which the message does.
- fix: - **`GuardForm`** ([§9.5][s9-5]). Error · build · fail-fast. Component path, event name, observed probe return type; the message names both admissible forms.

## CV1-093 (drift, clear=True)

- at: `src/diagnostics.jl:1319`
- claim: `site` vocabulary :run! | :replay! | :step! cites D-249, whose entry lists the binding site as one of three, the constructor, run! or replay!
- evidence: src/diagnostics.jl:1319 reads `site::Symbol # :run! | :replay! | :step!, the advance (D-249)`. D-249's fourth bullet (log.md:10283-10284) concerns the retired StopFaceInvalid and its sites, the constructor, run! and replay!. Its 2026-10-15 annotation marks that bullet historical. D-316 (log.md:14419-14425) introduces StopRequestInvalid(path, site, candidates) with run!, replay! and step! as the sites that take `ignore_stop_requests`.
- fix: site::Symbol # :run! | :replay! | :step!, the advance (D-316)

## CV1-104 (deviation, clear=True)

- at: `src/diagnostics.jl:1597`
- claim: Appendix C says MalformedDatum carries `The cause exception`; the field is `cause::Any`, and the docstring says any value the device chooses
- evidence: src/diagnostics.jl:1598 declares `cause::Any`, and MalformedDatum("s") builds (probe). The docstring (src/diagnostics.jl:1585) says cause is any value the device chooses, such as the caught exception. Appendix C (spec.md:16014-16016) says 'The cause exception'. The field has been untyped since commit 415ed0b7. No log entry types it: D-105 and D-217 write only `MalformedDatum(cause)`.
- fix: - **`MalformedDatum`** (…). Warning · runtime · rate-limited, a repeating source ([§11.8][s11-8]). The cause, any value the device records, typically the caught exception. Emitted by the author's loop body via `report!(handle, …)`.

## CV1-105 (drift, clear=True)

- at: `src/diagnostics.jl:1597`
- claim: code_map's list of the runtime channel's kinds omits `MalformedDatum`, a member of `KINDS` beside the thirteen it names
- evidence: src/dataplane.jl:36-38 KINDS = (MalformedDatum, OutOfClaimEntry, ClaimedFaceEntry, EntryTypeMismatch, ChatteringBudget, FiringBudget, StepFloor, DebtReanchor, UnboundedRun, ThreadBudget, DeviceCrash, DeviceJoinTimeout, ReplayDiscardedStaging, EmptyGreedyClaim), confirmed by the probe's '105 KINDS'. design/code_map.md:519-529 enumerates 'the members of dataplane.jl's `KINDS`' and names thirteen, leaving out MalformedDatum, which src/diagnostics.jl:1597 declares in that section. The list was written when commit e2ae3a9b moved the channel's kinds into diagnostics.jl, MalformedDatum among them, and it left MalformedDatum out from the start.
- fix: - The runtime channel's kinds, the members of dataplane.jl's `KINDS` (§11.8, Appendix C), in their own section beside `EmptyGreedyClaim`: `MalformedDatum`, the author's bad-datum report (§11.6), the three staging kinds (§11.4), …

## CV1-139 (deviation, clear=False)

- at: `src/diagnostics.jl:2354`
- claim: ArgumentInvalid reasons :both_given (step!, replay!), :not_replaying (live!), :entry_shape, :no_face, :face_name, :deadzone and :expo (TableBinding) are raised and rendered, but Appendix C names none of them, while it names the other reasons one by one
- evidence: src/sim.jl:2222 (step!) and src/sim.jl:1349 (replay!) raise :both_given. src/sim.jl:1444 (live!) raises :not_replaying. src/bindings.jl:67-87 (TableBinding) raises :entry_shape, :no_face, :face_name, :deadzone and :expo. Each has its own message arm (src/diagnostics.jl:2379-2427). The probe yields the five TableBinding reasons and the two messages. Appendix C (spec.md:15913-15950) names :inexact, :range, :not_a_count, :vocabulary, :claimed, :not_built, :disabled, :non_nominal, :nonpositive_width, :t0_without_about, :not_a_tap_set, :not_a_problem and :scalar one by one, but none of these seven. Neither the spec nor any docstring names them.
- fix: Add to Appendix C's ArgumentInvalid entry: "`step!` given both `frames` and `t_plus`, and `replay!` given both `to_boundary` and `to_time`, are reason `:both_given`. `live!` on a simulation already `:live` is `:not_replaying`. A `TableBinding` entry that is no NamedTuple is `:entry_shape`, one with no `face` `:no_face`, a face that is neither a string nor a symbol `:face_name`, and a `deadzone` outside [0, 1) or an `expo` outside [0, 1] is `:deadzone` or `:expo`."
- coordinator: See CV2-050.

## CV2-050 (deviation, clear=True)

- at: `src/sim.jl:1349`
- claim: replay! (and step!, line 2222) refuse a call giving both halt or advance spellings as ArgumentInvalid with reason :both_given, and live! (line 1444) refuses a :live simulation with reason :not_replaying; Appendix C's ArgumentInvalid entry names neither reason
- evidence: src/sim.jl:1349 (replay!) and 2222 (step!) throw ArgumentInvalid(reason = :both_given), and sim.jl:1444 (live!) throws reason :not_replaying. Probe probe.jl:91-92 confirms both reasons. Appendix C's ArgumentInvalid entry (spec.md:15913-15946) lists replay!, step! and live! among its calls and names the reason of nearly every other arm (:claimed, :not_built, :disabled, :non_nominal, :nonpositive_width, :t0_without_about, :not_a_tap_set, :not_a_problem, :range, :scalar, :inexact, :not_a_count). It names neither of these two. The prose states both refusals without a reason (spec.md:10533-10534, 10822, 10854-10855), and nothing in pending.md or the log records them.
- fix: Add to Appendix C's ArgumentInvalid entry: "`step!` given both `frames` and `t_plus`, and `replay!` given both `to_boundary` and `to_time`, are reason `:both_given`. `live!` on a simulation already `:live` is reason `:not_replaying`."
- coordinator: Same Appendix C entry as CV1-139 (ArgumentInvalid): apply one edit that names every raised reason the two rows list, each with its call, read from the raise sites. Keep each to a short clause.

## CV1-140 (drift, clear=True)

- at: `src/diagnostics.jl:2356`
- claim: the `call` field's comment lists the calls ArgumentInvalid refuses for, and omits :overlay!, :frame!, :apply! and :BS3 that Appendix C lists and the code raises
- evidence: The comment at src/diagnostics.jl:2356 lists :Model|:Simulation|:init!|:restore!|:Absolute|:Relative|:step!|:run!|:replay!|:live!|:pace!|:margin!|:trim!|:linearize|:trace|:TableBinding. The code also raises the call as :overlay! (`_check_recording(:overlay!, …)`, src/sim.jl:965), :apply! (`_claimed_gate`, src/model.jl:493), :frame! (src/frame.jl:80), and :BS3 (src/deployment.jl:420; probe '147 BS3' shows call :BS3). Appendix C (spec.md:15919-15921) lists all four. D-318, D-261 and D-461 record the refusals that added them.
- fix: call::Symbol # :Model|:Simulation|:init!|:overlay!|:frame!|:apply!|:restore!|:run!|:step!|:replay!|:live!|:pace!|:margin!|:trim!|:linearize|:trace|:TableBinding|:Absolute|:Relative|:BS3

## CV2-001 (drift, clear=True)

- at: `src/descriptor.jl:1`
- claim: code_map.md:474 lists D-418 in the descriptor entry's Spec footer, omits D-439, D-478, D-168 and D-261 that the body and the code cite
- evidence: design/code_map.md:474-475 lists D-418 and omits D-168, D-261, D-439, D-478. src/descriptor.jl cites D-168 (179), D-261 (81), D-439 (body of the summary writer) and D-478 (176), and the entry's body cites D-439 and D-478 (code_map.md:480, 472). D-418 (log.md:17117, face-selector head matching) is never cited in src/descriptor.jl: `git log -S'D-418' -- src/descriptor.jl` is empty. The citations came in with commits 44d52cce (D-168, D-261), cbfcc5f6 (D-439) and 7c24c484 (D-478), and none of them updated the footer.
- fix: Spec: §8.5, §9.1, §9.2, §13.2, §13.8, §13.9, D-168, D-211, D-237, D-261, D-432, D-433, D-434, D-437, D-439, D-466, D-467, D-468, D-478.

## CV2-034 (drift, clear=True)

- at: `src/sim.jl:100`
- claim: LoopError docstring says a run ends with it 'when a frame throws, whatever it throws', that the throw leaves the simulation errored, and that exception is a wrapper whose cause is the raw error; a fault outside the frame ends stopped and holds the raw exception (run! docstring, sim.jl:1514, repeats it)
- evidence: src/sim.jl:1749-1758 builds LoopError(cause) for any loop fault. A fault outside the frame leaves the model consistent, and the run reads stopped. Probe probe.jl:71-72 runs an unbounded run! on test_lattices' long-period rig: it throws ArgumentInvalid(:frame!, :range, k = 1001) and ends lifecycle :stopped with LoopError whose exception is the raw DiagnosticError{ArgumentInvalid}, not a StepError wrapper (also test/test_lattices.jl:404-408). The LoopError docstring (sim.jl:100-108) says a run ends with it when a frame throws, that this leaves the simulation errored, and that exception is a wrapper. run!'s docstring (sim.jl:1514) says a failure inside the loop leaves it errored. Spec §13.5 (spec.md:11915-11923) took the out-of-frame case in commit f010ff26 (2026-11-11), after the docstring's commit afc15682 (2026-11-05).
- fix: LoopError: "A run ends with it when the loop fails. A throw inside a [frame](@ref g-frame), whatever it throws, leaves the simulation `errored`, and the previous [snapshot](@ref g-snapshot) is the run's final one. A fault outside the frame, such as `frame!`'s refusal of a frame past the last the run may take, leaves it `stopped` at its last settled boundary. … `exception` holds the failure as the loop caught it. From inside a frame it is a wrapper whose `cause` is the raw error or the failed check's diagnostic, beside the time and the place in the frame where it was thrown. From outside the frame it is the raw exception." run!: "A failure inside a frame leaves the simulation `errored` instead, the cause kept on the record, and a fault outside the frame leaves it `stopped` with the same record. With no device rostered, `run!` then rethrows the failure."

## CV2-058 (drift, clear=True)

- at: `src/sim.jl:2216`
- claim: step! docstring says frames is 'an integer of at least 1 that keeps the frame index within Int'; the code bounds it by the last frame the run may take, which can be far below typemax(Int)
- evidence: src/sim.jl:2228-2229 bounds frames by `_last_frame(sim.model) - sim.run.frame`. Probe probe.jl:67-69 on the long-period rig shows _last_frame = 1000 (typemax(Int) = 9223372036854775807): frames = 1001 is refused as ArgumentInvalid :range and frames = 1000 is accepted (also test/test_lattices.jl:393-395). The refusal's own message reads "keeps the frame index within the last frame the run may take". Commit 4868f309 (D-445, D-450) moved the bound, and the docstring line (sim.jl:2209-2210) predates it.
- fix: - `frames`: the number of frames to advance, an integer of at least 1 that keeps the frame index within the last frame the run may take.

## CV2-030 (deviation, clear=True)

- at: `src/tracer.jl:316`
- claim: A member with more than 64 entering faces traces structurally, because the tag set is a 64-bit mask; neither the spec nor the log states the limit
- evidence: src/tracer.jl:313-316 gives a member a traced declaration only when `length(faces) ≤ 64` ("Beyond 64 faces the bitmask runs out"), and Tracer.dependencies is a UInt64 (tracer.jl:29). Probe probe.jl:50 builds a fan cycle: with 64 entering faces b traces global, and with 65 it traces structural, a continuous member with walking leaves. Spec §13.8 (spec.md:12459-12467) lists only two causes of structural tracing: discrete members, and faces or ports with no walking leaf. No log entry or pending.md bullet states the limit.
- fix: Add to §13.8's caveats: "A member with more than 64 faces entering the cluster traces structurally too, because a traced value's tags are a 64-bit set."
- coordinator: A new caveat sentence in §13.8; place it with the other caveats on structural tracing.

# G5d: rows for the fixer

Each row: the site at the pinned tip f14dbc1d, the claim, the verifier's evidence and proposed fix, and its note. The fix is a proposal: conform it to the rules and to the code.

## CV11a-044 (deviation, clear=True)

- at: `src/dataplane.jl:50`
- claim: code_map.md says 'The union DiagValue and KindCounts' field order are built from KINDS'. DiagValue is built from KINDS, but KindCounts and `_kind` are written by hand, one field and one method per kind, and the KINDS docstring says only that KindCounts 'keeps one field per member in its order'.
- evidence: src/dataplane.jl:41 `const DiagValue = Union{KINDS...}` is built from KINDS (probe P2c). src/dataplane.jl:50-64 KindCounts and src/dataplane.jl:70-83 `_kind` are written by hand, one field and one method per kind. Probe P2b: map(_kind, KINDS) == fieldnames(KindCounts), so the order matches but nothing builds it. git show 9b47941f shows KindCounts was hand-written from the start. design/code_map.md:296-298 says both are 'built from it'.
- fix: code_map.md 296-298: '`KINDS`, the closed set's one home. The union `DiagValue` is built from it, and `KindCounts` and `_kind` are written by hand in its order, one field and one method per kind, `StepFloor`'s field `step_floor` after `firing` (D-460).'
- note: The KINDS docstring (src/dataplane.jl:30-34) says KindCounts 'keeps one field per member in its order', which matches the code.

## CV11a-042 (deviation, clear=True)

- at: `src/dataplane.jl:177`
- claim: code_map.md names no entry for `WriterAccount`, the loop's private per-writer account, nor for `_fold!` and `_reset!`, which move a cell's batch into it.
- evidence: src/dataplane.jl:177-181 WriterAccount, src/dataplane.jl:184-189 _reset!, src/dataplane.jl:195-207 _fold!. rg over design/code_map.md finds none of the three names. The map mentions an 'account' only as something held (code_map.md:1087 roster entry, 1103-1104 plane, 1246 and 1260 sim.jl's folds), never the type or where it lives. _fold! is called at src/sim.jl:1959-1965, 2673-2678 and 2712-2717, and _reset! at src/sim.jl:1787-1790.
- fix: Add to code_map.md's dataplane.jl entry, after the diagnostic cells bullet: '- `WriterAccount`, the loop's private account for one writer, with `_fold!`, the frame-top take of a cell into it, and `_reset!`, which clears it when a run opens (§11.8, D-317).'
- note: The claim's summary says _reset! moves a batch in. It does not. It clears recent, suppressed and totals.

## CV11a-014 (deviation, clear=True)

- at: `src/dataplane.jl:231`
- claim: The WriterStatus `who` bullet says 'as a port view's incumbent holds it'; no spec section, appendix or docstring gives the literal names of the loop's record ("loop") or the device format ("device 1 (Pad)"). "harness" is only in the PortView docstring.
- evidence: src/sim.jl:2532 names a device writer "device $id ($(typename))". src/sim.jl:2838-2839 name the other two "harness" and "loop". Probe P3a shows who = ["device 1 (Pad)", "harness", "loop"]. The WriterStatus `who` bullet (src/dataplane.jl:233) says only 'as a port view's `incumbent` holds it'. rg finds no "loop" literal in design/spec.md, docs/src or any src docstring. Only the test helper comment test/utils.jl:67-69 gives it. "harness" is in the PortView docstring (src/devices.jl:475) and the Trace docstring (src/trace.jl:70).
- fix: WriterStatus `who` bullet: '- `who`: the writer's name, as a port view's `incumbent` holds it. A rostered device is named by its roster label, such as `"device 1 (Pad)"`, the harness writer is `"harness"`, and the loop is `"loop"`.'
- note: The claim is partly wrong. The device format is in one docstring: ControlRequestedStop (src/sim.jl:91-93) gives `"device 1 (Pad)"` as the roster label. The loop's name is documented nowhere.

## CV11a-016 (drift, clear=True)

- at: `src/dataplane.jl:260`
- claim: ResidueRecord: final ring and refused counts, quiet writer gives no record
- evidence: src/sim.jl:1964-1966: _sweep_tail! folds two cells, the loop's and the model's frame cell, into the loop's one account before _residue! builds its record. src/sim.jl:1973-1975 skips a quiet account. Probe P5a: two cells of 17 reports each fold into a 'loop' ResidueRecord with 32 recent entries (DIAG_RING = 16) and 2 suppressed. P5b: a quiet account gives no record. The docstring (src/dataplane.jl:260-264) bounds the record at 'the final ring, at most DIAG_RING entries'. The docstring arrived with 1cce1119 (D-203). The frame-cell fold came later with 697ff66d and is recorded by D-317, which spec 9603-9604 states for WriterStatus.
- fix: 'One writer's share of the tail residue (§11.8, D-203): what the run's-end sweep took past the final frame top. That is the final ring, at most `DIAG_RING` entries per diagnostic cell the sweep takes, of which the loop's record folds two (D-317), and the per-kind counts the ring refused. A quiet writer contributes no record.'
- note: The 'quiet writer contributes no record' half and the refused counts agree with the code.

## CV11a-021 (deviation, clear=True)

- at: `src/dataplane.jl:324`
- claim: The stale docstring says a device that has not beaten since attach 'reads stale whatever `now` is'.
- evidence: src/dataplane.jl:337-338 `stale(record; now) = record.heartbeat !== nothing && now - record.heartbeat > STALE_S`, and a never-beaten cell holds 0.0 (src/dataplane.jl:136). Probe P4 on a heartbeat-0.0 device record: now=1.0 gives false, now=2.0 false, now=3.0 true, the default time() true. The docstring (src/dataplane.jl:326-327) says such a device 'reads stale whatever `now` is'. Spec 10175-10177 says it reads stale 'from the start', meaning at wall-clock times.
- fix: 'A device that has not beaten since attach reads stale at any wall-clock `now`, since its heartbeat holds `0.0`.'
- note: The docstring is false only for a `now` of 2 s or less, which no wall clock gives. The fix narrows the wording and changes no code.

## CV11a-039 (deviation, clear=True)

- at: `src/dataplane.jl:339`
- claim: code_map.md 288-315 (src/dataplane.jl) never mentions the public `stale` or its constant `STALE_S`; neither name occurs anywhere in code_map.md.
- evidence: src/dataplane.jl:309 `const STALE_S = 2.0` and src/dataplane.jl:337 the public `stale` (docs/src/api.md:104). rg finds neither name in design/code_map.md. code_map.md:501-502 lists its sibling `orphaned` under devices.jl, and the dataplane.jl entry (code_map.md:288-315) names neither.
- fix: Add to code_map.md's dataplane.jl entry, after the FrameworkStatus bullet: '- `stale`, §12.2's heartbeat read on a `WriterStatus`, with its threshold `STALE_S` (D-133).'

## CV11a-041 (deviation, clear=True)

- at: `src/dataplane.jl:416`
- claim: code_map.md omits the staging shim `_normalize`, the CAS merge `stage_batch!`, the positional `_merge` and the scatter `_apply!`; the map says only 'Writer and Batch, and the staging cells'. `_normalize` holds the discard-and-report logic for OutOfClaimEntry, ClaimedFaceEntry and EntryTypeMismatch.
- evidence: src/dataplane.jl:416-446 _normalize, the shim that discards out-of-schema and unconvertible entries. src/dataplane.jl:452-457 _merge, src/dataplane.jl:460-468 stage_batch!, src/dataplane.jl:474-481 _apply!. rg finds none of the four names in design/code_map.md. Its dataplane.jl entry says only 'The compiled writer `Writer` and `Batch`, and the staging cells' (code_map.md:290). They are called from src/sim.jl:2623-2624, src/devices.jl:343 and src/roster.jl:404.
- fix: code_map.md 290: '- The compiled writer `Writer` and `Batch`, and the staging cells `StagingCell`, with the staging shim `_normalize`, where every staging diagnostic is raised (§11.4, D-044), the CAS merge `stage_batch!` over the positional `_merge`, and the drain's compiled scatter `_apply!` (D-202).'

## CV11a-040 (deviation, clear=True)

- at: `src/dataplane.jl:576`
- claim: code_map.md's dataplane.jl entry omits the `port(snapshot, path, name)` method that reads a published snapshot by address, a method Appendix B names.
- evidence: src/dataplane.jl:576-577 defines `port(snapshot::Snapshot, path, name)`. Probe P10a: one method matches, and it reads the published table. code_map.md names `port` only under model.jl (992) and sim.jl (1301). The dataplane.jl entry (288-315) omits the snapshot method, which the Snapshot docstring (src/dataplane.jl:521-523) and Appendix B name.
- fix: Add to code_map.md's dataplane.jl entry, beside the snapshots bullet: '- `port(snapshot, path, name)`, a published snapshot's read by address, as on the live table (§11.2, D-440).'

## CV11a-043 (deviation, clear=True)

- at: `src/dataplane.jl:594`
- claim: code_map.md names no entry for `Published`, the mutable holder of the one `@atomic latest` reference.
- evidence: src/dataplane.jl:594-596 `mutable struct Published; @atomic latest::Union{Nothing,Snapshot}; end`. The handle holds one (src/devices.jl:65 `const published::Published`, probe P11b). rg finds no `Published` in design/code_map.md. The roster.jl entry (code_map.md:1103-1104) says only that the plane holds '§11.2's published holder', and nothing says where the type lives.
- fix: Add to code_map.md's dataplane.jl entry: '- `Published`, the holder of §11.2's one `@atomic latest` reference, which the plane and every handle share (D-256).'

## CV11a-074 (drift, clear=True)

- at: `src/devices.jl:667`
- claim: Spec 11.6's wrapper sketch (spec.md:8978) writes `report!(entry, DeviceCrash(e))`. The code builds `DeviceCrash(err, entry.should_abort)`, and DeviceCrash has no one-argument constructor.
- evidence: src/diagnostics.jl:1688-1691: DeviceCrash has fields `cause` and `abort` and no one-argument constructor (probe P9: DeviceCrash(e) is a MethodError). src/devices.jl:667 and src/sim.jl:1849 build DeviceCrash(err, entry.should_abort). Spec 8978 (§11.6's sketch) writes `report!(entry, DeviceCrash(e))`, while §12.4's sketch at spec 10138 already writes `DeviceCrash(e, entry.should_abort)`. The ratified D-097 (log.md:3302) and D-138 (log.md:5056) record the payload with should_abort, and so does Appendix C 16051-16053. Commit f8dafc76 moved this sketch's address to the roster entry but left the one-argument call.
- fix: spec.md 8978: '    report!(entry, DeviceCrash(e, entry.should_abort))   # §12.4(6): sim continues, device absent'
- note: spec_rules.md:79-80 lets a sketch be simplified, but this one calls a constructor that does not exist and disagrees with §12.4's sketch.
- coordinator: Same site as G5a's S11c-041 (the wrapper sketch's report!); one edit covers both.

## CV11b-070 (deviation, clear=True)

- at: `src/checkpoint.jl:18`
- claim: The code_map.md ModelState bullet ends 'and the fingerprint, the `Deployment` and the structural layout `Fingerprint`'. This names the fingerprint twice and lists three items. ModelState has two such fields, `deployment` and `layout::Fingerprint`.
- evidence: src/checkpoint.jl:83-84 hold just two such fields, `deployment::Deployment` and `layout::Fingerprint`. Probe line 070 prints fieldnames(ModelState) = (:x, :s, :m, :table, :prior, :stepper, :t, :t₀, :deployment, :layout). design/code_map.md:194-196 says 'the fingerprint, the `Deployment` and the structural layout `Fingerprint`', which names the fingerprint twice. The wording comes from b1de9d49's comment 'fingerprint, the `Deployment` and the structural layout'. No separate fingerprint field ever existed.
- fix: ... the clock's `t` and its exact `t₀` (D-457), and the `Deployment` and the structural layout `Fingerprint`.
- note: This is a wording slip in the map, not a moved field. No log entry or rename records it.

## CV11b-001 (drift, clear=True)

- at: `src/roster.jl:3`
- claim: The file header says the roster carries 'the three-part admission'. Spec §11.3 'Device identity and admission' says 'Admission is a two-part check at the attach point, in order (D-375)': identity, then claims.
- evidence: src/sim.jl:2511-2522: attach! runs the identity check (AlreadyAttached) and then the claims check (ClaimConflict). Nothing else follows them. rg finds no CallerTaskConflict in src/. Spec §11.3 (design/spec.md:8441) and D-375 (design/log.md:15825) say admission is a two-part check. Commit d17d9c03 deleted the calling-task admission check (D-310).
- fix: ... the enumeration contract with its bidirectional conformance check, the two-part admission, both claim sources, and the harness writer as the derived remainder.

## CV11b-026 (deviation, clear=True)

- at: `src/roster.jl:235`
- claim: The raise site throws DeviceContractMismatch with reason :no_loop. The spec's Appendix C entry says 'what the contract lacks: the loop method, the output side ..., or the roster entry a detached handle ... no longer has'. It names no `reason` symbols, while BindingContractMismatch lists all nine of its reasons. The kind has three reasons, :no_loop, :no_output_side and :detached.
- evidence: src/diagnostics.jl:1841-1844 gives DeviceContractMismatch a `reason::Symbol` field with three values, :no_loop | :no_output_side | :detached. They are raised at src/roster.jl:235, src/devices.jl:370 and src/devices.jl:81. Probe line 026 shows reason :no_loop. Appendix C (design/spec.md:15803-15807) describes the three cases but never names the `reason` field or its symbols. Its twin BindingContractMismatch (spec.md:15799-15802) lists all nine. D-244 (log.md:10015) names the `:detached` reason.
- fix: Append to the Appendix C entry: 'A `reason` tells the cases apart: `:no_loop`, `:no_output_side` and `:detached`.'
- note: The entry leaves the field out but contradicts nothing: the three cases it describes match the three reasons.

## CV11b-033 (drift, clear=True)

- at: `src/roster.jl:296`
- claim: The DataPlane docstring says 'the §11.3 freeze itself is the lifecycle's :running state (devices.jl)'. The freeze is Control's `running` flag (control.jl:70), read by `lifecycle` in sim.jl, and devices.jl holds neither.
- evidence: The freeze is `@atomic running::Bool` on Control (src/control.jl:70; control.jl:30 calls it 'the §11.3 freeze (D-317)'). `lifecycle` (src/sim.jl:511-512) reads it as :running. devices.jl holds neither the flag nor `lifecycle`. Commit 0cea6765 'Move the control plane and the pacer into control.jl' took that state out of devices.jl, so the docstring's file pointer went stale.
- fix: ... and the id counter; the §11.3 freeze itself is `Control`'s `running` flag (control.jl), which `lifecycle` reads as `:running`.

## CV11b-036 (drift, clear=True)

- at: `src/roster.jl:309`
- claim: The DataPlane docstring says 'the inline body's entry leaves when that body returns, under wake's lock, since the loop reads the registry as it publishes'. No code removes a single entry from run_tasks. The only writes are the fill at spawn and `empty!` at run end. Every device runs in a spawned task and the loop runs on the calling task, so no inline device body exists.
- evidence: run_tasks is filled at spawn (src/sim.jl:1654-1655 via _register_tasks!, sim.jl:1808-1809) and emptied under wake's lock at run end (sim.jl:1750). _status reads it under the same lock (sim.jl:2834). No code deletes a single entry. Commit d17d9c03 'Delete the attended run mode: ... the inline branch of run!' (D-310) removed the inline body, and sim.jl:1652 notes that the loop runs on the calling task (D-310).
- fix: `run_tasks` is the run's device-id → `Task` registry, filled at spawn and emptied at run end under `wake`'s lock, since the loop reads the registry as it publishes, which is what lets `publish!` read `task_state` off the handles the loop owns (D-193). A device absent from it reads `:done` inside a run and `:none` outside one ...

## CV12-017 (deviation, clear=True)

- at: `src/sim.jl:654`
- claim: Every door (init!, overlay!, restore!, replay!) clears the stop word through _reset_periphery!; spec §12.1 and D-398 say it is cleared at a run's start only, the restore! docstring and the replay! docstring are silent, and only init! and overlay! docstrings say it
- evidence: src/sim.jl:654-662 _reset_periphery! clears stop_issuer, and init!, overlay! and _enter_checkpoint! (restore!, replay!) all call it. probe.jl:43 runs stop!, then restore!, then step!: 1 frame advances and the state is :initialized. Without a door (probe.jl:46) the same step! advances 0 frames and ends :stopped. The restore! docstring (sim.jl:1029) lists dropping the batches but not clearing the stop word. Spec §12.1 (spec.md:9765) says the word is cleared 'at the top of each run', with no 'only', and §12.6 defines a run as what a door builds. So the spec agrees with the code. The gap is the restore! docstring, which overlay!'s 'Like restore! ... It also clears the stop word' (sim.jl:945-947) makes read as if restore! did not clear it.
- fix: In restore!'s docstring (sim.jl:1029): "`restore!` drops every [batch](@ref g-batch) still waiting and clears the [stop word](@ref g-stop-word). It opens a fresh run ...". replay! clears the word twice, at its door and again at _run_body!'s start (sim.jl:1644), so leaving its docstring silent changes nothing a caller can observe.
- note: The claim's premise is wrong: neither §12.1 nor D-398 says 'only'. What survives is the restore! docstring's omission.

## CV12-089 (drift, clear=True)

- at: `src/sim.jl:1955`
- claim: _sweep_tail! docstring calls the ResidueRecords 'the termination record's third field'; TerminationRecord holds t, policy, source, residue, so residue is the fourth
- evidence: src/sim.jl:180-185 TerminationRecord holds t, policy, source, residue, so residue is the fourth field. The comment at sim.jl:1950 says 'third field'. At 1cce1119 the record was {t, source, residue}, and residue was then the third. Commits 46f261e1 and 63980506 (D-260) added policy::StopPolicy as the second field.
- fix: "... it is collected into the returned `ResidueRecord`s — the termination record's `residue` field — and presented through the logging backend ..."

## CV12-144 (deviation, clear=True)

- at: `src/sim.jl:2913`
- claim: Series docstring says 'A series holds these fields, each vector with one entry per snapshot', but `columns` is a NamedTuple, not a vector
- evidence: src/sim.jl:2913-2918 declares columns::NT<:NamedTuple and the three stamps as vectors. probe.jl:111 gives columns @NamedTuple{q::Vector{Float64}}, not a vector. The lead sentence (sim.jl:2900-2901) says each field is a vector with one entry per snapshot, which is false of columns. Each column inside it does have one entry per snapshot (probe.jl:112). The sentence has read this way since it was written (c3bfde03), and Series has always held a NamedTuple there, so nothing records a move.
- fix: "A series holds these fields. Each vector in it, every column included, has one entry per snapshot."

## CV12-154 (deviation, clear=True)

- at: `src/sim.jl:3039`
- claim: port/state/modes on the simulation cite §7.3, 'Discrete state, modes, and workspace'; that section treats stores and modes but not the path-addressed read of a port, which the spec treats only in Appendix B
- evidence: src/sim.jl:3027 cites '§7.3, D-317, D-440' above port, state and modes on the simulation. §7.3 (spec.md:2341) treats stores and modes, which fits state and modes. It does not treat reading a port by path, which the comment mostly describes. The spec treats that read only in Appendix B (spec.md:15137-15150); no other spec text matches 'port('. Appendix B's own line also cites §7.3, and model.jl:981, 1009 and 1039 repeat the same set.
- fix: # Design: §7.3, Appendix B, D-317, D-440.
- note: The same citation set sits on the model's port at model.jl:981, so a fixer may want to add Appendix B there too.
- coordinator: Cite the section that treats port, state and modes reads on the simulation; find it in the heading outline.

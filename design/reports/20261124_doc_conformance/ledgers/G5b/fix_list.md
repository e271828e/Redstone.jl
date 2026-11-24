# G5b: rows for the fixer

Each row: the site at the pinned tip f14dbc1d, the claim, the verifier's evidence and proposed fix, and its note. The fix is a proposal: conform it to the rules and to the code.

## K11-004 (drift, clear=True)

- at: `design/companions/flight_case_studies.md:368`
- claim: After the run, `TimeSeries` reads the retained snapshots
- evidence: No TimeSeries exists in src/. src/sim.jl:2936-2956: series(sim, read_set) -> Series gathers the log's retained snapshots into columns. design/log.md:16818 (D-407) rejects FlightCore's TimeSeries in favour of this reader, landed in commit 06ed3bf8.
- fix: After the run, `series` reads the retained snapshots, and the trace can re-drive a fresh `Simulation(world)` bit-identically.

## S12b-115 (deviation, clear=True)

- at: `design/spec.md:10130`
- claim: Init-bracket code block reads `init!(entry.device)`; the roster entry's field is `dev`.
- evidence: src/roster.jl:255 the field is `dev::AbstractDevice`; src/sim.jl:1841 calls `init!(entry.dev)`. git log -S'entry.device' -- src is empty, so no rename is recorded.
- fix: `        init!(entry.dev)` in the init-bracket block (and `entry.dev` wherever else the block names the device).

## S12b-120 (deviation, clear=True)

- at: `design/spec.md:10135`
- claim: Block sets the interrupt stop with `stop!(control, :interrupt)`; no such method exists. `stop!` takes a `Simulation` or a `DeviceHandle`.
- evidence: probe.jl:138: methods(stop!) are only stop!(::DeviceHandle) and stop!(::Simulation) (src/devices.jl:253, src/sim.jl:2328); the bracket calls `_request_stop!(entry.handle.control, :interrupt)` (src/sim.jl:1846). git log -S'stop!(control, :interrupt)' finds only design records, no src change.
- fix: `            _request_stop!(control, :interrupt)   # the stop word, issuer :interrupt; an earlier issuer keeps it`

## S12b-199 (deviation, clear=True)

- at: `design/spec.md:10254`
- claim: The loop masks delivery using Julia's `disable_sigint`; the code calls `Base.sigatomic_begin()` and `Base.sigatomic_end()` directly and never `disable_sigint`.
- evidence: src/sim.jl:1653-1656, 2110, 2131, 2134, 1743, 1773 call Base.sigatomic_begin()/sigatomic_end() directly; probe.jl:137 found no disable_sigint in src/sim.jl, and git log -S'disable_sigint' -- src test is empty. The split ends matter: sim.jl:2131 unmasks inside the catch so a pending raise lands in the outer arm, which a disable_sigint do-block cannot express.
- fix: The loop masks delivery across the boundary macro-sequence with Julia's sigatomic counter, `Base.sigatomic_begin` and `Base.sigatomic_end` (the primitive under `disable_sigint`), an increment that is negligible per frame.

## S12c-143 (drift, clear=True)

- at: `design/spec.md:10622`
- claim: From stopped, nothing advances until init!, restore! or replay! opens a new run
- evidence: src/sim.jl:966-974 overlay! is legal from stopped and opens a fresh run. Probe P57/P58: after overlay! on a stopped simulation, lifecycle is initialized and step!(frames=2) advances 2
- fix: From `stopped`, nothing advances until `init!`, `overlay!`, `restore!` or `replay!` opens a new run, and `errored` is terminal ([D-218][d-218], [D-219][d-219]).
- note: D-429 (commit 4f922f7f) added overlay! as a fourth door after this sentence was written. The sentence just before it in the spec was updated to name overlay!, and this one was not.

## S12d-001 (drift, clear=True)

- at: `design/spec.md:10794`
- claim: The replay drain 'does not swap the staging cells of the roster'.
- evidence: src/sim.jl:2709-2714 and 2757: at each replay frame top, _replay_drain! calls _discard_staged! on every roster entry and on the harness, and that does `@atomicswap writer.cell.pending = nothing` and reports ReplayDiscardedStaging. Probe P001 shows a harness batch pending before a replayed frame top and empty after it, with the discard reported at frame 3 and ref left at 2.0, not 99.0.
- fix: It takes the [staging cells](#g-staging-cell) of the [roster](#g-roster) (the list of attached device entries) and discards what they hold, applying none of it.
- note: D-218's position records 'live staging taken and discarded (ReplayDiscardedStaging)', and the same section later says a staged batch is discarded. The sentence keeps D-101's older 'never drained' reading. Read literally, 'does not swap' is false, because the replay drain does swap each cell to empty.

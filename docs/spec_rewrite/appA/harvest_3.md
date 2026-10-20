# Harvest 3: the ruling notes and the escalations

Agent 3's return, verbatim. Sources: the fifteen `notes_*.md` files in
`docs/design/briefs/` and the seven archived `escalations.md` files of the
chapter rewrites. Spec line numbers refer to the frozen spec at `e2b7393`.

I read all 22 files in full: 15 `notes_*.md` and 7 escalations. Most ruling notes are about implementation, tests or naming and teach nothing for authors. The candidates come mostly from the escalations and from the interrupt and shutdown rulings. Spec quotes come from `<S>/frozen/spec.md` with the link markup removed.

### No mutable cache in a field handle, and referenced data stays frozen
Group: component authors
Owning section(s): §4.4, §4.1; D-344
Spec sentence: "A field object must hold no mutable cache, such as a memoizing interpolator or a lazy loader" (983–984); "Concurrent consumers and the GUI thread would race on it. The remedy is to restructure the interpolant to be pure. The rule is the author's, because the build does not look inside a field handle" (985–987); "Signals may reference bulk data (§4.4) provided that data is read-only for the duration of the run" (805–806).
Recall line: A field handle is immutable all the way down. It holds no memoizing interpolator or lazy loader, and the bulk data it references is never written during a run. Restructure the interpolant to be pure. A cache inside a handle lets concurrent consumers and the GUI thread race on it.
Goes wrong without it: the model builds and runs, and concurrent readers race on the cache. `IllegalPortType` refuses only a mutable port type (Appendix C, 13744–13748). A non-isbits immutable handle is one opaque leaf, and the leaf walk never enters its fields. So a handle holding a mutable `Vector` builds (D-344 Rationale).
Source: escalations/ch01-04.md E1; D-344
Status: new

### Boundaries are publications, not frames, and newest wins
Group: periphery authors and consumers
Owning section(s): §12.3, §10.4; D-028, D-230
Spec sentence: "It counts *published boundaries*, that is grid, `t*` and boundary zero (the initialization boundary at `t₀`), not frames (§10.1, §10.4). Consecutive wakes are therefore not necessarily `h` apart." (8833–8835); "A slow consumer skips boundaries and always receives the current world." (8866–8867); "Any holder of a snapshot therefore indexes it without consulting the loop" (8878–8879); the counter's "absolute value is nowhere normative" (8885).
Recall line: A `t*` boundary adds a publication inside a frame, and a slow waiter skips boundaries. So never derive time or an index from a count of wakes times `h`. Read `t` and the boundary ordinal off the snapshot. The wait counter is not the ordinal and never resets.
Goes wrong without it: a telemetry or rate-estimating device that counts wakes mis-stamps every sample after the first localized event or the first skip. A device that takes the counter as an index is wrong from the second trajectory on, because the ordinal restarts and the counter does not (D-230). No check sees a device's arithmetic. Increment 78 shows the gap: a localized run's frames read `[0,1,2,3,4,4,5]` against boundaries `0:6`.
Source: notes_increments_77_78.md:244–246; D-028; D-230
Status: new

### Conditioning upstream, aircraft semantics in-model
Group: periphery authors and consumers
Owning section(s): §11.4; D-045
Spec sentence: "Mappings are binding data, not shaping code (D-045)." (7480); "A face's meaning is writer-independent (D-045). Faces therefore carry *post-conditioning* semantics." (7486–7488); "Aircraft-semantic derivation must *not* ride along (D-045). A command fan-out such as the illustrative `q_ref = q_sf · axis` is the case in point. It is flight control system (FCS) design and lives in-model, in the avionics." (7492–7494)
Recall line: A mapping conditions, through deadzone and expo, and delivers the level the face means whoever writes it. Derivation that carries aircraft meaning, such as a command fan-out, belongs in the model, never in `map_input`. Otherwise a slider or a script writing the same face means something else than the stick does.
Goes wrong without it: the aircraft logic is duplicated per device and diverges between writers (D-045's rejected "aircraft semantics duplicated per device"). A face fed by a GUI then delivers different semantics than the same face fed by a stick. Mappings are the author's own idiom and nothing checks them (A's binding-traits entry).
Source: escalations/ch11.md E1 (ruled 2026-10-13 to delete the contrary "Alternatively" sentence); D-045
Status: new

### `shutdown!` also runs twice, and with no `init!`
Group: periphery authors and consumers
Owning section(s): §11.6, §12.4; D-268, D-372
Spec sentence: "The same tolerance covers a repeated call (D-268)." (7930); "An interrupt landing between a `shutdown!`'s return and the cursor's advance repeats that call rather than leak the device, so each such interrupt adds one call." (7935–7937); "The tolerance also covers a call with no `init!` before it (D-268)." (7940)
Recall line (an added sentence): Two more paths reach `shutdown!` with no warning. An operator interrupt can repeat the call. An interrupt can also release a device whose `init!` never began. "Close only what is open" covers both. A release that assumes one call, or a completed `init!`, double-frees or throws.
Goes wrong without it: a non-idempotent release, such as closing a socket unconditionally or freeing a handle twice, throws or corrupts on Ctrl-C. The spec says the repeated call "is never reported". These calls arise only under interrupt timing, so tests rarely exercise them.
Source: notes_standalone_updates.md:304–306, 350–351, 399–402; escalations/ch11.md E2; D-268
Status: amends "`shutdown!` closes only what is open"

### Deep service paths are bound to one build; equations that must survive substitution read faces
Group: service users
Owning section(s): §14.7, §14.2; D-414, D-065
Spec sentence: "As authoring guidance, an equilibrium equation meant to survive substitution at a generic seam reads a face (D-414, D-125)." (12064–12066); "No check refuses a deep path past a generically held field (D-414)." (11499–11500); "Ownership alone is convention. … keeping a deep path inside an owned subtree is idiomatic rather than machine-checked (D-065)." (11503–11506)
Recall line: A condition path, trim read or tap path may reach any depth, and the framework checks nothing past a generic seam. Keep deep paths inside subtrees you own. Scope a family fragment by dispatch on the holding's type parameter. Read a face in any equation meant to survive a substitution.
Goes wrong without it: a substituted child publishes the same path at the same type with another meaning, "and a trim commits a wrong point silently" (D-414 Rationale). Since D-414 no `:past_generic` refusal exists. Two spec sentences state the residual hazard, but no spec sentence names it as such; D-414's Rationale does. This is the service-user twin of A's "The two observation sides". The owner may prefer to widen that entry instead.
Source: escalations/ch06.md E1; D-414
Status: new (alternatively amends "The two observation sides")

### Between ticks, a discrete store already holds the next tick's `s`
Group: service users (or component authors)
Owning section(s): §14.5, §3.1; D-067
Spec sentence: "At tick `t_k` it consumes the completed boundary's samples and produces `s_{k+1}`, the value the next tick reads." (11859–11860); "`s` has none and is latched in a store (the framework-owned home of a state letter) between ticks." (687–689)
Recall line (an added sentence): Read between ticks, a discrete store holds `s_{k+1}`, the value the next tick decodes, not the one the last tick decoded. After `init!` it already holds `s(1)`.
Goes wrong without it: a reader of `state(sim, …)` or `get_state` is off by one. Increment 65 found this. `GaussianWhiteNoise`'s counter reads `N + 1` after `N` ticks, and the brief itself had predicted `N`. Nothing checks a reader's expectation. This is weaker than the five above, because the spec implies the facet across two sentences but never states it from a reader's side.
Source: notes_increment_65.md:78–82, 126–128
Status: amends "Interval alignment"

### No home

- **A closed loop's condition must seed every integrator whose trim value is not zero.** Without that, the run starts off trim and nothing reports it. In increment 75, `trimmed` seeded two of three such integrators, and the cascade started 2 m off trim. The only nearby spec sentence is Flight.jl's formulation, "filter and actuator equilibria imposed by construction" (12134–12135), which is not stated as a contract. Source: notes_increment_75.md:53–56.
- **A standby tracker's lag grows with its tracking time `Tt` and with the slew rate of its own law.** With `Tt` from 0.2 to 0.5 s, the tracker sat up to 0.2 rad off the cascade's command, so a hand-back bumped. The spec names no `Tt`; this lesson belongs to the companions (agent 2). Source: notes_increment_75.md:57–63.
- **A test pin on a rate-limited signal cannot fail.** It belongs upstream of the limiter. This is test practice with no spec home. Source: notes_increment_75.md:67–71.

### Rejected

- A struct root input without `convert` at `linearize`'s default point: now refused by D-428, Appendix C 13909 (fails test 2).
- A reordered `x_deriv` or output return scrambling the buffer (notes_increments_32_33.md:244): names pair, §9.x 4929, D-151 (no longer true).
- Forgetting `T` at a wire input: `WalkingFaceAtFrozenEntry` (test 2).
- A mutable port type, a nested `StopFlag`, a `StopFlag` at a root input: `IllegalPortType` reasons (test 2).
- A shadowed `stop_reason` silently reading `""`: `ForgottenImport`, D-246 (test 2).
- A port declared but produced by no stage (notes_pipeline_redesign item 11): a build error (test 2).
- A schedule fed from the PID's own output closing a cycle (increment 69 ruling 6): a cycle diagnostic (test 2).
- A hand-typed `t = 0.3` off the indexed grid (increment 71): `CheckpointMidFrame` (test 2).
- `chunk_size ≤ 0` silently giving an empty walk (increment 72): now `ArgumentInvalid :range` (test 2).
- Stepping a claimed `Model` directly (increment 70): `ArgumentInvalid :claimed`. The ungated primitives are internal (test 2).
- `Float32` `Trigger` never firing (increment 68): D-320 refuses `Float32` (test 2).
- "Resumable by the next `run!`" (ch12 E1): a lifecycle API fact, refused by `ServiceLifecycle` (test 2).
- The front end's stop under starvation (ch12 E2): the spec no longer makes the claim, and nothing changes in an author's code (test 1).
- `mark_dead!`, the mandatory device functions, the shipped GUI binding (ch11 E3–E5): API and sketch facts (Appendix B).
- Diagnostic quotes differing from `src` (ch05): Appendix C text (test 2).
- `Group`'s rate field, the naming axis (ch08): structural and naming (test 1).
- The locality law's enforcement status (ch06 E1): resolved in §14.2 (11497–11506), which yields candidate 5.
- A positional parametric constructor not converting integer rates (increment 65 ruling 4): the library's keyword-constructor convention, an API fact.
- `Delay` cost growing with `K` (increment 69 ruling 9): performance, not semantics (test 1).
- The roster read once per run, `terminal_producer` on an unfed face, the `report!(entry, DeviceCrash)` routing: framework internals or API (test 1).

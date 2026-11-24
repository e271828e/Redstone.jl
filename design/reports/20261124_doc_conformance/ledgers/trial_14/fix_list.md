# §14 trial: rows for the fixer

Each row: the doc site at the pinned tip bd471af7, the claim, the verifier's evidence and proposed fix, and its note. The fix is a proposal: conform it to the rules and to the code.

## S14a-023 (drift, clear=True)

- at: `design/spec.md:12987`
- claim: Composition checks three things by type or length alone, including that each `set` payload is a NamedTuple
- evidence: src/conditions.jl:176-179 `_payload` refuses only `nothing` (`p !== nothing || throw(...)`); probe.jl:37-38,40 show set(x = 1.0), set(s = (1,2), m = "str") and set(u = [1.0]) all build a Fragment without error.
- fix: Composition checks three things, each by type or length alone, and none allocates. No `set` payload is `nothing`, each combinator operand is a node, and each `at` prefix is nonempty.
- note: D-437 (log.md:18177-18180) rules that `set` admits a bare payload and refuses `nothing` alone; D-438 likewise for stores; commit dc5e833e made the change. Appendix C (spec.md:15771-15772) already says `:set_payload` is for a payload of `nothing`.

## S14a-024 (drift, clear=True)

- at: `design/spec.md:12988`
- claim: A `set` payload that is not a NamedTuple is `ConditionNodeMisuse` with reason `:set_payload`
- evidence: src/conditions.jl:176-179 raises ConditionNodeMisuse :set_payload only for a payload of `nothing` (probe.jl:39); a non-NamedTuple payload such as 1.0 or [1.0] is accepted (probe.jl:37,40) and checked at resolution as a bare payload (src/conditions.jl:322-326).
- fix: A `set` payload of `nothing` is `ConditionNodeMisuse` with reason `:set_payload`, the payload named ([Appendix C][sC], [D-437][d-437]).
- note: Recorded by D-437/D-438 and commit dc5e833e; Appendix C at spec.md:15771 already carries the new wording.

## S14a-076 (drift, clear=True)

- at: `design/spec.md:13441`
- claim: `t₀` is an init-service argument (default `0.0`)
- evidence: src/model.jl:271 and :318 declare `t0 = 0`; so do src/sim.jl:751, :831, :1121 and src/trim.jl:560. The default is the integer 0, held exact (probe.jl:59 clock origin 0//1).
- fix: **`t₀` is an init-service argument** (default `0`), never a condition entry, because time is not a store of any component ([D-067][d-067]).
- note: Commit c58ce63d (D-457, hold the origin exact) replaced `t0::Real = 0.0` with `t0 = 0`. spec.md:15270 already writes the default as `0`.

## S14b-001 (deviation, clear=True)

- at: `design/spec.md:13502`
- claim: Each site compares the resolved plan's root-input coverage against the `Build`'s `input_faces`
- evidence: src/conditions.jl:701-703 compares Set(plan.faces) with structure.root_inputs, and the call sites pass build.structure (src/trim.jl:598, src/model.jl:314, src/sim.jl:841, src/linearize.jl:316). Build has no input_faces field (src/build.jl:703-710; probe line 63 prints hasfield(Build, :input_faces) = false). input_faces exists only as a per-component accessor (src/assembly.jl:435). The check does run before any write: probe line 56 shows status :built.
- fix: Each compares the resolved plan's root-input coverage against the root inputs the `Build`'s structure lists (`structure.root_inputs`) before writing anything.
- note: The code has never read a Build-level input_faces. Increment 18 (29a25b61) compared against flat.slots, and later renames led to structure.root_inputs. The operand's data is the same as input_faces(root). The log repeats the wording at design/log.md:2305 and 5861.

## S14b-002 (deviation, clear=False)

- at: `design/spec.md:13603`
- claim: lower and upper are canonicalized to guess's field order by the same type-level reorder (`NamedTuple{keys(guess)}(lower)`)
- evidence: src/trim.jl:665-666 packs the bounds by name, as lower = Float64[problem.lower[k] for k in decision_names] (and the same for upper). No NamedTuple{keys(guess)}(lower) reorder appears anywhere in the code. The type-level reorder is used only for residuals (src/trim.jl:653, 700). The behaviour matches: probe line 75 shows a permuted lower packed as [-π/2, -Inf] in guess order (θ, u).
- fix: They are then read out in `guess`'s field order by name (`lower[k]` for each `k` in `keys(guess)`).
- note: D-151 rules a type-level reorder NamedTuple{canonical_names}(y) at every seam, decisions and bounds included. Changing the doc to the code's by-name pack therefore touches D-151's wording. The other way out is to make the code use the reorder. The observable effect is the same either way.

## S14b-003 (drift, clear=True)

- at: `design/spec.md:13936`
- claim: An interrupt inside the commit's boundary zero moves the simulation to `built` and propagates raw
- evidence: src/model.jl:337 sets the status to :built and rethrows _wrap_step(model, 0, :boundary_zero, err) for any throw, interrupts included. The docstring at src/sim.jl:812 agrees. Probe lines 107-112 show an InterruptException in the commit's boundary zero leaving trim! as StepError{InterruptException} with host :boundary_zero and boundary 0, with lifecycle :built (and model status :built).
- fix: An interrupt inside the commit's boundary zero moves the simulation to `built` and propagates out of `trim!` as the commit's `StepError`, like any throw there ([§13.4][s13-4], [D-223][d-223], [D-441][d-441]).
- note: D-441 (ratified, design/log.md:18435) rules that every catch site wraps what reaches it, an InterruptException included. Its Rejected list drops 'letting the interrupt through raw'. Commit afc15682 made the change. D-223's last bullet, which says 'propagates raw', is the stale source.

## K14a-001 (drift, clear=True)

- at: `design/companions/trim_environment_walkthrough.md:7`
- claim: Decision D-139 was settled in commit `daf3298d` (also line 561)
- evidence: `git cat-file -t daf3298d` at W fails ("Not a valid object name"). The commit that settled row 139 / D-139 on 2026-08-05 is f2658bc1 ("Adjudicate round-4 dry-run finding 3 (row 139): give environment handles value-level constructors..."). The walkthrough was added the same day in d60be1b2, which already carried the dangling hash at both places.
- fix: Replace `daf3298d` with `f2658bc1` at line 7 ("...during the round-4 dry-run adjudication (commit `f2658bc1`)") and at line 561 ("For the record, commit `f2658bc1`, decision [D-139][d-139]:").
- note: The hash resolves to no object in the repo, which suggests a history rewrite. The git history is what records the real commit.

## K14a-004 (drift, clear=True)

- at: `design/companions/trim_environment_walkthrough.md:146`
- claim: This is what `design_world(ac)` ships, the blessed default for design tasks
- evidence: `rg design_world` finds no definition in src/, test/ or examples/. design/log.md:2454-2456 (the D-071 annotation of 2026-10-20) says "no source ships a `design_world`; it is the rig this design records for design-time work (§14.9)". design/spec.md:14230-14231 and 17107 use "the rig this design records".
- fix: This is the rig this design records for design tasks, `design_world(ac)`. No source ships it.
- note: 

## K14a-006 (drift, clear=False)

- at: `design/companions/trim_environment_walkthrough.md:269`
- claim: `condition("atmosphere.T_sl" => T_sl, ...)` writes root inputs by dotted path (also lines 314, 345, 383, 726)
- evidence: Probe P1: `condition("c.u" => 1.0)` raises MethodError, and no method of `condition` takes a Pair. src/conditions.jl:116-135 defines `condition(c; kw...)` only as a component's keyword method. Root inputs are written with `set(u = ...)` at the authoring level, scoped with `at` (conditions.jl:137-176 and the walk to the root input at 622-643). Probe P1: `init!(sim, at("c", set(u = (u = 2.5,))))` sets root input `in` to 2.5. Paths use slashes, not dots (D-040, log.md:1472-1488).
- fix: Write the baseline's environment layer with the algebra: `combine(at("atmosphere", set(u = (T_sl = T_sl, p_sl = p_sl, wind = wind))), at("terrain", set(u = (elevation = 0.0,))))` at lines 269 and 345, the same shape with `env.*` at 726, and `set(u = (atm = atm, trn = trn))` for the aircraft-as-root rigs at 314 and 383.
- note: No version of the spec ever had a pair-keyed `condition("path" => value)` form. The spec (§14.1, §14.2) and D-040 record the actual form, and the companion sketch never matched it. The fix is unclear because it touches five sketches and assumes the atmosphere and terrain input face names.

## K14a-012 (drift, clear=True)

- at: `design/companions/trim_environment_walkthrough.md:542`
- claim: §14.1's overlay-base decision: the base is always the declared defaults, never the stopped sim's current stores
- evidence: src/model.jl:459-462. `overlay!` resolves with `bases = _store_values(model.exec)`, so a partial entry merges onto the current stores (docstring model.jl:418-420). design/spec.md:12859-12861 says "applied through `init!` it overlays the declared defaults, and applied through `overlay!` it overlays the stopped run's stores". design/log.md:2155-2158 (D-063 annotation 2026-10-20) records that the rejected current-stores base returns as `overlay!`'s base (D-429).
- fix: §14.1's overlay base for `init!` is always the declared defaults, never the stopped sim's current stores. Only `overlay!` takes the current stores, and it takes its trace header after the overlay settles. That base exists precisely to keep a condition's meaning independent of history.
- note: 

## K14b-001 (drift, clear=True)

- at: `design/companions/linearization_walkthrough.md:327`
- claim: Trim's seeded half builds its executor with `_scratch(sim, T, act)`
- evidence: src/trim.jl:621 `seeded_exec = _scratch(model, T).exec`; src/model.jl:143 `_scratch(model::Model, ::Type{T})` takes no activation. Commit 29c3f5b6 replaced `_scratch(sim, T, act)` with `_scratch(sim, T).exec`, and trim now takes the model.
- fix: seeded_exec = _scratch(model, T).exec                # buffers at T, die with the call
- note: 

## K14b-002 (deviation, clear=True)

- at: `design/companions/linearization_walkthrough.md:375`
- claim: A bare NamedTuple handed to `linearize` gets the directive refusal `reads` gives (`ReadSetMisuse`)
- evidence: src/linearize.jl:282 `linearize(::Model, other; kw...)` throws `ArgumentInvalid(call = :linearize, argument = :taps, reason = :not_a_tap_set)`, and src/sim.jl:1171 forwards the Simulation method to it. test/test_linearize.jl:469-470 pins this. Probe P002 shows a bare NamedTuple gives `DiagnosticError{ArgumentInvalid}` with `:not_a_tap_set`, not `ReadSetMisuse`. The code has been this way since its first commit, 4f795b30, as the increment 54 brief planned (brief lines 137 and 330). The walkthrough was promoted afterwards (c347a010) with the wrong kind, and no record covers the difference.
- fix: `taps` returns a `Taps` value holding three `Reads`, so a bare NamedTuple handed to `linearize` is refused as `ArgumentInvalid` with reason `:not_a_tap_set`.
- note: 

## K14b-003 (drift, clear=False)

- at: `design/companions/linearization_walkthrough.md:396`
- claim: `x.θ` resolves to `StateRead{Dual,Nothing}(offset = 0)`, `x.ω` to `StateRead{Dual,Nothing}(offset = 1)`
- evidence: Probe P003: `_resolve_selector` gives `StateRead{Float64, ()}(0)` and `StateRead{Float64, ()}(1)` at the nominal activation. The x entries `_resolve_taps` keeps are `(1, DerivRead{Dual{LinearizeTag,Float64,8}, ()}(0))` and `(2, DerivRead{Dual8, ()}(1))` (src/linearize.jl:507-511). The offsets 0 and 1 agree. The chain parameter is `()`, not `Nothing`. At 4f795b30 the entry was `StateRead{P,I}` with an index field, so `I = Nothing` matched then. Commit 0c2ac39c ('Take a leaf address on every read selector and bake its step chain into the compiled read', D-276) replaced it with the chain `C`.
- fix: | `x.θ` | `StateRead{Float64,()}(offset = 0)`, kept as `(1, DerivRead{Dual,()}(offset = 0))` | `xbuf[1]`, and `ẋbuf[1]` for its derivative |
| `x.ω` | `StateRead{Float64,()}(offset = 1)`, kept as `(2, DerivRead{Dual,()}(offset = 1))` | `xbuf[2]`, `ẋbuf[2]` |
- note: The table could instead show only the nominal StateRead with `()`, since the prose below speaks of the StateRead baking the offset. Either wording is faithful to the code, so the fix is not unique.

## K14b-005 (deviation, clear=False)

- at: `design/companions/linearization_walkthrough.md:557`
- claim: The readback loop is `for (i, entry) in enumerate(x_entries)` with `_read(entry, ẋbuf_at(exec))` and a per-column `partials` loop over all columns
- evidence: src/linearize.jl:357-369 loops `for group in Iterators.partition(1:N, width)`. It reads x rows with `for (i, (_, entry)) in enumerate(x_entries)` and `_readback!(A, B, i, _read(entry, seeded_exec), group, n_x)` (:363-364). The entry is the DerivRead half of an `(site, DerivRead)` pair, and `_read` takes the executor itself (src/readers.jl:590). `_readback!` (linearize.jl:578-586) fills only the group's columns. No `ẋbuf_at` exists in src/, and `git log -S'ẋbuf_at'` finds only c347a010, the walkthrough's own commit. The grouped loop has been there since the first code commit, 4f795b30, which predates the walkthrough's promotion. No record covers the full-column sketch.
- fix: for group in Iterators.partition(1:N, width)        # one evaluation per group of `width` directions
    # seed the group's sites, then evaluate!(exec)
    for (i, (_, entry)) in enumerate(x_entries)      # rows of A and B; entry is the DerivRead
        ẋ₀[i] = _readback!(A, B, i, _read(entry, exec), group, n_x)
    end
    for (i, entry) in enumerate(y_entries)           # rows of C and D
        y₀[i] = Float64(_readback!(C, D, i, _read(entry, exec), group, n_x))
    end
end
# _readback! writes partial `pos` of the group's direction k into A/C (k ≤ n_x) or B/D (k > n_x)
- note: D-272 backs the code's grouping, which the walkthrough's own section 7 describes. No entry backs the doc's full-column loop. Writing the sketch with or without the `_readback!` helper are both faithful, so the fix is not unique.

## C14-001 (drift, clear=True)

- at: `src/conditions.jl:177`
- claim: spec 12987-12989 (§14.2): composition checks that each `set` payload is a NamedTuple, and a `set` payload that is not a NamedTuple is `ConditionNodeMisuse` with reason `:set_payload`.
- evidence: src/conditions.jl:177 is `_payload(name, p) = p !== nothing || throw(... :set_payload ...)`. In the probe, `set(x = 1.0)` and `set(s = :sym)` raise nothing, and only `set(x = nothing)` raises ConditionNodeMisuse :set_payload. Appendix C (spec 15771-15772) already says `:set_payload` is for a payload of `nothing` (D-437). D-437 (log.md:18179) says `set` admits a bare payload and refuses `nothing` alone. Commit dc5e833e records the change.
- fix: Each `set` payload is a NamedTuple or one bare value, each combinator operand is a node, and each `at` prefix is nonempty. A `set` payload of `nothing` is `ConditionNodeMisuse` with reason `:set_payload` ([Appendix C][sC]). A bare payload's shape is checked at resolution ([§14.3][s14-3]).
- note: 

## C14-003 (deviation, clear=True)

- at: `src/trim.jl:125`
- claim: spec 14165 (§14.9) sketch of `at(prefix::String, p::TrimProblem)` writes `reads = at(prefix, p.reads)` unconditionally, and the prose at 14154 says the lift prepends the prefix to the read set's mount chain.
- evidence: src/trim.jl:125 is `reads = problem.reads isa Reads ? at(prefix, problem.reads) : problem.reads`, and the docstring at trim.jl:116-118 states it. In the probe, `at("rig", p).reads === p.reads` for a NamedTuple reads, and trim! then raises TrimProblemInvalid :not_a_read_set. The spec sketch's unconditional `at(prefix, p.reads)` raises ConditionNodeMisuse :not_a_node instead (probe). No spec or log text records the pass-through, and code_map.md:1478-1480 names it as code fact only.
- fix: Sketch line: `reads = p.reads isa Reads ? at(prefix, p.reads) : p.reads,  #inert selector data: the prefix is prepended to the read set's mount chain; anything else passes through for setup to refuse`. Prose at 14154: "The `reads` field is a read set, and the lift prepends the prefix to the set's mount chain (...). A `reads` that is no read set passes through, so that `trim!`'s setup refuses it as `TrimProblemInvalid`."
- note: 

## C14-005 (drift, clear=True)

- at: `src/conditions.jl:670`
- claim: The comment on `_unconvertible` cites D-166 for the frozen discrete `s` and the pinned leaf at the seeded activation.
- evidence: src/conditions.jl:669-670 cites D-166 for a frozen discrete `s` and for a leaf a `Pinned` declaration holds. D-166 (log.md:6484-6486) concerns `Type{T}` output signatures and is `superseded → D-263`. D-263 (log.md:11272ff) rules the `Pinned` marker and the discrete tier's wholesale pinning. spec_rules.md:115 says never to cite a superseded entry.
- fix: # is the non-nominal case: at a seeded activation the leaves a decision descends into are the ones the activation retyped, and a *frozen* discrete `s` (§9.4, D-263) or a leaf a `Pinned` declaration holds at `Float64` is not one of them
- note: 

## C14-006 (drift, clear=True)

- at: `src/linearize.jl:518`
- claim: The comment on the `u` list's `_seeded_tap` cites D-167 for "a continuous one pins by declaration".
- evidence: src/linearize.jl:517-518 cites D-167 for "a continuous one pins by declaration". D-167 is `superseded → D-263` (log.md:6586), and its annotation (log.md:6640-6643) moves "demands frozen" to D-263's `Pinned{P}`. D-263's Position (log.md:11286-11288) now states the ruling. spec_rules.md:115 says never to cite a superseded entry.
- fix: # activation's scalar, named with its tier and its declared entry: a continuous one pins by declaration (D-263), a discrete one by tier (§8.2).
- note: Other code sites cite D-167 too: build.jl:896, build.jl:1644, diagnostics.jl:2190/2210. The last one emits "D-167" in a message's citation.

## C14-007 (drift, clear=True)

- at: `design/code_map.md:882`
- claim: The `src/linearize.jl` entry's Spec line lists D-167.
- evidence: design/code_map.md:882 lists D-167, which src/linearize.jl:518 cites. design/log.md:6586 gives D-167's status as `superseded → D-263`. D-263's Position (log.md:11286) carries the permissive reading with `Pinned` as its spelling, and linearize.jl cites D-263 twice. spec_rules.md:115 says never to cite a superseded entry.
- fix: Spec: §9.7, §14.4, §14.10, D-036, D-168, D-197, D-213, D-263, D-272, D-274, ... (D-263 in place of D-167, moved with the comment at linearize.jl:518)
- note: This follows C14-006. If the comment keeps D-167, the map line matches the file as it stands.

## C14-008 (deviation, clear=False)

- at: `src/linearize.jl:291`
- claim: Appendix C's `ArgumentInvalid` entry (spec ~15888-15915) and §14.8/§14.10 do not list the reasons these sites raise: `:nonpositive_width` (a `width` below 1), `:t0_without_about`, `:not_a_tap_set` (linearize.jl:282-285, 291-298), `:not_a_problem` (trim.jl:568-570), and `:range` on a `t0` that is not exact or cannot carry a run (model.jl `_origin`, via trim.jl:562 and linearize.jl:318).
- evidence: In the probe, linearize with width=0 gives ArgumentInvalid :nonpositive_width (linearize.jl:292). A t0 without about gives :t0_without_about (linearize.jl:294). A non-tap-set second argument gives :not_a_tap_set (linearize.jl:283). trim!(model, 1) gives :not_a_problem (trim.jl:569). A t0 of 1//0 or big(2)^70 gives :range (model.jl:375-376, 350). rg finds none of these reason names in spec.md. §14.10 (14343-14347) names only the kind for t0, says nothing of a width below 1, and Appendix C's ArgumentInvalid entry (15887-15915) lists none of them. D-420 names :t0_without_about only in its Rationale.
- fix: Add to Appendix C's ArgumentInvalid entry: "`linearize` refuses a `width` below 1 as `:nonpositive_width`, a `t0` without `about` as `:t0_without_about` ([D-420][d-420]), and a second argument that is no tap set as `:not_a_tap_set`; `trim!` refuses one that is no `TrimProblem` as `:not_a_problem`. A `t0` handed to `init!`, `trim!` or `linearize` that is not exact or whose run the clock's integers cannot carry is `:range` ([D-457][d-457])." Also add to §14.10: "A `width` below 1 is refused as `ArgumentInvalid`."
- note: The width-below-1 refusal adds a rule that §14.10 does not state, so it goes past wording.

## C14-009 (deviation, clear=True)

- at: `src/trim.jl:674`
- claim: Neither §14.8, the `trim!` docstring nor the `TrimProblem` docstring says that the guess is projected into the box before the search.
- evidence: src/trim.jl:666-674 clamps the guess into the box once, `d0 = clamp.(...)`, before `solve`. The setup evaluation at trim.jl:597 still uses the unprojected guess. In the probe, guess u=10.0 in box [-1, 3] showed condition calls at 10.0, 10.0, then 3.0, and returned solution u=3.0, status=stalled, saturated=[(:u, :upper)]. §14.8 (13792-13802) says only that d0 is packed and that bounds are honored by step projection (D-070). The trim! docstring (trim.jl:500-557) and the TrimProblem docstring (trim.jl:24-66) are silent on it, and no log or pending text records it.
- fix: Add to §14.8's "Box bounds and saturated decisions": "The search starts from the guess projected into the box, so a guess outside it starts at the nearest point inside, and every point the backend sees and returns lies in the box. Setup's guess evaluation reads the guess as authored." Add to the `trim!` or `TrimProblem` docstring: "The search starts from the guess clamped into the bounds."
- note: 


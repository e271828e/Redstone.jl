# Unit B (§14.4, §14.5, §14.6): claims

old: ### 14.4 One plan, two ways to apply it
note: title kept (R9, F16)

old: The paradigm-change tax feared at execution does not materialize.
new: A resolved condition (the path-addressed sparse overlay that sets a build's state) is applied two ways, because a one-shot service and an iterating one want different things from the same validated list of condition entries (D-066).
tag: R
ruling: R8
newcites: D-066
note: R8 and F28: the context paragraph replaces the aphorism; F28's wording, 'entry list' made 'list of condition entries' (R13, F29). The condition link and gloss move here, the section's new first use. D-066 Position: 'Two ways to apply one compiled plan'

added: The section gives the two ways, then the read-selector family.

added: #### Applying a plan

old: All string work, validation and addressing are functions of the shape of the condition (the path-addressed sparse overlay that sets a build's state).
new: All string work, validation and addressing are functions of the shape of the condition.
note: link and gloss moved to the context sentence, the new first use

old: Every hot path holds the shape fixed while varying values.

old: Execution is therefore resolve-once/execute-many, with two ways to apply one plan.
new: Execution is therefore resolve-once/execute-many. A valid list of condition entries compiles two ways, one for each way to apply it.
tag: R
ruling: R9
note: F16 amended wording, its first sentence, with 'entry list' made 'list of condition entries' (R13); the per-plan sentences sit in each bullet. Code: ConditionPlan and SpecializedPlan, src/conditions.jl 254-275, 640-707 (survey F16)

old: - Specialized `apply!` serves the service that iterates, trim's per-evaluation write.
new: - Specialized `apply!` serves the service that iterates, trim's per-evaluation write (D-066). Its plan holds, per leaf, a lens (the compiled navigation step of a condition entry), a destination and a converter.
tag: R
ruling: R7
newcites: D-066
note: list label becomes the bold headline clause of D-066's first semicolon ruling, 'specialized apply! ... for iterating services'. The plan sentence is F16's amended wording (R9); lens linked and glossed at its first use, gloss from #g-lens

old: It unrolls stores through the baked lenses and converters.
note: store linked at its first use, no gloss

old: Those are the same machine operations as today's in-place writes: zero-alloc, no strings, no dispatch.
new: Those are the same machine operations as FlightCore's in-place state writes, with no allocation, no strings and no dispatch.
tag: R
ruling: R12
note: 'today's' names FlightCore's in-place writes to a Model's state (checked ~/.julia/dev/Flight.jl/lib/FlightCore/src/modeling.jl, Model and f_init!/f_ode! extended in place); mid-sentence colon goes

old: The per-iteration shape check is the mechanism of §9.5 transferred.

old: The tree type is proven by dispatch, and it carries the full nesting, every field name and leaf type.

old: A `===` sweep over the prefix strings closes the remainder.
new: A `===` comparison of each prefix string closes the remainder.
tag: R
ruling: R9
note: F17: sweep is reserved for a pass through the execution order

old: `===` on strings compares content, so a prefix computed at run time pairs with the compiled one exactly as a literal does, at the cost of one short comparison per `at` node.

old: Shape drift (a tree of another type, or a prefix that differs at a position) is `ConditionShapeDrift` (Appendix C), a structured error rather than silent corruption.
new: Shape drift is a tree of another type, or a prefix that differs at a position. It is `ConditionShapeDrift` (Appendix C), reason `:tree_type` or `:prefix`, a structured error rather than silent corruption.
tag: R
ruling: R14
note: kind named with its reasons, src/conditions.jl 781, 785 (:tree_type, :prefix); one parenthetical per sentence

old: The cost is Julia codegen once per condition shape, and it grows with the shape's writes.
new: The cost is Julia codegen once per condition shape, and it grows with the shape's writes (D-066).
tag: C
newcites: D-066
note: D-066 Position '~10-50 ms codegen once per shape' and its 2026-10-02 annotation, 'the codegen cost grows with the shape's writes'

old: On Julia 1.13 it measures 10 to 50 ms up to 32 writes, 0.09 s at 64 and 0.2 s at 128 (`docs/reports/20261002_tuple_walks/`).

old: That cost is noise against the model's own first-sweep warmup (seconds), and against the 10³–10⁴ optimizer evaluations the codegen amortizes over.
new: That cost is noise against the model's own first-sweep warmup (seconds). It is paid once per tree type per session, so it spreads over every evaluation of every trim of that shape, an envelope of trims included.
tag: R
ruling: R9
note: F18 amended: the 10³-10⁴ count is cut as unsupported against §14.7's ~5-15 evaluations

old: - The dynamic walk serves the one-shot uses, `init!` and `linearize`'s operating condition.
new: - The dynamic walk serves the one-shot uses, `init!`, `linearize`'s operating condition and trim's setup write (§14.8, D-066).
tag: R
ruling: R9
newcites: §14.8 D-066
note: F19 adds trim's setup write (src/trim.jl 480-483; §14.8 12186-12187). List label becomes the bold headline of D-066's second semicolon ruling, 'dynamic entry-list walk ... for one-shot init' (R7)

old: It executes the same validated entry list by runtime dispatch per write.
new: It executes the same validated condition entries by runtime dispatch per write, from a plan that holds the converted values themselves.
tag: R
ruling: R9
note: F29 (bare entry, R13) and F16's amended last sentence, 'The dynamic walk's plan holds the converted values themselves'

old: That takes microseconds in total, with allocation permitted, since the stopped-sim path was never under the zero-alloc regime (§9.8).

old: It needs no per-shape codegen.

old: Fifty structurally different scripted conditions cost fifty walks, not fifty compiles.

old: Rule. Which of the two a service uses is internal, never user-facing API.
new: Which of the two a service uses is internal, never user-facing API.
note: the Rule. label goes; stated plain, since no entry rules it for the two ways (D-130 assumes it as a precedent); §13.3 10283 and D-130 rely on the sentence

old: A compiled plan or reader carries the activation it was compiled at and applies only to a store set of that activation.
tag: M
note: M4: moved down after the gather twin, where readers are defined

old: That pairing is a framework invariant the services uphold, not a user-facing check.
tag: M
note: M4

old: Neither plans nor readers are user values.
tag: M
note: M4

old: #### The read-selector family
note: no file links this anchor

old: The read-selector family is closed.
new: The read-selector family is closed (D-095).
tag: C
newcites: D-095
note: bold kept on D-095's one ruling, first in reading order ('spelled with a get_ prefix and completed'); the prefix sentence below cites it plain

old: Its members are `get_state(path, leaf)`, `get_deriv(path, leaf)`, `get_output(path, leaf)`, `get_input(leaf)` and `get_face(leaf)`.

old: They form one address space for every reader of the model.

old: Rule. `leaf` is a leaf address: the field or face name, followed by `.name` and `[k]` or `[k,l]` steps in any order, as in `"pose.q_eb[2]"`, `"ω_eb_b[1]"` or `"J[1,3]"`.
new: `leaf` is a leaf address (D-276). It is the field or face name (the name a port wears on its component's boundary), followed by `.name` and `[k]` or `[k,l]` steps in any order, as in `"pose.q_eb[2]"`, `"ω_eb_b[1]"` or `"J[1,3]"`.
tag: R
ruling: R7
newcites: D-276
note: Rule. label goes; bold headline of D-276's Position, 'The second argument of every read selector is a leaf address'; mid-sentence colon goes; face linked and glossed at its first use (late link fixed), gloss from #g-face

old: A bare `Symbol` is the short form of a plain name, so `get_state("kin", :θ)` reads `get_state("kin", "θ")`.
new: A bare `Symbol` is the short form of a plain name, so `get_state("kin", :θ)` reads `get_state("kin", "θ")` (D-276).
tag: R
ruling: R19
newcites: D-276
note: bold headline of D-276 bullet 1, bold nowhere else in the frozen spec

old: A face name is an arbitrary string and may contain a dot (§8.6), so on `get_input` and `get_face` the head is matched rather than parsed: it is the longest declared face name that is a prefix of the address and is followed by the end, a `.` or a `[`, and a `Symbol` leaf names the face whole, with no steps.
new: A face name is an arbitrary string and may contain a dot (§8.6), so on `get_input` and `get_face` the head is matched rather than parsed. The head is the longest declared face name that is a prefix of the address and is followed by the end, a `.` or a `[`. A `Symbol` leaf names the face whole, with no steps.
note: mid-sentence colon goes; one sentence becomes three

old: So `get_input("wing.throttle")` and `get_input("wind[1]")` both resolve, and where faces `a` and `a.b` both exist, `"a.b"` names the face `a.b`.

old: Each step is checked at resolution against the type resolved so far.
new: Each step is checked at resolution against the type resolved so far (D-276).
tag: R
ruling: R19
newcites: D-276
note: bold headline of D-276 bullet 2, bold nowhere else in the frozen spec

old: A `.name` step needs an isbits struct with that field.

old: An index step needs an `SArray`, with one index or one per dimension, and a vector leaf thereby yields named scalars.

old: A step never enters an opaque leaf (a field handle or a `Symbol`), which is read whole.

old: A continuous state field is flat (§7.1), so `get_deriv`, and `get_state` on the continuous tier, take at most an index step.
new: `get_deriv`, and `get_state` on the continuous tier, take at most an index step, since a continuous state field is flat (§7.1, D-276).
tag: R
ruling: R19
newcites: §7.1 D-276
note: bold headline of D-276 bullet 4 and its 2026-09-30 annotation; rule first, reason after; bold nowhere else in the frozen spec

old: A discrete `s` field is isbits or a `Symbol` (§3.2), and `get_state` on it takes the full address.

old: The address is checked once and baked, and the read runs as field loads and indexing unrolled at compile time (D-276).
tag: R
ruling: R19
note: bold headline of D-276 bullet 3, 'The baked read ... executes it as getfield and getindex calls unrolled at compile time', bold nowhere else; the binding read (bullet 5) stays plain with its pointers, and wiring (bullet 7) is not stated here

old: The names carry a deliberate `get_` prefix.
new: The names carry a deliberate `get_` prefix (D-095).
tag: C
newcites: D-095
note: D-095 Position: 'spelled with a get_ prefix ... a selector is a deferred read, so the prefix names the eventual action, keeps six short common nouns out of the namespace'; plain, the family's bold above carries D-095's one ruling

old: A selector is a deferred read, a value describing the read the compiled gather will perform.

old: The prefix names that action, and it keeps five short common nouns out of the namespace user declarations share with domain code.

old: There is no selector for a value a component computes without declaring it, and there cannot be one, because only cells are addressable (§4.2, §8.3).
new: There is no selector for a value a component computes without declaring it, and there cannot be one, because only declared cells and stores are addressable (§4.2, §8.3).
tag: R
ruling: R9
note: F20: the store selectors address stores (src/readers.jl 48-49, 'Only cells and stores are addressable')

old: So a reader that wants one is asking the producing component to declare it an output (§8.3).

old: `get_face` addresses an output face of the mount level, the level its read set is mounted at (§14.9).
new: `get_face` addresses an output face of the mount level, the level its read set is mounted at (§14.9, D-277). Mounting relocates a whole problem or tap set (the three selector lists declaring what linearization seeds and reports) with `at(prefix, …)`.
tag: C
newcites: §14.9 D-277
note: D-277 bullet 3: 'get_face(name) names an output face of the mount level ... at the root it is the integration read it was'. Mounting linked at its first use (late link fixed); its gloss, moved from old 11675, stands as its own sentence, the #g-mounting definition; tap set linked there with the taps gloss moved from old 11668

old: At the root that face is root-exported.

old: Either way the read is an integration read (§11.2).

old: Rule. A selector resolves against a source, before any client policy applies.
new: A selector resolves against a source, before any client policy applies (D-098).
tag: R
ruling: R7
newcites: D-098
note: Rule. label goes; bold headline of D-098's Position, 'a selector resolves against a source before any client policy'. R5 keeps the source rule as the one enforced rule

old: The table selectors (`get_output`, `get_input`, `get_face`) resolve against a table source.

old: A table source is a boundary snapshot, or the scratch tables a service evaluation instantiates (§14.8).
new: A table source is a boundary snapshot, or the scratch tables a service evaluation instantiates (§14.8, D-124).
tag: C
newcites: §14.8 D-124
note: D-124 Rationale: 'table sources (a boundary snapshot, or the scratch tables a service evaluation instantiates, §14.8)'; Rationale-only

old: The store selectors (`get_state`, `get_deriv`) resolve only against live stores.
new: The store selectors (`get_state`, `get_deriv`) resolve only against live stores (D-098).
tag: C
newcites: D-098
note: D-098 Position: 'store selectors (get_state/get_deriv) only against live stores'

old: The table/store axis separates table-borne values from store-borne ones, not snapshots from services.

old: Only stopped-sim service evaluations, `checkpoint`, and post-run inspection of the live stores (the replay-to-inspect, §11.2) ever hold live stores.
new: Only stopped-sim service evaluations, `checkpoint`, and post-run inspection of the live stores (the replay-to-inspect) ever hold live stores (§11.2).
note: the citation leaves the gloss's parentheses; checkpoint linked at its first use, no gloss

old: The snapshot deliberately carries no state stores (§11.2), and `ẋ` buffers are integrator scratch, not boundary-consistent objects outside a service evaluation.

old: A reader resolving for a table source that names a store selector is therefore refused at resolution, as a `ReadResolution` (D-406).
new: A reader resolving for a table source that names a store selector is therefore refused at resolution, as a `ReadResolution` with reason `:store_selector` (D-406).
tag: R
ruling: R14
note: reason named, src/readers.jl 441-442; D-406 bullet 1 'refused as :store_selector'

old: The resolver takes the source it resolves for, so the rule is the resolver's and not a client's.
new: The resolver takes the source it resolves for, so the rule is the resolver's and not a client's (D-406).
tag: R
ruling: R7
newcites: D-406
note: bold headline of D-406 bullet 1, 'The resolver takes the source it resolves for ... The source rule is the resolver's, not a client's', bold nowhere else; its citation repeated in the sentence

old: The honest remedy (§11.2) is to declare the field in `y_types`, return it from `y_state`, and read the resulting port (§5.3).

old: Client policy rides on top. It is D-083's service and inspection sides restated as a resolver property.
new: On top of the source rule sits one piece of authoring guidance (D-414).
tag: R
ruling: R5
newcites: D-414
note: R5: the two sentences are cut as false (D-414 Rejected, a resolver §14.4 keeps client-free; src/readers.jl 429-445) and replaced by the dictated guidance sentence. D-083 moves to the inspection sentence below

added: An inspection read, a binding's or `series`', may name any cell the structure has, since it promises nothing beyond this build (D-083).

added: Both resolve under the one service walk (§13.3).

old: - Service reads speak the contract.
new: A service read, trim's `reads` or a tap, that should outlive the build reads a face with `get_face` (D-125).
tag: R
ruling: R5
newcites: D-125
note: R5: the bold lead-in goes plain and becomes the dictated guidance, since D-414 bullet 4 makes it authoring guidance. D-125 Position, 'get_face is admitted to the service set ... so an equilibrium equation crossing a generic seam binds the curated face contract', with D-414's annotation. The list becomes paragraphs

old: Trim's `reads` and linearization's taps (the three selector lists declaring what linearization seeds and reports) name `get_state`/`get_deriv`/`get_output`/`get_input`/`get_face`.
new: Trim's `reads` and linearization's taps name `get_state`/`get_deriv`/`get_output`/`get_input`/`get_face`.
note: the taps link and gloss move to the first use, 'tap set' in the mounting sentence, the old gloss verbatim

old: They do so within the scopes the locality law (§6.1) and fragment scoping (§14.2) describe, as authoring guidance (D-414).

old: `get_face` is the set's seam-crossing member. It resolves through export chains exactly as mounting (relocating a whole problem or tap set with `at(prefix, …)`) resolves root input faces (§14.9), so the read side mirrors the write side.
new: `get_face` resolves through export chains exactly as mounting resolves root input faces (§14.9), so the read side mirrors the write side.
tag: R
ruling: R5
note: R5 cuts 'get_face is the set's seam-crossing member': since D-414 every path selector crosses a seam. The mounting gloss moved to the first use above. The sentence moves up into the guidance paragraph, beside the dictated get_face sentence (D-125 Position 'resolves through export chains exactly as §14.9's mounting resolves slot faces')

old: An equilibrium equation meant to outlive the build it was posed against therefore binds the curated face behind a generically-held child rather than a path into it.
new: An equilibrium equation meant to outlive the build it was posed against therefore binds the curated face behind a generically held child (one held through a non-concrete field type) rather than a path into it.
tag: R
ruling: R5
note: kept as guidance (R5); 'generically held' linked at first use, gloss from #g-generic-holding

old: A service evaluation needing an undeclared intermediate has one remedy, and it is the same for every client. The component exports it (§14.7).
new: A service evaluation needing an undeclared intermediate has that one remedy too, and it is the same for every client. The component exports it (§14.7).
tag: M
note: M5 and R6: merged into the undeclared-value paragraph, §14.4 its home; 'that ... too' ties it to the declare-an-output remedy

old: - Inspection readers admit the whole family, within the source rule.
new: Inspection reads admit the whole family, within the source rule.
tag: R
ruling: R5
note: bold lead-in goes plain (D-095 Rationale only); 'readers' becomes 'reads', the dictated text's word for a binding's or series' read

old: Output-device bindings, log extraction by `series` and snapshot inspection take deep paths, `get_face` names and leaf addresses alike (D-406, D-407, D-414).
new: Output-device bindings and log extraction by `series` take deep paths, `get_face` names and leaf addresses alike (D-406, D-407, D-414). Snapshot inspection reads a cell by path and port name instead (§11.2).
tag: R
ruling: R5
newcites: D-406 D-407 D-414 §11.2
note: F21: snapshot inspection leaves the selector clients, R5's dictated sentence (src/dataplane.jl 480-481)

old: The store selectors reach only the inspection clients that actually hold stores (`checkpoint`, post-run inspection). A snapshot-bound reader is barred from them by source, not by client.
new: A store selector resolves only for a reader that runs over live stores, which today are the services' (§14.7, §14.10). A snapshot-bound reader is barred from it by source, not by client.
tag: R
ruling: R5
newcites: §14.7 §14.10
note: F22's sentence, R5's dictated wording (src/readers.jl 36-42; src/bindings.jl 147, src/sim.jl 2252 resolve for :table)

old: - `ignore_stop_requests` is not a family client.
new: `ignore_stop_requests` is not a family client.
note: bold lead-in goes plain (D-095 Rationale and Rejected only)

old: It names requesters from the `Build`'s requester roster, period (§13.5, D-060, D-316).
new: It names requesters from the `Build`'s requester roster (the build's list of stop requests, one per `StopFlag` output port), period (§13.5, D-316).
tag: C
newcites: §13.5 D-316
note: D-060's policy clause is superseded by D-316 (annotation 2026-10-08); D-316 bullet 6 carries the fact. D-060 moves to the next sentence. requester roster linked and glossed (carried item), gloss from #g-requester-roster

old: Termination is run policy over the requests the model declares, and no path selector reaches `ignore_stop_requests`.
new: Termination is run policy over the requests the model declares, and no path selector reaches `ignore_stop_requests` (D-060).
tag: C
newcites: D-060
note: D-060 Rejected, 'Root-type-declared policy: stopping is run policy', a clause D-316's annotation leaves standing; Rationale-only

old: The five selectors, their sources, and their clients:
new: The five selectors and their sources:
tag: R
ruling: R5

old: | selector | resolves against | service reads | inspection readers | |---|---|---|---| | `get_state(path, leaf)` | live stores | named in the contract | only clients that hold stores | | `get_deriv(path, leaf)` | live stores | named in the contract | only clients that hold stores | | `get_output(path, leaf)` | a table source | named in the contract | admitted | | `get_input(leaf)` | a table source | named in the contract | admitted | | `get_face(leaf)` | a table source | named in the contract | admitted |
new: | selector | resolves against | |---|---| | `get_state(path, leaf)` | live stores | | `get_deriv(path, leaf)` | live stores | | `get_output(path, leaf)` | a table source | | `get_input(leaf)` | a table source | | `get_face(leaf)` | a table source |
tag: R
ruling: R5
note: R5: the table keeps its selector and source columns and drops the two client columns

old: Compiled readers are the gather twin over this family and the layout tables.
new: Compiled readers are the gather twin (D-066) over this family and the layout tables (where each value physically lives).
tag: R
ruling: R7
newcites: D-066
note: bold lead-in becomes the bold headline of D-066's third semicolon ruling, 'compiled readers as the gather twin'; §14.4 its home (R6). layout linked at first use, gloss from #g-schema-vs-layout

old: Trim's cost read (`ẋ` and output fields) and linearization's Jacobian gather are one primitive run in reverse.
new: Trim's residual reads (`ẋ` and output fields) and linearization's Jacobian gather are one primitive run in reverse.
tag: R
ruling: R9
note: F23: trim reads a residual system, not a cost (§14.7)

old: It is one machinery, in both directions, in the `Build`'s client kit.

old: The per-iteration ledger for trim has four terms.
tag: M
note: M3: moved up after the internal-API sentence

old: They are the user fragment math (the domain computations unchanged from today, plus the tree's few boxes, §14.2), the leaf stores, the folded shape check, and the sweep.
new: They are the user fragment math, the leaf stores, the folded shape check and the sweep (one pass through the execution order against the current state). The fragment math is the domain computations, unchanged from Flight.jl's, plus building the tree, which allocates nothing (§14.2).
tag: R
ruling: R9
note: M3 move; F9(c) 'plus building the tree, which allocates nothing'; R12 'today' becomes Flight.jl's (the domain math of Flight.jl's FlightPhysics and FlightApps models); sweep linked and glossed at its first true use (#g-sweep)

old: The sweep dominates, exactly as `f_ode!` does today.
new: The sweep dominates, exactly as `f_ode!` does in FlightCore, where it is the continuous-dynamics function a model extends.
tag: R
ruling: R12
note: M3 move; owner checked: ~/.julia/dev/Flight.jl/lib/FlightCore/src/modeling.jl 208-211, '#continuous dynamics, to be extended by Models'

old: `apply!` ends at established stores.

old: Making the model coherent is the job of boundary zero (the initialization boundary: the ordinary macro-sequence with an empty integrate), §14.5.
new: Making the model coherent is the job of boundary zero (the initialization boundary, the ordinary macro-sequence with an empty integrate), which §14.5 specifies.
note: colon in the gloss goes; the citation leaves the gloss; stays the section's last sentence (M3)

old: ### 14.5 Boundary zero: an ordinary boundary with authored incoming transitions

old: `apply!` establishes the stores at `t₀`.
note: store linked at its first use

old: The init service then completes the §10.6 macro-sequence with an empty integrate.
new: The init service then completes the §10.6 macro-sequence with an empty integrate (D-067).
tag: R
ruling: R7
newcites: §10.6 D-067
note: bold headline of D-067's Position, 'Boundary zero is the §10.6 macro-sequence run with an empty integrate'; §10.6 6646 states it plain and points here. Not in R7's list for §14.5: see rulings, open questions

old: The sequence is
new: The sequence is the following.
note: the inline sequence becomes a display, as in §10.6 6642-6644

old: project → [sweep → guards → handlers]\ → due `s_update` calls → first snapshot.
new: > project → [sweep → guards → handlers]\ → due `s_update` calls → first snapshot

old: After the first snapshot `init!` takes the trace header, the checkpoint (the `Model`'s state at a frame top as one value) of the state the sequence leaves (§11.5, D-274).

old: The parity with an ordinary boundary is exact, not approximate.
note: boundary linked here, since the old link sat inside 'boundary zero' (F4)

old: The pieces follow one by one.
new: The pieces follow one by one, in run order. Projection, the sweep, events and the due `s_update` calls come first, then the `t₀` argument, then what boundary zero (the initialization boundary at `t₀`) means for trim.
tag: X
note: the context's parts sentence (survey part C); boundary zero linked and glossed at its first prose use (late link fixed, F4), gloss from #g-boundary-zero

old: - Project runs.

old: Authored `x` can sit off-manifold.

old: A hand-assembled quaternion may be ulps off unit norm, or a condition (the path-addressed sparse overlay that sets a build's state) may write part of a constrained block against fresh defaults.

old: Projection after condition writes holds the same position it holds after any other `x` mutation.

old: And it costs nothing when the state is already clean.

old: - The sweep runs, and every discrete output stage publishes, due or not (D-205).

old: `t₀` is a grid point of every phase-free divisor, so the `Φ = 0` components are due in full.

old: An offset component (§10.5) is not due, because its first tick is at `Φ·Δt_base`.

old: Its output stages run at boundary zero all the same, publishing from the authored `s` and the `t₀` table in the ordinary sorted walk.

old: That evaluation is establishment, not a scheduled sample.

old: The schedule owns every instant after `t₀`, and the first sample the component's `s_update` consumes remains its `Φ·Δt_base` tick's.

old: What the rule buys is a `t₀` snapshot carrying the authored world fully evaluated.

old: No published cell holds the probe's synthesized values.

old: That is the §14.6 barrier extended from the root inputs to the whole table.

old: - Events run.

old: A condition can land a guard predicate in holding territory (firing on not-holding → holding transitions, never bare sign changes).

old: An authored stall flag, or a strut authored into contact, does exactly that.

old: The event then fires visibly at `t₀` rather than one step later.

old: The prior rule grounds that timing (§10.6).
new: The prior rule grounds that timing (§10.6, D-292).
tag: C
newcites: §10.6 D-292
note: D-292 bullet 1: 'Boundary zero sets every prior to not-holding, so an authored condition whose guard holds fires at t₀'; plain, §10.6 6487 bolds it (O7)

old: Boundary zero establishes every guard prior (the event's stored predicate sample from the previous boundary) as not-holding.
note: the late boundary-zero link moves to the section's first prose use (F4)

old: Suppressing those firings was rejected (D-067), on the stage-on-interaction lesson of §11.7 (widgets stage on edit or activation, never per render pass). Insurance that masks invariant violations is anti-diagnostic (D-026).
new: Suppressing those firings was rejected (D-067), on the lesson of the stage-on-interaction rule (§11.7). That lesson is that insurance masking invariant violations is anti-diagnostic (D-026).
tag: R
ruling: R9
note: F14: the gloss describing the parked GUI's widgets goes, and the lesson is stated as the insurance rule (§11.7 8337-8340, D-026)

old: The trace header is taken after the sequence (§11.5).

old: Replay restores it and runs no boundary zero, so whatever fired at `t₀` comes back as part of the restored state and never fires twice (§12.7).
new: Replay restores it and runs no boundary zero, so whatever fired at `t₀` comes back as part of the restored state and never fires twice (§12.7, D-274).
tag: C
newcites: §12.7 D-274
note: D-274 bullet 3, 'runs no boundary zero', and bullet 4, 'Replay restores it'. F4: the wrong #g-boundary link inside 'boundary zero' goes

old: The checkpoint records the post-firing state faithfully and suppresses nothing.

old: A stop request already reading `STOP_REQUESTED` is a different category.

old: Nothing fires.

old: The request simply holds in the published `t₀` snapshot and the loop reacts (§13.5).
new: The request simply holds in the published `t₀` snapshot and the loop reacts (§13.5, D-413).
tag: C
newcites: §13.5 D-413
note: D-413 bullet 1: 'After init! that snapshot is boundary zero's, so an authored condition already terminal ends the run at t₀'

old: - Due `s_update` calls run.
note: list label goes plain (R7)

old: This follows from an interval-alignment fact that is easy to mis-picture.

old: It is hereby a taught contract, sibling to the boundary-sampling line (§8.6).

old: A boundary's `s_update` is the outgoing transition.
new: A boundary's `s_update` is the outgoing transition (D-067).
tag: R
ruling: R7
newcites: D-067
note: bold headline of D-067 bullet 1, 'a boundary's update is the outgoing transition', citation now in the sentence (q4)

old: At tick `t_k` it consumes the completed boundary's samples and produces `s_{k+1}`, the value the next tick reads.

old: The transition that carried `s` into `t_k` ran at `t_{k-1}`.

old: Boundary zero is missing its incoming transitions on both tiers, and authorship replaces both.
new: Boundary zero is missing its incoming transitions on both tiers (the continuous and discrete sides of the hybrid formalism), and authorship replaces both.
note: tier linked and glossed at its first use, from the table header (late link fixed), gloss from #g-tier

old: | tier | `t₋₁` | `t₀` (boundary zero) | `t₁` | |---|---|---|---| | discrete | the `s_update` that would have produced a discrete leaf's `s(0)` never ran; the condition authored `s(0)` | `s_update` consumes the `t₀` samples and produces `s(1)` | the gated stages read `s(1)` | | continuous | the integration over `[t_{-1}, t_0]` that would have produced a continuous leaf's `x(0)` never ran; the condition authored `x(0)` | the authored `x(0)` is the initial condition of the outgoing integrate, $t_0 \to t_0 + h$ | |
note: carried verbatim with its two-space indent; the header's tier link moves to the prose first use

old: The outgoing work all runs, and `t₀`'s `s_update` has its only opportunity.

old: `s(1)` must sit in the store before `t₁`'s gated stages read it.

old: An accumulator $s_{k+1} = s_k + \Delta t \, e_k$ authored with $s_0 = 0$ under nonzero $e(t_0)$ would otherwise first integrate $e(t_1)$, putting the whole sampled-data lattice one period late (D-067).

old: The authored `s(0)` needs no protection, because it is published in the `t₀` snapshot regardless.

old: The continuous-tier analogue of `s_update`-at-`t₀` is not the empty incoming integrate but that first outgoing one.

old: Both authored values are the published initial conditions of their outgoing transitions.

old: - `t₀` is an init-service argument (default `0.0`), never a condition entry, because time is not a store of any component.
new: - `t₀` is an init-service argument (default `0.0`), never a condition entry, because time is not a store of any component (D-067).
tag: R
ruling: R7
newcites: D-067
note: bold lead-in becomes the bold headline of D-067 bullet 2, 't₀ is an init-service argument anchoring the harmonic grid'; Rejected 't₀ as a condition entry: time is not a store'

old: The harmonic grid (every discrete period an integer multiple of `Δt_base`) anchors at whatever `t₀` boundary zero runs at.

old: Both init-service entry points carry the argument, with the same default.
new: Both init-service entry points carry the argument, with the same default (D-110).
tag: R
ruling: R7
newcites: D-110
note: D-110's bold home is §14.5 (R7). Position: 'trim! gains the init-service t0 argument ... default 0.0 matching init! (one rule for both entry points)'

old: They are `init!(model, condition; t0)`, which the simulation's `init!(sim, condition; t0)` forwards to, and `trim!`'s commit (§14.8, D-319).
new: They are `init!(model, condition; t0)` and `trim!`'s commit (§14.8, D-319). The simulation's `init!(sim, condition; t0)` wraps the model's, resolving the condition and opening the run before the model's method writes.
tag: R
ruling: R9
note: F27 (src/sim.jl 591-607); 'door' avoided for the model's init!, which opens no run (R13)

old: `trim!(model, problem; baseline, t0, backend)` commits through the model's `init!`, and `trim!(sim, problem; baseline, t0, backend)` through the simulation's.
new: Each form of `trim!` commits through the matching `init!`, the model's or the simulation's (§14.8).
tag: R
ruling: R6
newcites: §14.8
note: R6: §14.8 keeps trim!'s signature (units/F/old.md, 'The backend seam'); §14.5 keeps which init! each form commits through, with a pointer

old: Conditions are time-free.

old: Nothing after boundary zero sets the origin.

old: A restore inherits the clock and takes no `t0` (D-273).

old: - Trim is untouched by all of this.
new: - Trim is untouched by all of this (D-067).
tag: R
ruling: R7
newcites: D-067
note: D-067 bullet 3 bold once, on row 200 (R7): 'Trim iterations bypass boundaries entirely ... only the commit runs boundary zero'

old: Optimizer iterations are raw write → sweep → read cycles on the activation, with no boundaries, no events and no `s_update`.

old: Only the committed solution executes boundary zero.

old: - A guard firing at commit is a wanted failure signal.
note: bold lead-in goes plain: D-067 bullet 3's one bold sits on 'Trim is untouched' (R7)

old: Today's hand-written trim asserts (`!stall`, no weight-on-wheels, `ω > ω_idle`) become the model's own event logic, surfaced through the ordinary machinery instead of `@assert`.
new: The hand-written trim asserts of Flight.jl's Cessna 172 models (`!stall`, no weight-on-wheels, `ω > ω_idle`) become the model's own event logic, surfaced through the ordinary machinery instead of `@assert`.
tag: R
ruling: R12
note: owner checked: ~/.julia/dev/Flight.jl/lib/FlightApps/src/c172/c172s/c172s.jl 256-257 and c172x/c172x.jl 317-318 (the weight-on-wheels and ω_idle asserts after f_init!); see rulings on !stall

old: A handler that fires at commit moves the committed stores off the solved point.

old: Saying nothing would be warn-but-assign relocated.

old: The channel that says it is the trim report (§14.8).
new: The channel that says it is the trim report (§14.8, D-126).
tag: R
ruling: R7
newcites: §14.8 D-126
note: bold headline of D-126's one ruling, 'Events firing at trim's boundary zero get a channel, the TrimReport carries the fired set'; first in reading order, §14.8 points (R7)

old: - A commit-fired handler is not the only mover, and the second one is unconditional.
new: - A commit-fired handler is not the only mover, and the second one is unconditional (D-155).
tag: R
ruling: R7
newcites: D-155
note: bold lead-in becomes the bold headline clause of D-155's first ruling, 'Projection is named the second legitimate mover of the committed point'; §14.8 bolds TrimCommitResiduals (unit G)

old: Boundary zero's first act is `x_projection`, so the committed `x` is `x_projection(x)`, not the solver's `x`.

old: An attitude quaternion renormalized by a few ulps is the canonical case.

old: That move is legitimate, wanted, and usually invisible in the residuals.

old: But the point the stores sit at is no longer the point the verdict was read at.

old: Both movers take the same remedy, specified with the report in §14.8.

old: ### 14.6 Root-input totality: the missing-value error and the `override` combinator

old: Root inputs are the one initialized datum without declared defaults.

old: That is the bare-types decision (§11.3), upheld here (D-068).
new: That is the bare-types decision (§11.3), upheld here (D-068, D-376).
tag: C
newcites: §11.3 D-068 D-376
note: D-376 Position: 'The services own root-input initial values. Neither export entries nor face declarations carry root-input defaults'; §11.3 7326 bolds it

old: So a root input's only source before boundary zero (the initialization boundary: the ordinary macro-sequence with an empty integrate) is the condition.
new: So a root input's only source before boundary zero is the condition (the path-addressed sparse overlay that sets a build's state). Boundary zero is the initialization boundary, the ordinary macro-sequence with an empty integrate.
note: condition linked and glossed at its first use (late link fixed); the boundary-zero gloss becomes its own sentence, one parenthetical per sentence; the gloss is #g-boundary-zero's

old: Three consequences follow.
new: Three consequences follow. They are the totality check, the probe-value barrier, and baselines layered by `override`.
tag: X
note: the parts sentence names the three in order

old: Totality is a precondition of starting, checked by the service.
new: Totality is a precondition of starting, checked by the service (D-068).
tag: R
ruling: R7
newcites: D-068
note: bold headline of D-068's Position sentence, 'Slot totality is enforced at the service', its citation now in the sentence

old: A condition value is legitimately partial.

old: Fragments compose, and trim iterations write subsets.

old: So "every root input covered" is not a property of conditions.

old: It is a property of every application that establishes a complete world over virgin stores.
new: Totality is a property of every application that establishes a complete world over virgin stores (D-149).
tag: R
ruling: R7
newcites: D-149
note: D-149's bold home is §14.6 (R7); Position: 'Slot totality is checked at every application that establishes a complete world over virgin stores'. 'It' becomes 'Totality' so the bold clause stands alone. §9.3 4690 bolds it too

old: That principle, not an enumeration, names the sites.

old: They are `init!`, trim's setup application to freshly allocated scratch stores, and trim's commit through boundary zero (§14.8).
new: They are `init!`, trim's setup application to freshly allocated scratch stores, trim's commit through boundary zero (§14.8), and linearization's operating condition under `about`, applied to its own scratch (§14.10).
tag: R
ruling: R3
newcites: §14.8 §14.10
note: R3, F2's dictated wording (src/linearize.jl 172-181); the wrong #g-boundary link inside 'boundary zero' goes (F4)

old: That is one class, one mechanism and one kind.

old: Each compares the resolved plan's root-input coverage against the `Build`'s `input_faces` before writing anything.

old: A shortfall is one collected, declaration-ordered diagnostic (`UninitializedInputs`, a §13.2 kind) naming every uncovered face.
new: A shortfall is one collected, declaration-ordered diagnostic (`UninitializedInputs`, Appendix C) naming every uncovered face.
tag: R
ruling: R9
newcites: Appendix C
note: F24: the kind's owning section is §14.6 (Appendix C 13659); §13.2 is the diagnostic value

old: Coverage is a plan-level fact, because both operands are resolution-time data.

old: The check is therefore one comparison, and it runs before any evaluation, not merely before any write.

old: Pre-write means all-or-nothing.

old: A rejected init leaves the sim exactly as it was, the same posture as failed trim.

old: The probe-value barrier is structural.
new: The probe-value barrier is structural (D-068).
tag: R
ruling: R7
newcites: D-068
note: bold headline of D-068 bullet 1, 'probe_value is structurally unreachable from the services path'

old: The `probe_value` synthesis (§9.3; zero/false/first-enum/`T()`) exists so build-time probes can exercise code with fabricated inputs.
new: The `probe_value` synthesis (zero, false, the first enum value or `T()`) exists so build-time probes can exercise code with fabricated inputs (§9.3).
note: the citation leaves the gloss's parentheses; the slashed list spelled out

old: A fabricated zero is a fine probe input and a terrible flight condition.

old: A silently zeroed `mixture` kills the engine and sends the user debugging aerodynamics.

old: The services path simply contains no call to it.

old: A root input gets a condition value or the application errors, with no third branch.

old: Replay likewise never synthesizes.

old: The trace header holds every root-input cell as boundary zero left it, and with totality enforced that record is complete by construction (the requirement discharged, §11.3).
new: The trace header holds every root-input cell as boundary zero left it, and with totality enforced that record is complete by construction. That discharges the requirement (§11.3).
note: the citation leaves the parentheses

old: Baselines are aircraft-shipped condition functions, layered by `override`.
new: Baselines are aircraft-shipped condition functions, layered by `override` (D-068).
tag: R
ruling: R7
newcites: D-068
note: bold narrowed to the headline of D-068 bullet 2, 'Baselines are aircraft-shipped full-coverage condition functions'; 'layered by override' is bullet 3's, bold below. condition stays unlinked, linked in the context

old: Nobody hand-writes ~20 root-input values per script.

old: Today `SystemsInitializer`'s `@kwdef` defaults carry that load.
new: In Flight.jl the `@kwdef` defaults of `SystemsInitializer`, the systems initializer of its Cessna 172 model (`c172.jl`), carry that load.
tag: R
ruling: R12
note: owner checked: ~/.julia/dev/Flight.jl/lib/FlightApps/src/c172/c172.jl 768, '@kwdef struct SystemsInitializer'

old: Their successor is ordinary user math in one authoritative home, such as `ready_for_taxi(ac)` or `cold_and_dark(ac)`, returning full-coverage conditions.

old: But "baseline plus tweaks" collides with the duplicate-leaf error (§14.2) by design.

old: The collision is the intent. Hence the fourth node kind, `override(base, patch)`.
new: The collision is the intent, and the fourth node kind, `override(base, patch)`, exists for it (D-068).
tag: R
ruling: R7
newcites: D-068
note: the bold term becomes the bold headline of D-068 bullet 3, 'override(base, patch) is admitted as the fourth node kind'; 'Hence' goes so the rule is not a consequence; override linked at its first prose use, no gloss (the next sentences define it)

old: It is ordered and asymmetric, where `combine` is symmetric and collision-intolerant.
note: combine linked at its first use

old: At resolution a leaf present in both takes the patch's value, with the origin recording both layers ("patch overrode base's `throttle`").
new: At resolution a leaf present in both takes the patch's value, and the origin names both layers.
tag: R
ruling: R9
note: F25: the quoted origin is not the code's spelling (src/conditions.jl 219-229), so the quote goes

old: Collisions within one layer remain errors.

old: Variadic layering (`override(campaign, aircraft, todays_case)`) composes.

old: Trim uses it on day one.

old: The committed condition is `override(baseline, solution)`, the solver's handful of values over full coverage (D-068).
new: The committed condition is `override(baseline, condition(d))`, the solved condition over full coverage (D-068).
tag: R
ruling: R9
note: F25: the commit is override(baseline, condition(d*)) (src/trim.jl 425-426; §14.9 12379); norm drops the asterisk

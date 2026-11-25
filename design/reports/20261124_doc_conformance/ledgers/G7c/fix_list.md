# G7c: rows for the fixer

Each row: the site at the pinned tip 62551b06, the claim, the verifier's evidence and proposed fix, and its note. The fix is a proposal: conform it to the rules and to the code.

## CV7a-002 (drift, clear=True)

- at: `src/show.jl:26`
- claim: code_map 1135 says each table prints each row's path 'with no label function'; the code renders the root's empty path as `root` through `_path_label`, and the entry names none of the label and count helpers
- evidence: src/show.jl:26 `_path_label(path) = isempty(path) ? "root" : path`, called on every row at src/show.jl:143 (Outputs) and :163 (Events). The probe prints `root       θ, ω     —` for build(Pendulum()).outputs. code_map.md:1135 still says "with no label function". The phrase dates from b16a8859, where it recorded the removal of the old `label(ci)` callback (`#ci` standalone, the path inside the Build). `_path_label` already existed then, so read today the phrase contradicts the code.
- fix: each table prints each row's path, the root's empty path as `root` through `_path_label`, and the `Events` table holds only the components that declare an event;

## CV7a-016 (drift, clear=True)

- at: `src/show.jl:318`
- claim: Under a proposing method the steps line prints a range, `N to M, as proposed`, with M = max(N, ⌊Δt_frame/h_min⌋); spec §9.2 and the log state the line only for a fixed-step method, and only code_map.md:1175-1179 describes the range
- evidence: src/show.jl:312-318: under `proposes(algorithm)` the line is `$steps to $(max(steps, fld(Δt_frame/h_min))), as proposed`. The probe prints `steps per frame: 4 to 1000, as proposed` and, with h_min = 1//1000, `4 to 10, as proposed`. spec.md:5376 states the line only for a fixed-step method. notes_increment_97.md:113 ratified "`show` prints the range of steps per frame, 'as proposed'" (commit 4367fa55), but §9.2 was never updated.
- fix: Add after the §9.2 steps bullet: "Under a proposing method the line states a range instead, `N to M, as proposed`: at least the fixed-step count `N` and at most `⌊Δt_frame / h_min⌋`, never less than `N` ([D-460][d-460])."

## CV7a-025 (deviation, clear=True)

- at: `src/show.jl:424`
- claim: code_map 1174-1175 says the Deployment's long form 'adds `attempt_budget` (D-460)'; the long form adds four fields: firing_budget, localization_tol, localization_budget and attempt_budget
- evidence: src/show.jl:288-293: the one-line form ends at the algorithm. src/show.jl:424-428: the long form adds four fields, which the probe confirms: `; firing_budget = 4, localization_tol = 1.0e-6, localization_budget = 8, attempt_budget = 7`. code_map.md:1174-1175 says only that the long form "adds `attempt_budget` (D-460)".
- fix: …, `h_min` where one is set, and the long form adds `firing_budget`, `localization_tol`, `localization_budget` and `attempt_budget` (D-460).

## CV7a-037 (drift, clear=True)

- at: `src/trace.jl:18`
- claim: The `TraceBatch` docstring says the drain runs before the run's frame index increments, so a batch drained at the top of frame k carries frame = k. The loop increments the frame index first and then drains, and the drain adds one to the trace's own count
- evidence: src/sim.jl:2021-2024: `frame_top!` runs `hooks.sim.run.frame += 1` and then `drain!`. src/sim.jl:2664 then advances `trc.frames += 1` before any thunk, and trace.jl:132 stamps `trc.frames`. The probe gives `run.frame = 1, batch.frame = 1, trace.frames = 1` after one step. The outcome `frame = k` holds, but the docstring at trace.jl:19 gives the wrong order. The order was changed in commit 697ff66d (the frame moved onto the model, D-317), and the site comment at sim.jl:2659-2662 cites D-317.
- fix: `frame` is the frame ordinal the batch was drained at the top of: the top hook advances the run's frame index to `k` before it runs the drain, and the drain advances the trace's own count to `k` before it records, so a batch drained at the top of frame `k` carries `frame = k` and replays there.

## CV7a-052 (deviation, clear=True)

- at: `src/trace.jl:221`
- claim: A record whose writer index has no schema entry raises `ReplayUnknownFace` with the bare position and the writer spelled `writer #N`. Appendix C names the bare position only 'where the writer's schema has no name for it' and the 'trace's device tag'; the missing-schema case and its positional tag are not stated
- evidence: trace.jl:217-226: a record whose writer index has no schema entry pushes one `ReplayUnknownFace` per entry, with the bare position and `writer = "writer #N"`. The probe gives `face=1 frame=1 writer="writer #9"` and `face=3 …`, and test_trace.jl:380-381 asserts `(1, 2, "writer #9")`. Appendix C (spec.md:15960-15962) gives the bare position only "where the writer's schema has no name for it" and always "the trace's device tag". §12.7 (spec.md:10977-10986) does not cover the missing-schema case either.
- fix: Face name, or the bare position where the writer's schema has no name for it or the record's writer has no schema; frame ordinal; the trace's device tag, or `writer #N` by the record's writer index where the `schemas` list has no entry for it; the root input-face list.

## CV7b-003 (drift, clear=True)

- at: `src/readers.jl:38`
- claim: Comment cites '§5.2, §8.3' for 'Only cells and stores are addressable'. The same cite sits in the Design lines at :25 and :492. §5.2 is 'Two-stage outputs: signatures, bundles and the hand-off laws' and says nothing on addressability.
- evidence: src/readers.jl:38 reads 'Only cells and stores are addressable (§5.2, §8.3).' The spec's own statement at design/spec.md:13328-13330 cites §4.2 and §8.3 for the same rule. §5.2 (spec.md:1138) covers the homes of the bundle views, 'Each datum has exactly one home', and says nothing on addressability. When readers.jl was added (21d99219), the spec of that commit (docs/framework_spec.md:7774) read 'only cells are addressable (§5.2)'. The spec has since moved the cite to §4.2, 'Consumers see ports, not stages', which fixes the port as the addressable unit (spec.md:920-922). The code comment was never updated.
- fix: Only cells and stores are addressable (§4.2, §8.3).
- note: The Design lines at src/readers.jl:25 and :492 also list §5.2. They head whole blocks, and §5.2 can stand there for the homes of the stores and cells. Only the inline cite at :38 is plainly wrong. Swapping §5.2 for §4.2 in those two lines too would match the spec's cite, but that is a separate call.

## CV7b-028 (deviation, clear=True)

- at: `src/readers.jl:788`
- claim: Spec §14.4 says 'A bare store has the field `x`, `s` or `m`, and a headless address may stand for it'. Appendix B (design/spec.md:15343-15347) says the empty default of `get_state` stands for 'a bare store's letter, `x`, `s` or `m`'. No selector reads an `m` store: `get_state` takes the letter `x` on the continuous tier and `s` on the discrete tier, and `get_deriv` takes `x`.
- evidence: src/readers.jl:789 gives get_state's headless head the letter x on the continuous tier and s on the discrete tier, read from state_decls (src/build.jl:33: decl.x or decl.s). get_deriv (:797) takes x. No path reaches an m store. Probe results: get_state("latch", :m) on BareLatch, which has a bare m_init, gives ReadResolution :undeclared. get_state("src") on a component with only a mode store gives :store_shape, and get_state("src", :phase) gives :undeclared. The spec agrees with the code elsewhere: §14.8 at design/spec.md:13682-13683 says get_state and get_deriv are 'validated against x_init/s_init'. design/pending.md has no bullet that owes a mode-store selector.
- fix: §14.4 (spec.md:13280-13281): 'A bare store (a store declared as one leaf) has the field `x`, `s` or `m`, and a headless store-selector address may stand for a bare `x` or `s`, the stores the selectors read.' Appendix B (spec.md:15347): 'The empty default stands for a bare store's letter, `x` or `s`, or a bare contract's default face, `u` or `y`.'

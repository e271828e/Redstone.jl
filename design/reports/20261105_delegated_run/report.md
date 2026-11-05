# Delegated run of 2026-11-05

The user delegated the first entries of `design/pending.md`'s work order to
one Fable agent each, run sequentially on the real tree by an orchestrating
session, with the calls the rules normally put to the user taken by the
agent and recorded here. This file is the record the user reviews: one
section per item, with the classification, the commits, every ruling with
its reason, and the gate. Each section is written by the orchestrator from
the agent's final report. Nothing was pushed.

The second entry, stage-function locations in the descriptor, was dropped
by the user during the run: the remedy for an algebraic loop is structural
(§5.5), a member is often a library block the user cannot edit, and the
`cycle` field of the diagnostic already carries the wires, the
classification and each member's tracing mode, while an assembly's `types`
row locates its wire declarations. A member's `y_direct` location would
point the user at code that is not where the fix goes. The bullet was
deleted at `84d28e7`, with no log entry by the log's rule 9, and the
inspector's `pending.md` took the structural reading for its loop drawer
row at `RedstoneInspector.jl` commit `7ae9dae`, which also records the
class rename's inspector half as the item after increment 8's merge. The
run went from the first entry to the third.

## 1. The descriptor's class value `"leaf"` becomes `"primitive"`

Classification: loose local fix, one commit, no brief, no review. The
bullet settled every value and the change is a literal, two schema
definition names and the vocabulary around them; no reading on an unruled
seam was needed and the guardrail was not reached.

Commit: `c894949` Rename the descriptor class value leaf to primitive, with
PrimitiveNode and PrimitiveFace in the schema and the writer. Files:
`src/descriptor.json`, `src/descriptor.jl`, `test/test_descriptor.jl`,
`design/code_map.md`, `design/pending.md`.

Rulings:

1. The writer's internals follow the vocabulary, not only the literal:
   `_leaf_node`, `_leaf_faces`, `_leaf_face` became `_primitive_node`,
   `_primitive_faces`, `_primitive_face`, and the `leaves` dict of
   `_nodes`/`_push_nodes!` became `primitives`. The bullet lists the writer
   among what conforms and `code_rules.md` names a local by the spec's
   noun. Rejected: changing the literal alone.
2. Prose in the schema, the writer's comments and the test names that said
   "leaf" for a node now say "primitive" (the `Cycle`, `PrimitiveFace`,
   `Timing` and `OutputsSection` descriptions, two testset names, comments).
   Every "leaf walk" mention stays, since that is the value leaf. One test
   comment, "the type string is the leaf's", meant the type under `Pinned`
   and now reads "the unwrapped type's". Rejected: leaving descriptions a
   client reads beside definitions they would contradict.
3. No log edit. D-432's bullets say "each leaf's stage lists" in the node
   sense; `log_rules.md` keeps an entry's vocabulary of its day, and a word
   choice is not a contrary design reading. Rejected: an annotation on
   D-432.
4. No spec edit. §13.9 already spells the class as assembly or primitive
   and never writes the JSON literal.
5. No format bump, as the bullet settles; `DESCRIPTOR_FORMAT` stays 1.0.
6. The bullet is retired and its residue, the inspector's half, folded as
   a dated sentence into the inspector stage-1 bullet, which lists what
   this repo owes. Rejected: keeping a first bullet this repo cannot act on.

Gate: the `descriptor` runner green (533 tests), then the full gate green
(`Redstone | 8739 8739 8m12.2s`, exit 0). Battery green before the commit.
The examples runner was not run: no imported name changed.

What `RedstoneInspector.jl` owes at its next pin on the core, surveyed
read-only at its tip `8364db2` and edited nowhere:

- `frontend/schema/descriptor.json` replaced by the core's at the new pin,
  then `npm run types` regenerates `descriptor.d.ts` with `PrimitiveNode`
  and `PrimitiveFace`.
- Frontend source and tests on the old names: `src/lib/resolve.ts`,
  `src/lib/detail.ts`, and the tests `resolve`, `rekey`, `wires`, `level`,
  `focus`, `rates`, `detail`, `icons`; every `class === "leaf"` comparison
  and `"leaf"` literal in `src/lib`, `src/canvas`, `src/frame` and the e2e
  specs (`detail`, `drawer`, `search`, `tree`) classified: a descriptor
  class reads `"primitive"`, an internal role string such as
  `role: "leaf"` in `level.test.ts:97` is the inspector's own call.
- Every `frontend/fixtures/*.json` carrying `"class": "leaf"` regenerated
  from the core at the new pin, since the regenerated schema refuses them.
- Records: `design/descriptor_design.md:110`, `design/build_release.md:200,210`,
  `design/initial_design.md` answer 17 and its neighbours, `frontend/MAP.md`,
  and the briefs `inspector_02_foundation_pure` and `inspector_04_frame`,
  under that repo's rule on frozen records.
- A bullet for this half in its `design/pending.md`, citing `c894949`.

Noticed, not touched: "leaf" in the node sense survives outside the
descriptor in `examples/src/longitudinal.jl:103`, in comments of
`test/test_conditions.jl` (lines 64, 420, 451, 620–665, in both senses) and
in D-432's bullets; a vocabulary sweep would be its own item. The schema's
`PrimitiveNode`, like `LeafNode` before it, carries no `description` while
`AssemblyNode` does.

## 3. Tighten the blocks' `V` bound to what the build admits

Classification: loose fix, as the bullet ruled; nothing found upgraded
it. Two commits, docs first, since the spec's `Freeze` sketch and its bold
sentence stated the old bound and `pending.md`'s header makes the spec
edit part of the item.

Commits: `ce3791a` Bound the blocks' V to Float64 and SArrays of Float64
in the spec, the log and the companions; `363d127` Tighten the blocks' V
bound to Float64 and SArrays of Float64, refusing the rest at the
constructor.

Rulings:

1. The count held: fifteen struct bounds, `Freeze`, `Delay`,
   `DiscreteIntegrator`, `DiscreteLimitedIntegrator`, `RateLimiter`,
   `Integrator`, `FirstOrderLag`, `Step`, `Sequence`, `LimitedIntegrator`,
   `LimitedDoubleIntegrator`, `Relay`, `Comparator`, `PID`, `DiscretePID`,
   sixteen with `GaussianWhiteNoise`, all now
   `Union{Float64, SArray{<:Tuple, Float64}}`.
2. `Relay`'s keyword constructor called the positional one with `V`
   inferred, so a misfit raised `MethodError`, not the `TypeError` the
   bullet states; it now applies the type explicitly,
   `Relay{typeof(lower)}(…)`, as every other block does. Rejected: one
   block off the stated refusal.
3. "One test per tier" read as one constructor refusal on a continuous
   block and one on a discrete block, each at `Float32` and at an
   `MVector` (`Integrator`, `DiscreteIntegrator`), plus a `Relay` line
   pinning ruling 2 and `Freeze{Float32}` beside the `Freeze{HeightField}`
   pin. Rejected: one assertion per block.
4. The dispatch helpers on `V <: StaticArray` and `V <: Real` stay: the
   new bound is a subtype of both, and narrowing them is the next item's
   helper rewrite.
5. Spec and log: §13.7's `Freeze` sketch and bold sentence take the new
   bound, citing D-320 beside D-312; D-312, whose position says `Real` and
   `StaticArray`, carries a dated annotation recording the narrowing and
   its reason, by the log's rule 1. Rejected: a new entry, the bound
   following from two ratified ones; and leaving D-312 silent against the
   spec.
6. The inventory's rows, `pid_anti_windup.md`'s literal of the old bound,
   and `code_map.md`'s two phrases now say `Float64` and `SArray`.

Gate: routed `blocks build` green (3603 tests), full gate green
(`Redstone | 8745 8745 8m14.3s`, exit 0), examples runner green
(`Longitudinal | 77 77`). Battery green before the docs commit; the
post-commit hook rebuilt the PDFs.

Notes for the broadcast item: keep `Relay`'s explicit type application if
it routes through the shape helper, or the refusal falls back to
`MethodError`; `promoted_keywords`, `shape_type`, `check_limits` and the
dispatch helpers are untouched; the inventory's promotion paragraph is
untouched and is that item's first commit.

Noticed, not touched: `code_map.md` claims one entry per file of `src/`
and `test/` but carries entries for only four `test/` files, no
`test_*.jl` among them. The inventory's `Freeze` over a struct candidate
row still stands.

## 4. One broadcast convention for the blocks' keywords

Classification: loose fix in three commits, as the bullet ruled. No spec
or log sentence touched: §13.7 says nothing about promotion, and the
inventory's paragraph was the one text to rewrite.

Commits: `340e327` Rewrite the inventory's keyword paragraph from
promotion to one broadcast convention for the blocks; `4f01b9d` Route the
blocks' shared keywords through one broadcast helper making Float64 of one
shape, replacing promoted_keywords and its refusals; `51d658c` Widen
RateLimiter's rates and FirstOrderLag's τ to V and refuse non-positive
time constants in the lag and the controllers.

Rulings:

1. The helper is two functions in a new section of `src/blocks.jl`:
   `shape_zero(given)`, the sum of the values' zeros as `Float64`, the
   PID's rule; and `broadcast_keywords(given)`, mapping `Float64.(v .+
   shape)` over a `NamedTuple`, `Tuple` or `Vector`. Rejected: one
   function with the reduce inline, leaving `shape_type` a second home
   for the rule.
2. `shape_type` kept as the PID's one-line name over the shared rule,
   since reading `V` off the first value fails when every keyword is
   `AsPort()`; `fixed_parameters` stays for the trackers.
3. `GaussianWhiteNoise`'s idiom absorbed into the helper; its `μ = nothing`
   default stays, resolved in the body.
4. `Sequence` routes through the helper too, so `values = (0, SVector(1,
   2))` is a vector sequence. Rejected: leaving the one promoting spelling.
5. A `Float32` keyword in a broadcast block becomes `Float64`, as an `Int`
   does, by the helper's definition and as `PID(Kp = 1f0)` already pinned.
   The previous item's `Relay(lower = 0f0, …)` refusal could not survive
   routing `Relay` and became an `MVector` refusal, with a positive
   `Relay{Float64}` pin beside it. The `float(x0)` blocks still refuse
   `1f0` as `TypeError`. Read as inside the bullet's wording; flagged
   below as a seam.
6. `Relay`'s explicit type application kept, per item 3's note.
7. `check_time_constant(name, value; zero_legal)` beside `check_tracking`:
   skips `AsPort()`, passes `Inf`, `ArgumentError` naming the keyword.
   Continuous blocks refuse non-positive (`FirstOrderLag`'s `τ`, `PID`'s
   `τd` and `Tt`, `LQRTracker`'s `Tt`); discrete blocks refuse negative
   only (`DiscretePID`'s `τd` and `Tt`, `DiscreteLQRTracker`'s `Tt`),
   their zeros being documented legal. Rejected: the literal list with
   non-positive on both trackers, which refuses `DiscreteLQRTracker`'s
   documented `Tt = 0`; and continuous only, leaving the discrete
   divergence unchecked.
8. `RateLimiter` keeps its own inline refusal, `all(rising .> 0) &&
   all(falling .> 0)`, since the rates are not time constants.
9. Docstring rule 32 read as not reaching a sentence that became false:
   the limited integrators' refused-mix sentence replaced, not moved to a
   comment.
10. `-0.0` becomes `0.0` through the helper, as on the PID; no special case.

Gate: commit 2, routed `blocks build` green (3613), full gate green
(`Redstone | 8755 8755 8m06.9s`); commit 3, routed `blocks build
precompile` green (3672), full gate green (`Redstone | 8813 8813
8m08.8s`), examples green (`Longitudinal | 77 77`). Battery green before
each of the three commits.

Docs: the inventory's paragraph at lines 128–137; `code_map.md`'s
`src/blocks.jl` entry (the helper's bullet, the limited integrators'
bullet, the PID bullet naming `check_time_constant`); docstrings of the
seven routed blocks rewritten from promotion to broadcast, `RateLimiter`
and `FirstOrderLag` on per-component rates and `τ`, one sentence on the
refusal in `PID`, `DiscretePID` and both trackers.

Seam for the user: the library now converts a `Float32` keyword two ways,
by each spelling's design. A broadcast keyword set makes `Float64` of it
(`PID`, the noise, the seven routed blocks and `Relay`); a `float(x0)`
block refuses it as `TypeError`. Both are pinned. One answer is a one-line
ruling either way: `float` to `Float64` in the plain blocks, or a
`Real`-but-not-`Float64` refusal in the helper.

Noticed, not touched: `pid_anti_windup.md` line 450 says the PID's
keywords broadcast "by `GaussianWhiteNoise`'s idiom", still true through
the shared helper; the audit report of 2026-11-04 section 5.2 recommended
these refusals and stays untouched as the rules say.

## 5. A contract entry that is not a type

Classification: loose local fix, docs commit first. The raw error has one
site, the fix is one arm in the walk plus a one-line pass-through, and no
reading changed the spec's meaning beyond the bullet's wording.

Commits: `e9653be` Refuse a contract entry that is no type as
IllegalPortType under the reason :not_a_type in §8.2 and its Appendix C
row; `5ee58f7` Refuse a contract entry that is no type in the walk as
IllegalPortType :not_a_type and pass it through retype_entry as written,
retiring the work order's first bullet.

The probe, before the fix, tried fifteen shapes: `u_types` and `y_types`,
named and bare, a tuple of types, a number, a string, continuous and
discrete, alone as root, in a `Group`, wired, and fed from a root input.
Every one failed as a `MethodError` on `_holds_marker` from
`classify_tier`'s contract loop. After the fix all fifteen refuse as
`IllegalPortType` `:not_a_type`, one report per entry, collected across a
model.

Rulings:

1. The reason is `:not_a_type`, after the neighbours `:nested_marker`,
   `:no_leaves` and `:handle_at_root`.
2. The check sits in `classify_tier`'s contract loop in `src/assembly.jl`,
   ahead of `_holds_marker`, both tiers, the entry read no further.
   Rejected: a separate pass gating the primitive out of the walk, since
   other primitives' resolvers read its contract anyway.
3. `retype_entry` in `src/leaves.jl` gains a pass-through for a non-type
   entry, since without it a root primitive's face check and every wire
   into the entry raise a raw `MethodError` before the barrier throws; a
   mutant probe showed it and the build-level tests kill it. Rejected:
   branching in `contract_at` at its two call sites.
4. The payload's `declared` carries the value itself under `:not_a_type`,
   the message rendering it with `repr`. Rejected: a new field.
5. The spec's new sentence is unbolded and there is no log entry: the
   spec already said an entry is a type, the sentence names the
   enforcement, and no design alternative was rejected.

Gate: routed `declare assembly build diagnostics leaves show descriptor`
green (2631), full gate green (`Redstone | 8840 8840 8m06.8s`, exit 0).
Battery green before each commit. Examples not run: no imported name
changed.

Docs: §8.2's `u_types` block and Appendix C's `IllegalPortType` row;
`code_map.md`'s `assembly.jl` and `leaves.jl` entries; one sentence each
in the `u_types`, `y_types` and `IllegalPortType` docstrings. Six fixtures
in `test/test_build.jl`, a block in `build_tier`'s testset, and the kind
roster and a rendering assertion in `test/test_diagnostics.jl`.

Noticed, not touched: a whole contract declared `nothing` reads as an
empty contract through `_keyed(::Nothing, ::Symbol)`, the store's
spelling shared with the contracts, and is accepted silently; the spec
admits a `NamedTuple` or one type, not `nothing`. A one-line arm could
refuse it under the same reason if the user wants it.

## The run

Four items landed in nine commits, `c894949` to `5ee58f7`, plus the
reorder at `a84cf57` and this record; one item dropped. Every agent
classified its item a loose fix, none reached the guardrail, and every
gate and battery was green. Three things are left for the user:

- the `Float32` keyword seam of item 4, two conversions by spelling;
- the discrete tier's negative-only time-constant refusal of item 4,
  read into the bullet from `DiscretePID`'s legal zero;
- the silent `nothing` contract of item 5.

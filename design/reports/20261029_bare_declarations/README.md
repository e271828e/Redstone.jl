# Bare declarations, 2026-10-29

Not normative. This is the design record of one session's analysis, written at
tip `3dca1d9` as the handoff for the two increments that land it. The ruling
it records is the user's; the rest is the seam inventory a fresh session
needs in order to write the docs commits, the prototype and the briefs
without re-deriving them. The log entries and the spec amendments listed
under "Docs" are the normative record once they land.

## The problem

Every store and contract declaration is a `NamedTuple`: `x_init`, `s_init`,
`m_init`, `u_types`, `y_types`. A component with one input, one output or one
state field has no use for the label, and the label still costs a field
access at every read and a one-field tuple at every return. The library is
the evidence: two dozen blocks spell `(in = V,)`, `(out = V,)` and
`(q = c.x0,)`, and the `Integrator` reads

```julia
x_init(c::Integrator) = (q = c.x0,)
u_types(::Integrator{V}) where {V} = (in = V,)
y_types(::Integrator{V}) where {V} = (out = V,)
y_state(::Integrator, (; x)) = (out = x.q,)
x_deriv(::Integrator, (; u)) = (q = u.in,)
```

D-247 weighed the bare form and refused it on three grounds. Two have lapsed.
Auto-publication, which needed a state field name to match a port, was
removed by D-252. "No grounding model wants it" is contradicted by the
library. The third ground, a second store shape at every name-keyed seam, is
real and is the cost this report inventories.

## The ruling

The user ruled on 2026-10-29 for the **headless form**: a bare declaration's
store or port has no name, and the framework addresses it by the component
path alone. The alternative, a fixed default face such as `in`/`out` with
only the bundle unwrapped, was weighed and declined. It costs nothing in the
path grammar, the descriptor or the periphery, but it shows the author a name
they never wrote, in wiring and in the inspector, which is half the thing the
change removes.

The `Integrator` after both halves:

```julia
x_init(c::Integrator) = c.x0
u_types(::Integrator{V}) where {V} = V
y_types(::Integrator{V}) where {V} = V
y_state(::Integrator, (; x)) = x
x_deriv(::Integrator, (; u)) = u

local_wires(::Plant)  = ("gain" => "integrator",)       # one segment: the child's sole port on that side
output_wires(::Plant) = ("integrator" => "position",)   # an assembly face is where a name gets attached
at("integrator", set(x = 1.0))                           # a bare payload for a bare store
get_state("integrator")                                  # headless leaf address; "[2]" indexes an SVector state
```

## Two problems, not one

For a **store** the field name has two jobs: pairing returns with declared
fields (`x_deriv`, the handler's `x` and `m` keys, `x_projection`,
`s_update`), and addressing a leaf from outside (a condition's merge key, a
reader's leaf-address head, linearization's `x` list, the `field` payload of
diagnostics). Nothing in the hot path needs it: the executor's `x` view is
`reconstruct(XT, xbuf, x_off)` and `XT` can be `Float64` as readily as a
one-field `NamedTuple` type.

For a **contract** the entry name is the face, which wiring addresses as
`"child/face"` (D-040, D-207). The layout keys every cell `(path, Symbol)`,
the feedthrough graph keys its edges the same way, the trace records batches
by face, the log tree and the descriptor spell `path/port`, and at a primitive
root the two contracts share one namespace (D-210). A bare contract is a port
with no face, so this half changes the path grammar. The stores half does
not. They are independent and land as two increments, stores first.

## Representation

Three layers, treated differently.

- **String-keyed bookkeeping keeps a `Symbol` key.** Feeds and claims,
  `Layout.addr`, the feedthrough graph, the `Outputs` name lists, the
  root-input list and the diagnostics' `face`/`port`/`field` payloads key on
  `(path, Symbol)`. A bare declaration takes one reserved name there,
  `const BARE = Symbol("")`, so that half of `assembly.jl` and `build.jl` runs
  unchanged. Nothing outside the constant's definition spells the literal
  (an `implementation.md` trap). The empty symbol interpolates as `""`, so a
  leak renders as `plant/`, visibly wrong; one renderer owns the spelling of
  every `(path, name)` pair and drops an empty name.
- **The typed artifacts the executor runs carry the bare shape first-class.**
  A `StageEntry`'s `XT` is the state type as declared (`Float64`,
  `SVector{3,Float64}` or a `NamedTuple` type). Its `inputs` and `outputs`
  are a `NamedTuple` of addresses or one `CellAddr`, and the bundle gathers by
  dispatch:

  ```julia
  gather_input(addrs::NamedTuple, store) = gather_group(addrs, store)
  gather_input(addr::CellAddr, store)    = gather_cell(store, addr)
  ```

  Wrapping here would cost a one-field tuple at every gather and an unwrap
  at every return check, which is D-247's "bijection owed at every seam".
  The leaf walk, the flat buffer, the cell store and `_accepts` already take
  any `P` and need no change.
- **The author-facing seams understand "no name".** Conditions, readers, the
  wiring grammar, the descriptor and the renderers. They exist under either
  representation; with the sentinel each is a check for `BARE`.

## Defaults the user accepted

Stated in the brief as rulings; none changes the shape of the work.

- A bare store is anything `x_init`, `s_init` or `m_init` returns that is not
  a `NamedTuple`, checked as one leaf against the tier's vocabulary (`x`: a
  real or an `SArray` of reals, D-094; `s`/`m`: isbits or `Symbol`, D-231).
  All three stores admit it. A bare `NamedTuple` value is the named form,
  with no ambiguity, since §7.1 forbids a `NamedTuple` leaf inside `x`.
- **The stateless marker becomes `nothing`**: `x_init(::Gain) = nothing`,
  `s_init(::Sampler) = nothing`. It is a bare store of zero leaves, and
  `nleaves(Nothing) == 0` already. The bundle law's presence test becomes
  "the store is not `nothing`", the undeclared fallback becomes `nothing`,
  and the flat buffer allots a zero-width block as for `(;)` today. `(;)`
  retires with a message naming the new spelling, so one canonical form
  remains. D-263's reason for a mandatory marker stands unchanged.
- The leaf address gains a headless form: `parse_leaf("")` and
  `parse_leaf("[2]")` are legal, and the selectors take an empty default
  leaf. It lands in the stores half, where conditions and readers need it,
  and the contracts half reuses it for `get_output`, `get_input`, `get_face`.
- `set(x = 1.0)` is admitted at call time, since the shape is known only
  against a build, and checked at resolution: a bare payload against a named
  store, or the reverse, is a `ConditionResolution`. For a bare `m` store the
  handler's `m` key and a condition's `m` payload replace the whole value,
  since there is nothing to merge.
- `StoreNotNamedTuple` retires. A bare value outside the vocabulary is an
  illegal leaf, carried by `IllegalStateLeaf`/`IllegalStoreField` with no
  field name. D-247 rejected that arm only because the bare form was refused.
- The declared shape, never the return's type, decides which law a return is
  held to. A bare port of `NamedTuple` type returns a `NamedTuple` and is one
  cell.
- Bare is per declaration and independent across the five. An assembly face
  is never bare. `ws_init` is untouched.
- Under the contracts half, a primitive root with a bare `u_types` has no
  face for the write surface, and one with both contracts bare collides under
  D-210. Both are refused, with the component test rig as the remedy (D-120).

## Seam inventory, stores half

- `assembly.jl`: `check_store_form` turns from a refusal into the shape
  classification; `classify_tier`, `check_stores` and `check_state_leaves`
  iterate `pairs(store)` and take the shape helper. The `nothing` marker.
- `declare.jl`: `bundle_names`/`event_bundle_names` test presence by
  `!isempty(...)`, which must become shape-aware (`isempty(0.0)` is `false`
  by accident). Fallbacks to `nothing`. Docstrings of the five declarations
  and the return laws.
- `build.jl`: `Decls.x`/`.s` loosen their types. `_check_derivative`,
  `_check_update`, `_check_state_write`, `_check_handler` (`returned.x`,
  `returned.m`) each gain a bare arm, one `_accepts(XT, typeof(v), T)`.
  `_homes`/`_state_fields` for `DeclaredNotProduced`. `establish_defaults!`
  and `xblocks` already work on a bare value. `compile` passes `typeof(decl.x)`
  as `XT`, which already works.
- `leaves.jl`: `flatten_state!` is specialized on `NamedTuple{Vs}` and its
  fallback throws `:return_type`; it needs a bare-`XT` arm decided at
  generation. `leaf_names(XT)` on a bare type yields `""` heads, which the
  nonfinite sweep renders by the path alone.
- `executor.jl`: `_latch!` and `_merge_modes!` for a bare `m` (replace).
  `_store_successor!` already takes any `S`.
- `conditions.jl`: `set`'s `_payload` admits a bare value; `_leaf_offset`,
  `StoreWrite`'s `merge(defaults, overlay)` and `_undeclared`'s candidates
  gain bare arms; `_store_bases` unchanged.
- `readers.jl`: headless `parse_leaf`; `get_state`/`get_deriv` default leaf.
  `resolve_leaf` and `walk_steps` unchanged.
- `linearize.jl`: the `x` list's seed site through the same offset arm.
- `checkpoint.jl`: the fingerprint's "each component's `x` type" works on a
  bare type; verify.
- `diagnostics.jl`: `ConformanceFailure`, `IllegalStateLeaf`,
  `IllegalStoreField`, `ConditionResolution`, `NonfiniteState` renderings;
  the "must return a NamedTuple shaped like" phrasings; the one renderer.
- `blocks.jl`: every block with a single state field is rewritten to the
  bare form (`Integrator`, `FirstOrderLag`, `UnitDelay`, `RateLimiter`,
  `DiscreteIntegrator`, `DiscreteLimitedIntegrator`, `GaussianWhiteNoise`,
  `LinearBlock`, `DiscreteLinearBlock`, `LQRTracker`, and the single-mode
  `Step`, `Relay`, `LimitedIntegrator`). Every stateless block takes
  `nothing`. The suite follows, `test_blocks.jl` being the bulk of the diff,
  and the examples' stateless primitives too.

## Seam inventory, contracts half

Everything the probe and the scatter need, plus the grammar.

- `assembly.jl`: `resolve_terminal` and `_fanout` accept a one-segment
  endpoint when the child is a primitive whose contract on that side is
  bare; `input_faces`/`output_faces` list the bare face; `_contract` and
  `declared_at` `map` over a `NamedTuple` and need the bare arm; the root
  checks (`_check_root_faces`, the root-input claim); the passthrough
  helpers' default face for a bare child is the child's own name.
- `build.jl`: `_check_ports`, `_embed_ports`, `products`, `in_values`,
  `_check_wires` and `cell_layout` work through the `BARE` key; the probe's
  "is the return a `NamedTuple`" clause dispatches on the declared shape;
  `compile`'s `in_group`/`addr_group` hand a `CellAddr` for a bare side.
- `store.jl`: `scatter_group!`'s single-cell twin with the same
  generation-time check; `gather_input`.
- `executor.jl`: `_bundle_expr`'s `:u`, `:y_x`/`:y_s`, `:y` arms call
  `gather_input`; `run_entry!`'s scatter likewise.
- `readers.jl`: `get_output`, `get_input`, `get_face` headless; `match_leaf`
  against a face list holding `BARE`.
- `descriptor.jl`, `descriptor.json`: `LeafFace.name` and `Endpoint.port`
  admit an absent name, a format bump (§13.9). The visual grammar draws the
  port square with no label beside it; answer 2 and the legibility floor
  already produce that state.
- `show.jl`: the `Outputs` table and the feedthrough line through the
  renderer. `trace.jl`/`dataplane.jl`: batches keyed by `BARE` for a bare
  root face never arise, since a bare `u_types` at the root is refused.
- `diagnostics.jl`: every kind carrying `face`/`port` renders through the one
  renderer; `UnconnectedInput`, `WireTypeMismatch`, `TwoProducers`,
  `UnknownPort`, `FaceDirectionConflict`, `DeclaredNotProduced`,
  `UndeclaredReturnField`, `ProducedByTwoStages`, `IllegalPortType`,
  `ConformanceFailure` `:ports`.
- `blocks.jl`: every single-input or single-output block; `Junction`'s `out`;
  the examples and the suite.

## Docs

Stores half, one docs commit ahead of the code: a new log entry superseding
D-247 and amending D-094 (the flat declaration) and D-276 (the headless
address); the stateless marker's new spelling against D-263; spec §3.1, §3.2,
§5.2 (bundle law, return laws), §7.1, §7.3, §8.2 (state and mode
declarations, completeness), §9.5 (per-function predicates, handler
returns), §14.1, §14.3, §14.4, Appendix B, Appendix C (`StoreNotNamedTuple`
retires); the glossary where it says a store is a `NamedTuple`.

Contracts half: entries amending D-036 ("NamedTuples, period"), D-040/D-207
(the one-segment endpoint), D-210 (the root collision's bare arm), D-276
(face selectors); spec §4.3, §5.2, §6.1, §8.2 (`u_types`, `y_types`,
function arguments), §8.6, §8.8, §9.5, §11.3, §13.9, Appendix C; the
descriptor format bump; the inspector's `visual_grammar.md` gets a note on the
unlabeled port.

Read `tools/spec_style.md` and `tools/decisions_style.md` before either, and
run their batteries after.

## Plan for the next session

1. Read this report, `brief_lessons.md`, the latest brief in
   `design/briefs/` as the template, and the two style tools.
2. Delegate the stores prototype to one Opus agent on a scratch worktree,
   with this report as its brief. What it must prove, with measurements for
   the brief: `flatten_state!` and the executor bundle on a bare `XT`; the
   conformance check still folding away under the allocation canary (§9.8);
   the Dual sweep over a rewritten `Integrator` and a `nothing`-marked
   `Gain`; `set(x = 1.0)` and `get_state("integrator")` end to end; the
   size of the `test_blocks.jl` churn.
3. Docs commit, then the increment brief, shown to the user before anything
   lands, then the pipeline (`delegation.md`). Tag the tip before the first
   stage commit. Run the examples runner at the gate beside the suite, since
   the library and the examples both change.
4. The contracts half repeats the sequence once the stores half is pushed.
   The midpoint, bare stores with named contracts, is a consistent design.

Work lands on master, as the pipeline does. The branch question was weighed
and declined: nothing is pushed before a half's gate is green, and the
registers (`pending.md`, `implementation.md`) move once instead of diverging.

## What this report does not settle

- The exact message text of each new refusal, which the brief fixes.
- Whether `Pinned` needs any arm: it wraps a whole entry today and a bare
  entry is a whole entry, so none is expected.
- The inspector's handling of a bare port beyond "square, no label"; the
  detail pane and the hover title spell the path alone.

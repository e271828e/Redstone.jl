### 14.4 One plan, two ways to apply it

A resolved [condition](#g-condition) (the path-addressed sparse overlay that
sets a build's state) is applied two ways, because a one-shot service and an
iterating one want different things from the same validated list of
condition entries ([D-066][d-066]). The section gives the two ways, then the
read-selector family.

#### Applying a plan

All string work, validation and addressing are functions of the *shape* of
the condition. Every hot path holds the shape fixed while varying values.
Execution is therefore resolve-once/execute-many. A valid list of condition
entries compiles two ways, one for each way to apply it.

- **Specialized `apply!` serves the service that iterates**, trim's
  per-evaluation write ([D-066][d-066]). Its plan holds, per leaf, a
  [lens](#g-lens) (the compiled navigation step of a condition entry), a
  destination and a converter. It unrolls [stores](#g-store) through the
  baked lenses and converters. Those are the same machine operations as
  FlightCore's in-place state writes, with no allocation, no strings and no
  dispatch. The per-iteration shape check is the mechanism of [§9.5][s9-5]
  transferred. The tree type is proven by dispatch, and it carries the full
  nesting, every field name and leaf type. A `===` comparison of each prefix
  string closes the remainder. `===` on strings compares content, so a
  prefix computed at run time pairs with the compiled one exactly as a
  literal does, at the cost of one short comparison per `at` node. Shape
  drift is a tree of another type, or a prefix that differs at a position.
  It is `ConditionShapeDrift` ([Appendix C][sC]), reason `:tree_type` or
  `:prefix`, a structured error rather than silent corruption. The cost is
  Julia codegen *once per condition shape*, and it grows with the shape's
  writes ([D-066][d-066]). On Julia 1.13 it measures 10 to 50 ms up to 32
  writes, 0.09 s at 64 and 0.2 s at 128
  (`docs/reports/20261002_tuple_walks/`). That cost is noise against the
  model's own first-sweep warmup (seconds). It is paid once per tree type per
  session, so it spreads over every evaluation of every trim of that shape,
  an envelope of trims included.
- **The dynamic walk serves the one-shot uses**, `init!`, `linearize`'s
  operating condition and trim's setup write ([§14.8][s14-8],
  [D-066][d-066]). It executes the same validated condition entries by
  runtime dispatch per write, from a plan that holds the converted values
  themselves. That takes microseconds in total, with allocation permitted,
  since the stopped-sim path was never under the zero-alloc regime
  ([§9.8][s9-8]). It needs no per-shape codegen. Fifty structurally
  different scripted conditions cost fifty walks, not fifty compiles.

Which of the two a service uses is internal, never user-facing API.

The per-iteration ledger for trim has four terms. They are the user
fragment math, the leaf stores, the folded shape check and the
[sweep](#g-sweep) (one pass through the execution order against the current
state). The fragment math is the domain computations, unchanged from
Flight.jl's, plus building the tree, which allocates nothing
([§14.2][s14-2]). The sweep dominates, exactly as `f_ode!` does in
FlightCore, where it is the continuous-dynamics function a model extends.

#### The read-selector family

**The read-[selector](#g-selector) family is closed** ([D-095][d-095]). Its
members are `get_state(path, leaf)`, `get_deriv(path, leaf)`,
`get_output(path, leaf)`, `get_input(leaf)` and `get_face(leaf)`. They form
one address space for every reader of the model.

**`leaf` is a [leaf address](#g-leaf-address)** ([D-276][d-276]). It is the
field or [face](#g-face) name (the name a port wears on its component's
boundary), followed by `.name` and `[k]` or `[k,l]` steps in any order, as
in `"pose.q_eb[2]"`, `"ω_eb_b[1]"` or `"J[1,3]"`. **A bare `Symbol` is the
short form of a plain name**, so `get_state("kin", :θ)` reads
`get_state("kin", "θ")` ([D-276][d-276]). A face name is an arbitrary string and may contain
a dot ([§8.6][s8-6]), so on `get_input` and `get_face` the head is matched
rather than parsed. The head is the longest declared face name that is a
prefix of the address and is followed by the end, a `.` or a `[`. A
`Symbol` leaf names the face whole, with no steps. So
`get_input("wing.throttle")` and `get_input("wind[1]")` both resolve, and
where faces `a` and `a.b` both exist, `"a.b"` names the face `a.b`.
**Each step is checked at resolution against the type resolved so far**
([D-276][d-276]). A
`.name` step needs an isbits struct with that field. An index step needs an
`SArray`, with one index or one per dimension, and a vector leaf thereby
yields named scalars. A step never enters an opaque leaf (a field handle or
a `Symbol`), which is read whole. **`get_deriv`, and `get_state` on the continuous
tier, take at most an index step**, since a continuous state field is flat
([§7.1][s7-1], [D-276][d-276]). A discrete `s` field is isbits or a `Symbol`
([§3.2][s3-2]), and `get_state` on it takes the full address. **The address
is checked once and baked**, and the read runs as field loads and indexing
unrolled at compile time ([D-276][d-276]).

The names carry a deliberate `get_` prefix ([D-095][d-095]). A selector is
a *deferred read*, a value describing the read the compiled gather will
perform. The prefix names that action, and it keeps five short common nouns
out of the namespace user declarations share with domain code.

There is no selector for a value a [component](#g-component) computes
without declaring it, and there cannot be one, because only declared
[cells](#g-cell) and stores are addressable ([§4.2][s4-2], [§8.3][s8-3]).
So a reader that wants one is asking the producing component to declare it
an output ([§8.3][s8-3]). A service evaluation needing an undeclared
intermediate has that one remedy too, and it is the same for every client.
The component exports it ([§14.7][s14-7]).

`get_face` addresses an output face of the mount level, the level its read
set is mounted at ([§14.9][s14-9], [D-277][d-277]). [Mounting](#g-mounting)
relocates a whole problem or [tap set](#g-taps) (the three selector lists
declaring what linearization seeds and reports) with `at(prefix, …)`. At the root that
face is root-exported. Either way the read is an *integration* read
([§11.2][s11-2]).

**A selector resolves against a source**, before any client policy applies
([D-098][d-098]). The table selectors (`get_output`, `get_input`,
`get_face`) resolve against a *table source*. A table source is a
[boundary](#g-boundary) [snapshot](#g-snapshot), or the scratch tables a
service evaluation instantiates ([§14.8][s14-8], [D-124][d-124]). The store
selectors (`get_state`, `get_deriv`) resolve only against live stores
([D-098][d-098]). The table/store axis separates table-borne values from
store-borne ones, not snapshots from services.

Only stopped-sim service evaluations, [`checkpoint`](#g-checkpoint), and
post-run inspection of the live stores (the [replay](#g-replay)-to-inspect)
ever hold live stores ([§11.2][s11-2]). The snapshot deliberately carries
no state stores ([§11.2][s11-2]), and `ẋ` [buffers](#g-buffer) are
integrator scratch, not boundary-consistent objects outside a service
evaluation. A reader resolving for a table source that names a store
selector is therefore refused at resolution, as a `ReadResolution` with
reason `:store_selector` ([D-406][d-406]). **The resolver takes the source
it resolves for**, so the rule is the resolver's and not a client's
([D-406][d-406]). The honest remedy ([§11.2][s11-2]) is to declare the field
in `y_types`, return it from `y_state`, and read the resulting
[port](#g-port) ([§5.3][s5-3]).

On top of the source rule sits one piece of authoring guidance
([D-414][d-414]). A service read, trim's `reads` or a tap, that should outlive
the build reads a face with `get_face` ([D-125][d-125]).
`get_face` resolves through export chains exactly as mounting resolves
[root input](#g-root-input) faces ([§14.9][s14-9]), so the read side
mirrors the write side. An inspection read, a binding's or `series`', may
name any cell the structure has, since it promises nothing beyond this
build ([D-083][d-083]). Both resolve under the one service walk
([§13.3][s13-3]).

Trim's `reads` and linearization's taps name
`get_state`/`get_deriv`/`get_output`/`get_input`/`get_face`. They do so
within the scopes the locality law ([§6.1][s6-1]) and
[fragment](#g-fragment) scoping ([§14.2][s14-2]) describe, as authoring
guidance ([D-414][d-414]). An equilibrium equation meant to outlive the
build it was posed against therefore binds the curated face behind a
[generically held](#g-generic-holding) child (one held through a
non-concrete field type) rather than a path into it.

Inspection reads admit the whole family, within the source rule.
Output-[device](#g-device) bindings and log extraction by `series` take
deep paths, `get_face` names and leaf addresses alike ([D-406][d-406],
[D-407][d-407], [D-414][d-414]). Snapshot inspection reads a cell by path
and port name instead ([§11.2][s11-2]). A store selector resolves only for
a reader that runs over live stores, which today are the services'
([§14.7][s14-7], [§14.10][s14-10]). A snapshot-bound reader is barred from
it by source, not by client.

`ignore_stop_requests` is not a family client. It names requesters from the
`Build`'s [requester roster](#g-requester-roster) (the build's list of stop
requests, one per `StopFlag` output port), period ([§13.5][s13-5],
[D-316][d-316]). Termination is run policy over the requests the model
declares, and no path selector reaches `ignore_stop_requests`
([D-060][d-060]).

The five selectors and their sources:

| selector | resolves against |
|---|---|
| `get_state(path, leaf)` | live stores |
| `get_deriv(path, leaf)` | live stores |
| `get_output(path, leaf)` | a table source |
| `get_input(leaf)` | a table source |
| `get_face(leaf)` | a table source |

**Compiled readers are the gather twin** ([D-066][d-066]) over this family
and the [layout](#g-schema-vs-layout) tables (where each value physically
lives). Trim's residual reads (`ẋ` and output fields) and linearization's
Jacobian gather are one primitive run in reverse. It is one machinery, in
both directions, in the `Build`'s client kit.

A compiled plan or reader carries the [activation](#g-activation) it was
compiled at and applies only to a store set of that activation. That
pairing is a framework invariant the services uphold, not a user-facing
check. Neither plans nor readers are user values.

`apply!` ends at established stores. Making the model *coherent* is the job
of [boundary zero](#g-boundary-zero) (the initialization boundary, the
ordinary macro-sequence with an empty integrate), which [§14.5][s14-5]
specifies.

### 14.5 Boundary zero: an ordinary boundary with authored incoming transitions

`apply!` establishes the [stores](#g-store) at `t₀`. **The init service then
completes the [§10.6][s10-6] macro-sequence with an empty integrate**
([D-067][d-067]). The sequence is the following.

> project → [[sweep](#g-sweep) → [guards](#g-guard) → handlers]\* → [due](#g-due) `s_update` calls → first [snapshot](#g-snapshot)

After the first snapshot `init!` takes the [trace header](#g-trace-header),
the [checkpoint](#g-checkpoint) (the `Model`'s state at a frame top as one
value) of the state the sequence leaves ([§11.5][s11-5], [D-274][d-274]).
The parity with an ordinary [boundary](#g-boundary) is exact, not
approximate. The pieces follow one by one, in run order. Projection, the
sweep, events and the due `s_update` calls come first, then the `t₀`
argument, then what [boundary zero](#g-boundary-zero) (the initialization
boundary at `t₀`) means for trim.

- Project runs. Authored `x` can sit off-manifold. A hand-assembled
  quaternion may be ulps off unit norm, or a [condition](#g-condition) (the
  path-addressed sparse overlay that sets a build's state) may write part of
  a constrained block against fresh defaults.
  [Projection](#g-projection) after condition writes holds the same position
  it holds after any other `x` mutation. And it costs nothing when the state
  is already clean.
- The sweep runs, and **every discrete output stage publishes, due or not**
  ([D-205][d-205]). `t₀` is a grid point of every phase-free divisor, so the
  `Φ = 0` components are due in full. An offset [component](#g-component)
  ([§10.5][s10-5]) is *not* due, because its first [tick](#g-tick) is at
  `Φ·Δt_base`. Its output stages run at boundary zero all the same,
  publishing from the authored `s` and the `t₀` table in the ordinary sorted
  walk. That evaluation is establishment, not a scheduled sample. The
  schedule owns every instant after `t₀`, and the first sample the
  component's `s_update` consumes remains its `Φ·Δt_base` tick's. What the
  rule buys is a `t₀` snapshot carrying the authored world fully evaluated.
  No published [cell](#g-cell) holds the [probe](#g-probe)'s synthesized
  values. That is the [§14.6][s14-6] barrier extended from the
  [root inputs](#g-root-input) to the whole table.
- Events run. A condition can land a guard [predicate](#g-predicate) in
  [holding](#g-edge-semantics) territory (firing on not-holding → holding
  transitions, never bare sign changes). An authored stall flag, or a strut
  authored into contact, does exactly that. The event then fires visibly at
  `t₀` rather than one step later. The [prior](#g-prior) rule grounds that
  timing ([§10.6][s10-6], [D-292][d-292]). Boundary zero establishes every
  guard prior (the event's stored predicate sample from the previous
  boundary) as not-holding. Suppressing those firings was rejected
  ([D-067][d-067]), on the lesson of the
  [stage-on-interaction](#g-stage-on-interaction) rule ([§11.7][s11-7]).
  That lesson is that insurance masking invariant violations is
  anti-diagnostic ([D-026][d-026]). The trace header is taken after the
  sequence ([§11.5][s11-5]). [Replay](#g-replay) restores it and runs no
  boundary zero, so whatever fired at `t₀` comes back as part of the
  restored state and never fires twice ([§12.7][s12-7], [D-274][d-274]).
  The checkpoint records the post-firing state faithfully and suppresses
  nothing. A [stop request](#g-stop-request) already reading
  `STOP_REQUESTED` is a different category. Nothing *fires*. The request
  simply holds in the published `t₀` snapshot and the loop reacts
  ([§13.5][s13-5], [D-413][d-413]).
- Due `s_update` calls run. This follows from an interval-alignment fact
  that is easy to mis-picture. It is hereby a taught contract, sibling to
  the boundary-sampling line ([§8.6][s8-6]). **A boundary's `s_update` is
  the *outgoing* transition** ([D-067][d-067]). At tick `t_k` it consumes
  the completed boundary's samples and produces `s_{k+1}`, the value the
  next tick reads. The transition that carried `s` *into* `t_k` ran at
  `t_{k-1}`. Boundary zero is missing its incoming transitions on *both*
  [tiers](#g-tier) (the continuous and discrete sides of the hybrid
  formalism), and authorship replaces both.

  | tier | `t₋₁` | `t₀` (boundary zero) | `t₁` |
  |---|---|---|---|
  | discrete | the `s_update` that would have produced a discrete leaf's `s(0)` never ran; the condition authored `s(0)` | `s_update` consumes the `t₀` samples and produces `s(1)` | the gated stages read `s(1)` |
  | continuous | the integration over `[t_{-1}, t_0]` that would have produced a continuous leaf's `x(0)` never ran; the condition authored `x(0)` | the authored `x(0)` is the initial condition of the outgoing integrate, $t_0 \to t_0 + h$ | |

  The outgoing work all runs, and `t₀`'s `s_update` has its only
  opportunity. `s(1)` must sit in the store before `t₁`'s gated stages read
  it. An accumulator $s_{k+1} = s_k + \Delta t \, e_k$ authored with
  $s_0 = 0$ under nonzero $e(t_0)$ would otherwise first integrate
  $e(t_1)$, putting the whole sampled-data lattice one period late
  ([D-067][d-067]). The authored `s(0)` needs no protection, because it is
  published in the `t₀` snapshot regardless. The continuous-tier analogue
  of `s_update`-at-`t₀` is not the empty incoming integrate but that first
  *outgoing* one. Both authored values are the published initial conditions
  of their outgoing transitions.
- **`t₀` is an init-service argument** (default `0.0`), never a condition
  entry, because time is not a store of any component ([D-067][d-067]). The
  [harmonic grid](#g-harmonic-grid) (every discrete period an integer
  multiple of `Δt_base`) anchors at whatever `t₀` boundary zero runs at.
  **Both init-service entry points carry the argument, with the same
  default** ([D-110][d-110]). They are `init!(model, condition; t0)` and
  `trim!`'s commit ([§14.8][s14-8], [D-319][d-319]). The simulation's
  `init!(sim, condition; t0)` wraps the model's, resolving the condition and
  opening the run before the model's method writes. Each form of `trim!`
  commits through the matching `init!`, the model's or the simulation's
  ([§14.8][s14-8]). Conditions are time-free. Nothing after boundary zero
  sets the origin. A restore inherits the clock and takes no `t0`
  ([D-273][d-273]).
- **Trim is untouched by all of this** ([D-067][d-067]). Optimizer
  iterations are raw write → sweep → read cycles on the activation, with no
  boundaries, no events and no `s_update`. Only the committed solution
  executes boundary zero.
- A guard firing at commit is a wanted failure signal. The hand-written trim
  asserts of Flight.jl's Cessna 172 models (`!stall`, no weight-on-wheels,
  `ω > ω_idle`) become the model's own event logic, surfaced through the
  ordinary machinery instead of `@assert`. A handler that fires at commit
  moves the committed stores off the solved point. Saying nothing would be
  warn-but-assign relocated. **The channel that says it is the trim report**
  ([§14.8][s14-8], [D-126][d-126]).
- **A commit-fired handler is not the only mover**, and the second one is
  unconditional ([D-155][d-155]). Boundary zero's *first* act is
  `x_projection`, so the committed `x` is `x_projection(x*)`, not the
  solver's `x*`. An attitude quaternion renormalized by a few ulps is the
  canonical case. That move is legitimate, wanted, and usually invisible in
  the residuals. But the point the stores sit at is no longer the point the
  verdict was read at. Both movers take the same remedy, specified with the
  report in [§14.8][s14-8].

### 14.6 Root-input totality: the missing-value error and the `override` combinator

[Root inputs](#g-root-input) are the one initialized datum without declared
defaults. That is the bare-types decision ([§11.3][s11-3]), upheld here
([D-068][d-068], [D-376][d-376]). So a root input's only source before
[boundary zero](#g-boundary-zero) is the [condition](#g-condition) (the
path-addressed sparse overlay that sets a build's state). Boundary zero is
the initialization boundary, the ordinary macro-sequence with an empty
integrate. Three consequences follow. They are the totality check, the
probe-value barrier, and baselines layered by `override`.

**Totality is a precondition of starting, checked by the service**
([D-068][d-068]). A condition value is legitimately partial.
[Fragments](#g-fragment) compose, and trim iterations write subsets. So
"every root input covered" is not a property of conditions. **Totality is a
property of every application that establishes a complete world over
virgin stores** ([D-149][d-149]). That principle, not an enumeration,
names the sites. They are `init!`, trim's setup application to freshly
allocated scratch stores, trim's commit through boundary zero
([§14.8][s14-8]), and linearization's operating condition under `about`,
applied to its own scratch ([§14.10][s14-10]). That is one class, one
mechanism and one kind. Each compares the resolved plan's root-input
coverage against the `Build`'s `input_faces` before writing anything. A
shortfall is one collected, declaration-ordered diagnostic
(`UninitializedInputs`, [Appendix C][sC]) naming every uncovered face.
Coverage is a *plan-level fact*, because both operands are resolution-time
data. The check is therefore one comparison, and it runs before any
evaluation, not merely before any write. Pre-write means all-or-nothing. A
rejected init leaves the sim exactly as it was, the same posture as failed
trim.

**The [probe](#g-probe-value)-value barrier is structural**
([D-068][d-068]). The `probe_value` synthesis (zero, false, the first enum
value or `T()`) exists so build-time probes can exercise code with
fabricated inputs ([§9.3][s9-3]). A fabricated zero is a fine probe input
and a terrible flight condition. A silently zeroed `mixture` kills the
engine and sends the user debugging aerodynamics. The services path simply
contains no call to it. A root input gets a condition value or the
application errors, with no third branch. [Replay](#g-replay) likewise
never synthesizes. The [trace header](#g-trace-header) holds every
root-input cell as boundary zero left it, and with totality enforced that
record is complete by construction. That discharges the requirement
([§11.3][s11-3]).

**[Baselines](#g-baseline) are aircraft-shipped condition functions**,
layered by `override` ([D-068][d-068]). Nobody hand-writes ~20 root-input
values per script. In Flight.jl the `@kwdef` defaults of
`SystemsInitializer`, the systems initializer of its Cessna 172 model
(`c172.jl`), carry that load. Their successor is ordinary user math in one
authoritative home, such as `ready_for_taxi(ac)` or `cold_and_dark(ac)`,
returning full-coverage conditions. But "baseline plus tweaks" collides
with the duplicate-leaf error ([§14.2][s14-2]) by design. The collision
*is* the intent, and **the fourth node kind,
[`override(base, patch)`](#g-override), exists for it** ([D-068][d-068]).
It is ordered and asymmetric, where [`combine`](#g-combine) is symmetric
and collision-intolerant. At resolution a leaf present in both takes the
patch's value, and the origin names both layers. Collisions *within* one
layer remain errors. Variadic layering
(`override(campaign, aircraft, todays_case)`) composes. Trim uses it on day
one. The committed condition is `override(baseline, condition(d*))`, the
solved condition over full coverage ([D-068][d-068]).

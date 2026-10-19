## 14. Stopped-sim services

[§9.6][s9-6] previewed the services as activation clients. They
are initialization, trim and linearization. Everything they share
reduces to one artifact, the **[condition](#g-condition) value**. A condition
is the datum that says "set this build to this state."
[§14.1][s14-1]–[§14.4][s14-4] settle its representation, composition and
application. [§14.5][s14-5]–[§14.6][s14-6] cover the [boundary](#g-boundary)-zero
sequence and [root-input totality](#g-root-input-totality) (the requirement
that an application establishing a complete world cover every root input).
[§14.7][s14-7]–[§14.9][s14-9] cover the trim service in full.
[§14.10][s14-10] covers linearization. A fourth stopped-sim service,
`checkpoint`, returns a [checkpoint](#g-checkpoint) (the `Model`'s state at
a frame top as one value). A checkpoint is not a condition and has no
algebra, and `restore!` puts it back ([D-273][d-273]).

**Lifecycle preconditions.** Every service requires a non-running simulation.
While a run exists the loop owns the [stores](#g-store) between
[drains](#g-drain) (the frame-top swap that publishes staged device writes into
the root inputs), and a service reading or writing them would race it. Pause
is no exception, by the doctrine that freezes the [roster](#g-roster). Pause is
a control-plane state *inside* a run, so a prohibition that holds mid-run holds
while paused ([§11.3][s11-3], [§12.1][s12-1]).

Within the stopped-sim states, legality follows each service's inputs.

| service | `built` | `initialized` | `stopped` | its inputs |
|---|---|---|---|---|
| `checkpoint` | error | legal | legal | a frame-top rest; refused after a `t*` stop and after an abandoned frame |
| `init!` | legal | legal | legal | authored conditions |
| `restore!` | legal | legal | legal | a checkpoint whose fingerprint and deployment match the simulation's and whose `t` sits on its grid ([§12.6][s12-6]) |
| `trim!` | legal | legal | legal | authored conditions; the scratch world is [`override`](#g-override)`(baseline, condition(guess))` ([§14.8][s14-8]), never the sim's stores |
| `linearize`, operating point defaulted to `checkpoint(sim)` | error | legal | legal | inherits `checkpoint`'s precondition, its refusals included |
| `linearize`, explicit `about` ([§14.10][s14-10]) | legal | legal | legal | inherits `init!`'s legality — legal wherever `init!` is |

Each row's service also has a form on a [`Model`](#g-model) (a deployment
materialized at one scalar type), gated by the model's status rather than
by the lifecycle ([D-319][d-319]). `checkpoint` and the default `linearize` are
legal at `:consistent`. `init!`, `restore!`, `trim!` and `linearize` with an
explicit `about` are legal at any status. A model a simulation has claimed
refuses each form that writes, `init!`, `restore!` and `trim!`
([D-318][d-318]).

**`errored` is terminal for every row** ([D-059][d-059], [D-108][d-108]).
Post-mortem inspection of an errored sim's stores, log and [trace](#g-trace)
stays available as a diagnostic read. It may not become a checkpoint.

A violation is `ServiceLifecycle` ([Appendix C][sC]). Its payload is the
operation, the current status and the legal statuses. It is the same kind
`attach!`/`detach!` raise while `running` ([§11.3][s11-3]), so there is one
error form for "this operation is illegal in the current lifecycle state."
`MissingInit` is distinct, and names a missing prior step.

### 14.1 Conditions are path-addressed overlays on the declared defaults

A [condition](#g-condition) may specify state fields (`x` on the continuous
[tier](#g-tier), `s` on the discrete) and modes (`m`,
[continuous components](#g-continuous-component) only, [§3.2][s3-2]). All
three are addressed by a [§8.6][s8-6] slash path plus a field name. It may
also specify [root inputs](#g-root-input), addressed by [face](#g-face). It
never specifies outputs, which are derived data. It never specifies
[workspace](#g-workspace) (component-declared mutable scratch arriving as the
`ws` bundle field). Entries are validated in the [§13.1][s13-1] collecting
form. The full list is checked, violations are collected, and one
`DiagnosticError` is thrown.

**The overlay base is always the declared defaults.** Every [store](#g-store)
has a declared initial value (declaration-by-initial-value, [§8.2][s8-2]), so
conditions are naturally sparse. Applying one means "fresh run from the
`x_init`, `s_init` and `m_init` defaults, with these overrides" ([D-063][d-063]). A
condition is an initial condition and nothing else ([D-273][d-273]). A simulation's state
past its initial instant is a [checkpoint](#g-checkpoint) (the `Model`'s
state at a frame top as one value), not a condition, and it has no algebra
([D-274][d-274]).

**Doctrine.** Addressing conditions by path does not reopen the
observation-by-path rejection ([§13.5][s13-5]). That rejection was about
*runtime* coupling, where a root-authored predicate reaches through generic
[seams](#g-seam) the root does not own and breaks on substitution. A condition
is a *design-time statement about a concrete build*. It is authored in the
same vocabulary as `local_wires`, which also speaks paths, about children
its author owns. The composition law ([§14.2][s14-2]) makes the parallel
exact.

**Pre-[sweep](#g-sweep) doctrine.** Condition writes precede the first sweep by
definition. A would-be init value that depends on swept outputs is therefore
either analytically known to the caller or an equilibrium constraint. The
first case is trim's `α_filt = α_a`. There α is a *decision variable*, so the
value is known above, not computable below. The second case is a job for the
trim service, not for init.

"Caller-computable" reaches past closed-form knowledge to **environment
queries**. A condition needing one constructs the same handle the sweep will
produce, and then calls the same query function the consuming component calls.
There are two routes to that handle. One is the
[value-level constructor](#g-value-level-constructor) (the plain public
function building a field handle from the component and input values,
[§8.2][s8-2]), applied to the same values the [`baseline`](#g-baseline) writes
into the environment [component](#g-component)'s root inputs. The other
applies in a rig where an isbits handle itself is a root-input value
([§4.4][s4-4], [D-364][d-364]). There the condition simply holds the value the
`baseline` wrote. Either way there is one
implementation of the field math, evaluated one level up, with no pre-sweep
and no new mechanism. Where closed-form enforcement of a target is not wanted
at all, the second escape already covers the case. Promote the eliminated
state coordinates to decision variables and enforce the targets as residuals
on swept outputs. That route needs no environment access at condition time
whatsoever.

### 14.2 Fragment composition: locality without schema

Init knowledge is [component](#g-component)-local. The engine knows
`n_eng → ω = n_eng·ω_rated`, and nothing above it should have to. Making that
locality a schema entry was rejected ([D-064][d-064]). That spelling would
declare `initialize(::C, spec)`, today's `f_init!` reborn declaratively, and
add an [assembly](#g-assembly)-level rule routing sub-specs to children.

What preserves the locality is an idiom, not schema. It is the
**condition method**, a method of the framework's `condition` generic,
shipped beside the component and dispatched on the component, returning
the component's own [fragment](#g-fragment). The
generic is framework-owned so that an owner's pull reaches a child's fragment
across a package seam. A model package extends it through
`import Redstone: condition`, as it extends the declaration family
([§8.1][s8-1]). No shadowing check covers it: a method written to a foreign
`condition` fails loudly at the owner's pull, as a `MethodError` naming the
child.

```julia
condition(eng::PistonEngine; n_eng) =
    set(x = (ω = n_eng * eng.ω_rated,), m = (phase = Phase.running,))
```

Fragments are composed by *pull* from the structure's owner.

```julia
condition(sys::C172XSystems; n_eng, α_a, β_a) = combine(
    at("pwp/engine", condition(sys.pwp.engine; n_eng)),
    at("aero",       set(x = (α_filt = α_a, β_filt = β_a))))
```

Dispatch selects variant-specific methods, so the c172s/c172x actuation split
costs no upstream edits. The three combinators are constructors of an
**inert, lazy tree**. No path arithmetic happens at composition.

```julia
struct Fragment{X,S,M,L}  x::X; s::S; m::M; u::L  end      #set(; x, s, m, u): self-vocabulary payloads; no paths
struct Scoped{N}  prefix::String; node::N  end             #at(prefix, node): stores, never applies
struct Combined{T<:Tuple}  nodes::T  end                   #combine(ns...): collects; order = diagnostics only
```

Every node is isbits except the prefix strings, and a prefix is a reference to
the author's own literal. So **rebuilding the tree per trim iteration
allocates nothing**. There is no path arithmetic and no copy of the payloads.
The one validation is the empty-prefix check below, which reads a length and
allocates nothing. The zero-alloc property of today's `assign!` loop holds of the
construction and of the walk that *applies* the tree ([§14.4][s14-4]) alike. An
evaluation's cost is therefore the sweep it feeds.

**Rule.** `at` refuses an empty prefix when it is called. An empty prefix
names no child, and a node meant for the level where it is authored stays
unwrapped. The refusal holds at the root too, because `at` builds an inert
tree and cannot know where it will be mounted. On a condition node it raises
`ConditionNodeMisuse` ([Appendix C][sC]) before any resolution pass runs.
The read side's lifts refuse the same way ([§14.9][s14-9], [D-278][d-278]).

`set`'s payloads speak only about the component at the authoring point.
Addressing children is exclusively `at`'s job, so there is one way to say
everything. A `u` payload names faces *of the authoring level's
[contract](#g-contract)*. Resolution walks the export chain to the root input
and errors if the face never surfaces. That walk always has a name to follow.
One-level routing gives every level a declared face for every signal crossing
its boundary, so the chain a sub-assembly's face routes through is in the
`Build` ([§6.1][s6-1], [§9.2][s9-2]). An internally-wired input has no root
input behind it, and writing it would be meaningless because the first sweep
overwrites it. Unexported stays unpokeable for init exactly as it does for the
GUI ([§11.7][s11-7]).

**The locality law** here is the one [§6.1][s6-1] states for connections, now
in its third instance. The three instances are [local wires](#g-local-wire), computed
interface connections and conditions. Each level speaks its own fields, its
declared children's names, and its own faces. Delegation runs by dispatch at
every genericity [seam](#g-seam). An `at` prefix may stop at *any* child's
faces, owned or generically held, because the face graph is total
([D-207][d-207]). A deep `at` or [condition](#g-condition) path resolves
wherever the structure has it ([§13.3][s13-3], [D-414][d-414]). Absolute paths exist only in the flattened entry
list, a *compiled derivative* of the composition, as cell offsets are of
`local_wires`. Substituting a component invalidates precisely the
fragments its owner shipped, nothing else. The build checks the law wherever it
can see what the law constrains. Wiring resolves one level ([§6.1][s6-1]). The faces a `u`
payload names resolve through the export chain, under any `at` prefix ([D-207][d-207]). No
check refuses a deep path past a generically held field ([D-414][d-414]). An
author who ships a fragment for a family scopes it by dispatch on the
holding's type parameter, so a fragment reaching into one powerplant is
defined for the aircraft that hold that powerplant. Ownership alone is
convention. It is a fact about who maintains the code, and the build cannot see
it, so keeping a deep path inside an owned subtree is idiomatic rather than
machine-checked ([D-065][d-065]). `set`/`at`/`combine` are [§13.7][s13-7] standard-library
material, ordinary artifacts with no privileges.

A [combine](#g-combine) collision is two entries on one leaf. Collisions are
errors at resolution, and the error reports *both* origins. The
message names the layering combinator: "`combine` is collision-intolerant by
design — use `override(base, patch)` to layer." Last-writer-wins was rejected
([D-065][d-065]). That rejection is also why the combinator is not
`Base.merge`, and is no longer named after it ([D-204][d-204]). `Base.merge`
is last-wins on NamedTuples, the exact semantics rejected here, and its own
name should not promise them. Because `combine` is its own function, a bare
NamedTuple blended into a node cannot fall through to any last-wins method.
The blend is still closed explicitly. A `combine(::Fragment, ::NamedTuple)`,
or any other blend of a condition node with a bare NamedTuple, is an **error
method**. Its message is directive: wrap the NamedTuple in `set(…)` (or
`at(prefix, set(…))`) and combine nodes with nodes. The rejection carries
a [kind](#g-kind) like every other. It is `ConditionNodeMisuse`
([Appendix C][sC]), carrying the offending argument's type and the node kinds
in hand. It is raised at composition time, before any resolution pass runs
or any origin exists. That is why it is its own kind and not a
`ConditionResolution` sub-kind ([§14.3][s14-3]). The explicit, *ordered*
layering spelling, `override`, belongs with the use case
[root-input totality](#g-root-input-totality) produces ([§14.6][s14-6]).

### 14.3 Resolution: flatten, validate, compile once

Resolution takes the root node plus a `Build`. Flattening is the only place
path strings are ever concatenated. It is a trivial recursion with a path
accumulator, and it also records each entry's **tree position**, its
`getfield`/`getindex` step tuple.

The collecting pass then checks each flat entry:

- the path resolves, with [did-you-mean](#g-did-you-mean) (the offending name
  plus the list-in-hand it should have matched) over children;
- the field is declared in the target's `x_init`/`s_init`/`m_init`;
- the value type is convertible to the declared leaf type;
- input [faces](#g-face) reach [root inputs](#g-root-input);
- no `(path, store, field)` is duplicated.

The `Build` supplies two lookup families. **Schema** is the evaluated
declarations, and it is the authority. It answers whether you may write this
field, and at what leaf type. **Layout** is the destination. It holds the `x`
backing ranges, the store indices for `s` and for `m`, and the root-input
indices from the [activation](#g-activation) (the build's typed products at a given
scalar type). The names and the face chains come from
[`Structure`](#g-structure) (the structure step's product, the components, wires, faces
and tiers), never from an activation, since no activation fixes them
([§9.1][s9-1], [D-253][d-253]).

A valid list compiles to a plan. Per leaf, the plan holds a [lens](#g-lens)
(the compiled navigation step of a condition entry), a destination offset, and
a converter. The lens is the position tuple lifted to a type parameter, so
navigation of the fixed tree type is type-stable.

**Rule.** The converter is baked now, selected per leaf from that leaf's type
in the resolved shape.

**Why.** Leaf types are shape facts, carried by the tree type along with the
full nesting and every field name ([§14.4][s14-4]). Selection therefore
consults no runtime fact and stays a resolution-time bake.

There are two cases.

| leaf in the resolved shape | converter baked |
|---|---|
| already at the activation's scalar type — decision-descended | the type's ordinary `convert`/constructor methods *at that eltype* |
| a plain `Float64` leaf against a non-nominal activation's scratch — a held constant | the `Float64 → Dual` zero-partial embedding |

**A leaf already at the activation's scalar type** is decision-descended.
Under a `Dual`-seeded evaluation of a type-stable `trim_condition(d)`, every
decision-dependent leaf is `Dual`-typed in the shape ([§14.7][s14-7]). Such a
leaf takes the type's ordinary `convert`/constructor methods *at that eltype*.
An authored `RQuat` of `Dual`s becomes the `SVector{4}` state leaf at `Dual`,
with the partials flowing through untouched. That untouched flow of partials
is what makes the seeded decisions reach the [sweep](#g-sweep) at all. At the
nominal activation the same rule is the ordinary `Float64` conversion. An
authored `RQuat` value becomes the `SVector{4}` state leaf it initializes.

**A plain `Float64` leaf against a non-nominal activation's scratch** is a held
constant, and it takes the `Float64 → Dual` zero-partial embedding. That
embedding is semantically exact in that case, and in no other. "Held at the
operating point" *is* zero partials. Zero partials are the whole of a
linearization operating-point [condition](#g-condition), which is authored
decision-free ([§14.10][s14-10]).

The selection is a one-time boundary decision, and it leaves the nominal
exact-match doctrine for table [cells](#g-cell) ([§9.5][s9-5]) untouched.
Converters run here, on the write path. They never run on state
[views](#g-view) ([§7.1][s7-1]).

Overlay partiality for the `s` and `m` stores is baked the same way. The
writer holds `merge(init_m_defaults, overlay)`, with the base resolved at
compile time (the overlay-base rule, [§14.1][s14-1]).

### 14.4 One plan, two ways to apply it

**The paradigm-change tax feared at execution does not materialize.** All
string work, validation and addressing are functions of the *shape* of the
[condition](#g-condition) (the path-addressed sparse overlay that sets a
build's state). Every hot path holds the shape fixed while varying values.
Execution is therefore resolve-once/execute-many, with two ways to apply one
plan.

- **Specialized `apply!`** serves the service that iterates, trim's
  per-evaluation write. It unrolls stores through the baked lenses and
  converters. Those are the same machine operations as today's in-place
  writes: zero-alloc, no strings, no dispatch. The
  per-iteration shape check is the mechanism of [§9.5][s9-5] transferred. The
  tree type is proven by dispatch, and it carries the full nesting, every
  field name and leaf type. A `===` sweep over the prefix strings closes the
  remainder. `===` on strings compares content, so a prefix computed at run
  time pairs with the compiled one exactly as a literal does, at the cost of
  one short comparison per `at` node. Shape drift (a tree of another type, or
  a prefix that differs at a position) is `ConditionShapeDrift`
  ([Appendix C][sC]), a structured error rather than silent corruption. The
  cost is Julia codegen *once per condition shape*, and it grows with the
  shape's writes. On Julia 1.13 it measures 10 to 50 ms up to 32 writes,
  0.09 s at 64 and 0.2 s at 128 (`docs/reports/20261002_tuple_walks/`).
  That cost is noise against the model's own first-sweep warmup (seconds),
  and against the 10³–10⁴ optimizer evaluations the codegen amortizes over.
- **The dynamic walk** serves the one-shot uses, `init!` and `linearize`'s
  operating condition. It executes the same validated entry list by runtime
  dispatch per write. That takes microseconds in total,
  with allocation permitted, since the stopped-sim path was never under the
  zero-alloc regime ([§9.8][s9-8]). It needs no per-shape codegen. Fifty
  structurally different scripted conditions cost fifty walks, not fifty
  compiles.

**Rule.** Which of the two a service uses is internal, never user-facing API.

A compiled plan or reader carries the [activation](#g-activation) it was
compiled at and applies only to a store set of that activation. That pairing
is a framework invariant the services uphold, not a user-facing check. Neither
plans nor readers are user values.

#### The read-selector family

**The read-[selector](#g-selector) family is closed.** Its members are
`get_state(path, leaf)`, `get_deriv(path, leaf)`, `get_output(path, leaf)`,
`get_input(leaf)` and `get_face(leaf)`. They form one address space for every
reader of the model.

**Rule.** `leaf` is a [leaf address](#g-leaf-address): the field or face
name, followed by `.name` and `[k]` or `[k,l]` steps in any order, as in
`"pose.q_eb[2]"`, `"ω_eb_b[1]"` or `"J[1,3]"`. A bare `Symbol` is the short
form of a plain name, so `get_state("kin", :θ)` reads `get_state("kin", "θ")`.
A face name is an arbitrary string and may contain a dot ([§8.6][s8-6]), so on
`get_input` and `get_face` the head is matched rather than
parsed: it is the longest declared face name that is a prefix of the
address and is followed by the end, a `.` or a `[`, and a `Symbol` leaf
names the face whole, with no steps. So `get_input("wing.throttle")` and
`get_input("wind[1]")` both resolve, and where faces `a` and `a.b` both
exist, `"a.b"` names the face `a.b`.
Each step is checked at resolution against the type resolved so far. A
`.name` step needs an isbits struct with that field. An index step needs an
`SArray`, with one index or one per dimension, and a vector leaf thereby
yields named scalars. A step never enters an opaque leaf (a field handle or
a `Symbol`), which is read whole. A continuous state field is flat
([§7.1][s7-1]), so `get_deriv`, and `get_state` on the continuous tier, take
at most an index step. A discrete `s` field is isbits or a `Symbol` ([§3.2][s3-2]), and
`get_state` on it takes the full address. The address is checked once and baked,
and the read runs as field loads and indexing unrolled at compile time
([D-276][d-276]).

The names carry a deliberate `get_` prefix. A selector is a *deferred read*, a
value describing the read the compiled gather will perform. The prefix names
that action, and it keeps five short common nouns out of the namespace user
declarations share with domain code.

There is no selector for a value a [component](#g-component) computes without
declaring it, and there cannot be one, because only [cells](#g-cell) are
addressable ([§4.2][s4-2], [§8.3][s8-3]). So a reader that wants one is asking the producing
component to declare it an output ([§8.3][s8-3]). `get_face` addresses an
output [face](#g-face) of the mount level, the level its read set is mounted
at ([§14.9][s14-9]). At the root that face is root-exported. Either way the
read is an *integration* read ([§11.2][s11-2]).

**Rule.** A selector resolves against a source, before any client policy
applies.

The table selectors (`get_output`, `get_input`, `get_face`) resolve against a
*table source*. A table source is a [boundary](#g-boundary)
[snapshot](#g-snapshot), or the scratch tables a service evaluation
instantiates ([§14.8][s14-8]). The store selectors (`get_state`, `get_deriv`)
resolve only against live stores. The table/store axis separates table-borne
values from store-borne ones, not snapshots from services.

Only stopped-sim service evaluations, `checkpoint`, and post-run inspection of
the live stores (the [replay](#g-replay)-to-inspect, [§11.2][s11-2]) ever hold
live stores. The snapshot deliberately carries no state stores
([§11.2][s11-2]), and `ẋ` [buffers](#g-buffer) are integrator scratch, not
boundary-consistent objects outside a service evaluation. A reader resolving
for a table source that names a store selector is therefore refused at
resolution, as a `ReadResolution` ([D-406][d-406]). The resolver takes the
source it resolves for, so the rule is the resolver's and not a client's.
The honest remedy
([§11.2][s11-2]) is to declare the field in `y_types`, return it from
`y_state`, and read the resulting [port](#g-port) ([§5.3][s5-3]).

Client policy rides on top. It is [D-083][d-083]'s service and inspection
sides restated as a resolver property.

- **Service reads speak the [contract](#g-contract).** Trim's `reads` and
  linearization's [taps](#g-taps) (the three selector lists declaring what
  linearization seeds and reports) name
  `get_state`/`get_deriv`/`get_output`/`get_input`/`get_face`. They do so
  within the scopes the locality law ([§6.1][s6-1]) and
  [fragment](#g-fragment) scoping ([§14.2][s14-2]) describe, as authoring
  guidance ([D-414][d-414]). `get_face` is the
  set's [seam](#g-seam)-crossing member. It resolves through export chains
  exactly as [mounting](#g-mounting) (relocating a whole problem or tap set
  with `at(prefix, …)`) resolves [root input](#g-root-input) faces
  ([§14.9][s14-9]), so the read side mirrors the write side. An equilibrium
  equation meant to outlive the build it was posed against therefore binds
  the curated face behind a generically-held child rather than a path into
  it. A service evaluation
  needing an undeclared intermediate has one remedy, and it is the same for
  every client. The component exports it ([§14.7][s14-7]).
- **Inspection readers admit the whole family, within the source rule.**
  Output-[device](#g-device) bindings, log extraction by `series` and snapshot
  inspection take deep paths, `get_face` names and leaf addresses alike
  ([D-406][d-406], [D-407][d-407], [D-414][d-414]). The store selectors reach only the
  inspection clients that actually hold stores (`checkpoint`, post-run
  inspection). A snapshot-bound reader is barred from them by source, not by
  client.
- **`ignore_stop_requests` is not a family client.** It names requesters
  from the `Build`'s requester roster, period ([§13.5][s13-5], [D-060][d-060],
  [D-316][d-316]). Termination is run policy over the requests the model declares, and
  no path selector reaches `ignore_stop_requests`.

The five selectors, their sources, and their clients:

| selector | resolves against | service reads | inspection readers |
|---|---|---|---|
| `get_state(path, leaf)` | live stores | named in the contract | only clients that hold stores |
| `get_deriv(path, leaf)` | live stores | named in the contract | only clients that hold stores |
| `get_output(path, leaf)` | a table source | named in the contract | admitted |
| `get_input(leaf)` | a table source | named in the contract | admitted |
| `get_face(leaf)` | a table source | named in the contract | admitted |

**Compiled readers are the gather twin** over this family and the layout
tables. Trim's cost read (`ẋ` and output fields) and linearization's
Jacobian gather are one primitive run in reverse.
It is one machinery, in both directions, in the `Build`'s client kit.

The per-iteration ledger for trim has four terms. They are the user fragment
math (the domain computations unchanged from today, plus the tree's few boxes,
[§14.2][s14-2]), the leaf stores, the folded shape check, and the sweep. The
sweep dominates, exactly as `f_ode!` does today. `apply!` ends at established
stores. Making the model *coherent* is the job of
[boundary zero](#g-boundary-zero) (the initialization boundary: the ordinary
macro-sequence with an empty integrate), [§14.5][s14-5].

### 14.5 Boundary zero: an ordinary boundary with authored incoming transitions

`apply!` establishes the stores at `t₀`. The init service then completes the
[§10.6][s10-6] macro-sequence with an empty integrate. The sequence is
project → [[sweep](#g-sweep) → [guards](#g-guard) → handlers]\* →
[due](#g-due) `s_update` calls → first [snapshot](#g-snapshot). After the
first snapshot `init!` takes the [trace header](#g-trace-header), the
[checkpoint](#g-checkpoint) (the `Model`'s state at a frame top as one
value) of the state the sequence leaves ([§11.5][s11-5], [D-274][d-274]).
The parity with an ordinary boundary is exact, not approximate. The pieces
follow one by one.

- **Project runs.** Authored `x` can sit off-manifold. A hand-assembled
  quaternion may be ulps off unit norm, or a [condition](#g-condition) (the
  path-addressed sparse overlay that sets a build's state) may write part of a
  constrained block against fresh defaults. [Projection](#g-projection) after
  condition writes holds the same position it holds after any other `x`
  mutation. And it costs nothing when the state is already clean.
- **The sweep runs, and every discrete output stage publishes, due or not
  ([D-205][d-205]).** `t₀` is a grid point of every phase-free divisor, so the
  `Φ = 0` components are due in full. An offset [component](#g-component)
  ([§10.5][s10-5]) is *not* due, because its first [tick](#g-tick) is at
  `Φ·Δt_base`. Its output stages run at boundary zero all the same, publishing
  from the authored `s` and the `t₀` table in the ordinary sorted walk. That
  evaluation is establishment, not a scheduled sample. The schedule owns every
  instant after `t₀`, and the first sample the component's `s_update`
  consumes remains its `Φ·Δt_base` tick's. What the rule buys is a `t₀`
  [snapshot](#g-snapshot) carrying the authored world fully evaluated. No
  published [cell](#g-cell) holds the [probe](#g-probe)'s synthesized values.
  That is the [§14.6][s14-6] barrier extended from the
  [root inputs](#g-root-input) to the whole table.
- **Events run.** A condition can land a guard [predicate](#g-predicate) in
  [holding](#g-edge-semantics) territory (firing on not-holding → holding
  transitions, never bare sign changes). An authored stall flag, or a strut
  authored into contact, does exactly that. The event then fires visibly at
  `t₀` rather than one step later. The [prior](#g-prior) rule grounds that
  timing ([§10.6][s10-6]). [Boundary zero](#g-boundary-zero) establishes every
  guard prior (the event's stored predicate sample from the previous boundary)
  as not-holding. Suppressing those firings was rejected ([D-067][d-067]), on
  the [stage-on-interaction](#g-stage-on-interaction) lesson of
  [§11.7][s11-7] (widgets stage on edit or activation, never per render pass).
  Insurance that masks invariant violations is anti-diagnostic
  ([D-026][d-026]). The trace header is taken after the sequence
  ([§11.5][s11-5]). [Replay](#g-replay) restores it and runs no
  [boundary](#g-boundary) zero, so whatever fired at `t₀` comes back as
  part of the restored state and never fires twice ([§12.7][s12-7]). The
  checkpoint records the post-firing state faithfully and suppresses
  nothing. A [stop request](#g-stop-request) already reading
  `STOP_REQUESTED` is a different category. Nothing *fires*. The request
  simply holds in the published `t₀` snapshot and the loop reacts
  ([§13.5][s13-5]).
- **Due `s_update` calls run.** This follows from an interval-alignment
  fact that is easy to mis-picture. It is hereby a taught contract, sibling to
  the boundary-sampling line ([§8.6][s8-6]). **A boundary's `s_update`
  is the *outgoing* transition.** At tick `t_k` it consumes the completed
  boundary's samples and produces `s_{k+1}`, the value the next tick reads.
  The transition that carried `s` *into* `t_k` ran at `t_{k-1}`. Boundary
  zero is missing its incoming transitions on *both* tiers, and authorship
  replaces both.

  | [tier](#g-tier) | `t₋₁` | `t₀` (boundary zero) | `t₁` |
  |---|---|---|---|
  | discrete | the `s_update` that would have produced a discrete leaf's `s(0)` never ran; the condition authored `s(0)` | `s_update` consumes the `t₀` samples and produces `s(1)` | the gated stages read `s(1)` |
  | continuous | the integration over `[t_{-1}, t_0]` that would have produced a continuous leaf's `x(0)` never ran; the condition authored `x(0)` | the authored `x(0)` is the initial condition of the outgoing integrate, $t_0 \to t_0 + h$ | |

  The outgoing work all runs, and `t₀`'s `s_update` has its only
  opportunity. `s(1)` must sit in the store before `t₁`'s gated stages read
  it. An accumulator $s_{k+1} = s_k + \Delta t \, e_k$ authored with $s_0 = 0$
  under nonzero $e(t_0)$ would otherwise first integrate $e(t_1)$, putting the
  whole sampled-data lattice one period late ([D-067][d-067]). The authored
  `s(0)` needs no protection, because it is published in the `t₀` snapshot
  regardless. The continuous-tier analogue of `s_update`-at-`t₀` is not
  the empty incoming integrate but that first *outgoing* one. Both authored
  values are the published initial conditions of their outgoing transitions.
- **`t₀` is an init-service argument** (default `0.0`), never a condition
  entry, because time is not a store of any component. The
  [harmonic grid](#g-harmonic-grid) (every discrete period an integer multiple
  of `Δt_base`) anchors at whatever `t₀` boundary zero runs at. Both
  init-service entry points carry the argument, with the same default. They
  are `init!(model, condition; t0)`, which the simulation's
  `init!(sim, condition; t0)` forwards to, and `trim!`'s commit
  ([§14.8][s14-8], [D-319][d-319]). `trim!(model, problem; baseline, t0, backend)`
  commits through the model's `init!`, and
  `trim!(sim, problem; baseline, t0, backend)` through the simulation's.
  Conditions are time-free. Nothing after boundary zero sets the origin. A
  restore inherits the clock and takes no `t0` ([D-273][d-273]).
- **Trim is untouched by all of this.** Optimizer iterations are raw
  write → sweep → read cycles on the activation, with no boundaries, no events
  and no `s_update`. Only the committed solution executes boundary zero.
- **A guard firing at commit is a wanted failure signal.** Today's
  hand-written trim asserts (`!stall`, no weight-on-wheels, `ω > ω_idle`)
  become the model's own event logic, surfaced through the ordinary machinery
  instead of `@assert`. A handler that fires at commit moves the committed
  stores off the solved point. Saying nothing would be warn-but-assign
  relocated. The channel that says it is the trim report ([§14.8][s14-8]).
- **A commit-fired handler is not the only mover, and the second one is
  unconditional.** Boundary zero's *first* act is `x_projection`, so the
  committed `x` is `x_projection(x*)`, not the solver's `x*`. An attitude
  quaternion renormalized by a few ulps is the canonical case. That move is
  legitimate, wanted, and usually invisible in the residuals. But the point
  the stores sit at is no longer the point the verdict was read at. Both
  movers take the same remedy, specified with the report in [§14.8][s14-8].

### 14.6 Root-input totality: the missing-value error and the `override` combinator

[Root inputs](#g-root-input) are the one initialized datum without declared
defaults. That is the bare-types decision ([§11.3][s11-3]), upheld here
([D-068][d-068]). So a root input's only source before
[boundary zero](#g-boundary-zero) (the initialization boundary: the ordinary
macro-sequence with an empty integrate) is the condition. Three consequences
follow.

**Totality is a precondition of starting, checked by the service.** A
condition value is legitimately partial. [Fragments](#g-fragment) compose,
and trim iterations write subsets. So
"every root input covered" is not a property of conditions. It is a property
of *every application that establishes a complete world over virgin stores*.
That principle, not an enumeration, names the sites. They are `init!`, trim's
setup application to freshly allocated scratch stores, and trim's commit
through [boundary](#g-boundary) zero ([§14.8][s14-8]). That is one class, one
mechanism and one kind. Each compares the resolved plan's root-input coverage
against the `Build`'s `input_faces` before writing anything. A shortfall is
one collected, declaration-ordered diagnostic (`UninitializedInputs`, a
[§13.2][s13-2] kind) naming every uncovered face. Coverage is a *plan-level
fact*, because both operands are resolution-time data. The check is therefore
one comparison, and it runs before any evaluation, not merely before any
write. Pre-write means all-or-nothing. A rejected init leaves the sim exactly
as it was, the same posture as failed trim.

**The [probe](#g-probe-value)-value barrier is structural.** The `probe_value`
synthesis ([§9.3][s9-3]; zero/false/first-enum/`T()`) exists so build-time
probes can exercise code with fabricated inputs. A fabricated zero is a fine
probe input and a terrible flight condition. A silently zeroed `mixture` kills
the engine and sends the user debugging aerodynamics. The services path simply
contains no call to it. A root input gets a condition value or the application
errors, with no third branch. [Replay](#g-replay) likewise never synthesizes.
The [trace header](#g-trace-header) holds every root-input cell as boundary
zero left it, and with totality enforced that record is complete by
construction (the requirement discharged, [§11.3][s11-3]).

**[Baselines](#g-baseline) are aircraft-shipped [condition](#g-condition)
functions, layered by `override`.** Nobody hand-writes ~20 root-input values
per script. Today `SystemsInitializer`'s `@kwdef` defaults carry that load.
Their successor is ordinary user math in one authoritative home, such as
`ready_for_taxi(ac)` or `cold_and_dark(ac)`, returning full-coverage
conditions. But "baseline plus tweaks" collides with the duplicate-leaf error
([§14.2][s14-2]) by design. The collision *is* the intent. Hence the fourth
node kind, **`override(base, patch)`**. It is ordered and asymmetric, where
`combine` is symmetric and collision-intolerant. At resolution a leaf present
in both takes the patch's value, with the origin recording both layers
("patch overrode base's `throttle`"). Collisions *within* one layer remain
errors. Variadic layering (`override(campaign, aircraft, todays_case)`)
composes. Trim uses it on day one. The committed condition is
`override(baseline, solution)`, the solver's handful of values over full
coverage ([D-068][d-068]).

### 14.7 The trim problem: NamedTuple decisions, declared reads, named residuals

The aircraft author ships one value. It says what the solver may vary, what
those decisions make of the model, what to read back after each evaluation,
and which equations the readings must satisfy.

**Rule.** The field set is normative. The lift ([§14.9][s14-9]) is
field-by-field, so this list is closed.

- `guess`, `lower` and `upper` are same-named all-`Float64` NamedTuples.
- `condition` is the condition-valued function over decisions.
- `reads` is the declared read set.
- `residuals` is the residual function.
- `tolerances` is an all-`Float64` NamedTuple, same-named as the residual
  function's return.
- `checks` is the check function, and `check_tolerances` an all-`Float64`
  NamedTuple same-named as its return. Both default to empty.

`tolerances` is carried *in the problem* because a relocated problem must carry
its own convergence test. `at` passes it through untouched.

[Worked](#g-worked), the C172 cruise case reduces to its three-equation core.
The real problem is the same shape with the full 7-variable search, and the
θ-constraint elimination survives inside `trim_condition`.

```julia
cruise = TrimProblem(
    guess      = (throttle = 0.6, elevator = -0.05, α = 0.06),
    lower      = (throttle = 0.0, elevator = -1.0,  α = -0.1),
    upper      = (throttle = 1.0, elevator =  1.0,  α =  0.3),
    condition  = d -> trim_condition(ac, params, d),    #params closed over (§14.2)
    reads      = reads(v̇_b = get_deriv("vehicle/dynamics", :v_eb_b),
                       ω̇_b = get_deriv("vehicle/dynamics", :ω_eb_b),
                       EAS = get_output("vehicle/airdata", :EAS)),
    residuals  = (r, d) -> (axial_force  = r.v̇_b[1],
                            normal_force = r.v̇_b[3],
                            pitch_moment = r.ω̇_b[2]),
    tolerances = (axial_force = 1e-3, normal_force = 1e-3, pitch_moment = 1e-4),
    checks           = (r, d) -> (EAS = r.EAS - params.EAS,),  # read back after the commit
    check_tolerances = (EAS = 0.1,))
```

The rest of the section takes what the author ships one piece at a time,
against today's `c172.jl`.

- **Decision variables, initial guess and box bounds are plain, same-*named*,
  all-`Float64` NamedTuples.** The `AbstractTrimState{N}`/`FieldVector`
  supertype dies. Its only job was vectorization, and vectorization is the
  service's. The service packs and unpacks by field order, and that order is
  the `guess` NamedTuple's own. [§9.5][s9-5] states the rule this
  [seam](#g-seam) runs on: **the names are the pairing, order carries no
  semantics**. `lower` and `upper` are checked at setup for key-set equality
  with `guess` and for `Float64` fields. They are then canonicalized to
  `guess`'s field order by the same type-level reorder
  (`NamedTuple{keys(guess)}(lower)`). A permuted bound spelling is therefore
  a non-event, rather than `α`'s bound silently applied to `throttle`. A
  key-set or field-type mismatch is `TrimProblemInvalid`. Guess, bounds and
  the returned solution share one spelling, and
  `Base.merge(guess, (throttle = 0.3,))` is free warm-start tweaking. An
  author who wants a documented `@kwdef` struct keeps it privately and
  converts.
- **`TrimParameters` stays a plain user struct** the framework never sees. The
  assignment is the pure `trim_condition(ac, params, d)` fragment-tree
  function ([§14.2][s14-2]), applied per iteration by the compiled plan
  ([§14.4][s14-4]).
- **The read side is declared, then compiled.** The spelling is
  `reads(name = get_state(path, leaf) | get_deriv(path, leaf) |
  get_output(path, leaf) | get_input(leaf) | get_face(leaf), ...)`, the
  service read set ([§14.4][s14-4]), each `leaf` a
  [leaf address](#g-leaf-address) (the field name with dotted and bracketed
  steps below it). `get_state` and `get_deriv`
  address a declared state field and its derivative (validated against
  `x_init`/`s_init`). `get_output` addresses a declared output
  [port](#g-port) (validated against `y_types`). `get_input` and
  `get_face` address a root input [face](#g-face) and an output face
  (validated against the root face lists). The path [selectors](#g-selector) (the closed family of
  deferred reads resolving against a source) reach any port the structure has
  ([§13.3][s13-3], [D-414][d-414]). An equilibrium equation meant to survive
  substitution at a generic seam reads a face. A value a [component](#g-component) computes without
  declaring it is not addressable at all ([§8.3][s8-3], [§14.4][s14-4]). A
  trim evaluation needing one is a signal that the component should export
  it. A derivative wanted across a [contract](#g-contract) boundary takes the
  same remedy. Publish it as an ordinary output port computed in
  `y_direct` (the one-line binding of the fused idiom, [§5.3][s5-3], made
  contract). That leaves `get_deriv` scoped to owned concrete subtrees. The
  compiled reader (the gather twin, [§14.4][s14-4]) fills a stack-only
  NamedTuple per evaluation.
- **The user supplies a residual *system*, not a scalar cost.** It is authored
  as a NamedTuple of named equations and packed to the solver's vector by
  field order. The order here is `tolerances`' field order, the declared side
  again, and the residual return is canonicalized to it. The decisions rule
  holds symmetrically on both ends of the seam. Names pair, and order never
  does.
- **Checks are equations the service reports once, at the committed state,
  and never solves.** `checks` has the residual function's signature, and
  `check_tolerances` pairs with its return as `tolerances` pairs with the
  residuals'. The service gathers the checks after the commit, from the
  boundary-zero sweep, and reports them ([§14.8][s14-8]). Setup observes their
  return's shape at the guess evaluation, as it observes the residuals'
  ([§14.8][s14-8]). Their reads join the problem's one read set. *Why.*
  Under analytic elimination the condition math pins the airspeed and the
  flight-path angle from the targets and the atmosphere the user's `params`
  record holds, while the world measures
  against the atmosphere the baseline wrote. If the two disagree, the
  residuals vanish at a true equilibrium that is not the requested point,
  and nothing in the residual system can tell ([D-139][d-139]). A check reading EAS
  from the world's airdata at the committed state and subtracting the
  requested value is where a world measurement meets the request, so any
  mismatch moves it. The checks stay out of the solve because they carry no
  information for it ([D-262][d-262]).
- **The FlightCore formulation's core is correct and survives verbatim as user
  math.** That core is analytic elimination: `θ_constraint` substituting the
  pitch constraint, filter and actuator equilibria imposed by construction, and
  the minimal 7-variable search.
- **What changes is the numerics.** Trim is a square root-find. FlightCore's
  derivative-free scalar minimization over $\|r\|^2$ against a hand-scaled
  absolute `stopval` was the rational choice only because Jacobians through
  the mutating `f_ode!` chain and the assignment math were out of reach
  ([D-069][d-069]).
- **Nonlinear least squares with exact AD Jacobians is the default.** The
  `Dual` [activation](#g-activation) seeds the decision variables through the
  `T`-generic assignment, [sweep](#g-sweep) and `x_deriv`. The seeds
  survive the condition write boundary because [§14.3][s14-3] selects the
  baked converter per leaf from the shape. A decision-descended leaf is
  `Dual`-typed there and takes the structural conversion, while the
  zero-partial embedding stays on the held `Float64` leaves. The *default* is
  nonlinear least squares on $r(d)$ with exact AD Jacobians, in the
  trust-region/Levenberg–Marquardt family ([§14.8][s14-8]). Convergence is
  quadratic (~5–15 evaluations), the tolerances are per-residual and
  physical, and failure reports name the unbalanced equations with
  magnitudes. The convergence verdict itself is service-owned and
  backend-independent ([§14.8][s14-8]).
- **Non-squareness degrades gracefully.** Redundant actuation becomes weighted
  or minimum-norm least squares. Infeasible demands converge to a nonzero
  residual identifying the impossible balance. At the solution,
  $\partial r / \partial d$ is free flight-physics data (control
  effectiveness) that cross-checks linearization.
- **The derivative-free scalar path survives as the fallback.** The service
  squares *and normalizes* the residuals against the tolerances, minimizing
  $\sum (r_i/\mathit{tol}_i)^2$ at `stopval = 1` ([§14.8][s14-8]). That
  normalization is where the hand-scaled absolute threshold is repaired. It
  leaves today's algorithm as the degenerate case.
- **Two problems are [recorded, not built](#g-recorded-not-built)** (a
  worked-out extension deliberately left unimplemented, its seams named). They
  are closed-loop sampled-data trim and on-ground static equilibrium, each
  simply another problem value over the same service. Closed-loop trim appends
  $g(s) - s = 0$ residuals via a nondestructive scratch evaluation of
  `s_update`, which was structurally impossible under FlightCore's
  mutating `f_disc!`. On-ground static equilibrium solves strut compressions
  and attitude against gear forces.

The residual signature:

```julia
residuals(reads::NamedTuple, d::NamedTuple) → NamedTuple
```

**Rule.** What the solver varies is passed. What is fixed per problem is
closed over.

The gathered reads and the decision NamedTuple arrive as arguments. `d` is the
one value that *cannot* be closed over. `TrimParameters` stays behind the
closure, exactly as `condition` already holds it, and the framework never sees
it. Being user-shaped, that record is also where any environment handles the
condition math needs conventionally ride (the
[value-level constructor](#g-value-level-constructor), [§8.2][s8-2]; the
pre-sweep doctrine, [§14.1][s14-1]). The problem *receives* the environment,
and never writes it ([§14.9][s14-9]).

The returned NamedTuple's names are the equation names the report and the
failure messages use. The service packs residuals and tolerances by field
order. `tolerances`' order is canonical for the r-side, and each residual
return is reordered to it (`NamedTuple{keys(tolerances)}(r)`) before packing.
An equation list spelled in a different order inside the lambda therefore
pairs correctly and costs nothing. Names and types are checked at setup,
because the guess evaluation the service performs anyway observes the
residual key set. A `tolerances` key-set mismatch, or any field-type
disagreement on either side of the seam, is `TrimProblemInvalid`
([Appendix C][sC]), with the offending field and the names or types in hand.
Order is never a mismatch.

### 14.8 The trim service: solver seam, scratch stores, commit and report

A `TrimProblem` is an inert value until a service runs it. `trim!` is that
service. It drives a solver it holds behind one method, works on scratch
stores of its own, commits a converged solution the way `init!` would, and
returns a report.

#### The backend seam

The signature is
`trim!(model, problem; baseline, t0 = 0.0, backend = LevenbergMarquardt())`,
where `model` is a [`Model`](#g-model) (a deployment materialized at one
scalar type) at `Float64` ([D-319][d-319]). `trim!(sim, problem; …)` gates on the
simulation's lifecycle and commits through the simulation's `init!`. The
default backend is an in-house dense Levenberg–Marquardt. For decision
dimensions ~10 with exact Jacobians, the core is ~100 lines: a damping loop, a
small linear solve, a convergence test. That is the [§10.2][s10-2] stepper
precedent exactly, a tiny needed core against a heavy dependency. The
per-residual physical tolerances sharpen the case ([§14.7][s14-7]). They are a
convergence test no external package spells natively. That is precisely why
the *service*, not the backend, applies it.

The backend contract is a **pinned signature**, value-passed, with one
required method per backend. That one method is the [seam](#g-seam).

```julia
solve(backend, eval!, d0, lower, upper, tol) -> (; d, status, n_evaluations, n_iterations)
```

`eval!(r, J, d)` is in-place and always fills `r`, the residual vector packed
in `tolerances`' field order. It fills `J` **iff `J !== nothing`**. The
Jacobian is requested by argument, so a Jacobian-free backend simply always
passes `nothing`, and there is still exactly one evaluation method to
implement.

`d0`, `lower` and `upper` are packed `Vector{Float64}` in `guess`'s field
order, with `±Inf` meaning unbounded. The declared side is canonical on both
ends, and the service has canonicalized before packing ([§14.7][s14-7]). A
backend that ignores bounds therefore ignores two vectors, not a missing
argument.

`tol` is a `Vector{Float64}` in `tolerances`' field order. It is data the
backend *may* stop on, under the service's per-backend-family translation below,
and it is decisive of nothing.

The return holds `d`, the solution, `status::Symbol` from a deliberately
**open** set, and the diagnostic counts `n_evaluations` and `n_iterations`. The status is
recorded verbatim in the report because the verdict is the service's
([D-158][d-158]). The name `solve` is subject to the exported-name audit (`pending.md`)
like every other API spelling. The backend sees vectors and never names, so
the solution it returns unpacks by the same order it was given.

#### The convergence verdict is the service's, uniformly

`converged` means `all(abs.(rᵢ) .≤ tolᵢ)`. That is the per-residual box test
([§14.7][s14-7]) in its own physical units, evaluated **by the service at the
backend's returned point**. It is one residual evaluation, noise against the
solve that produced it. That verdict, and nothing else, gates the commit and
fills `TrimReport.converged`. The backend's returned `status` is recorded in
the report as diagnostic data, and it is authoritative over nothing.

#### The tolerance translation, per backend family

The tolerance translation is the service's too, per backend family. In
least-squares backends the tolerances *are* the stopping criterion. They feed
the per-residual test directly, so LM's damping loop tests exactly what the
service will re-test.

The derivative-free scalar fallback is `NLoptBackend(:LN_BOBYQA)` in a package
extension. It passes `nothing` for the Jacobian, keeps today's algorithm one
keyword away, and leaves the framework core carrying zero optimizer
dependencies. For that fallback the service squares *and normalizes*. The
objective minimized is $\sum_i (r_i/\mathit{tol}_i)^2$ with `stopval = 1`.
That objective is dimensionless where FlightCore's threshold was hand-scaled
and absolute ([§14.7][s14-7]). It is a well-scaled valley where a raw
$\|r\|^2$ sums forces against moments.

The two criteria cannot disagree in the dangerous direction:

$$\sum_i (r_i/\mathit{tol}_i)^2 \le 1
\quad\Longrightarrow\quad (r_i/\mathit{tol}_i)^2 \le 1 \;\text{ for every } i$$

so the `stopval` sphere is *inscribed* in the tolerance box, and a fallback
stopping at `stopval` necessarily passes the service's box test. The converse
disagreement, a backend stopping early and reporting an optimistic status, is
caught by the re-check, which remains the single authority. What is *not*
claimed is point identity. Different backends may land on different
solutions, which is an algorithmic difference and a legitimate one. What is
eliminated is per-backend meanings of `converged`.

#### Box bounds and saturated decisions

Box bounds are honored by step projection. A decision variable saturated *at
the solution* is flagged in the report: "converged with `elevator` at its upper
bound". That is the classic CG-limit diagnostic, today inferable only from
mysterious residuals.

#### Scratch stores, stated without type luck

Every `trim!` invocation instantiates a fresh working store set. Each half of
it (below) is a scratch `Model` of its own, materialized from the deployment
the service was called on ([D-317][d-317], [D-319][d-319]). The set holds the
`x` backing, the `s` and `m` stores, the [root input](#g-root-input) and
[signal tables](#g-signal-table), and the derivative [buffer](#g-buffer). The
set is built from the [activation](#g-activation)'s *layout* (the build's typed
products at a given scalar type). The layout is the reusable compiled
artifact. The buffers are per-invocation and die with the call (stopped-sim
allocation, [§9.8][s9-8]). Each set also calls every
[workspace](#g-workspace) allocator once, at the activation's scalar
([D-077][d-077]).

The `Dual` backend's buffers being un-aliasable by type is defense in depth,
not the mechanism. A `Float64` backend (NLopt) gets equally fresh buffers. The
invariant is backend-independent. **The simulation's authoritative stores have
exactly one writer, the commit through [boundary zero](#g-boundary-zero)** (the
initialization boundary: the ordinary macro-sequence with an empty integrate).

Setup applies `override(baseline, condition(guess))` to the scratch set once,
and that application's full coverage is *checked here*. The check is the
comparison of the resolved plan against the `Build`'s `input_faces`
([§14.6][s14-6]), one plan-level comparison before the first evaluation.
[Sweeps](#g-sweep) therefore see a complete world. Raw instantiation is sound
exactly because of that check, since every root input is written before any
read. An incomplete `baseline` is one declaration-ordered
`UninitializedInputs` at setup rather than a whole solve against undefined
[cells](#g-cell).

**The frozen cells are established, not probe-seeded.** At the seeded
activation the discrete [tier](#g-tier) is frozen ([§9.4][s9-4]). Its stages
never run there, so nothing at that activation can derive a discrete output
cell from the authored `s`. Setup therefore instantiates the
[scratch](#g-scratch) set in two halves. A [nominal](#g-nominal) set takes the
composite first, by the dynamic walk ([§14.4][s14-4]), and runs one
establishment round. That round is boundary zero's sweep with every discrete
output stage admitted, due or not ([D-205][d-205]), with no
[projection](#g-projection), no [guards](#g-guard) and no `s_update`. The
seeded set is then written by the specialized `apply!`, and its frozen cells
are copied from the nominal set as zero-partial constants (the embedding of
[§14.3][s14-3]). Every cell the iterations read is thus derived from the
authored world. A frozen cell holds what the authored discrete state
publishes, which makes "held at the operating point" literal. No scratch cell
holds the [probe](#g-probe)'s synthesized values. That is the [§14.6][s14-6]
barrier reaching the scratch world, as [D-205][d-205] made it reach the
published one. The iterations are untouched. They are raw write → sweep → read
cycles at the seeded activation, over the continuous chain and
`x_deriv` alone ([§14.5][s14-5]). The zero-decision problem (below)
is the nominal half alone, and its one evaluation is that establishment round
([D-213][d-213]).

The commit applies the same composite over the same `baseline`
(`override(baseline, condition(d*))`, [§14.9][s14-9]), so its coverage is
setup's. Commit's totality check is therefore structurally unfailable through
the trim path, and it stands as the shared `init!`-[boundary](#g-boundary)
defense. A converged solve is always committable. `TrimReport` therefore
carries no committed flag, and the no-throw doctrine needs no exception.

Iterations rewrite the composite's write-set via the compiled plan. The
write-set is `override(baseline, condition(d))`, the same tree setup resolved,
so a store both layers touch merges exactly as it did at setup. An LM
evaluation is one Dual-seeded sweep yielding `r` (value parts) and `J`
(partials) together. No convergence means no commit. Non-convergence is the
service's box test failing at the returned point, whatever status the backend
attached to it. No commit means the sim is bit-for-bit untouched, including
"never initialized". Today's warn-but-assign is structurally impossible.

The same structure covers an interrupt. Ctrl-C during a long solve unwinds an
ordinary Julia call operating on per-invocation scratch stores. No commit has
happened, and the simulation is bit-for-bit untouched, exactly as a
non-converged solve leaves it. The services need no counterpart to the loop's
boundary masking ([§12.4][s12-4]).

#### The commit, in full

The committed solution is applied as an `init!` in every respect. It is
`override(baseline, solution)` through boundary zero, with the pre-write
[root-input totality](#g-root-input-totality) check ([§14.6][s14-6]), the
sequence ([§14.5][s14-5]) and [guards](#g-guard) at commit.

The `t0` argument that anchors the grid, and its default, are the same for
both init-service entry points ([§14.5][s14-5]). The
[recorders](#g-recorders) restart exactly as [§12.6][s12-6] states for
`init!`. The [trace](#g-trace) and the log are new objects, and any
[batches](#g-batch) still in [staging cells](#g-staging-cell) (where a
device's pending write batch waits between drains) are cleared.

A fresh recording starting at its own anchor is unattended mode's
natural shape. A trim at a point reached by flying is not offered. Trim
takes an authored baseline. Fly-then-retrim is `checkpoint` the flight,
then author the trim's baseline from what the [checkpoint](#g-checkpoint)
(the `Model`'s state at a frame top as one value) shows
([D-273][d-273]).

#### The report, not an exception

`trim!` returns a structured `TrimReport`:

```julia
# what trim! returns: a value to read, never an exception to catch
struct TrimReport
    converged   # the service's box test at the backend's returned point
    …           # the remaining fields, enumerated below; this section
                # does not name them
end
```

Field by field:

- The `converged` flag is the service's own box test at the returned point,
  never a backend's opinion.
- The solution NamedTuple is guess-shaped, hence warm-startable.
- The **solved-point residuals** come with their tolerances. They are the very
  numbers the verdict is read off, gathered at the backend's returned point.
- The **committed-state residuals** are the same residuals re-gathered from
  the boundary-zero world after the commit.
- The **committed-state checks** are the check function's return at the
  committed state, gathered beside the committed-state residuals and empty
  when the problem declares none ([§14.7][s14-7]).
- The backend's returned status comes with its iteration and evaluation
  counts. These are diagnostic throughout, informative about *how* the solve
  went and decisive about nothing.
- The saturated-bounds list.
- The commit's fired events, as component paths and event names. The list is
  empty when boundary zero ran quiet ([§14.5][s14-5]).

The committed-state residuals are nearly free. That boundary's sweep has
already run, so the residuals' declared reads need only gather from it. There
is no offset caveat to carry. Every output stage publishes at boundary zero
([D-205][d-205], [§14.5][s14-5]), so a residual reading an offset
[component](#g-component)'s [port](#g-port) reads a commit-refreshed cell like
any other. Those committed-state residuals are the numbers describing the
state the simulation is actually *in*, which is the point a `linearize` at
its default operating point reads. A non-empty fired-event set also raises
`TrimCommitEvents` ([Appendix C][sC]). The committed stores then sit at the
post-handler point, not the reported solution, and a `linearize` at its
default operating point ([§14.10][s14-10]) reads that point.

The two residual sets are what make the moved point auditable. A converged
solve whose *committed-state* residuals violate the box test raises
`TrimCommitResiduals` ([Appendix C][sC]), naming the offending residuals with
their committed values and tolerances. The move, whether `x_projection` or
a commit-fired handler ([§14.5][s14-5]), is surfaced rather than left silent.
The verdict itself is not re-litigated. It gated the commit, at the solved
point, and the numbers ([D-150][d-150]) stand as reported.

The committed-state checks audit the point rather than the move. A
converged solve whose committed-state checks leave their tolerances raises
`TrimCommitChecks` ([Appendix C][sC]), naming the offending checks with their
committed values and tolerances. The equilibrium is real. The operating
point is not the one the problem asked for, which is what a params-vs-world
atmosphere mismatch produces under elimination ([§14.7][s14-7], [D-139][d-139]). The checks
are gathered from the same boundary-zero sweep, so they cost no evaluation
of their own. No commit means no checks, exactly as for the committed-state
residuals.

Non-convergence never throws. It is an expected *outcome*, per the
exceptions-are-broken-machinery line ([§13][s13]). In an envelope sweep,
hitting the infeasible edge is information. A malformed problem is a different
case. It is a `DiagnosticError`-class failure at setup, `TrimProblemInvalid`
([Appendix C][sC]). The malformed cases are a guess/bounds key-set or
field-type disagreement, an unknown `reads` [selector](#g-selector), a
`tolerances`/residual key-set mismatch observed at the setup guess evaluation,
and a `check_tolerances`/check key-set mismatch observed at the same
evaluation.
The error carries the offending field with the names or types in hand,
collected, and the read set's own `ReadResolution` values beside it
([§14.4][s14-4], [D-406][d-406]). A permuted spelling is
none of these ([§14.7][s14-7]).

A throw inside the commit's boundary zero is a third case, and neither of
those. It is model code failing. It propagates out of `trim!` as the commit's
`StepError`. The simulation is left `built` ([§13.4][s13-4], [D-223][d-223]),
and no report is returned for that solve ([D-224][d-224]).

An *empty* problem is none of them either.
[`TrimProblem`](#g-trimproblem)`(guess = (;), …)` is legal, not
`TrimProblemInvalid`. With zero decision variables the solver is bypassed
outright. There is nothing to pack, no seeded activation and no backend call.
The service simply evaluates the residuals once at the
[baseline](#g-baseline). The ordinary box test decides `converged`, and the
commit runs as usual. The degenerate problem is the "is this operating point
an equilibrium?" probe. It evaluates this condition's equations and reports,
which is useful in its own right and free.

#### The AD obligation, scoped

The default formulation requires `Dual` genericity of exactly the continuous
output-stage chains and `x_deriv`, plus the user's assignment and
residual math. The discrete [tier](#g-tier)'s stages and `s_update`, and
the event system's guards and handlers, never see a `Dual`. They are frozen
constants with zero partials, semantically exact ([§8.2][s8-2]).

This is *not a new obligation*. It is the same activation linearization is
defined on. AD-readiness is also a build-checked property. The Dual probe
detonates [pinned](#g-walked) intermediates with a culprit-naming
`InexactError`, and `build(world; activations)` puts it in CI. The robustness
comes from enforcement, not hope.

C172 migration audit (one afternoon):

- `Interpolations.jl` tables (propeller coefficient maps, engine maps) must
  accept generic scalars. They do. A call `itp(x::Dual)` works through the
  `BSpline`/`scale`/`extrapolate` compositions in Flight.jl's tables. But
  prefer cubic knots over linear where partials matter, since linear knots
  make Jacobian entries piecewise-constant. That is no regression against
  finite differences ([D-307][d-307]). A manual chain rule via
  `Interpolations.gradient` is the escape hatch for anything exotic, and the
  pattern for wrapping non-Julia black boxes ([§14.10][s14-10],
  [D-266][d-266]).
- In-model saturations (actuator limits, idle/FRC clamps) zero Jacobian columns
  when active. LM damping tolerates the rank deficiency, and the report names
  the saturated variable ([D-070][d-070]). Cruise trim leaves those
  saturations inactive.
- The landing gear is never evaluated off-zero airborne.
- `norm`-at-zero guards are already in place (e5efb3a).

The fallback is per problem, through one `backend =` keyword.

### 14.9 Mounting: problems as relocatable values

**What a `TrimProblem` is.** It is not a condition but an **implicitly
specified condition**. `condition` is a condition-*valued function* over the
decision space. `reads`/`residuals` are the equations that pin the free
variables down. `guess`/`bounds` say where to search. Solving makes the
implicit condition explicit. The commit is then literally an init,
`override(baseline, condition(d*))` through [boundary zero](#g-boundary-zero)
(the initialization boundary: the ordinary macro-sequence with an empty
integrate). The services unify as clients of one condition algebra. `init!`
applies an explicit condition, and `trim!` searches a family for the member
satisfying its equations.

**`at` lifts a problem field by field, and each field falls in one of three
cases.** The `condition` field is condition-producing (path-relative), so the
lift post-composes it. The `reads` field is a read set, and the lift prepends
the prefix to the set's mount chain. Every other field is path-free and passes
through. The rule that residual math sees only the gathered NamedTuple
([§14.7][s14-7]) pays off here.

```julia
at(prefix::String, p::TrimProblem) = TrimProblem(
    guess      = p.guess,                      #path-free: pass through
    lower      = p.lower,
    upper      = p.upper,
    condition  = d -> at(prefix, p.condition(d)),  #post-compose: wrap each returned tree
    reads      = at(prefix, p.reads),              #inert selector data: the prefix joins the read set's mount chain
    residuals  = p.residuals,                      #path-free: pass through
    tolerances = p.tolerances,
    checks     = p.checks,
    check_tolerances = p.check_tolerances)
```

The condition side needs nothing new at resolution. The flattening
accumulator of [§14.3][s14-3] enters each `Scoped` wrapper and prefixes every
entry below it.

**Rule.** A read set carries its mount chain as data. `at(prefix, read_set)`
prepends the prefix to that chain and joins nothing. A `Reads` value is no
condition node, so `Scoped` never wraps one. Resolution walks the chain from
the root, each prefix from the level the previous one reached
([§13.3][s13-3]). It then rebases every [selector](#g-selector) (one of the
closed family of deferred reads) to the root before the selector resolves. A
path selector's path is joined to the mount (`"vehicle/dynamics"` →
`"wing/vehicle/dynamics"`). `get_input` names an input [face](#g-face) (the
name a port wears on its component's boundary) of the mount level. It follows
the export chain to the [root input](#g-root-input) it lands on. `get_face`
names an output face of the mount level and reads its producer's port
([D-277][d-277]). A refusal spells the selector as authored and names the
mount. `at` refuses an empty prefix on a read set, as it does on a condition
node ([§14.2][s14-2]), and raises `ReadSetMisuse`. A problem's lift and a tap
set's lift reach that refusal through `at` on their read sets ([D-278][d-278]).

Root input entries authored in the aircraft's face vocabulary resolve through
the export chain *from the mount point* (`throttle` at `"wing"` → root input
`"wing.throttle"`). An unexported face fails
resolution by name, and correctly so. An internally wired input (a
[scenario component](#g-scenario-component) driving the wingman's throttle) is
untrimmable from outside, and the build says so. The service compiles the
scoped condition and reads, and runs the identical loop. It never knows where
its paths are mounted.

**A problem never authors the environment.** The environment is the world's
and the `baseline`'s business. In a full world it is a sibling
[component](#g-component)'s root inputs. In a thin rig it is a root input
holding an isbits handle, or a [constant source](#g-constant-source) holding a
bulk-data one ([D-364][d-364]). The problem *receives* its handles through the user
parameter record ([§14.7][s14-7]), and only queries them.

**Why.** The reason is the resolution rule just stated. A condition entry
naming an internally wired input fails by name, correctly. A problem writing
an environment face would therefore be applicable only to those rigs where
that face happens to be unconnected. The relocatability this section exists to
guarantee would be lost.

**The world wrapper dissolves.** Flight.jl's `f_init!(::Model{<:SimpleWorld})`
(initialize environment, then call the aircraft's trim) has no successor
method. The environment, the other aircraft and all root inputs are covered by
the `baseline` condition ([§14.6][s14-6]), applied once at setup. The commit
is `override(baseline, at(mount, condition(d*)))`. Method nesting became value
layering.

**"Aircraft as root" is a thin world.** By default the aircraft is not
literally the root. Its environment inputs ([§4.4][s4-4] function-valued
signals) are wired from provider components. Design tasks therefore use a
shipped rig, `design_world(ac)` = aircraft +
`SimpleAtmosphere(wind = NoWind())` + `HorizontalTerrain`. That rig is today's
ad-hoc models inside `linearize` promoted to a named artifact. There is one
mechanism. The "root" case is the shallowest world, and the trim problem mounts
at `"aircraft"` like anywhere else. Leaving an environment face *unconnected*
is legal by construction, though, for an isbits handle. The face becomes an
ordinary root input holding the handle **value**, written by the `baseline`
like any other root input. That is the test-rig idiom. It is the
function-valued sibling of a constant source (a library component publishing
a value its instance holds), with zero ceremony for a frozen environment.
**A handle that references bulk data is never a root input. The rig wires a
constant source holding it** ([D-364][d-364]). Root inputs are traced and
checkpointed by value, and such a handle can be neither recorded faithfully nor
kept frozen when a writer supplies it ([§4.4][s4-4], [D-237][d-237]). For design
tasks the shipped rig stays `design_world(ac)`. That keeps the environment's
tunables in the root-input vocabulary that conditions, linearization's
input surface and the [trace header](#g-trace-header) already speak.

**Swarm doctrine.** The service solves *one problem at a time*. Sequential
independent trims (trim lead, commit, trim wing against the committed world)
cover weak or one-way coupling. A joint trim is user-side value composition.
Concatenate decision NamedTuples under prefixed names, combine the scoped
condition trees, and stack the residuals. If joint trims become routine, a
`product(p₁ => "lead", p₂ => "wing")` helper belongs in the [§13.7][s13-7]
library. That helper is [recorded, not built](#g-recorded-not-built) (a
worked-out extension deliberately left unimplemented, its seams named).

### 14.10 Linearization: tap selectors, one seeded pass, a pure query

**The tap declaration.** Today's per-aircraft
`XStateSpace`/`UStateSpace`/`YStateSpace` structs, plus the
`get_*_ss`/`assign_*_ss!` shuttle methods, run to ~150 lines of bookkeeping
per variant. All of it becomes three [selector](#g-selector) lists (the closed
family of deferred reads resolving against a source), declared together as
one tap set, `taps(x = …, u = …, y = …)` ([D-272][d-272]). Membership is closed per
list. The `x` list takes `get_state`, the `u` list `get_input`, and the `y`
list `get_output` and `get_face` ([§14.4][s14-4]). The NamedTuple key is the
label control design slices by.

**Rule.** A tap names one scalar. Its [leaf address](#g-leaf-address) (the
field name with dotted and bracketed steps below it, [§14.4][s14-4], [D-276][d-276])
resolves to one scalar leaf, so a vector leaf yields *named scalars*, one
tap per [component](#g-component). A tap resolving to a vector or a bundle is
rejected at resolution, and so is a member in the wrong list. Two
taps resolving to one site are rejected together, both labels in hand: one
site is one column, and a second seed there would overwrite the first
([D-272][d-272]).

```julia
taps(x = (p = get_state("vehicle/dynamics", "ω_eb_b[1]"),
          θ = get_state("vehicle/kinematics", :θ_nb), …),
     u = (throttle_cmd = get_input(:throttle),
          wind_n = get_input("wind[1]"), …),
     y = (EAS = get_output("vehicle/airflow", :EAS), …))
```

The three lists are validated at resolution, with
[did-you-mean](#g-did-you-mean) errors (the offending name plus the
list-in-hand it should have matched). The `x` list is validated against the
continuous tier's `x_init` stores, the `u` list against [faces](#g-face), and
the `y` list against `y_types`. An `x` entry naming a discrete store is
rejected at resolution with the entry and its tier in hand. That is the
no-silent-zeros rule again ([D-167][d-167], [D-197][d-197]). The frozen tier's
only possible partials are zeros, and the rejection's next-move guidance
points at the recorded step-map extension below. The lists compile to offsets
once, and relocate whole via `at(prefix, taps)`. The shuttle layer's successor
is that compiled writer/reader pair, and the promised `get_x_ss` deletion
([§7.1][s7-1]) is discharged.

**The evaluation.** Each invocation instantiates its own scratch store set, the
trim service's mechanism verbatim ([§14.8][s14-8]), and establishes the
operating point in it (below). It then runs the seeded Dual evaluation, one
direction per `x`-tap and per `u`-tap entry, in groups of `width` directions
per pass. **Rule.** `width` is a keyword of `linearize`, default 8, and the
default width's scalar type is public, so a build can pre-materialize its
activation through `activations` ([§9.4][s9-4]) and a tap set of any size
then linearizes with no compile at the keyboard ([D-272][d-272]). Value
parts give `ẋ₀` and `y₀`. Partials give `A` and `B` against the `x`- and
`u`-seeds, and `C` and `D` against the same seeds read at `y`. All four come
out simultaneously, exact to machine precision. `linearization_walkthrough.md`
runs the pass on a two-state model, seed by seed.

```
  x-taps ─┐                                         ┌─ value parts → ẋ₀, y₀
          ├─ seed directions → one Dual evaluation ─┤
  u-taps ─┘          (chunked internally)           └─ partials    → A, B, C, D
```

That seeded evaluation replaces four `FiniteDiff` jacobians, their step-size
heuristics and ~4n perturbed evaluations.

**What the pass seeds, and what it holds frozen.** Unseeded states sit
constant at the operating point, and so do unseeded
[root inputs](#g-root-input). Establishing the operating point embeds their
`Float64` values as zero-partial constants. A root-input [cell](#g-cell)
follows the [activation](#g-activation) scalar (the build's typed products at a given
scalar type) by *walking* its consuming `u_types` entry at that scalar
([§8.2][s8-2]). The discrete [tier](#g-tier) is frozen with zero partials,
which is precisely "linearize with the discrete state held" ([§8.2][s8-2]).
Differentiation participation is a per-invocation *seeding* fact for every
root input the schema leaves seedable, one rule for `x` and root inputs
alike. One declared exception is visible in the schema. A root input whose
entry is declared `Pinned` is **declaredly unseedable**, and its cell is
frozen at every activation. Selecting it as a `B`-matrix tap is therefore
rejected at tap resolution with the offending entry in hand, rather than
silently yielding a zero column ([D-167][d-167]). Under fan-out the rejection
names the **pinning consumer**, not the face alone. A root input is unseedable
whenever any one of its consumers demands frozen, which is the fan-out meet
([§8.2][s8-2]; [D-168][d-168]). The author's next move is to promote that leaf
to a tolerant entry, or to route the tap around it. Either move depends on
knowing which leaf froze the root input. A discrete consumer pins its entry
by tier, not by declaration ([§8.2][s8-2]), so a root input it reads is
unseedable at every activation with nothing to promote. The rejection then
names the tier, and the next move is to tap the continuous cell that
consumer drives, or the recorded step map below ([D-272][d-272]). Seeded and frozen,
side by side:

| leaf | in the one pass | what fixes it |
|---|---|---|
| a state leaf named by an `x` tap | seeded, one direction | per-invocation seeding |
| any other state leaf | sits constant at the operating point | per-invocation seeding |
| a root input named by a `u` tap | seeded, one direction | per-invocation seeding |
| any other seedable root input | constant, its `Float64` value embedded as a zero-partial constant | per-invocation seeding |
| a root input whose entry is declared `Pinned` | frozen at every activation, and rejected as a `B`-matrix tap | the schema: a declaration |
| a root input a discrete consumer reads | frozen at every activation, and rejected as a `B`-matrix tap | the tier |
| any discrete-tier leaf | frozen, zero partials | the tier |

**A pure query, and the default operating point.** Linearization is the
first service with no commit and no [boundary zero](#g-boundary-zero) (the
initialization boundary: the ordinary macro-sequence with an empty integrate).
It works on scratch buffers only, and nothing it computes becomes
authoritative. Flight.jl's restore-the-trim dance, the re-`assign!` after
`FiniteDiff` dirtied the model, has no successor. The default operating point
is the [checkpoint](#g-checkpoint) (the `Model`'s state at a frame top as
one value) of the simulation or the model as it stands. It is
`checkpoint(sim)` on a simulation and `checkpoint(model)` on a
[`Model`](#g-model) (a deployment materialized at one scalar type), each
restored into the scratch world with no boundary zero ([§12.6][s12-6],
[D-274][d-274], [D-319][d-319]). The frozen tier's cells are the checkpoint's held cells.
After a `trim!` commit, `linearize(sim, taps)` or `linearize(model, taps)` is
about the trim point with nothing re-specified. `about = <condition>`,
with `t0` beside it as in `trim!`, linearizes anywhere else without
touching the sim.

**The returned object and `LinearizedSS`.** `linearize` returns a
`Linearization` value: `ẋ₀`, `x₀`, `u₀` and `y₀` as NamedTuples under the tap
labels, `A`, `B`, `C` and `D` as matrices, and the three label sets of the
[taps](#g-taps) (the three selector lists declaring what linearization seeds
and reports) ([D-272][d-272]). On that data, `subsystem`/`delete_vars` survive as pure
label-indexed matrix slicing, with no model involvement. The `c172x_ctl` LQR
pipeline consumes it with cosmetic changes. `LinearizedSS` the *component*
survives separately, as an ordinary
[continuous component](#g-continuous-component) in the migrated library. Its
`x_init` is the state vector, its faces are labeled, and the affine update
lives in `y_direct`/`x_deriv`. It has no privileges, and its
schema is everyone else's.

**Recorded guidance.** Linearization taps should select minimal-coordinate
mechanizations. Perturbing Euler-angle states is meaningful where seeding
quaternion components steps off the unit-norm manifold. This is why today's
code linearizes the `{NED}` variant. `design_world(ac)` rigs that variant,
promoting implicit practice to stated rule. The coordinate choice belongs to
the tap author, not the framework.

**The sampled-data Dual activation is
[recorded, not built](#g-recorded-not-built)** (a worked-out extension
deliberately left unimplemented, its seams named). The frozen-exact doctrine is
consumer-scoped, not a capability wall. Today's services differentiate the
continuous dynamics with the discrete state held. For that, a frozen discrete
output (a ZOH constant with zero partials) is the exact answer. The type
system enforces it ([§8.2][s8-2]). This is stated once, because the question
recurs. **The frozen discrete cell is not an AD limitation on the signal path.
It is the true zero of an instantaneous dependence that the hybrid semantics
never had.** The signal flow through a discrete component is temporal, not
instantaneous, and AD follows the actual data movement.
`frozen_discrete_walkthrough.md` works the three-component chain through.

Differentiating "through" the discrete side means differentiating a
*different object*. That object is the sampled-data step map
$\Phi : ((x_k, s_k), \mathrm{inputs}) \to (x_{k+1}, s_{k+1})$, taken over the
model's *whole* state, both letters at once. One evaluation of $\Phi$
integrates one period, then runs the [due](#g-due) [ticks](#g-tick). The
extension is additive along existing [seams](#g-seam).

- **[Walked](#g-walked)-leaf parametrization** of the discrete tier's
  real-scalar state leaves. Counters and enums stay [pinned](#g-walked), like
  `m`.
- **Opt-in participation** on discrete components, with frozen-exact staying
  the default. A participating component opts in through an explicit trait,
  and that trait **turns the walk on for its contracts**. Its `Float64`
  leaves follow the scalar and `Pinned` keeps its meaning, exactly as on the
  continuous tier ([§8.2][s8-2]). Participation therefore stays authored per
  leaf on that tier too, and no declaration changes shape, which gives
  graceful migration with no flag day.
- **One new activation** ([§9.4][s9-4]): "continuous chain + `x_deriv`
  + the discrete tier's output stages + `s_update`".
- **Forward sensitivities** through the in-house RK steppers, for free. That
  is a payoff of owning the loop ([§10.1][s10-1]).
- **A distinct `s`-tap list** beside the `x` list, labeling the step map's
  state blocks $\partial(x^+, s^+)/\partial(x, s)$ ([D-197][d-197]). The `x`
  list keeps its continuous meaning unchanged.

The honest boundary is that $\Phi$ is differentiable only where the event
pattern is locally constant. Exactness across a firing needs saltation
corrections. The scope is therefore event-quiescent operating points, which
trim points already are, because [guards](#g-guard) at commit see to that
([§14.5][s14-5]). The scope comes with a loud diagnostic if an event fires
inside a differentiated step. Two consumers wait. The first is the closed-loop
trim door ([§14.7][s14-7]), whose $g(s) - s = 0$ residuals currently imply the
derivative-free fallback, since a frozen `s_update` has no Jacobian
columns. The second is exact discrete-time linearization of the full loop,
which is digital design on the exact discretized plant instead of continuous
linearization plus Tustin.

**Declarative non-participation: what the schema states, and what stays
recorded.** **Both halves of this door have a spelling.** The output half is
[D-263][d-263]. A continuous producer's declaration is per-leaf, so "this
[port](#g-port) is frozen under differentiation" has a spelling. Declare the
leaf `Pinned{Float64}`, and strip with `ForwardDiff.value` inside the stage
([§8.2][s8-2], [§9.5][s9-5]). An opaque wrapper (an FMU, a C aerodynamic
table) and a deliberately severed coupling can therefore both say so in the
schema, instead of showing up in Jacobians as unexplained zero rows. The
conformance check holds them to it at every activation.

The input half is [D-167][d-167]. A consumer's entries are per-leaf too, so a
`Pinned` entry declares "never hand me partials". That is the AD-incompatible
component's own statement, enforced at the wire ([§6.1][s6-1]). At a root
input, such an entry *is* the forbid-seeding marker itself. That marker
carries semantics rather than mere protection, because it types the
root-input cell at every activation. An unseeded root input is therefore a
*choice*, where a `Pinned`-entry root input is a *declaration*. Tap
resolution rejects the latter with the offending entry in hand instead of
returning a silent zero column.

**An implementation that cannot take `Dual`s has a third move.** The marker
records that a leaf carries no partials, not that an implementation cannot
propagate them. A component that must participate, a C table or an FMU whose
coupling matters to the Jacobian, keeps its entry tolerant and supplies its
own local derivative inside the stage. It evaluates at the value, obtains a
local Jacobian by whatever means it has, a finite difference at a step its
own grid suggests or the table's analytic slope, and chains it onto the
incoming partials ([D-266][d-266]):

```julia
lookup(tb, u::Float64) = c_lookup(tb, u)                      # nominal: straight to the table

function lookup(tb, u::ForwardDiff.Dual{Tag}) where {Tag}      # Dual: the local rule
    u0 = ForwardDiff.value(u)
    y0 = c_lookup(tb, u0)
    h  = sqrt(eps(u0))                                         # or a step the table's grid suggests
    dy = (c_lookup(tb, u0 + h) - y0) / h
    return ForwardDiff.Dual{Tag}(y0, dy * ForwardDiff.partials(u))
end
```

The stripping happens mid-expression, which [§9.5][s9-5] leaves legal at an
unpinned leaf, and the seeded pass sees the component as an ordinary
differentiable one. The derivative is finite-difference in quality on this
one component and exact everywhere else. Linearization keeps this one
mechanism and no perturbation-based fallback ([D-266][d-266]). The derivative-free
trim fallback ([§14.8][s14-8]) exists for problems with no Jacobian columns, a
case linearization does not have. `handle_walk_walkthrough.md` places the
rule beside the `Freeze` block ([§13.7][s13-7]) and the pinned entry.

What stays recorded is only the remaining **tooling** over that visibility.
One piece is pinned-face validation by the tap declaration, where selecting a
declared-frozen output is a warning. The other is a
[feedthrough](#g-feedthrough)-graph lint, where a frozen output fed by
participating inputs names the severed coupling. Both are additive when a
consumer shows up, with no flag day. Until then the declared pins and the
visible zero rows suffice.

---


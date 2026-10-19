## 14. Stopped-sim services

[§9.6][s9-6] previewed trim and linearization as clients of an
[activation](#g-activation) (the build's typed products at a given scalar
type). The stopped-sim services
are initialization, trim, linearization, and `checkpoint` with its partner
`restore!`. The first three share one artifact, the
[condition](#g-condition). A condition is the datum that says "set this build
to this state." `checkpoint` returns a [checkpoint](#g-checkpoint) (the
[`Model`](#g-model)'s state at a frame top as one value), and `restore!` puts
it back. A checkpoint is a distinct value with no condition algebra
([D-273][d-273]). [§14.1][s14-1] settles the condition's representation,
[§14.2][s14-2] its composition, [§14.3][s14-3] its resolution and
[§14.4][s14-4] its application; [§14.5][s14-5] covers the
[boundary-zero](#g-boundary-zero) sequence; [§14.6][s14-6] covers
[root-input totality](#g-root-input-totality) (the requirement that an
application establishing a complete world cover every
[root input](#g-root-input)); [§14.7][s14-7] the trim problem,
[§14.8][s14-8] the trim service and [§14.9][s14-9] mounting, which together
cover the trim service in full; and [§14.10][s14-10] covers linearization.

#### Lifecycle preconditions

**Every service requires a non-running simulation** ([D-108][d-108]). While a
run exists the loop owns the [stores](#g-store) between [drains](#g-drain)
(the frame-top swap that publishes staged device writes into the root inputs),
and a service reading or writing them would race it. Pause is no exception,
by the doctrine that freezes the [roster](#g-roster) (the list of attached
devices, read once at `run!`). Pause is a [control-plane](#g-control-plane)
state *inside* a run, so a prohibition that holds mid-run holds while paused
([§11.3][s11-3], [§12.1][s12-1]).

**Within the stopped-sim states, legality follows each service's inputs**
([D-108][d-108]).

| service | `built` | `initialized` | `stopped` | its inputs |
|---|---|---|---|---|
| `checkpoint` | error | legal | legal | a frame-top rest; refused after a `t*` stop and after an abandoned frame |
| `init!` | legal | legal | legal | authored conditions |
| `restore!` | legal | legal | legal | a checkpoint whose fingerprint and deployment match the simulation's and whose `t` sits on its grid ([§12.6][s12-6]) |
| `trim!` | legal | legal | legal | authored conditions; the scratch world is [`override`](#g-override)`(baseline, condition(guess))` ([§14.8][s14-8]), never the sim's stores |
| `linearize`, operating point defaulted to `checkpoint(sim)` | error | legal | legal | inherits `checkpoint`'s precondition, its refusals included |
| `linearize`, explicit `about` ([§14.10][s14-10]) | legal | legal | legal | inherits `init!`'s legality, legal wherever `init!` is |

No service accepts an `errored` simulation ([§12.6][s12-6], [D-108][d-108]).
Post-mortem inspection of an errored sim's stores, log and
[trace](#g-trace) (the primary record of a session) stays available as a
diagnostic read ([D-232][d-232]). It may not become a checkpoint
([D-108][d-108], [D-274][d-274]).

A violation is `ServiceLifecycle` ([Appendix C][sC], [D-108][d-108]). Its
payload is the operation, the current status and the legal statuses. It is the
same kind `attach!`/`detach!` raise while `running` ([§11.3][s11-3]), so there
is one error form for "this operation is illegal in the current lifecycle
state." `MissingInit` is distinct, and names a missing prior step. The
`checkpoint` row's two refusals, after a `t*` stop and after an abandoned
frame, are `CheckpointMidFrame` ([§12.6][s12-6], [Appendix C][sC]).

**Each row's service also has a form on a `Model`** (a deployment materialized
at one scalar type), gated by the model's status rather than by the lifecycle
([D-319][d-319]). `checkpoint` and the default `linearize` are legal at
`:consistent`. `init!`, `restore!`, `trim!` and `linearize` with an explicit
`about` are legal at any status. A model a simulation has claimed refuses each
form that writes, `init!`, `restore!` and `trim!`, as `ArgumentInvalid` with
reason `:claimed` ([D-318][d-318]).

### 14.1 Conditions are path-addressed overlays on the declared defaults

This section covers, in order, what a condition may specify, the overlay base,
why addressing a condition by path is legitimate, the pre-sweep doctrine and
the environment queries a condition may make.

A [condition](#g-condition) may specify state fields, `x` on the continuous
[tier](#g-tier) and `s` on the discrete. It may also specify modes, `m`, which
only [continuous components](#g-continuous-component) have ([§3.2][s3-2]). All
three are addressed by a slash path ([§8.6][s8-6]) plus a field name. Beyond
state, a condition may specify [root inputs](#g-root-input), addressed by
[face](#g-face) (the name a port wears on its component's boundary).
**It never specifies outputs**, which are derived data ([D-063][d-063]). It
never specifies [workspace](#g-workspace) (component-declared mutable scratch
arriving as the `ws` bundle field) ([D-306][d-306]). Condition entries are
validated in the collecting form ([§13.1][s13-1]). The full list is checked,
violations are collected, and one `DiagnosticError` is thrown. A condition
entry naming an output or a workspace field is one such violation,
`ConditionResolution` with reason `:undeclared_field` ([Appendix C][sC]).

**The overlay base is always the declared defaults** ([D-063][d-063]). Every
[store](#g-store) (the framework-owned home of a component's `x`, `s` or `m`
state) has a declared initial value under declaration-by-initial-value
([§8.2][s8-2]), so conditions are naturally sparse. Applying one means "fresh
run from the `x_init`, `s_init` and `m_init` defaults, with these overrides"
([D-063][d-063]). **A condition is an initial condition and nothing else**
([D-273][d-273]). A simulation's state past its initial instant is a
[checkpoint](#g-checkpoint) (the `Model`'s state at a frame top as one value),
not a condition, and it has no algebra ([D-274][d-274]).

Addressing conditions by path does not reopen the observation-by-path
rejection ([§13.5][s13-5], [D-409][d-409]). That rejection bars a run from
acting on reads its model did not declare. A condition is not such a read. It
is a *design-time statement about a concrete build*, written before the run
begins, and the locality law of [§14.2][s14-2] is how an author keeps it to
children the author owns.

**A would-be init value that depends on swept outputs is either analytically
known to the caller or an equilibrium constraint** ([D-064][d-064]). This is
the pre-sweep doctrine, and it holds because condition writes precede the
first [sweep](#g-sweep) (one pass through the execution order against the
current state) by definition. The first case is trim's `α_filt = α_a`. There
α is a *decision variable*, so the value is known above, not computable below.
The second case is a job for the trim service, not for init.

**"Caller-computable" reaches past closed-form knowledge to environment
queries** ([D-139][d-139]). A condition needing one constructs the same handle
the sweep will produce, and then calls the same query function the consuming
component calls. There are two routes to that handle. One is the
[value-level constructor](#g-value-level-constructor) (the plain public
function building a field handle from the component and input values) of
[§8.2][s8-2], applied to the same values the [`baseline`](#g-baseline) writes
into the environment [component](#g-component)'s root inputs. The other
applies in a rig where an isbits handle itself is a root-input value
([§4.4][s4-4], [D-364][d-364]). There the condition simply holds the value the
`baseline` wrote. Either way there is one implementation of the field math,
evaluated one level up, with no pre-sweep and no new mechanism. Where
closed-form enforcement of a target is not wanted at all, the second escape
already covers the case ([D-139][d-139]). Promote the eliminated state
coordinates to decision variables and enforce the targets as residuals on
swept outputs. That route needs no environment access at condition time
whatsoever.

### 14.2 Fragment composition: locality without schema

Init knowledge is [component](#g-component)-local. An engine component knows
`n_eng → ω = n_eng·ω_rated`, and nothing above it should have to. Making that
locality a schema entry was rejected ([D-064][d-064]). That spelling would
declare `initialize(::C, spec)`, a declarative rebirth of `f_init!`,
FlightCore's per-model initialization hook. It would also add an
[assembly](#g-assembly)-level rule routing sub-specs to children. This section
covers, in order, the condition method, composition by pull, what `set`'s
payloads may name, the inert tree, the empty-prefix refusal, the locality law,
and the collision and blend errors.

**What preserves the locality is an idiom, not schema** ([D-064][d-064]). It
is the [condition](#g-condition) method, a method of the framework's
`condition` generic, shipped beside the component and dispatched on the
component, returning the component's own [fragment](#g-fragment) (the leaf
node of the condition algebra, built by `set`) ([D-405][d-405]). The generic
is framework-owned so that an owner's pull, described below, reaches a
child's fragment when the two live in different packages. A model package
extends it through `import Redstone: condition`, as it extends the declaration
family ([§8.1][s8-1]). No shadowing check covers it, because a method written
to a foreign `condition` fails loudly at the owner's pull, as a `MethodError`
naming the child ([D-316][d-316]). In the first block, the engine is an
illustrative component named after FlightPhysics' `PistonEngine`, and `Phase`
an illustrative enum of its modes.

```julia
condition(eng::PistonEngine; n_eng) =
    set(x = (ω = n_eng * eng.ω_rated,), m = (phase = Phase.running,))
```

Fragments are composed by *pull* from the structure's owner, here
`C172XSystems` (the C172X aircraft's systems assembly, after FlightApps'
`C172X.Systems`).

```julia
condition(sys::C172XSystems; n_eng, α_a, β_a) = combine(
    at("pwp/engine", condition(sys.pwp.engine; n_eng)),
    at("aero",       set(x = (α_filt = α_a, β_filt = β_a))))
```

`set`'s payloads speak only about the component at the authoring point.
Addressing children is exclusively the job of [`at`](#g-at) (the scoping
combinator), so there is one way to say everything. A `u` payload names faces
*of the authoring level's [contract](#g-contract)*. **Resolution walks the
export chain to the root input** and errors if the face never surfaces
([D-065][d-065]), as `ConditionResolution` with reason `:no_input_face`, or
`:unexported_face` at the root ([Appendix C][sC]). That walk always has a name
to follow. One-level routing gives every level a declared face for every
signal crossing its boundary, so the chain a sub-assembly's face routes
through is in the `Build` ([§6.1][s6-1], [§9.2][s9-2], [D-207][d-207]). An
internally-wired input has no root input behind it, and writing it would be
meaningless because the first sweep overwrites it. Such a write is
`ConditionResolution` with reason `:internally_wired`. Unexported stays
unpokeable for init exactly as it is for a front end's panels
([§11.7][s11-7]).

Dispatch selects variant-specific methods, so the actuation split between
FlightApps' C172 variants, c172s and c172x, costs no upstream edits.

**Composition builds an inert, lazy [fragment tree](#g-fragment-tree)**
([D-065][d-065]). `set` builds the leaf, `at` and [`combine`](#g-combine)
(the symmetric, collision-intolerant combinator) build the tree's inner nodes,
and `override` builds a fourth node type ([§14.6][s14-6]). No path arithmetic
happens at composition.

```julia
struct Fragment{X,S,M,L}  x::X; s::S; m::M; u::L  end      #set(; x, s, m, u): self-vocabulary payloads; no paths
struct Scoped{N}  prefix::String; node::N  end             #at(prefix, node): stores, never applies
struct Combined{T<:Tuple}  nodes::T  end                   #combine(ns...): collects; order = diagnostics only
```

Every node is isbits except the prefix strings, and a prefix is a reference to
the author's own literal. So, with literal prefixes, rebuilding the tree per
trim iteration allocates nothing. There is no path arithmetic and no copy of
the payloads. Composition checks three things, each by type or length alone,
and none allocates. Each `set` payload is a NamedTuple, each combinator
operand is a node, and each `at` prefix is nonempty. A `set` payload that is
not a NamedTuple is `ConditionNodeMisuse` with reason `:set_payload`
([Appendix C][sC]). The trim of Flight.jl's Cessna 172 model (`c172.jl`)
writes each trial state through FlightPhysics' `assign!`, and the zero-alloc
property of that `assign!` loop holds of the construction with literal
prefixes and of the specialized `apply!` that writes the tree ([§14.4][s14-4])
alike. An evaluation's cost is therefore the sweep it
feeds.

**`at` refuses an empty prefix when it is called** ([D-278][d-278]). An empty
prefix names no child, and a node meant for the level where it is authored
stays unwrapped. The refusal holds at the root too, because `at` builds an
inert tree and cannot know where it will be mounted. On a condition node it
raises `ConditionNodeMisuse` with reason `:empty_prefix` ([Appendix C][sC])
before any resolution pass runs. The read side's lifts refuse the same way
([§14.9][s14-9], [D-278][d-278]).

**The locality law here is the one [§6.1][s6-1] states for connections**, now
in its third instance ([D-065][d-065]). The three instances are
[local wires](#g-local-wire), computed interface connections and conditions.
Each level speaks its own fields, its declared children's names, and its own
faces. Delegation runs by dispatch at every genericity [seam](#g-seam). An
`at` prefix may stop at *any* child's faces, owned or
[generically held](#g-generic-holding), because the face graph is total
([D-207][d-207]). A deep `at` or condition path resolves wherever the
structure has it ([§13.3][s13-3], [D-414][d-414]). Absolute paths exist only
in the flattened list of condition entries, a *compiled derivative* of the
composition, as [cell](#g-cell) offsets are of `local_wires`. Under the
locality law, substituting a component invalidates only the fragments its
owner shipped. The build checks the law wherever it can see what the law
constrains. Wiring resolves one level ([§6.1][s6-1]). The faces a `u` payload
names resolve through the export chain, under any `at` prefix
([D-207][d-207]). No check refuses a deep path past a generically held field
([D-414][d-414]). An author who ships a fragment for a family scopes it by
dispatch on the holding's type parameter, so a fragment reaching into one
powerplant is defined for the aircraft that hold that powerplant
([D-414][d-414]). Ownership alone is convention. It is a fact about who
maintains the code, and the build cannot see it, so keeping a deep path inside
an owned subtree is idiomatic rather than machine-checked ([D-065][d-065]).
`set`, `at` and `combine` are ordinary functions with no privileges, as the
blocks of [§13.7][s13-7] are ordinary components.

A `combine` collision is two condition entries on one leaf. **Collisions are
errors at resolution** ([D-065][d-065]). The error is `DuplicateConditionLeaf`
([Appendix C][sC]), and it reports *both* origins. Its message names the
layering combinator. It reads "`combine` is collision-intolerant by design — use
`override(base, patch)` to layer." Last-writer-wins was rejected
([D-065][d-065]). That rejection is also why **the combinator is not
`Base.merge`**, and is no longer named after it ([D-204][d-204]). `Base.merge`
is last-wins on NamedTuples, the exact semantics rejected here, and its own
name should not promise them. Because `combine` is its own function, a bare
NamedTuple blended into a node cannot fall through to any last-wins method.

The blend is still closed explicitly. A `combine(::Fragment, ::NamedTuple)`,
or any other blend of a condition node with a bare NamedTuple, is an error
method. Its message is directive. It says to wrap the NamedTuple in `set(…)`
(or `at(prefix, set(…))`) and to combine nodes with nodes. The rejection
carries a [kind](#g-kind) like every other. **It is `ConditionNodeMisuse`**
([Appendix C][sC], [D-113][d-113]), carrying the offending argument's type and
the node types in hand. It is raised at composition time, before any
resolution pass runs or any origin exists. That is why it is its own kind and
not a `ConditionResolution` sub-kind ([§14.3][s14-3]). The explicit,
*ordered* layering spelling, [`override`](#g-override), belongs with the use
case [root-input totality](#g-root-input-totality) produces ([§14.6][s14-6]).

### 14.3 Resolution: flatten, validate, compile once

Resolution takes the root node plus a [`Build`](#g-build) (the artifact
`build(world)` produces). This section covers, in order, flattening, the
collecting checks, the two lookup families, the plan, the converter rule with
its two cases, and overlay partiality.

**Flattening is the only place path strings are ever concatenated**
([D-065][d-065]). It is a trivial recursion with a path accumulator, and it
also records each [condition](#g-condition) entry's tree position, its
`getfield`/`getindex` step tuple.

The collecting pass then checks each flat condition entry:

- the path resolves, with [did-you-mean](#g-did-you-mean) (the offending name
  plus the list-in-hand it should have matched) over children;
- the field is declared in the target's `x_init`/`s_init`/`m_init`;
- the value type is convertible to the declared leaf type;
- input [faces](#g-face) reach [root inputs](#g-root-input);
- no leaf is written twice, where a `u` payload's leaf is the root input its
  face resolves to.

Each check names its kind ([Appendix C][sC]). A path that does not resolve is
`PathResolution` with reason `:unknown_child`. An undeclared field is
`ConditionResolution` with reason `:undeclared_field`, or `:no_store` or
`:assembly_path` where the target has no such store or is an assembly. A
value that does not convert is `ConditionResolution` with reason
`:unconvertible`. A face that reaches no root input takes one of the face
reasons [§14.2][s14-2] names. A leaf written twice is `DuplicateConditionLeaf`.

The `Build` supplies two lookup families.
[Schema](#g-schema-vs-layout) is the evaluated declarations, and it is the
authority. It answers whether you may write this field, and at what leaf
type. Layout is the destination. It holds the `x` backing ranges, the store
indices for `s` and for `m`, and the root-input indices from the
[activation](#g-activation) (the build's typed products at a given scalar
type). The face chains come from [`Structure`](#g-structure) (the structure
step's product, the components, wires, faces and tiers), never from an
activation's typing; the names a declaration evaluates to are the same at
every activation ([§9.1][s9-1], [D-253][d-253]).

A valid list of condition entries compiles two ways ([§14.4][s14-4]). The
specialized `apply!`'s plan holds, per leaf, a [lens](#g-lens) (the compiled
navigation step of a condition entry), a destination and a converter. The
dynamic walk's plan holds the converted values themselves. The lens is the
position tuple lifted to a type parameter, so navigation of the fixed tree
type is type-stable.

**The converter is baked now, selected per leaf from that leaf's type in the
resolved shape** ([D-065][d-065], [D-148][d-148]). Leaf types are shape facts,
carried by the tree type along with the full nesting and every field name
([§14.4][s14-4]). Selection therefore consults no runtime fact and stays a
resolution-time bake.

There are two cases.

| leaf in the resolved shape | converter baked |
|---|---|
| already at the activation's scalar type, decision-descended | the type's ordinary `convert`/constructor methods *at that eltype* |
| a plain `Float64` leaf against a non-nominal activation's scratch, a held constant | the `Float64 → Dual` zero-partial embedding |

A leaf already at the activation's scalar type is decision-descended. Under a
`Dual`-seeded evaluation of a type-stable `trim_condition(d)`, every
decision-dependent leaf is `Dual`-typed in the shape ([§14.7][s14-7]). Such a
leaf takes the type's ordinary `convert`/constructor methods *at that eltype*.
An authored `RQuat` (FlightPhysics' rotation quaternion) of `Dual`s becomes
the `SVector{4}` state leaf at `Dual`, with the partials flowing through
untouched. That untouched flow of partials is what makes the seeded decisions
reach the [sweep](#g-sweep) at all. At the [nominal](#g-nominal) activation
the same rule is the ordinary `Float64` conversion. An authored `RQuat` value
becomes the `SVector{4}` state leaf it initializes.

A plain `Float64` leaf against a non-nominal activation's
[scratch](#g-scratch) is a held constant, and it takes the `Float64 → Dual`
zero-partial embedding. That embedding is semantically exact in that case, and
in no other. "Held at the operating point" *is* zero partials. Zero partials
are the whole of a linearization operating-point condition, which is
authored decision-free ([§14.10][s14-10]).

The selection is a one-time resolution decision, and it leaves the nominal
exact-match doctrine for table [cells](#g-cell) ([§9.5][s9-5]) untouched.
Converters run here, on the write path. They never run on state
[views](#g-view) ([§7.1][s7-1], [D-148][d-148]).

Overlay partiality for the `s` and `m` stores is baked the same way
([D-065][d-065]). Each `s` or `m` store's write is one whole value,
`merge(defaults, overlay)`, with the store's declared defaults resolved at
compile time under the overlay-base rule ([§14.1][s14-1]).


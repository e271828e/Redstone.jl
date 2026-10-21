<a id="g-activation"></a>**activation** — the build's typed products at a given scalar type `T`.
It re-types the [cells](#g-cell) and the state type by the
[leaf walk](#g-leaf-walk), lays out the buffers, re-invokes the workspace
allocators and re-runs the probe chain ([§9.4][s9-4]). The nominal `Float64`
activation is the nominal evaluation's product. Any other is derived from it
on request ([§9.1][s9-1]).

<a id="g-always-on-conformance-check"></a>**always-on conformance check** — the probe's comparison left permanently in
place. It holds each probed function's return to that function's predicate,
a stage's to its cells' types ([§9.5][s9-5]). For a stage it is decided when
the table write's method is generated over both types, so a conformant return
generates no check instruction ([D-235][d-235]). Fields pair by name.

<a id="g-build"></a>**`Build`** — the artifact `build(world)` produces, bundling the three steps'
products. They are `Structure`, `Outputs`, `Events`, the activations keyed by
scalar type, and `warnings` ([§9.2][s9-2]). It is the inspectable contract of
the instantiation. `attach!` validates against it ([§9.2][s9-2]). Replay's
fingerprint check ([§12.7][s12-7]), the ignore list ([§13.5][s13-5]) and
condition resolution ([§14.3][s14-3]) read it too.

<a id="g-events"></a>**`Events`** — a product of the nominal evaluation, built last, after the
nominal stage probes. It holds per component the event names, their detection
policies and the bundle names. It is separate from `Outputs` because a
consumer of the execution order should not carry the event tables
([§9.1][s9-1], [D-253][d-253]).

<a id="g-leaf-walk"></a>**leaf walk** — the framework's derivation of per-activation types from a
declared nominal type. `Float64` leaves and `Float64` type parameters follow
the activation scalar, a `Pinned{P}` leaf yields `P`, and everything else
pins, a mutable type's parameters included ([§8.2][s8-2], [D-263][d-263]).
Each activation walks `x_init` and a continuous leaf's contracts
([§9.4][s9-4]). `m_init`, `s_init` and the discrete tier's contracts pin
wholesale.

<a id="g-measurement-seam"></a>**measurement seam / phase bodies** — `phase_bodies(sim)` returns the
compiled bodies of the nominal activation bound over the simulation's own
buffers. They are `rhs`, `sweep_1`, `sweep_2` and `ticks`, plus per-event
guards and handlers and per-component `x_projection`. Its one promise is
identity with what the loop runs, which is what makes the allocation
assertions ([§9.8][s9-8]) honest ([§9.7][s9-7]).

<a id="g-model"></a>**`Model`** — a [deployment](#g-deployment) materialized at one scalar type. It
holds the deployment, its [executor](#g-executor), its status and its
diagnostic cell ([§12.6][s12-6]). A `Simulation` runs only a `Model{Float64}`,
and claims it at construction ([§9.2][s9-2], [D-317][d-317], [D-318][d-318]).
A `Model` at another scalar is a service's scratch. Its entry points are
listed under "Deployment and the model" in [Appendix B][sB].

<a id="g-nominal"></a>**nominal** — the `Float64` activation, and of a declaration its `Float64`
face (for a continuous producer's output declaration, its evaluation at
`Float64`). It is the only activation that runs in real time, and the one
where the conformance check demands exact type match ([§9.4][s9-4],
[§9.5][s9-5]). A `Simulation` runs only a `Model{Float64}` ([§9.2][s9-2]).

<a id="g-probe"></a>**probe** — the build's evaluation of a user function with real values,
checking shape and type conformance and discarding the result. The nominal
evaluation probes every user function once, at the initial state
([§9.3][s9-3]). Each other activation re-runs the probe chain over its
[executable set](#g-executable-set) ([§9.4][s9-4]). Probes see only the
initial state's branch.

<a id="g-structure"></a>**`Structure`** — the structure step's product, everything the instance
alone fixes. It holds the components and tiers, one row per assembly with its
children and wires, the root inputs, the rate chains and the scope triples
([§9.1][s9-1], [D-253][d-253]). The face table and each face's
routing chain are functions over its wires ([D-315][d-315]). Nothing in it
depends on a scalar type.

<a id="g-walked"></a>**walked / pinned / exempt** — the eltype-genericity classes. Walked
payload/value types follow the activation scalar, pinned parameters and
definitions stay `Float64`, and the discrete side is exempt ([§7.2][s7-2]).
One [leaf walk](#g-leaf-walk) reads a continuous leaf's state and contracts
alike. A contract leaf opts out of walking with the `Pinned{P}` marker
([§8.2][s8-2]).

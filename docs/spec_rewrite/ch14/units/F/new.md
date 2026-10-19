### 14.7 The trim problem: NamedTuple decisions, declared reads, named residuals

The aircraft author ships one value. It says what the solver may vary, what
those decisions make of the model, what to read back after each evaluation,
and which equations the readings must satisfy. That value is a
[`TrimProblem`](#g-trimproblem). This section gives its fields, then its
decisions and parameters, its reads, its residuals and checks, the
formulation it encodes and its recorded extensions.

#### The fields

**The field set is normative and closed** ([D-118][d-118], [D-262][d-262]).
It is closed because the lift ([§14.9][s14-9]) is field-by-field.

- **`guess`, `lower` and `upper` are same-named all-`Float64` NamedTuples**
  ([D-069][d-069]).
- `condition` is the function over decisions whose value is a
  [condition](#g-condition) (the path-addressed sparse overlay that sets a
  build's state).
- `reads` is the declared read set.
- `residuals` is the residual function.
- `tolerances` is an all-`Float64` NamedTuple, same-named as the residual
  function's return.
- `checks` is the check function, and `check_tolerances` an all-`Float64`
  NamedTuple same-named as its return. Both default to empty.

`tolerances` is carried *in the problem* because a relocated problem must carry
its own convergence test. [`at`](#g-at) (the scoping combinator storing a path
prefix beside a node) passes it through untouched ([D-118][d-118]).

[Worked](#g-worked), the cruise case of Flight.jl's Cessna 172 model
(`c172.jl`) reduces to its three-equation core. The real problem is the same
shape with the full 7-variable search, and the θ-constraint elimination
survives inside `trim_condition`, the worked problem's illustrative condition
function.

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
against Flight.jl's `c172.jl`.

#### Decisions and parameters

Decision variables, initial guess and box bounds are plain, same-*named*,
all-`Float64` NamedTuples. FlightPhysics' decision-variable supertype,
`AbstractTrimState{N}`, is dropped. It is an alias of StaticArrays'
`FieldVector{N, Float64}`. Its only job was vectorization, and vectorization
is the service's ([D-069][d-069]). The service packs and unpacks by field order, and
that order is the `guess` NamedTuple's own. This [seam](#g-seam) runs on the
rule [§9.5][s9-5] states, "the names are the pairing, order carries no
semantics" ([D-151][d-151]). `lower` and `upper` are checked at setup for
key-set equality with `guess` and for `Float64` fields. They are then
canonicalized to `guess`'s field order by the same type-level reorder
(`NamedTuple{keys(guess)}(lower)`). A permuted bound spelling is therefore a
non-event, rather than `α`'s bound silently applied to `throttle`. A key-set or
field-type mismatch is `TrimProblemInvalid`. Guess, bounds and the returned
solution share one spelling, and `Base.merge(guess, (throttle = 0.3,))` is free
warm-start tweaking. An author who wants a documented `@kwdef` struct keeps it
privately and converts.

`TrimParameters` is the struct in Flight.jl's `c172.jl` that holds a trim's
targets and settings. **`TrimParameters` stays a plain user struct** the
framework never sees ([D-069][d-069], [D-118][d-118]). The assignment is the
pure `trim_condition(ac, params, d)` [fragment](#g-fragment)-tree function
([§14.2][s14-2]), applied per iteration by the compiled plan ([§14.4][s14-4]).

#### Reads

**The read side is declared, then compiled** ([D-069][d-069]). The spelling is
`reads(name = get_state(path, leaf) | get_deriv(path, leaf) |
get_output(path, leaf) | get_input(leaf) | get_face(leaf), ...)`, the
service read set ([§14.4][s14-4], [D-124][d-124]). Each `leaf` is a
[leaf address](#g-leaf-address) (the field name with dotted and bracketed
steps below it). `get_state` and `get_deriv` address a declared state field
and its derivative (validated against `x_init`/`s_init`). `get_output`
addresses a declared output [port](#g-port) (validated against `y_types`).
`get_input` and `get_face` address a [root input](#g-root-input)
[face](#g-face) and an output face (validated against the faces of the level
the read set is mounted at, the root's when unmounted) ([D-277][d-277]).

The path [selectors](#g-selector) (the closed family of deferred reads
resolving against a source) reach any port the structure has
([§13.3][s13-3], [D-414][d-414]). As authoring guidance, an equilibrium
equation meant to survive substitution at a generic seam reads a face
([D-414][d-414], [D-125][d-125]). A trim evaluation needing a value a
[component](#g-component) computes without declaring it finds no selector for
it ([§14.4][s14-4]). That is a signal that the component should export it. A
derivative wanted across a [contract](#g-contract) boundary takes the same
remedy. Publish it as an ordinary output port computed in `y_direct`. That is
the one-line binding of the fused idiom ([§5.3][s5-3]), made contract. By
convention, then, `get_deriv` stays inside subtrees the problem's author owns
([D-414][d-414]). The compiled reader fills a stack-only NamedTuple per
evaluation. It is the gather twin ([§14.4][s14-4]).

#### Residuals and checks

**The user supplies a residual *system*, not a scalar cost**
([D-069][d-069]). It is authored as a NamedTuple of named equations. The
residual function that returns it has this signature.

```julia
residuals(reads::NamedTuple, d::NamedTuple) → NamedTuple
```

**What the solver varies is passed, and what is fixed per problem is closed
over** ([D-118][d-118]).

The gathered reads and the decision NamedTuple arrive as arguments. `d` is the
one value that *cannot* be closed over. `TrimParameters` stays behind the
closure, exactly as `condition` already holds it, and the framework never sees
it. Being user-shaped, that record is also where any environment handles the
condition math needs conventionally ride. [§8.2][s8-2] gives the
[value-level constructor](#g-value-level-constructor) (the plain exported
function building a field handle from the component and input values) that
builds such a handle, and [§14.1][s14-1] the pre-sweep doctrine. The problem
*receives* the environment, and never writes it ([§14.9][s14-9]).

The returned NamedTuple's names are the equation names the report and the
failure messages use ([D-118][d-118]). The service packs residuals and
tolerances to the solver's vector by field order. The order is `tolerances`'
field order, the declared side again, canonical for the r-side. Each residual
return is reordered to it (`NamedTuple{keys(tolerances)}(r)`) before packing
([D-151][d-151]). An equation list spelled in a different order inside the
lambda therefore pairs correctly and costs nothing. The decisions rule holds
symmetrically on both ends of the seam. Names pair, and order never does.
Names and types are checked at setup, because the guess evaluation the service
performs anyway observes the residual key set. A `tolerances` key-set
mismatch, or any field-type disagreement on either side of the seam, is
`TrimProblemInvalid` ([Appendix C][sC]), with the offending field and the
names or types in hand. Order is never a mismatch.

**Checks are equations the service reports once, at the committed state, and
never solves** ([D-262][d-262]). `checks` has the residual function's
signature, and `check_tolerances` pairs with its return as `tolerances` pairs
with the residuals'. The service gathers the checks after the commit, from the
[sweep](#g-sweep) of [boundary zero](#g-boundary-zero) (the initialization
boundary, the ordinary macro-sequence with an empty integrate), and reports
them ([§14.8][s14-8]). Setup observes their return's shape at the guess
evaluation, as it observes the residuals' ([§14.8][s14-8]). Their reads join
the problem's one read set.

The reason for the checks lies in analytic elimination. Under it, the
condition math pins the airspeed and the flight-path angle from the targets
and the atmosphere the user's `params` record holds, while the world measures
against the atmosphere the [baseline](#g-baseline) wrote. If the two disagree,
the residuals vanish at a true equilibrium that is not the requested point,
and nothing in the residual system can tell ([D-139][d-139]). A check reading
EAS (equivalent airspeed) from the world's airdata at the committed state and
subtracting the requested value is where a world measurement meets the
request, so any mismatch moves it. The checks stay out of the solve because
they carry no information for it ([D-262][d-262]).

#### The formulation

**The FlightPhysics formulation's core is correct and survives verbatim as
user math** ([D-069][d-069]). That core is analytic elimination, namely
FlightPhysics' `θ_constraint` substituting the pitch constraint, filter and
actuator equilibria imposed by construction, and the minimal 7-variable
search.

What changes is the numerics. Trim is a square root-find. The Cessna 172
model's derivative-free scalar minimization over $\|r\|^2$ against a hand-scaled
absolute `stopval` was the rational choice only because Jacobians through
FlightCore's mutating `f_ode!` chain and the assignment math were out of reach
([D-069][d-069]).

The *default* is nonlinear least squares on $r(d)$ with exact AD Jacobians, in
the trust-region/Levenberg–Marquardt family ([§14.8][s14-8], [D-069][d-069]).
The `Dual` [activation](#g-activation) (the build's typed products at a given
scalar type) seeds the decision variables through the `T`-generic assignment,
sweep and `x_deriv`. The seeds survive the condition write because a
decision-descended leaf is `Dual`-typed in the shape and keeps its partials
([§14.3][s14-3], [D-148][d-148]). Convergence is quadratic (~5–15
evaluations), the tolerances are per-residual and physical, and failure
reports name the unbalanced equations with magnitudes. The convergence verdict
itself is service-owned and backend-independent ([§14.8][s14-8]).

**Non-squareness degrades gracefully** ([D-069][d-069]). Redundant actuation
becomes weighted or minimum-norm least squares. Infeasible demands converge to
a nonzero residual identifying the impossible balance. At the solution,
$\partial r / \partial d$ is free flight-physics data (control effectiveness)
that cross-checks linearization.

**The derivative-free scalar path would survive as the fallback**, with
Flight.jl's algorithm as its degenerate case ([D-069][d-069]). [§14.8][s14-8]
gives the normalization of the residuals against the tolerances that would
repair the hand-scaled absolute threshold.

#### Recorded extensions

**Two problems are [recorded, not built](#g-recorded-not-built)** (a
worked-out extension deliberately left unimplemented, its seams named)
([D-069][d-069]). They are closed-loop sampled-data trim and on-ground static
equilibrium, each simply another problem value over the same service.
Closed-loop trim appends `s_update(s) - s = 0` residuals via a nondestructive
[scratch](#g-scratch) evaluation of `s_update`, which was structurally
impossible under FlightCore's mutating `f_periodic!`. On-ground static equilibrium
solves strut compressions and attitude against gear forces.

### 14.8 The trim service: solver seam, scratch stores, commit and report

A [`TrimProblem`](#g-trimproblem) is an inert value until a service runs it.
`trim!` is that service. It drives a solver it holds behind one method, works
on its own [scratch](#g-scratch) stores (mutable working storage whose contents
are never authoritative), commits a converged solution the way `init!` would,
and returns a report.

#### The backend seam

The signature is
`trim!(model, problem; baseline, t0 = 0.0, backend = LevenbergMarquardt())`,
where `model` is a [`Model`](#g-model) (a deployment materialized at one
scalar type) at `Float64` ([D-319][d-319]). A `Model` at another scalar is
refused as `ArgumentInvalid` with reason `:non_nominal` ([D-319][d-319]). A
model that a simulation has claimed is refused before any check, as
`ArgumentInvalid` with reason `:claimed`, since the call commits
([D-319][d-319]). The `baseline` keyword takes a [baseline](#g-baseline) (an
aircraft-shipped, full-coverage condition function). `trim!(sim, problem; …)`
gates on the simulation's lifecycle and commits through the simulation's
`init!`.

**The default backend is an in-house dense Levenberg–Marquardt**
([D-070][d-070]). For decision dimensions ~10 with exact Jacobians, the core is
~100 lines, namely a damping loop, a small linear solve and a convergence
test. That is the [§10.2][s10-2] stepper precedent exactly, a tiny needed core
against a heavy dependency. The per-residual physical tolerances sharpen the
case ([§14.7][s14-7]). They are a convergence test no external package spells
natively. That is precisely why the *service*, not the backend, applies it.

**The backend [seam](#g-seam) is a pinned signature**, value-passed, with one
required method per backend ([D-158][d-158]). That one method is the seam.

```julia
solve(backend, eval!, d0, lower, upper, tol) -> (; d, status, n_evaluations, n_iterations)
```

`eval!(r, J, d)` is in-place and always fills `r`, the residual vector packed
in `tolerances`' field order. It fills `J` iff `J !== nothing`. The Jacobian is
requested by argument, so a Jacobian-free backend simply always passes
`nothing`, and there is still exactly one evaluation method to implement.

`d0`, `lower` and `upper` are packed `Vector{Float64}` in `guess`'s field
order, with `±Inf` meaning unbounded. The declared side is canonical on both
ends, and the service has canonicalized before packing ([§14.7][s14-7]). A
backend that ignores bounds therefore ignores two vectors, not a missing
argument.

`tol` is a `Vector{Float64}` in `tolerances`' field order. It is data the
backend *may* stop on, under the service's per-backend-family translation
below, and it is decisive of nothing.

The return holds `d`, the solution, `status::Symbol`, and the diagnostic counts
`n_evaluations` and `n_iterations`. **The status set is deliberately open**,
and the status is recorded verbatim in the report because the verdict is the
service's ([D-158][d-158]). The name `solve` is subject to the exported-name
audit (`pending.md`) like every other API spelling. The backend sees vectors
and never names, so the solution it returns unpacks by the same order it was
given ([D-151][d-151]).

#### The convergence verdict

**The convergence verdict is the service's, uniformly** ([D-150][d-150]).
`converged` means `all(abs.(rᵢ) .≤ tolᵢ)`. That is the per-residual box test
([§14.7][s14-7]) in its own physical units, evaluated by the service at the
backend's returned point. It is one residual evaluation, noise against the
solve that produced it. That verdict, and nothing else, gates the commit and
fills `TrimReport.converged`. The backend's returned `status` is recorded in
the report as diagnostic data, and it is authoritative over nothing.

#### The tolerance translation

The tolerance translation is the service's too, per backend family
([D-150][d-150]). In least-squares backends the tolerances *are* the stopping
criterion. They feed the per-residual test directly, so LM's damping loop tests
exactly what the service will re-test.

The derivative-free fallback is designed and not yet built, and `pending.md`
lists it ([D-070][d-070]). In the design it is `NLoptBackend(:LN_BOBYQA)` in a
package extension. It would pass `nothing` for the Jacobian, keep Flight.jl's
algorithm one keyword away, and leave the framework core carrying zero
optimizer dependencies. For that fallback the service would square *and
normalize*. The objective minimized would be $\sum_i (r_i/\mathit{tol}_i)^2$
with `stopval = 1`. That objective is dimensionless where the threshold
in Flight.jl's Cessna 172 model (`c172.jl`) was hand-scaled and absolute ([§14.7][s14-7]). It is a well-scaled
valley where a raw $\|r\|^2$ sums forces against moments.

The two criteria cannot disagree in the dangerous direction, because of this
implication ([D-150][d-150]).

$$\sum_i (r_i/\mathit{tol}_i)^2 \le 1
\quad\Longrightarrow\quad (r_i/\mathit{tol}_i)^2 \le 1 \;\text{ for every } i$$

The `stopval` sphere is therefore *inscribed* in the tolerance box, and a
fallback stopping at `stopval` necessarily passes the service's box test. The
converse disagreement, a backend stopping early and reporting an optimistic
status, is caught by the re-check, which remains the single authority. What is
*not* claimed is point identity. Different backends may land on different
solutions, which is an algorithmic difference and a legitimate one. What is
eliminated is per-backend meanings of `converged`.

#### Box bounds and saturated decisions

**Box bounds are honored by step projection** ([D-070][d-070]). A decision
variable saturated *at the solution* is listed in the report's saturated list,
as `(:elevator, :upper)`. That is the classic CG-limit diagnostic, which
Flight.jl's trim leaves inferable only from mysterious residuals.

#### Scratch stores

Every `trim!` invocation instantiates a fresh working store set. Each half of
it (below) is a scratch `Model` of its own, materialized from the deployment
the service was called on ([D-317][d-317], [D-319][d-319]). The set holds the
`x` backing, the `s` and `m` stores, the [root input](#g-root-input) and
[signal tables](#g-signal-table), and the derivative [buffer](#g-buffer). The
set is built from the [activation](#g-activation)'s *layout* (the build's typed
products at a given scalar type). The layout is the reusable compiled
artifact. The buffers are per-invocation and die with the call (stopped-sim
allocation, [§9.8][s9-8]). Each set also calls every
[workspace](#g-workspace) (component-declared mutable scratch, arriving as
`ws`) allocator once, at the activation's scalar ([D-077][d-077]).

The `Dual` backend's buffers being un-aliasable by type is defense in depth,
not the mechanism. A `Float64` backend, such as the designed NLopt fallback,
would get equally fresh buffers. The invariant is backend-independent.
**The simulation's authoritative stores have exactly one writer**, the commit
through [boundary zero](#g-boundary-zero) (the initialization boundary, the
ordinary macro-sequence with an empty integrate) ([D-070][d-070]).

Setup applies `override(baseline, condition(guess))`, the problem's
[condition](#g-condition) at the guess layered over the baseline by
[override](#g-override), to the scratch set once. That application's full
coverage is *checked here*, as [§14.6][s14-6] requires ([D-149][d-149]).
[Sweeps](#g-sweep) therefore see a complete world. Raw instantiation is sound
exactly because of that check, since every root input is written before any
read. An incomplete `baseline` is one declaration-ordered
`UninitializedInputs` at setup rather than a whole solve against undefined
[cells](#g-cell).

**The frozen cells are established, not probe-seeded** ([D-213][d-213]). At the
seeded activation the discrete [tier](#g-tier) is frozen ([§9.4][s9-4]). Its
stages never run there, so nothing at that activation can derive a discrete
output cell from the authored `s`. Setup therefore instantiates the scratch set
in two halves. A [nominal](#g-nominal) set (one at the `Float64` activation)
takes the composite first, by the dynamic walk ([§14.4][s14-4]), and runs one
establishment round. That round is boundary zero's sweep with every discrete
output stage admitted, due or not ([D-205][d-205]), with no
[projection](#g-projection), no [guards](#g-guard) and no `s_update`. The
seeded set is then written by the specialized `apply!`. Its frozen cells are
copied from the nominal set, `Float64` values that a continuous consumer reads
as zero-partial constants ([§9.5][s9-5]). Every cell the iterations read is
thus derived from the authored world. A frozen cell holds what the authored
discrete state publishes, which makes "held at the operating point" literal.
No scratch cell holds the [probe](#g-probe)'s synthesized values. That is the
[§14.6][s14-6] barrier reaching the scratch world, as [D-205][d-205] made it
reach the published one. The iterations are untouched. They are raw write →
sweep → read cycles at the seeded activation, over the continuous chain and
`x_deriv` alone ([§14.5][s14-5]). The zero-decision problem (below) is the
nominal half alone. Its one evaluation is that establishment round, followed
by one derivative evaluation for the reads ([D-213][d-213]).

The commit applies the same composite over the same `baseline`
(`override(baseline, condition(d*))`, [§14.9][s14-9]), so its coverage is
setup's. Commit's totality check is therefore structurally unfailable through
the trim path, and it stands as the shared `init!` defense ([D-149][d-149]). A
converged solve is always committable. `TrimReport` therefore carries no
committed flag, and the no-throw doctrine needs no exception.

Iterations rewrite the composite's write-set via the compiled plan. The
write-set is `override(baseline, condition(d))`, the same tree setup resolved,
so a store both layers touch merges exactly as it did at setup. An LM
evaluation is one Dual-seeded sweep yielding `r` from the value parts and `J`
from the partials, together ([D-069][d-069]). No convergence means no commit.
Non-convergence is the service's box test failing at the returned point,
whatever status the backend attached to it ([D-150][d-150]). No commit means
the sim is bit-for-bit untouched, including "never initialized". Flight.jl's
warn-but-assign is structurally impossible.

The same structure covers an interrupt. Ctrl-C during a long solve unwinds an
ordinary Julia call operating on per-invocation scratch stores. No commit has
happened, and the simulation is bit-for-bit untouched, exactly as a
non-converged solve leaves it. The services need no counterpart to the loop's
boundary masking ([§12.4][s12-4]). An interrupt inside the commit's boundary
zero moves the simulation to `built` and propagates raw ([§13.4][s13-4],
[D-223][d-223]).


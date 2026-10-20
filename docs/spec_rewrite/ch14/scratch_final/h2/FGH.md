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

The problem below is [worked](#g-worked) (spelled in full against a concrete case). It is the
cruise case of Flight.jl's Cessna 172 model (`c172.jl`), reduced to its
three-equation core. The real problem is the same shape with the full 7-variable
search, and the θ-constraint elimination survives inside its condition function,
which the worked problem calls `trim_condition`.

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

FlightPhysics' decision-variable supertype, `AbstractTrimState{N}`, is dropped. It
is an alias of StaticArrays' `FieldVector{N, Float64}`. Its only job was
vectorization, and vectorization is the service's ([D-069][d-069]). The service packs and
unpacks by field order, and that order is the `guess` NamedTuple's own. This [seam](#g-seam)
runs on the rule [§9.5][s9-5] states, "the names are the pairing, order carries no
semantics" ([D-151][d-151]). `lower` and `upper` are checked at setup for key-set equality
with `guess` and for `Float64` fields. They are then canonicalized to `guess`'s field
order by the same type-level reorder (`NamedTuple{keys(guess)}(lower)`). A
permuted bound spelling is therefore a non-event, rather than `α`'s bound silently
applied to `throttle`. A key-set or field-type mismatch is `TrimProblemInvalid`.
Guess, bounds and the returned solution share one spelling, and
`Base.merge(guess, (throttle = 0.3,))` is free warm-start tweaking. An author who
wants a documented `@kwdef` struct keeps it privately and converts.

`TrimParameters` is the struct in Flight.jl's `c172.jl` that holds a trim's
targets and settings. **`TrimParameters` stays a plain user struct** the
framework never sees ([D-069][d-069], [D-118][d-118]). The assignment is the
pure `trim_condition(ac, params, d)` [fragment](#g-fragment)-tree function
([§14.2][s14-2]), applied per iteration by the compiled plan ([§14.4][s14-4]).

#### Reads

**The read side is declared, then compiled** ([D-069][d-069]). **The spelling
is `reads(name = get_state(path, leaf) | get_deriv(path, leaf) |
get_output(path, leaf) | get_input(leaf) | get_face(leaf), ...)`**, the
service read set ([§14.4][s14-4], [D-124][d-124]). Each `leaf` is a
[leaf address](#g-leaf-address) (the field name with dotted and bracketed
steps below it). `get_state` and `get_deriv` address a declared state field
and its derivative (validated against `x_init`/`s_init`). `get_output`
addresses a declared output [port](#g-port) (validated against `y_types`).
`get_input` and `get_face` address a [root input](#g-root-input)
[face](#g-face) and an output face (validated against the faces of the level
the read set is mounted at, the root's when unmounted) ([D-277][d-277]).

The path [selectors](#g-selector) (the closed family of deferred reads resolving against a
source) reach any port or state field the structure has ([§13.3][s13-3], [D-414][d-414]). As
authoring guidance, an equilibrium equation meant to survive substitution at a
generic seam reads a face ([D-414][d-414], [D-125][d-125]). A trim evaluation needing a value a
[component](#g-component) computes without declaring it finds no selector for it ([§14.4][s14-4]). That
is a signal that the component should export it. A derivative wanted across a
[contract](#g-contract) boundary takes the same remedy. Publish it as an ordinary output port
computed in `y_direct`. That is the one-line binding of the fused idiom ([§5.3][s5-3]),
made contract. By convention, then, `get_deriv` stays inside subtrees the
problem's author owns ([D-414][d-414]). The compiled reader fills a stack-only NamedTuple
per evaluation. It is the gather twin ([§14.4][s14-4]).

#### Residuals and checks

**The user supplies a residual *system*, not a scalar cost**
([D-069][d-069]). It is authored as a NamedTuple of named equations. The
residual function that returns it has this signature.

```julia
residuals(reads::NamedTuple, d::NamedTuple) → NamedTuple
```

**What the solver varies is passed, and what is fixed per problem is closed
over** ([D-118][d-118]).

The gathered reads and the decision NamedTuple arrive as arguments. `d` is the one
value that *cannot* be closed over. `TrimParameters` stays behind the closure,
exactly as `condition` already holds it. Being user-shaped, that record is also
where any environment handles the condition math needs conventionally ride. [§8.2][s8-2]
gives the [value-level constructor](#g-value-level-constructor) that builds such a handle, a plain exported
function of the component and its input values. [§14.1][s14-1] gives the pre-sweep
doctrine. The problem *receives* the environment, and never writes it ([§14.9][s14-9]).

**The returned NamedTuple's names are the equation names** the report and the
failure messages use ([D-118][d-118]). The service packs residuals and tolerances to the
solver's vector by field order. The order is `tolerances`' field order, the
declared side again, canonical for the residuals. Each residual return is
reordered to it (`NamedTuple{keys(tolerances)}(r)`) before packing ([D-151][d-151]). An
equation list spelled in a different order inside the lambda therefore pairs
correctly and costs nothing. The decisions rule holds symmetrically on both ends
of the seam. Names pair, and order never does. Names and types are checked at
setup, because the guess evaluation the service performs anyway observes the
residual key set. A `tolerances` key-set mismatch, or any field-type disagreement
on either side of the seam, is `TrimProblemInvalid` ([Appendix C][sC]), with the
offending field and the names or types in hand. Order is never a mismatch.

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

**Flight.jl's trim formulation is correct at its core and survives verbatim as
user math** ([D-069][d-069]). That core is analytic elimination, namely FlightPhysics'
`θ_constraint` substituting the pitch constraint, filter and actuator equilibria
imposed by construction, and the minimal 7-variable search over `c172.jl`'s
`TrimState`.

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
`trim!(model, problem; baseline, t0 = 0.0, backend = LevenbergMarquardt())`, where
`model` is a [`Model`](#g-model) (a deployment materialized at one scalar type) at `Float64`
([D-319][d-319]). A `Model` at another scalar is refused as `ArgumentInvalid` with reason
`:non_nominal` ([D-319][d-319]). A `Model` that a simulation has claimed is refused before
any check, as `ArgumentInvalid` with reason `:claimed`, since the call commits
([D-318][d-318], [D-319][d-319]). The `baseline` keyword takes a [baseline](#g-baseline) (a full-coverage
condition, such as an aircraft-shipped function returns). `trim!(sim, problem; …)`
gates on the simulation's lifecycle and commits through the simulation's `init!`.

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

`eval!(r, J, d)` is in-place and always fills `r`, the residual vector packed in
`tolerances`' field order. It fills `J` exactly when `J !== nothing`. The Jacobian is
requested by argument, so a Jacobian-free backend simply always passes `nothing`,
and there is still exactly one evaluation method to implement.

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

The tolerance translation is the service's too, per backend family ([D-150][d-150]). In
least-squares backends the tolerances *are* the stopping criterion. They feed the
per-residual test directly, so the damping loop of Levenberg–Marquardt (LM)
tests exactly what the service will re-test.

The derivative-free fallback is designed and not yet built, and `pending.md` lists
it ([D-070][d-070]). In the design it is `NLoptBackend(:LN_BOBYQA)` in a package extension.
It would pass `nothing` for the Jacobian, keep Flight.jl's algorithm one keyword
away, and leave the framework core carrying zero optimizer dependencies. For
that fallback the service would square *and normalize*. The objective minimized
would be $\sum_i (r_i/\mathit{tol}_i)^2$ with `stopval = 1`. That objective is
dimensionless where the threshold in Flight.jl's Cessna 172 model (`c172.jl`) was
hand-scaled and absolute ([§14.7][s14-7]). It is a well-scaled valley where a raw
$\|r\|^2$ sums forces against moments.

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

**Box bounds are honored by step projection** ([D-070][d-070]). A decision variable saturated
*at the solution* is listed in the report's saturated list, as
`(:elevator, :upper)`. That is the classic CG-limit diagnostic (CG is the center
of gravity), which Flight.jl's trim leaves inferable only from mysterious
residuals.

#### Scratch stores

Every `trim!` invocation instantiates a fresh working store set. Each half of it
(below) is a scratch `Model` of its own, materialized from the deployment the
service was called on ([D-317][d-317], [D-319][d-319]). The set holds the `x` backing, the `s` and `m`
stores, the [root input](#g-root-input) and [signal tables](#g-signal-table), and the derivative [buffer](#g-buffer). The set is
built from the *layout* of the [activation](#g-activation) (the build's typed products at a given
scalar type). The layout is the reusable compiled artifact. The buffers are
per-invocation and die with the call (stopped-sim allocation, [§9.8][s9-8]). Each set
also calls every [workspace](#g-workspace) (component-declared mutable scratch, arriving as `ws`)
allocator once, at the activation's scalar ([D-077][d-077]).

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

**The frozen cells are established, not probe-seeded** ([D-213][d-213]). At the seeded
activation the discrete [tier](#g-tier) (the discrete side of the hybrid formalism) is
frozen ([§9.4][s9-4]). Its stages never run there, so nothing at that activation can
derive a discrete output cell from the authored `s`. Setup therefore instantiates
the scratch set in two halves. A [nominal](#g-nominal) set (one at the `Float64` activation)
takes the composite first, by the dynamic walk ([§14.4][s14-4]), and runs one
establishment round. That round is boundary zero's sweep with every discrete
output stage admitted, due or not ([D-205][d-205]), with no [projection](#g-projection) (the per-component
`x_projection` hook), no [guards](#g-guard) and no `s_update`. The seeded set is then written by
the specialized `apply!`. Its frozen cells are copied from the nominal set,
`Float64` values that a continuous consumer reads as zero-partial constants
([§9.5][s9-5]). Every cell the iterations read is thus derived from the authored world.
A frozen cell holds what the authored discrete state publishes, which makes
"held at the operating point" literal. No scratch cell holds a synthesized
[probe value](#g-probe-value) (a fabricated value a build-time probe runs on). That is the
probe-value barrier of [§14.6][s14-6] reaching the scratch world, as [D-205][d-205] made it reach
the published one. The iterations are untouched ([§14.5][s14-5]). They run at the seeded
activation, over the continuous chain and `x_deriv` alone. The empty problem
(below) is the nominal half alone ([D-213][d-213]). Its one evaluation is that
establishment round, followed by one derivative evaluation for the reads.

The commit (below) applies the same composite over the same `baseline`, so its
coverage is setup's. Commit's totality check is therefore structurally
unfailable through the trim path, and it stands as the shared `init!` defense
([D-149][d-149]). A converged solve is always committable. `TrimReport` therefore carries
no committed flag, and the no-throw rule (below) needs no exception.

Iterations rewrite the composite's write-set via the compiled plan. The
write-set is `override(baseline, condition(d))`, the same tree setup resolved, so
a store both layers touch merges exactly as it did at setup. An LM evaluation is
one Dual-seeded sweep yielding `r` from the value parts and `J` from the partials,
together ([D-069][d-069]). No convergence means no commit. Non-convergence is the
service's box test failing at the returned point, whatever status the backend
attached to it ([D-150][d-150]). No commit means the sim is bit-for-bit untouched,
including "never initialized". Flight.jl's warn-but-assign, where the Cessna 172
trim warns on a failed optimization and assigns its result anyway, is
structurally impossible.

The same structure covers an interrupt. Ctrl-C during a long solve unwinds an
ordinary Julia call operating on per-invocation scratch stores. No commit has
happened, and the simulation is bit-for-bit untouched, exactly as a
non-converged solve leaves it. The services need no counterpart to the loop's
boundary masking ([§12.4][s12-4]). An interrupt inside the commit's boundary
zero moves the simulation to `built` and propagates raw ([§13.4][s13-4],
[D-223][d-223]).
#### The commit, in full

The committed solution is applied as an `init!` in every respect. It is
`override(baseline, condition(d*))` through boundary zero, with the pre-write
[root-input totality](#g-root-input-totality) check ([§14.6][s14-6]), the
sequence ([§14.5][s14-5]) and guards at commit. That check requires the
application to cover every root input.

The `t0` argument that anchors the grid, and its default, are the same for
both init-service entry points ([§14.5][s14-5], [D-110][d-110]). The
[recorders](#g-recorders) (the trace and the log jointly) restart exactly as
[§12.6][s12-6] states for `init!` ([D-110][d-110]). The [trace](#g-trace)
(the primary record of a session) and the log are new objects. Any
[batches](#g-batch) still in [staging cells](#g-staging-cell) (where a
device's pending write batch waits between drains) are cleared.

A fresh recording that starts at its own anchor is the natural shape of an
[unattended run](#g-unattended-run) (a run with empty staging and no snapshot readers). Trim is not
offered at a point reached by flying. It takes an authored baseline.
Fly-then-retrim is spelled as a [checkpoint](#g-checkpoint) (the `Model`'s state at a frame top as
one value) of the flight, then a trim baseline authored from what the checkpoint
shows ([D-273][d-273]).

#### The report

`trim!` returns a structured `TrimReport` ([D-070][d-070]). The sketch names
its eleven fields in order.

```julia
# what trim! returns: a value to read, never an exception to catch
struct TrimReport
    converged            # the service's box test at the backend's returned point
    solution             # the solution NamedTuple, guess-shaped
    residuals            # the solved-point residuals the verdict is read off
    tolerances           # the tolerances they come with
    committed_residuals  # the same residuals, re-gathered after the commit
    committed_checks     # the check function's return at the committed state
    status               # the backend's returned status, diagnostic only
    n_evaluations        # the backend's evaluation count
    n_iterations         # the backend's iteration count
    saturated            # the saturated-bounds list
    fired_events         # the events the commit fired
end
```

The list below takes the fields in turn.

- `converged` is the service's own box test at the returned point, never a
  backend's opinion.
- `solution` is the solution NamedTuple. It is guess-shaped, hence
  warm-startable.
- `residuals` are the solved-point residuals, and `tolerances` the tolerances they
  come with ([D-155][d-155]). They are the very numbers the verdict is read off, gathered
  at the backend's returned point.
- `committed_residuals` are the committed-state residuals, the same
  residuals re-gathered from the boundary-zero world after the commit.
- `committed_checks` holds the committed-state checks, the check function's
  return at the committed state. They are gathered beside the
  committed-state residuals and empty when the problem declares none
  ([§14.7][s14-7]).
- `status` is the backend's returned status, and `n_evaluations` and
  `n_iterations` are its evaluation and iteration counts. These are
  diagnostic throughout, informative about *how* the solve went and decisive
  about nothing.
- `saturated` is the saturated-bounds list.
- `fired_events` holds the commit's fired events, as component paths and
  event names. The list is empty when boundary zero ran quiet
  ([§14.5][s14-5], [D-126][d-126]).

The committed-state residuals are nearly free ([D-155][d-155]). Boundary zero's sweep has
already run, so the residuals' declared reads need one derivative evaluation and
a gather from it. There is no offset caveat to carry. Every output stage
publishes at boundary zero ([D-205][d-205], [§14.5][s14-5]). A residual reading the [port](#g-port) (one
declared name, one cell) of a [component](#g-component) whose schedule has a nonzero [phase](#g-phase) (an
offset against its grid) therefore reads a commit-refreshed cell like any other.
Those committed-state residuals are the numbers describing the state the
simulation is actually *in*, which is the point a `linearize` at its default
operating point ([§14.10][s14-10]) reads.

A non-empty fired-event set also raises `TrimCommitEvents`, a logged warning
([Appendix C][sC], [D-126][d-126]). The committed stores then sit at the post-handler point,
not the reported solution, and that is the point `linearize` reads by default.

The two residual sets are what make the moved point auditable. **A converged solve
whose committed-state residuals violate the box test raises `TrimCommitResiduals`**,
naming the offending residuals with their committed values and tolerances
([Appendix C][sC], [D-155][d-155]). The move, whether `x_projection` or a commit-fired handler
([§14.5][s14-5]), is surfaced rather than left silent. The verdict itself is not
revisited. It gated the commit at the solved point, and the numbers stand as
reported ([D-150][d-150]).

The committed-state checks audit the point rather than the move. **A
converged solve whose committed-state checks leave their tolerances raises
`TrimCommitChecks`**, naming the offending checks with their committed values
and tolerances ([Appendix C][sC], [D-262][d-262]). The equilibrium is real.
The operating point is not the one the problem asked for, which is what a
params-vs-world atmosphere mismatch produces under elimination
([§14.7][s14-7], [D-139][d-139]). The checks are gathered from the same
boundary-zero sweep, so they cost no evaluation of their own. No commit means
no checks, exactly as for the committed-state residuals.

**Non-convergence never throws** ([D-070][d-070]). It is an expected *outcome*, not broken
machinery ([§13.5][s13-5]). When trims span the flight envelope, hitting the infeasible
edge is information.

A malformed problem is a different case. It fails at setup with a
`DiagnosticError` carrying `TrimProblemInvalid` ([Appendix C][sC]). The
malformed cases are these.

- A field that is not a NamedTuple, or a `reads` that is no read set.
- A guess/bounds key-set or field-type disagreement.
- A box with `lower` above `upper`.
- A tolerance or check tolerance that is not finite and positive.
- A `tolerances`/residual key-set mismatch observed at the setup guess
  evaluation, and a `check_tolerances`/check key-set mismatch observed at the
  same evaluation.
- A residual or check return whose fields are not real scalars, observed at
  that evaluation too.

The error carries the offending field with the names or types in hand,
collected. The read set's own refusals ride beside it, `ReadResolution` and
the path walk's `PathResolution` ([§14.4][s14-4], [D-406][d-406]). An unknown
`reads` [selector](#g-selector) (one of the closed family of deferred reads)
is refused that way. A permuted spelling is none of these ([§14.7][s14-7]).

A throw inside the commit's boundary zero is a third case, and neither of
those. It is model code failing. **The throw propagates out of `trim!` as the
commit's `StepError`**, and no report is returned for that solve
([D-224][d-224]). The simulation is left `built` ([§13.4][s13-4],
[D-223][d-223]).

An *empty* problem is none of them either. **`TrimProblem(guess = (;), …)` is legal**,
not `TrimProblemInvalid` ([D-156][d-156]). With zero decision variables the solver is
bypassed outright. There is nothing to pack, no seeded activation and no backend
call. The service simply evaluates the residuals once at
`override(baseline, condition((;)))`, the baseline with whatever the problem's
condition sets. The ordinary box test decides `converged`, and the commit runs as
usual. The empty problem asks "is this operating point an equilibrium?" It
evaluates this condition's equations and reports, which is useful in its own
right and costs no solve.

#### The AD obligation

**The default formulation requires `Dual` genericity of exactly the
continuous output-stage chains and `x_deriv`**, plus the user's assignment
and residual math ([D-070][d-070]). The discrete tier's stages and
`s_update`, and the event system's guards and handlers, never see a `Dual`.
They are frozen constants with zero partials, semantically exact
([§8.2][s8-2]).

This is *not a new obligation*. It is the same activation linearization is
defined on. AD-readiness is also a build-checked property. A
[pinned](#g-walked) intermediate (a value held at `Float64` inside authored
continuous math) makes the Dual probe fail with a culprit-naming
`MethodError` or `InexactError` ([D-307][d-307]). `build(world; activations)`
puts the probe in CI ([D-280][d-280]). The robustness comes from enforcement,
not hope.

A migration audit of Flight.jl's Cessna 172 model against this obligation took
one afternoon. Its findings on tables and saturations follow ([D-070][d-070]), and its
two Flight.jl-only findings, on the landing gear and the `norm`-at-zero guards,
are in the `migration_outline.md` companion.

- `Interpolations.jl` tables (propeller coefficient maps, engine maps) must accept
  generic scalars. They do. A call `itp(x::Dual)` works through the
  `BSpline`/`scale`/`extrapolate` compositions in Flight.jl's tables. Prefer cubic
  knots over linear where partials matter, though, since linear knots make
  Jacobian elements piecewise-constant. That is no regression against finite
  differences ([D-307][d-307]). A manual chain rule via `Interpolations.gradient` is the
  escape hatch for anything exotic, and the pattern for wrapping non-Julia black
  boxes ([§14.10][s14-10], [D-266][d-266]).
- In-model saturations (actuator limits, idle/FRC clamps) zero Jacobian columns
  when active. FRC is the friction constraint compensator of FlightPhysics'
  piston engine (`piston.jl`). LM damping tolerates the rank deficiency ([D-070][d-070]).
  The report's `saturated` list names a decision only at its own bound, so an
  in-model saturation shows in the Jacobian's zero columns rather than in the
  report. Cruise trim leaves those saturations inactive.

The derivative-free fallback would be chosen per call, through the one
`backend =` keyword.

### 14.9 Mounting: problems as relocatable values

This section treats a [`TrimProblem`](#g-trimproblem) (the closed nine-field value a trim solves) as
a relocatable value. [Mounting](#g-mounting) (relocating a whole problem or tap set to a
prefix) is the work of [`at`](#g-at), the scoping combinator. The section says what a
problem is, then how `at` lifts one, how a mounted read set and mounted input
entries resolve, why a problem never authors the environment, and how worlds,
thin rigs (worlds holding only the aircraft and its environment) and swarms use
the lift.

**A `TrimProblem` is not a [condition](#g-condition) but an implicitly specified condition** ([D-071][d-071]).
A condition is the datum that says "set this build to this state". `condition` is
a condition-*valued function* over the decision space. `reads`/`residuals` are the
equations that pin the free variables down. `guess`, `lower` and `upper` say where to
search. Solving makes the implicit condition explicit. The commit is then
literally an init, `override(baseline, condition(d*))` through [boundary zero](#g-boundary-zero) (the
initialization boundary, the ordinary macro-sequence with an empty integrate).
[`override`](#g-override) is the ordered, asymmetric layering combinator, in which the patch wins
on a shared leaf. The services unify as clients of one condition algebra. `init!`
applies an explicit condition, and `trim!` searches a family for the member
satisfying its equations.

**`at` lifts a problem field by field**, and each field falls in one of three
cases ([D-071][d-071], [D-277][d-277]). The `condition` field is
condition-producing (path-relative), so the lift post-composes it. The
`reads` field is a read set, and the lift prepends the prefix to the set's
mount chain (the prefixes it is mounted under, root first). Every other field
is path-free and passes through. The rule that residual math sees only the
gathered NamedTuple ([§14.7][s14-7]) is what makes the residuals path-free.

```julia
at(prefix::String, p::TrimProblem) = TrimProblem(
    guess      = p.guess,                      #path-free: pass through
    lower      = p.lower,
    upper      = p.upper,
    condition  = d -> at(prefix, p.condition(d)),  #post-compose: wrap each returned tree
    reads      = at(prefix, p.reads),              #inert selector data: the prefix is prepended to the read set's mount chain
    residuals  = p.residuals,                      #path-free: pass through
    tolerances = p.tolerances,
    checks     = p.checks,
    check_tolerances = p.check_tolerances)
```

The condition side needs nothing new at resolution. The flattening accumulator
of [§14.3][s14-3] enters each `Scoped` wrapper (the node `at` builds over a condition node)
and prefixes every condition entry below it.

**A read set carries its mount chain as data** ([D-277][d-277]). A read set is a `Reads` value.
`at(prefix, read_set)` prepends the prefix to that chain and joins nothing. **A
`Reads` value is no condition node**, so `Scoped` never wraps one ([D-277][d-277]). **Resolution
walks the chain from the root**, each prefix from the level the previous one
reached ([§13.3][s13-3], [D-277][d-277]). It then rebases every [selector](#g-selector) (one of the closed family
of deferred reads) to the root before the selector resolves. A path selector's
path is joined to the mount (`"vehicle/dynamics"` → `"wing/vehicle/dynamics"`).
`get_input` names an input [face](#g-face) (the name a port wears on its [component](#g-component)'s
boundary) of the mount level. It follows the export chain to the [root input](#g-root-input) it
lands on (the root component's own input face). `get_face` names an output face of
the mount level and reads its producer's port ([D-277][d-277]).

**A refusal spells the selector as authored and names the mount**
([D-277][d-277]). `at` refuses an empty prefix on a read set, as it does on a
condition node ([§14.2][s14-2]), and raises `ReadSetMisuse`. A problem's lift
and a tap set's lift reach that refusal through `at` on their read sets
([D-278][d-278]).

**Input entries authored in the aircraft's face vocabulary resolve through the
export chain from the mount point** ([D-071][d-071]). For a wingman aircraft
mounted at `"wing"`, the input entry `throttle` resolves to root input
`"wing.throttle"`. An unexported face fails resolution by name, and correctly so
([§14.2][s14-2]). An internally wired input (a [scenario
component](#g-scenario-component) driving the wingman's throttle) is untrimmable
from outside. Resolution refuses it by name, with the producer that drives it in
hand, as `ConditionResolution` for a condition entry and as `ReadResolution` for
a `get_input`. The service compiles the scoped condition and reads, and runs the
identical loop. It never knows where its paths are mounted.

**A problem never authors the environment** ([D-139][d-139]). The environment is
the business of the world and of the [`baseline`](#g-baseline) (the
full-coverage condition `trim!` takes as a keyword). In a full world it is a
sibling component's root inputs. In a thin rig it is a root input holding an
isbits [handle](#g-field-handle) (an immutable query object carried on an
ordinary port). In a thin rig it can also be a [constant
source](#g-constant-source) (a library component publishing a value its instance
holds) holding a bulk-data handle ([D-364][d-364]). The problem *receives* its
handles through the user parameter record ([§14.7][s14-7]), and only queries
them.

The reason is the resolution rule stated above. A condition entry naming an
internally wired input fails by name, correctly. A problem writing an
environment face would therefore be applicable only to those rigs where that
face happens to be unconnected. The relocatability this section exists to
guarantee would be lost.

**The world wrapper dissolves** ([D-071][d-071]). FlightPhysics' world initializer, its
method of FlightCore's `f_init!` on a FlightCore `Model{<:SimpleWorld}` (initialize
environment, then call the aircraft's trim), has no successor method. The
environment, the other aircraft and all root inputs are covered by the `baseline`
condition ([§14.6][s14-6]), applied once at setup. The commit is
`override(baseline, at(mount, condition(d*)))`. Method nesting became value
layering.

"Aircraft as root" is a thin rig. **Design tasks use the rig this design records,
[`design_world(ac)`](#g-design_world)** ([D-071][d-071]). They need one because by default the aircraft is not
literally the root. Its environment inputs are function-valued signals ([§4.4][s4-4]),
wired from provider components. The rig is `design_world(ac)` = aircraft +
`SimpleAtmosphere(wind = NoWind())` + `HorizontalTerrain`, where `SimpleAtmosphere`
and `NoWind` are FlightPhysics' atmosphere types. `design_world` promotes the ad-hoc
atmosphere and terrain FlightCore `Model`s inside Flight.jl's `linearize` to a named
artifact. There is one mechanism. The "root" case is the shallowest world, and
the trim problem mounts at `"aircraft"` like anywhere else.

Leaving an environment face *unconnected* is legal by construction, though, for an
isbits handle ([D-364][d-364]). The face becomes an ordinary root input holding the
handle *value*, written by the `baseline` like any other root input. That is the
test-rig idiom. It is the function-valued sibling of a constant source, with
zero ceremony for a frozen environment. **A handle that references bulk data is
never a root input**, and the rig wires a constant source holding it ([D-364][d-364]). Root
inputs are traced and checkpointed by value, and [§4.4][s4-4] states why such a handle
cannot be one ([D-237][d-237]). For design tasks the rig stays `design_world(ac)`. That
keeps the environment's tunables in the root-input vocabulary that conditions,
linearization's input surface and the [trace header](#g-trace-header) (the trace's fixed preamble)
already speak.

The swarm doctrine covers trims of several aircraft. **The service solves one
problem at a time** ([D-071][d-071]). Sequential independent trims (trim the lead aircraft,
commit, trim the wingman against the committed world) cover weak or one-way
coupling. A joint trim is user-side value composition. Concatenate decision
NamedTuples under prefixed names, combine the scoped condition trees, and stack
the residuals. If joint trims become routine, **a
`product(p₁ => "lead", p₂ => "wing")` helper is the extension recorded for them**
([D-071][d-071]). That helper is [recorded, not built](#g-recorded-not-built) (a worked-out extension deliberately
left unimplemented, its seams named).
### 14.10 Linearization: tap selectors, one seeded pass, a pure query

`linearize` computes the matrices `A`, `B`, `C` and `D` about an operating
point in one seeded evaluation, and it commits nothing. What it seeds and
reads is a [tap set](#g-taps) (three labeled lists declaring what
linearization seeds and reports). This section covers, in order, the tap set,
the operating point, the seeded pass, the leaves the pass seeds and the leaves
it holds frozen, the returned value, the guidance on coordinates, the recorded
sampled-data extension, and declared non-participation with the local
derivative rule.

#### The tap set

Flight.jl's per-aircraft `XStateSpace`/`UStateSpace`/`YStateSpace` structs,
plus the `get_*_ss`/`assign_*_ss!` shuttle methods, run to ~150 lines of
bookkeeping per variant. All of it becomes three [selector](#g-selector)
lists (the closed family of deferred reads resolving against a source).
**The three lists are declared together as one tap set,
`taps(x = …, u = …, y = …)`** ([D-072][d-072], [D-272][d-272]). Membership is
closed per list. The `x` list takes `get_state`, the `u` list `get_input`,
and the `y` list `get_output` and `get_face` ([§14.4][s14-4]). The NamedTuple
key is the label control design slices by.

**A tap names one scalar** ([D-272][d-272]). Its [leaf address](#g-leaf-address) (the field name with dotted and
bracketed steps below it) resolves to one scalar leaf ([§14.4][s14-4], [D-276][d-276]). So a
vector leaf yields *named scalars*, one tap per element. A seeded tap, in the `x` or
`u` list, reaches its scalar through one index step at most and never a `.name`
step, because a seed is written into a whole state field or [root input](#g-root-input) (the
root's own input face), or into one array element of it. A seeded tap's leaf is
exactly `Float64`. Any other seeded address is rejected at resolution as a
`TapResolution`. A `y` tap is a read and takes any leaf address. A tap resolving to
a vector or a struct is rejected at resolution as a `TapResolution`, and so is a
member in the wrong list. A second tap resolving to a site already seeded is
rejected naming the earlier label, since one site is one column and a second
seed there would overwrite the first ([D-272][d-272]).

```julia
taps(x = (p = get_state("vehicle/dynamics", "ω_eb_b[1]"),
          θ = get_state("vehicle/kinematics", :θ_nb), …),
     u = (throttle_cmd = get_input(:throttle),
          wind_n = get_input("wind[1]"), …),
     y = (EAS = get_output("vehicle/airflow", :EAS), …))
```

The three lists are validated at resolution, with [did-you-mean](#g-did-you-mean) errors (the
offending name plus the list-in-hand it should have matched). Those errors are
the selectors' own `ReadResolution` ([D-406][d-406]). The `x` list is validated against the
`x_init` [stores](#g-store) of the continuous [tier](#g-tier) (the continuous or discrete side of the
hybrid formalism), the `u` list against [faces](#g-face), and the `y` list against `y_types`. **An
`x` tap naming a discrete store is rejected at resolution** as a `TapResolution`, with
the tap and its tier in hand ([D-197][d-197]). That is the no-silent-zeros rule ([§9.5][s9-5]).
The discrete tier is frozen ([§8.2][s8-2]), so its only possible partials are zeros. The
rejection's next-move guidance points at the recorded step-map extension below.
The lists compile to offsets once, and relocate whole via `at(prefix, taps)`
([D-072][d-072]). The shuttle layer's successor is that compiled writer/reader pair, and
**no hand-written state-space mapping remains** ([§7.1][s7-1], [D-072][d-072]).

#### The operating point

**Linearization is a pure query** ([D-072][d-072]). It commits nothing and
runs no [boundary zero](#g-boundary-zero) (the initialization boundary, the
ordinary macro-sequence with an empty integrate). It works only on
[scratch](#g-scratch) buffers (mutable working storage whose contents are
never authoritative), and nothing it computes becomes authoritative.
Flight.jl's restore-the-trim dance, the re-`assign!` after the `FiniteDiff`
package dirtied the model, has no successor.

**The default operating point is the [checkpoint](#g-checkpoint)** of the simulation or the [`Model`](#g-model) (a
deployment materialized at one scalar type) as it stands ([D-274][d-274], [D-319][d-319]). A
checkpoint is the `Model`'s state at a frame top as one value. It is
`checkpoint(sim)` on a simulation and `checkpoint(model)` on a `Model`, each restored
into the scratch world with no boundary zero ([§12.6][s12-6], [D-274][d-274], [D-319][d-319]). The frozen
tier's [cells](#g-cell) (the typed entries of the signal table) are the checkpoint's held
cells. After a `trim!` commit, `linearize(sim, taps)` or `linearize(model, taps)` is
about the trim point with nothing re-specified. **`about = <condition>`, with `t0`
beside it, linearizes anywhere else without touching the sim**, its coverage
checked as [§14.6][s14-6] requires ([D-272][d-272]). `t0` is admitted only there, and a `t0` passed
without `about` is an `ArgumentInvalid`.

#### The seeded pass

Each invocation instantiates its own scratch store set, the trim service's
mechanism verbatim ([§14.8][s14-8]), and establishes the operating point in it (above).
**It then runs the seeded `Dual` evaluation**, one direction per `x` tap and per `u` tap,
in groups of `width` directions per pass ([D-072][d-072]). **`width` is a keyword of `linearize`,
default 8** ([D-272][d-272]). The default width's scalar type is named. A build can
therefore pre-materialize its [activation](#g-activation) (the build's typed products at a given
scalar type) through `activations` ([§9.4][s9-4]), and a tap set of any size then
linearizes with no compile at the keyboard ([D-272][d-272]). Value parts give `ẋ₀` and `y₀`.
Partials give `A` and `B` against the `x`- and `u`-seeds, and `C` and `D` against the same
seeds read at `y`. All four come out simultaneously, exact to machine precision.
`linearization_walkthrough.md` runs the pass on a two-state model, seed by seed.

```
  x-taps ─┐                                         ┌─ value parts → ẋ₀, y₀
          ├─ seed directions → one Dual evaluation ─┤
  u-taps ─┘          (chunked internally)           └─ partials    → A, B, C, D
```

That seeded evaluation replaces Flight.jl's four `FiniteDiff` Jacobians, their
step-size heuristics and ~4n perturbed evaluations.

#### Seeded and frozen leaves

**Unseeded states sit constant at the operating point**, and so do unseeded root
inputs ([D-072][d-072]). Establishing the operating point embeds their `Float64` values as
zero-partial constants. The discrete tier is frozen with zero partials, which is
precisely "linearize with the discrete state held" ([§8.2][s8-2]). Partials enter
through per-invocation seeding, one rule for `x` and root inputs alike ([§7.2][s7-2],
[D-297][d-297]). [§8.2][s8-2] states which root inputs the schema leaves seedable ([D-295][d-295]). A root
input whose input entry is declared `Pinned` is declaredly unseedable, and its
cell is frozen at every activation.

**Selecting such a root input as a `B`-matrix tap is rejected at tap resolution** as a
`TapResolution`, with the offending input entry in hand, rather than silently
yielding a zero column ([D-295][d-295], [D-296][d-296]). Under fan-out the rejection names the
pinning consumer, not the face alone. A root input is unseedable whenever any
one of its consumers demands frozen, which is the fan-out meet ([§8.2][s8-2], [D-168][d-168]).
The author's next move is to promote that leaf to a tolerant input entry, or to
route the tap around it. Either move depends on knowing which leaf froze the
root input. A discrete consumer pins its input entry by tier, not by declaration
([§8.2][s8-2]), so a root input it reads is unseedable at every activation with nothing
to promote. The rejection then names the tier, and the next move is to tap the
continuous cell that consumer drives, or the recorded step map below ([D-272][d-272]).

The table sets seeded and frozen leaves side by side.

| leaf | in the one pass | what fixes it |
|---|---|---|
| a state leaf named by an `x` tap | seeded, one direction | per-invocation seeding |
| any other state leaf | sits constant at the operating point | per-invocation seeding |
| a root input named by a `u` tap | seeded, one direction | per-invocation seeding |
| any other seedable root input | constant, its `Float64` value embedded as a zero-partial constant | per-invocation seeding |
| a root input whose input entry is declared `Pinned` | frozen at every activation, and rejected as a `B`-matrix tap | the schema: a declaration |
| a root input a discrete consumer reads | frozen at every activation, and rejected as a `B`-matrix tap | the tier |
| any discrete-tier leaf | frozen, zero partials | the tier |

#### The returned value

**`linearize` returns a `Linearization` value** ([D-072][d-072], [D-272][d-272]). It holds `ẋ₀`, `x₀`, `u₀` and
`y₀` as NamedTuples under the tap labels, `A`, `B`, `C` and `D` as matrices, and the three
label sets of the taps ([D-272][d-272]). On that data, FlightPhysics'
`subsystem`/`delete_vars` survive as pure label-indexed matrix slicing, with no
model involvement. Flight.jl's `c172x_ctl` LQR (linear-quadratic regulator)
pipeline consumes it with cosmetic changes. **FlightPhysics' `LinearizedSS`, the
[component](#g-component), survives separately, as an ordinary [continuous component](#g-continuous-component)** in the
migrated library ([D-072][d-072]). Its `x_init` is the state vector, its faces are labeled,
and the affine update lives in `y_direct`/`x_deriv`. It has no privileges, and its
schema is everyone else's.

#### Coordinate guidance

The recorded guidance is that linearization taps should select
minimal-coordinate mechanizations ([D-072][d-072]). Perturbing Euler-angle states is
meaningful where seeding quaternion components steps off the unit-norm manifold.
This is why Flight.jl's C172X design code linearizes the aircraft's `{NED}`
variant, the one built on north-east-down (NED) kinematics. [`design_world(ac)`](#g-design_world)
(the thin rig that mounts an aircraft for trim and linearization) rigs that
variant, promoting implicit practice to stated rule. The coordinate choice
belongs to the tap author, not the framework.

#### The sampled-data extension

**The sampled-data `Dual` activation is [recorded, not built](#g-recorded-not-built)**, a worked-out extension
deliberately left unimplemented with its seams named ([D-073][d-073]). The frozen-exact
doctrine is consumer-scoped, not a capability wall. Trim and linearization
differentiate the continuous dynamics with the discrete state held, and for that
a frozen discrete output (a zero-order-hold constant with zero partials) is the
exact answer, as [§7.2][s7-2] states ([D-072][d-072]). The frozen discrete cell is not an AD
limitation on the signal path. It is the true zero of an instantaneous
dependence that the hybrid semantics never had. The signal flow through a
discrete component is temporal, not instantaneous, and AD follows the actual
data movement. `frozen_discrete_walkthrough.md` works the three-component chain
through.

Differentiating "through" the discrete side means differentiating a
*different object*. That object is the sampled-data step map
$\Phi : ((x_k, s_k), \mathrm{inputs}) \to (x_{k+1}, s_{k+1})$, taken over the
model's *whole* state, both letters at once. One evaluation of $\Phi$
integrates one period, then runs the [due](#g-due) [ticks](#g-tick). The
extension is additive along existing [seams](#g-seam).

- [Walked](#g-walked)-leaf parametrization of the discrete tier's real-scalar
  state leaves. Counters and enums stay pinned, like `m`.
- Opt-in participation on discrete components, with frozen-exact staying the
  default. A participating component opts in through an explicit trait, and
  that trait turns the walk on for its [contracts](#g-contract) (its declared
  interface). Its `Float64` leaves follow the scalar and `Pinned` keeps its
  meaning, exactly as on the continuous tier ([§8.2][s8-2]). Participation
  therefore stays authored per leaf on that tier too, and no declaration
  changes shape, which gives graceful migration with no flag day.
- One new activation, "continuous chain + `x_deriv` + the discrete tier's
  output stages + `s_update`" ([§9.4][s9-4]).
- Forward sensitivities through the in-house RK steppers, for free. That is a
  payoff of owning the loop ([§10.1][s10-1]).
- **A distinct `s`-tap list sits beside the `x` list**, labeling the step
  map's state blocks $\partial(x^+, s^+)/\partial(x, s)$ ([D-197][d-197]). The
  `x` list keeps its continuous meaning unchanged.

The honest limit is that $\Phi$ is differentiable only where the event pattern
is locally constant. Exactness across a firing needs saltation corrections (the
jump terms a sensitivity takes across an event). The scope is therefore
event-quiescent operating points, which trim points already are, because [guards](#g-guard)
at commit see to that ([§14.5][s14-5]). The scope comes with a loud diagnostic if an
event fires inside a differentiated step. Two consumers wait. The first is the
closed-loop trim extension ([§14.7][s14-7]), whose `s_update(s) - s = 0` residuals would
currently need the derivative-free fallback, since a frozen `s_update` has no
Jacobian columns. The second is exact discrete-time linearization of the full
loop, which is digital design on the exact discretized plant instead of
continuous linearization plus Tustin's discretization.

#### Declared non-participation

Both halves of non-participation have a spelling ([D-263][d-263]). The output half is the
freeze door, which declares a leaf frozen under differentiation as [§8.2][s8-2] and [§9.5][s9-5]
spell it ([D-286][d-286]). An opaque wrapper, such as an FMU (a Functional Mock-up Unit,
a packaged external model) or a C aerodynamic table, and a deliberately severed
coupling can therefore both say so in the schema, instead of showing up in
Jacobians as unexplained zero rows. The conformance check holds them to it at
every activation ([D-286][d-286]). The input half is the FFI door ([§8.2][s8-2]). A consumer's
`Pinned` input entry declares "never hand me partials", enforced at the wire
([§6.1][s6-1], [D-263][d-263]). At a root input, such an input entry *is* the forbid-seeding marker
itself. That marker carries semantics rather than mere protection, because it
types the root-input cell at every activation. An unseeded root input is
therefore a *choice*, where a `Pinned`-entry root input is a *declaration* ([D-295][d-295]).

An implementation that cannot take `Dual`s has a third move. The marker records
that a leaf carries no partials, not that an implementation cannot propagate
them. **A component that must participate keeps its input entry tolerant and
supplies its own local derivative inside the stage** ([D-266][d-266]). A C table or an FMU
whose coupling matters to the Jacobian is such a component. It evaluates at the
value and obtains a local Jacobian by whatever means it has, such as a finite
difference at a step its own grid suggests or the table's analytic slope. It
then chains that Jacobian onto the incoming partials ([D-266][d-266]).

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

The block strips the partials with `ForwardDiff.value` mid-expression, which [§9.5][s9-5]
leaves legal at an unpinned leaf, and the seeded pass sees the component as an
ordinary differentiable one. The derivative is finite-difference in quality on
this one component and exact everywhere else. **Linearization keeps this one
mechanism and no perturbation-based fallback** ([D-266][d-266]). The derivative-free trim
fallback ([§14.8][s14-8]) would serve problems with no Jacobian columns, a case
linearization does not have. `handle_walk_walkthrough.md` places the rule beside
the `Freeze` block ([§13.7][s13-7]) and the pinned input entry.

What stays recorded is only the remaining tooling over the schema's declared
non-participation. One piece is pinned-face validation by the tap declaration,
where selecting a declared-frozen output is a warning. The other is a
[feedthrough](#g-feedthrough)-graph lint, where a frozen output fed by participating inputs names
the severed coupling. Both are additive when a consumer shows up, with no flag
day. Until then the declared pins and the visible zero rows suffice.

---


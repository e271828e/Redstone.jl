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


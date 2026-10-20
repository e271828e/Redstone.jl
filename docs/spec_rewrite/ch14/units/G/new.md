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

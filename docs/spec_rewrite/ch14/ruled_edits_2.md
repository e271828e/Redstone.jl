# Chapter 14, step 6: the ruled edits, half 2 (units F, G and H)

Each entry gives the ruling, the unit, and the old and new text of the edited
paragraph, bullet or code line, verbatim. Replay them in order on the units as
`chapter_fixes_2.md` left them: an entry's old text is the file as the entries
before it left it. Every edited paragraph or bullet is rewrapped to 80 rendered
columns (link markup collapsed, `*` and backticks not counted), so the old and
new blocks are whole paragraphs. A code-line edit is not rewrapped. Entries
run in the order applied, so B13 follows B4. B11 keeps its restatement, "For
design tasks the rig stays `design_world(ac)`", minus "shipped": it carries the
one claim the bold lacks (design tasks still use `design_world(ac)` after the
test-rig idiom) and is the antecedent of "That keeps".

## B4, unit F, from line 164 of the edited file

Old:

````text
**The FlightPhysics formulation's core is correct and survives verbatim as
user math** ([D-069][d-069]). That core is analytic elimination, namely
FlightPhysics' `θ_constraint` substituting the pitch constraint, filter and
actuator equilibria imposed by construction, and the minimal 7-variable
search over `c172.jl`'s `TrimState`.
````

New:

````text
**Flight.jl's trim formulation is correct at its core and survives verbatim as
user math** ([D-069][d-069]). That core is analytic elimination, namely FlightPhysics'
`θ_constraint` substituting the pitch constraint, filter and actuator equilibria
imposed by construction, and the minimal 7-variable search over `c172.jl`'s
`TrimState`.
````

## B13, unit F, from line 93 of the edited file

Old:

````text
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
````

New:

````text
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
````

## B7, unit G, line 218 of the edited file (a code line, not rewrapped)

Old:

````text
    reads      = at(prefix, p.reads),              #inert selector data: the prefix joins the read set's mount chain
````

New:

````text
    reads      = at(prefix, p.reads),              #inert selector data: the prefix is prepended to the read set's mount chain
````

## B8, unit G, from line 81 of the edited file

Old:

````text
A non-empty fired-event set also raises `TrimCommitEvents` ([Appendix C][sC], [D-126][d-126]).
The committed stores then sit at the post-handler point, not the reported
solution, and that is the point `linearize` reads by default.
````

New:

````text
A non-empty fired-event set also raises `TrimCommitEvents`, a logged warning
([Appendix C][sC], [D-126][d-126]). The committed stores then sit at the post-handler point,
not the reported solution, and that is the point `linearize` reads by default.
````

## B9, unit G, from line 52 of the edited file

Old:

````text
- `residuals` are the solved-point residuals, and `tolerances` the
  tolerances they come with ([§14.5][s14-5], [D-155][d-155]). They are the
  very numbers the verdict is read off, gathered at the backend's returned
  point.
````

New:

````text
- `residuals` are the solved-point residuals, and `tolerances` the tolerances they
  come with ([D-155][d-155]). They are the very numbers the verdict is read off, gathered
  at the backend's returned point.
````

## B10, unit H, from line 44 of the edited file

Old:

````text
The three lists are validated at resolution, with [did-you-mean](#g-did-you-mean) errors (the
offending name plus the list-in-hand it should have matched). Those errors are
the selectors' own `ReadResolution` ([D-406][d-406]). The `x` list is validated against the
`x_init` [stores](#g-store) of the continuous [tier](#g-tier) (the continuous or discrete side of the
hybrid formalism), the `u` list against [faces](#g-face), and the `y` list against `y_types`. **An
`x` tap naming a discrete store is rejected at resolution** as a `TapResolution`, with
the tap and its tier in hand ([D-197][d-197]). That is the no-silent-zeros rule again
([D-197][d-197]). The discrete tier is frozen ([§8.2][s8-2]), so its only possible partials are
zeros. The rejection's next-move guidance points at the recorded step-map
extension below. The lists compile to offsets once, and relocate whole via
`at(prefix, taps)` ([D-072][d-072]). The shuttle layer's successor is that compiled
writer/reader pair, and **no hand-written state-space mapping remains** ([§7.1][s7-1],
[D-072][d-072]).
````

New:

````text
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
````

## B11, unit G, from line 282 of the edited file

Old:

````text
"Aircraft as root" is a thin rig. **Design tasks use a shipped rig,
[`design_world(ac)`](#g-design_world)** ([D-071][d-071]). They need one because by default the aircraft is not
literally the root. Its environment inputs are function-valued signals ([§4.4][s4-4]),
wired from provider components. The rig is `design_world(ac)` = aircraft +
`SimpleAtmosphere(wind = NoWind())` + `HorizontalTerrain`, where `SimpleAtmosphere`
and `NoWind` are FlightPhysics' atmosphere types. `design_world` promotes the ad-hoc
atmosphere and terrain FlightCore `Model`s inside Flight.jl's `linearize` to a named
artifact. There is one mechanism. The "root" case is the shallowest world, and
the trim problem mounts at `"aircraft"` like anywhere else.
````

New:

````text
"Aircraft as root" is a thin rig. **Design tasks use the rig this design records,
[`design_world(ac)`](#g-design_world)** ([D-071][d-071]). They need one because by default the aircraft is not
literally the root. Its environment inputs are function-valued signals ([§4.4][s4-4]),
wired from provider components. The rig is `design_world(ac)` = aircraft +
`SimpleAtmosphere(wind = NoWind())` + `HorizontalTerrain`, where `SimpleAtmosphere`
and `NoWind` are FlightPhysics' atmosphere types. `design_world` promotes the ad-hoc
atmosphere and terrain FlightCore `Model`s inside Flight.jl's `linearize` to a named
artifact. There is one mechanism. The "root" case is the shallowest world, and
the trim problem mounts at `"aircraft"` like anywhere else.
````

## B11, unit G, from line 292 of the edited file

Old:

````text
Leaving an environment face *unconnected* is legal by construction, though, for
an isbits handle ([D-364][d-364]). The face becomes an ordinary root input
holding the handle *value*, written by the `baseline` like any other root input.
That is the test-rig idiom. It is the function-valued sibling of a constant
source, with zero ceremony for a frozen environment. **A handle that references
bulk data is never a root input**, and the rig wires a constant source holding
it ([D-364][d-364]). Root inputs are traced and checkpointed by value, and
[§4.4][s4-4] states why such a handle cannot be one ([D-237][d-237]). For design
tasks the shipped rig stays `design_world(ac)`. That keeps the environment's
tunables in the root-input vocabulary that conditions, linearization's input
surface and the [trace header](#g-trace-header) (the trace's fixed preamble)
already speak.
````

New:

````text
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
````

## B12, unit G, from line 172 of the edited file

Old:

````text
- In-model saturations (actuator limits, idle/FRC clamps) zero Jacobian
  columns when active. FRC is the friction constraint compensator of
  FlightPhysics' piston engine (`piston.jl`). LM damping tolerates the rank
  deficiency, and the report names the saturated variable ([D-070][d-070]).
  Cruise trim leaves those saturations inactive.
````

New:

````text
- In-model saturations (actuator limits, idle/FRC clamps) zero Jacobian columns
  when active. FRC is the friction constraint compensator of FlightPhysics'
  piston engine (`piston.jl`). LM damping tolerates the rank deficiency ([D-070][d-070]).
  The report's `saturated` list names a decision only at its own bound, so an
  in-model saturation shows in the Jacobian's zero columns rather than in the
  report. Cruise trim leaves those saturations inactive.
````

## B14, unit H, from line 80 of the edited file

Old:

````text
Each invocation instantiates its own scratch store set, the trim service's
mechanism verbatim ([§14.8][s14-8]), and establishes the operating point in it (above).
**It then runs the seeded `Dual` evaluation**, one direction per `x` tap and per `u` tap,
in groups of `width` directions per pass ([D-072][d-072]). **`width` is a keyword of `linearize`,
default 8** ([D-272][d-272]). The default width's scalar type is public. A build can
therefore pre-materialize its [activation](#g-activation) (the build's typed products at a given
scalar type) through `activations` ([§9.4][s9-4]), and a tap set of any size then
linearizes with no compile at the keyboard ([D-272][d-272]). Value parts give `ẋ₀` and `y₀`.
Partials give `A` and `B` against the `x`- and `u`-seeds, and `C` and `D` against the same
seeds read at `y`. All four come out simultaneously, exact to machine precision.
`linearization_walkthrough.md` runs the pass on a two-state model, seed by seed.
````

New:

````text
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
````

## B15, unit H, from line 24 of the edited file

Old:

````text
**A tap names one scalar** ([D-272][d-272]). Its [leaf address](#g-leaf-address) (the field name with dotted and
bracketed steps below it) resolves to one scalar leaf ([§14.4][s14-4], [D-276][d-276]). So a
vector leaf yields *named scalars*, one tap per element. A seeded tap, in the `x` or
`u` list, reaches its scalar through one index step at most and never a `.name`
step, because a seed is written into a whole state field or [root input](#g-root-input) (the
root's own input face), or into one array element of it. A seeded tap's leaf is
exactly `Float64`. A `y` tap is a read and takes any leaf address. A tap resolving
to a vector or a struct is rejected at resolution as a `TapResolution`, and so is
a member in the wrong list. A second tap resolving to a site already seeded is
rejected naming the earlier label, since one site is one column and a second
seed there would overwrite the first ([D-272][d-272]).
````

New:

````text
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
````

## B16, unit G, from line 132 of the edited file

Old:

````text
An *empty* problem is none of them either. **`TrimProblem(guess = (;), …)` is legal**,
not `TrimProblemInvalid` ([D-156][d-156]). With zero decision variables the solver is
bypassed outright. There is nothing to pack, no seeded activation and no backend
call. The service simply evaluates the residuals once at
`override(baseline, condition((;)))`, the baseline with whatever the problem's
condition sets. The ordinary box test decides `converged`, and the commit runs as
usual. The empty problem asks "is this operating point an equilibrium?" It
evaluates this condition's equations and reports, which is useful in its own
right and free.
````

New:

````text
An *empty* problem is none of them either. **`TrimProblem(guess = (;), …)` is legal**,
not `TrimProblemInvalid` ([D-156][d-156]). With zero decision variables the solver is
bypassed outright. There is nothing to pack, no seeded activation and no backend
call. The service simply evaluates the residuals once at
`override(baseline, condition((;)))`, the baseline with whatever the problem's
condition sets. The ordinary box test decides `converged`, and the commit runs as
usual. The empty problem asks "is this operating point an equilibrium?" It
evaluates this condition's equations and reports, which is useful in its own
right and costs no solve.
````

## B17, unit H, line 133 of the edited file (a table row, not rewrapped)

Old:

````text
| a root input whose entry is declared `Pinned` | frozen at every activation, and rejected as a `B`-matrix tap | the schema: a declaration |
````

New:

````text
| a root input whose input entry is declared `Pinned` | frozen at every activation, and rejected as a `B`-matrix tap | the schema: a declaration |
````

## B18, unit H, from line 68 of the edited file

Old:

````text
**The default operating point is the [checkpoint](#g-checkpoint)** of the simulation or the [`Model`](#g-model) (a
deployment materialized at one scalar type) as it stands ([D-274][d-274], [D-319][d-319]). A
checkpoint is the `Model`'s state at a frame top as one value. It is
`checkpoint(sim)` on a simulation and `checkpoint(model)` on a `Model`, each restored
into the scratch world with no boundary zero ([§12.6][s12-6], [D-274][d-274], [D-319][d-319]). The frozen
tier's [cells](#g-cell) (the typed entries of the signal table) are the checkpoint's held
cells. After a `trim!` commit, `linearize(sim, taps)` or `linearize(model, taps)` is
about the trim point with nothing re-specified. **`about = <condition>`, with `t0`
beside it, linearizes anywhere else without touching the sim** ([D-272][d-272]). `t0` is
admitted only there, and a `t0` passed without `about` is an `ArgumentInvalid`.
````

New:

````text
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
````

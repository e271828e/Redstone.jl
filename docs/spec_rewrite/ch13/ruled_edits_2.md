# Chapter 13: ruled edits, units F and G (step 6)

Each entry gives the item, the unit, and the whole paragraph before and
after the edit, verbatim from `units/<U>/new.md`, rewrap included.
Replace each old paragraph with its new one, in order.

## B8, unit F

Old:

````text
The requester roster (the build's list of stop requests, one
`Requester(path, port, reason)` per `StopFlag` output port, in build order)
names every request. **The build records one `Requester(path, port, reason)`
per `StopFlag` output port**, as the `requesters` of the activation's cell
layout, index-aligned with the `StopFlag` block ([D-316][d-316]). The
requester at index `i` owns the block's offset `i - 1`, and requester roster
order is build order. The reason is the publishing component's `stop_reason`,
an optional declaration with default `""` ([§8.2][s8-2]). One reason serves
all of a component's requests. It is instance data on the component, never a
port value.
````

New:

````text
**The build records one `Requester(path, port, reason)` per `StopFlag` output
port**, as the `requesters` of the activation's cell layout, index-aligned with
the `StopFlag` block ([D-316][d-316]). This list is the requester roster (the build's
list of stop requests, one `Requester(path, port, reason)` per `StopFlag` output
port, in build order), and it names every request. The requester at index `i`
owns the block's offset `i - 1`. The reason is the publishing component's
`stop_reason`, an optional declaration with default `""` ([§8.2][s8-2]). One reason
serves all of a component's requests. It is instance data on the component,
never a port value.
````

## B13 (cut), unit F

Old:

````text
Every advance checks the latest snapshot for an honoured request before its
first frame. After `init!` that snapshot is boundary zero's, so an authored
[condition](#g-condition) (the path-addressed sparse overlay that sets a
build's state) already terminal ends the run at `t₀` with that snapshot
final, integrating nothing. A run that starts later ends where it started,
advancing no frame. The request is the author's and the ignore list the
integrator's, and the ignore list sits beside `t_end` at the same
declaration site.
````

New:

````text
Every advance checks the latest snapshot for an honoured request before its
first frame. After `init!` that snapshot is boundary zero's, so an authored
[condition](#g-condition) (the path-addressed sparse overlay that sets a build's state) already
terminal ends the run at `t₀` with that snapshot final, integrating nothing. A
run that starts later ends where it started, advancing no frame.
````

## B13 (move), unit F

Old:

````text
[§12.6][s12-6] declares the stop policy per advance, with `t_end` and
`ignore_stop_requests` as keywords of `run!`, `replay!` and `step!`, and gives
the value's lifetime. Each of the three calls takes `Inf` and `()` as the
defaults ([D-255][d-255]). The defaults belong to the calls that take the policy. With no
constructor defaults the [trace header](#g-trace-header) (the trace's fixed preamble) has no policy
to record ([§11.5][s11-5]). The [termination record](#g-termination-record) (the stopped-sim value naming how the
run ended) carries the policy that actually ended the run.
````

New:

````text
[§12.6][s12-6] declares the stop policy per advance, with `t_end` and
`ignore_stop_requests` as keywords of `run!`, `replay!` and `step!`, and gives
the value's lifetime. Each of the three calls takes `Inf` and `()` as the
defaults ([D-255][d-255]). The defaults belong to the calls that take the policy. With no
constructor defaults the [trace header](#g-trace-header) (the trace's fixed preamble) has no policy
to record ([§11.5][s11-5]). The [termination record](#g-termination-record) (the stopped-sim value naming how the
run ended) carries the policy that actually ended the run. The ignore list sits
beside `t_end` at the same declaration site.
````

## B14, unit F

Old:

````text
Placement is checked at build. **Two placements are `IllegalPortType`**
([D-316][d-316]). A `StopFlag` leaf nested inside a port of another type is
refused with reason `:stop_flag_nested`, and a root input whose type carries a
`StopFlag` anywhere with reason `:stop_flag_at_root`. The first is refused
because the build lists requests per port, so a request inside a struct field
or a static array would have no listing of its own. The second is refused
because a request is the model's, never an operator's. The operator's path is
the control plane ([§12.1][s12-1]). A `StopFlag` input port places nothing and
is left alone.
````

New:

````text
Placement is checked at build. **Two placements are `IllegalPortType`** ([D-316][d-316]). A
`StopFlag` leaf nested inside a port of another type is refused with reason
`:stop_flag_nested`, and a root input whose type carries a `StopFlag` anywhere
with reason `:stop_flag_at_root`. The first is refused because the build lists
requests per port, so a request inside a struct field or a static array would
have no listing of its own. The second is refused because a request is the
model's, never an operator's. A `StopFlag` input port places nothing and is left
alone.
````

## B17, unit F

Old:

````text
Publication is a [stop request](#g-stop-request) (an output port of the framework enum `StopFlag`),
declared where the stop's `Bool` is detected. **A port whose type is exactly
`StopFlag` is a stop request**, whoever publishes it ([D-316][d-316]). The enum is
`@enum StopFlag NO_STOP STOP_REQUESTED`. An enum is one leaf, pinned at every
activation ([§4.3][s4-3]), and [cells](#g-cell) (typed entries of the signal table) are stored per
element type ([§9.7][s9-7]), so every request in the model lands in one `StopFlag`
block. The stop's `Bool` is gathered at the boundary of the assembly that owns
it, in one visible block. The landing gear `Ldg` from the example of [§6.1][s6-1] ORs
its three legs through a junction (the ownership idiom, [§6.2][s6-2]; the library,
[§13.7][s13-7]). It wires the result into a `StopRequest` child, the library's spelling
of a request, described below. No level above it re-exports anything, because
the loop reads the request where it is.
````

New:

````text
Publication is a [stop request](#g-stop-request) (an output port of the framework enum `StopFlag`),
declared where the stop's `Bool` is detected. **A port whose type is exactly
`StopFlag` is a stop request**, whoever publishes it ([D-316][d-316]). The enum is
`@enum StopFlag NO_STOP STOP_REQUESTED`. An enum is one leaf, pinned at every
activation ([§4.3][s4-3]), and [cells](#g-cell) (typed entries of the signal table) are stored per
element type ([§9.7][s9-7]), so every request in the model lands in one `StopFlag`
block. The stop's `Bool` is gathered at the boundary of the assembly that owns
it, in one visible block. The landing gear `Ldg` from the example of [§6.1][s6-1] ORs
its three legs through a junction (the ownership idiom, [§6.2][s6-2]; the library,
[§13.7][s13-7]). It wires the result into a `StopRequest` child, described below. No
level above it re-exports anything, because the loop reads the request where it
is.
````

## B20, unit F

Old:

````text
Publication is a [stop request](#g-stop-request) (an output port of the framework enum `StopFlag`),
declared where the stop's `Bool` is detected. **A port whose type is exactly
`StopFlag` is a stop request**, whoever publishes it ([D-316][d-316]). The enum is
`@enum StopFlag NO_STOP STOP_REQUESTED`. An enum is one leaf, pinned at every
activation ([§4.3][s4-3]), and [cells](#g-cell) (typed entries of the signal table) are stored per
element type ([§9.7][s9-7]), so every request in the model lands in one `StopFlag`
block. The stop's `Bool` is gathered at the boundary of the assembly that owns
it, in one visible block. The landing gear `Ldg` from the example of [§6.1][s6-1] ORs
its three legs through a junction (the ownership idiom, [§6.2][s6-2]; the library,
[§13.7][s13-7]). It wires the result into a `StopRequest` child, described below. No
level above it re-exports anything, because the loop reads the request where it
is.
````

New:

````text
Publication is a [stop request](#g-stop-request), an output [port](#g-port) (the addressable unit of the
model) of the framework enum `StopFlag`, declared where the stop's `Bool` is
detected. **A port whose type is exactly `StopFlag` is a stop request**, whoever
publishes it ([D-316][d-316]). The enum is `@enum StopFlag NO_STOP STOP_REQUESTED`. An
enum is one leaf, pinned at every activation ([§4.3][s4-3]), and [cells](#g-cell) (typed entries of
the signal table) are stored per element type ([§9.7][s9-7]), so every request in the
model lands in one `StopFlag` block. The stop's `Bool` is gathered at the
boundary of the assembly that owns it, in one visible block. The landing gear
`Ldg` from the example of [§6.1][s6-1] ORs its three legs through a junction (the
ownership idiom, [§6.2][s6-2]; the library, [§13.7][s13-7]). It wires the result into a
`StopRequest` child, described below. No level above it re-exports anything,
because the loop reads the request where it is.
````

## B22, unit F

Old:

````text
**The termination record names the source, as a typed value** ([D-203][d-203]).
The run's termination record carries its *outcome*, and the `StopPolicy` of
the advance that ended it ([D-255][d-255]). The record holds four things, the
final boundary time, the terminating policy, the source and the tail residue
(the post-account diagnostics the run's-end sweep folds in). [§11.8][s11-8]
specifies that sweep. **The time is always present**, because boundary zero
precedes every record and a throw inside boundary zero writes none
([§12.6][s12-6], [D-233][d-233]). The source follows the diagnostic
convention, so its type is its identity and its payload is plain data
([§13.2][s13-2], [D-203][d-203]). There are four source types.
````

New:

````text
**The termination record names the source, as a typed value** ([D-203][d-203]). The run's
termination record carries its *outcome*, and the `StopPolicy` of the advance that
ended it ([D-255][d-255], [D-260][d-260]). The record holds four things, the final boundary time,
the terminating policy, the source and the tail residue (the post-account
diagnostics the run's-end sweep folds in). [§11.8][s11-8] specifies that sweep. **The time
is always present**, because boundary zero precedes every record and a throw
inside boundary zero writes none ([§12.6][s12-6], [D-233][d-233]). The source follows the
diagnostic convention, so its type is its identity and its payload is plain data
([§13.2][s13-2], [D-203][d-203]). There are four source types.
````

## B86, unit F

Old:

````text
Rejecting observation-by-path separates inspection from the reads a run acts on,
a line [D-316][d-316] narrows. Inspection is human-facing, has no effect on run
semantics, and legitimately sees every public cell. The log retaining the full
table, a front end's panels rendering a component's ports, and inspection under
[replay](#g-replay) (the ordinary loop re-driven from a recorded trace) are all inspection. A
read the run acts on changes what the run *does*, and it reads only what the model
declared for it, never an arbitrary cell. The stop scan is the one such read. It
reads the `StopFlag` block, which holds nothing but the requests their authors
declared by type. [§13.3][s13-3] scopes path resolution by client, on a line of its own.
The ignore list addresses the `Build`'s requester roster, a build product like
the root-input list. It binds at an advance, a stopped-sim point where
conditions already address state by path ([§14.1][s14-1]). The requester is loud at
inspection, since the requester roster and the termination record name it.
Substitution is answered by the ignore list, and disabling is one keyword. The
trigger is the author's knowledge and the ignore list the integrator's. Output
devices are the other half of the same doctrine. Their reads are inspection on
snapshot paths ([§11.2][s11-2]), though attach resolves them strictly, as [§13.3][s13-3]'s service
clients ([D-406][d-406]).
````

New:

````text
Rejecting observation-by-path separates inspection from the reads a run acts on,
a line [D-316][d-316] narrows. Inspection is human-facing, has no effect on run
semantics, and legitimately sees every public cell. The log retaining the full
table, a front end's panels rendering a component's ports, and inspection under
[replay](#g-replay) (the ordinary loop re-driven from a recorded trace) are all inspection. A
read the run acts on changes what the run *does*, and it reads only what the model
declared for it, never an arbitrary cell. The stop scan is the one such read. It
reads the `StopFlag` block, which holds nothing but the requests their authors
declared by type. [§13.3][s13-3] scopes path resolution by client, on a line of its own.
The ignore list addresses the `Build`'s requester roster, a build product like
the root-input list. It binds at an advance, a stopped-sim point where
conditions already address state by path ([§14.1][s14-1]). The requester is loud at
inspection, since the requester roster and the termination record name it. A
substitution that changes when runs end is answered by the ignore list ([D-060][d-060]),
and disabling is one keyword. The trigger is the author's knowledge and the
ignore list the integrator's. Output devices are the other half of the same
doctrine. Their reads are inspection on snapshot paths ([§11.2][s11-2]), though attach
resolves them strictly, as [§13.3][s13-3]'s service clients ([D-406][d-406]).
````

## B2, unit G

Old:

````text
The build diagnostic offers both exits explicitly ([D-140][d-140],
[D-343][d-343]). For a loop between `systems/aero` and `systems/dyn` it reads
"artificial at port level: `systems/aero`'s `F` does not route `a`; split
`systems/aero`, or narrow the neighbor's contract if `a` is consumed only in a
fallback branch". The dead hop is the member's input face that its stage-2
function does not route to the output port. The diagnostic carries the dead
hop ([D-245][d-245]) as a separate field of its [payload](#g-payload) (the
structured data a diagnostic carries) rather than dotting the hop onto the
path ([§8.6][s8-6], [§13.2][s13-2]).
````

New:

````text
The build diagnostic offers both exits explicitly ([D-140][d-140], [D-343][d-343]). For a loop
between `systems/aero` and `systems/dyn` it reads "artificial at port level:
`systems/aero`'s `F` does not route `a`; split `systems/aero`, or narrow the
neighbor's contract if `a` is consumed only in a fallback branch". The dead hop
runs from the member's input face that its stage-2 function does not route to
the output port. The diagnostic carries the dead hop ([D-245][d-245]) as a separate field
of its [payload](#g-payload) (the structured data a diagnostic carries) rather than dotting
the hop onto the path ([§8.6][s8-6], [§13.2][s13-2]).
````

## B3, unit G

Old:

````text
The starting inventory holds the `Junction`, with `SumJunction{V, N}`,
`Or{N}` and `And{N}` as its named forms, `UnitDelay{V}`, `Constant{V}`,
`Freeze{V}` and `StopRequest`. The shipped list lives in
`companions/library_inventory.md`. `UnitDelay` is the spelling the second
loop-breaking remedy ([§5.5][s5-5]) needs. `Constant{V}` is the source block
([D-143][d-143]). `Freeze{V}` is the declared stop-gradient ([D-266][d-266]).
`StopRequest` is the library spelling of a [stop request](#g-stop-request) (a
port that ends the run when it reads `STOP_REQUESTED`) ([§13.5][s13-5],
[D-316][d-316]). The request is its port's `StopFlag` type, which any
component may publish, so the block holds no privilege.
````

New:

````text
The starting inventory holds the `Junction`, with `SumJunction{V, N}`, `Or{N}`
and `And{N}` as its named forms, `UnitDelay{V}`, `Constant{V}`, `Freeze{V}` and
`StopRequest`. The shipped list lives in `companions/library_inventory.md`.
`UnitDelay` is the spelling the second loop-breaking remedy ([§5.5][s5-5]) needs.
`Constant{V}` is the source block ([D-143][d-143]). `Freeze{V}` is the declared
stop-gradient ([D-266][d-266]). `StopRequest` is the library spelling of a [stop request](#g-stop-request)
(an output port of the framework enum `StopFlag`) ([§13.5][s13-5], [D-316][d-316]). The request is
its port's `StopFlag` type, which any component may publish, so the block holds
no privilege.
````

## B5, unit G

Old:

````text
The demonstrated need is the root-input rule ([§8.2][s8-2]). An [abstract entry](#g-abstract-entry) (an
`u_types` entry admitting any concrete producer face), such as the illustrative
`terrain = AbstractTerrainField`, cannot surface as a root input, because
abstract-at-root is a build error, `AbstractAtRoot` ([§8.2][s8-2], [Appendix C][sC]). The rig
therefore satisfies that entry *inside* the rig ([D-120][d-120]). In the sketch below, the
component under test is `Strut`, an illustrative landing-gear strut whose
terrain input is abstract. **A concrete stub child (a provider of
`SampleTerrainField`, an illustrative concrete terrain) is wired to the face**,
and the concrete remainder is exposed via
`input_passthrough(rig, "strut"; except = ("terrain",))` ([D-120][d-120]).
````

New:

````text
The demonstrated need is the root-input rule ([§8.2][s8-2]). An [abstract entry](#g-abstract-entry) (an
`u_types` entry admitting any concrete producer face), such as the illustrative
`terrain = AbstractTerrainField`, cannot surface as a root input, because
abstract-at-root is a build error, `AbstractAtRoot` ([§8.2][s8-2], [Appendix C][sC]). The rig
therefore satisfies that entry *inside* the rig ([D-120][d-120]). In the sketch below, the
component under test is `Strut`, an illustrative landing-gear strut whose
terrain input is abstract. **A concrete stub child is wired to the face**, and the
concrete remainder is exposed via
`input_passthrough(rig, "strut"; except = ("terrain",))` ([D-120][d-120]). The stub
provides `SampleTerrainField`, an illustrative concrete terrain.
````

## B7 (sampled mode), unit G

Old:

````text
- The *global* (value-blind) set-tracer is a `Real` subtype that carries a set
  of input indices, unioned by every operation. It has
  may-depend semantics, a sound over-approximation. A saturated `clamp` still
  reports, and $u^2$ at $u = 0$ still reports. It is exact, in one evaluation.
  It requires the traced stage-2 code to be free of branches and lookups on
  *input-tainted* values.
- The *sampled* set-tracer (the local, primal-carrying mode) at sampled states
  is the fallback whenever the global tracer hits an undecidable branch, such
  as piecewise friction, stall blending or any gridded lookup at an
  input-tainted coordinate. It reports the dependence pattern of the taken
  paths, sampled across randomized states. Its only misses are untaken
  branches ([D-012][d-012], [D-349][d-349]).
````

New:

````text
- The *global* (value-blind) set-tracer is a `Real` subtype that carries a set
  of input indices, unioned by every operation. It has
  may-depend semantics, a sound over-approximation. A saturated `clamp` still
  reports, and $u^2$ at $u = 0$ still reports. It is exact, in one evaluation.
  It requires the traced stage-2 code to be free of branches and lookups on
  *input-tainted* values.
- The *sampled* set-tracer (the log's *local* mode) at sampled states is the
  fallback whenever the global tracer hits an undecidable branch, such as
  piecewise friction, stall blending or any gridded lookup at an input-tainted
  coordinate. It reports the dependence pattern of the taken paths, sampled
  across randomized states. Its only misses are untaken branches ([D-012][d-012], [D-349][d-349]).
````

## B7 (per-member variant), unit G

Old:

````text
Classification touches no activation machinery. There is no
[activation](#g-activation) (the build's typed products at a given scalar
type), no layouts and no table. The cycle classifier uses the *per-member*
(local) variant of tracing, the order-free per-member trace at the probe point
([D-012][d-012]). The "tracer activation" ([§9.4][s9-4]) names the other
variant ([D-012][d-012]), the global set-tracer run as an ordinary activation.
The two must not be conflated. The per-member variant is not the sampled mode.
A member's map may come from either mode.
````

New:

````text
Classification touches no activation machinery. There is no [activation](#g-activation) (the
build's typed products at a given scalar type), no layouts and no table. The
cycle classifier uses the *per-member* variant of tracing (the log's *local*
variant), an order-free trace at the probe point ([D-012][d-012]). The "tracer
activation" ([§9.4][s9-4]) names the other variant ([D-012][d-012]), the global set-tracer run as
an ordinary activation. The two must not be conflated. The per-member variant is
not the sampled mode. A member's map may come from either mode.
````

## B12, unit G

Old:

````text
**A block joins the library's inventory by judgement against three
guidelines** ([D-313][d-313]). The guidelines ask whether a block is
domain-agnostic and generally useful, whether it has didactic value, and
whether its implementation is difficult to get right. None is a
requirement. They are weighed, not satisfied one by one, and a listed block
is built whenever wanted. The inventory, and the Simulink mapping that
prunes it, is `companions/library_inventory.md`. A one-line expression such
as a gain earns no block, because a separate component costs a build entry,
a cell, a gather and a scatter ([§9.7][s9-7]). Domain components, such as
aerodynamics, engines or sensors, belong in separate packages built on the
framework. Simulink's library is a language, while this is a toolbox.
````

New:

````text
**A block joins the library's inventory by judgement against three guidelines**
([D-313][d-313]). The guidelines ask whether a block is domain-agnostic and generally
useful, whether it has didactic value, and whether its implementation is
difficult to get right. None is a requirement. They are weighed, not satisfied
one by one, and a listed block is built whenever wanted. A one-line expression
such as a gain earns no block, because a separate component costs a build entry,
a cell, a gather and a scatter ([§9.7][s9-7]). Domain components, such as aerodynamics,
engines or sensors, belong in separate packages built on the framework.
Simulink's library is a language, while this is a toolbox.
````

## B16, unit G

Old:

````text
The starting inventory holds the `Junction`, with `SumJunction{V, N}`, `Or{N}`
and `And{N}` as its named forms, `UnitDelay{V}`, `Constant{V}`, `Freeze{V}` and
`StopRequest`. The shipped list lives in `companions/library_inventory.md`.
`UnitDelay` is the spelling the second loop-breaking remedy ([§5.5][s5-5]) needs.
`Constant{V}` is the source block ([D-143][d-143]). `Freeze{V}` is the declared
stop-gradient ([D-266][d-266]). `StopRequest` is the library spelling of a [stop request](#g-stop-request)
(an output port of the framework enum `StopFlag`) ([§13.5][s13-5], [D-316][d-316]). The request is
its port's `StopFlag` type, which any component may publish, so the block holds
no privilege.
````

New:

````text
The starting inventory holds the `Junction`, with `SumJunction{V, N}`, `Or{N}`
and `And{N}` as its named forms, `UnitDelay{V}`, `Constant{V}`, `Freeze{V}` and
`StopRequest`. The shipped list lives in `companions/library_inventory.md`.
`UnitDelay` is the spelling the second loop-breaking remedy ([§5.5][s5-5]) needs.
`Constant{V}` is the source block ([D-143][d-143]). `Freeze{V}` is the declared
stop-gradient ([D-266][d-266]). `StopRequest` is the library spelling of a [stop request](#g-stop-request)
(an output port of the framework enum `StopFlag`) ([§13.5][s13-5], [D-316][d-316]).
````

## B12 (amended), unit G

Old:

````text
The starting inventory holds the `Junction`, with `SumJunction{V, N}`, `Or{N}`
and `And{N}` as its named forms, `UnitDelay{V}`, `Constant{V}`, `Freeze{V}` and
`StopRequest`. The shipped list lives in `companions/library_inventory.md`.
`UnitDelay` is the spelling the second loop-breaking remedy ([§5.5][s5-5]) needs.
`Constant{V}` is the source block ([D-143][d-143]). `Freeze{V}` is the declared
stop-gradient ([D-266][d-266]). `StopRequest` is the library spelling of a [stop request](#g-stop-request)
(an output port of the framework enum `StopFlag`) ([§13.5][s13-5], [D-316][d-316]).
````

New:

````text
The starting inventory holds the `Junction`, with `SumJunction{V, N}`, `Or{N}`
and `And{N}` as its named forms, `UnitDelay{V}`, `Constant{V}`, `Freeze{V}` and
`StopRequest`. The shipped list, and the Simulink mapping that prunes it, live
in `companions/library_inventory.md`. `UnitDelay` is the spelling the second
loop-breaking remedy ([§5.5][s5-5]) needs. `Constant{V}` is the source block ([D-143][d-143]).
`Freeze{V}` is the declared stop-gradient ([D-266][d-266]). `StopRequest` is the library
spelling of a [stop request](#g-stop-request) (an output port of the framework enum `StopFlag`)
([§13.5][s13-5], [D-316][d-316]).
````

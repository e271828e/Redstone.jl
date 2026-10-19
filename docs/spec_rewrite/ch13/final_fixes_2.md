# Chapter 13: final fixes, units F and G (step 6b)

Each entry gives the item, the unit, and the whole paragraph before and
after the edit, verbatim from `units/<U>/new.md`, rewrap included.
Replace each old paragraph with its new one, in order.

## Finding 1, unit G

Old:

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

New:

````text
- The *global* (value-blind) set-tracer is a `Real` subtype that carries a set
  of input indices, unioned by every operation. It has
  may-depend semantics, a sound over-approximation. A saturated `clamp` still
  reports, and $u^2$ at $u = 0$ still reports. It is exact, in one evaluation.
  It requires the traced stage-2 code to be free of branches and lookups on
  *input-tainted* values.
- The *sampled* set-tracer (the log's *local*, primal-carrying mode) at sampled
  states is the fallback whenever the global tracer hits an undecidable branch,
  such as piecewise friction, stall blending or any gridded lookup at an
  input-tainted coordinate. It reports the dependence pattern of the taken
  paths, sampled across randomized states. Its only misses are untaken branches
  ([D-012][d-012], [D-349][d-349]).
````

## Finding 2, unit G

Old:

````text
Generic-holding [contracts](#g-contract) (each a component's declared interface) are a
structural customer of computed interface connections, which are therefore
prominent in this section. [D-062][d-062] makes three tooling commitments for them,
namely the passthrough helpers' predicate, the routes `show(::Structure)` prints
for each root [face](#g-face) (the name a port wears on its component's boundary), and a
standard library of [components](#g-component) (the units of modeling, each a leaf or an
assembly of components). The section covers the predicate and the face routes
first, then the standard component library and the component test rig.
````

New:

````text
Generic-holding [contracts](#g-contract) (each a component's declared interface) are a
structural customer of computed interface connections, which are therefore
prominent in this section. [D-062][d-062] makes three tooling commitments for them,
namely the passthrough helpers' predicate, the routes `show(::Structure)` prints
for each root [face](#g-face) (the name a port wears on its component's boundary), and a
standard library of [components](#g-component). Components are the units of modeling, each a
leaf or an assembly of components. The section covers the predicate and the face
routes first, then the standard component library and the component test rig.
````

## Finding 3, unit G

Old:

````text
**Only *inputs* are seeded** ([D-349][d-349]), so branching on state, modes, parameters or time
never interferes. Stage-2 functions also receive state views, but neither those
nor the stage-1 hand-down are ever seeded. Stage-1 functions are never traced,
since there is nothing to seed. Derivatives, [guards](#g-guard) (the declared functions
defining each event's predicate), handlers and [projections](#g-projection) (the optional
per-component hook `x ← x_projection(x)`) are outside tracing's jurisdiction
entirely.
````

New:

````text
**Only *inputs* are seeded** ([D-349][d-349]), so branching on state, modes, parameters or time
never interferes. Stage-2 functions also receive state views, but neither those
nor the stage-1 hand-down are ever seeded. Stage-1 functions are never traced,
since there is nothing to seed. Derivatives, [guards](#g-guard) (the declared functions
defining each event's predicate), handlers and [projections](#g-projection) are outside tracing's
jurisdiction entirely. A projection is the optional per-component hook
`x ← x_projection(x)`.
````

## Finding 4, unit F

Old:

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

New:

````text
[§12.6][s12-6] declares the stop policy per advance, with `t_end` and
`ignore_stop_requests` as keywords of `run!`, `replay!` and `step!`, and gives
the value's lifetime. Each of the three calls takes `Inf` and `()` as the
defaults ([D-255][d-255]). The defaults belong to the calls that take the policy. With no
constructor defaults the [trace header](#g-trace-header) (the trace's fixed preamble) has no policy
to record ([§11.5][s11-5]). The [termination record](#g-termination-record) (the stopped-sim value naming how the
run ended) carries the policy that actually ended the run. The ignore list,
`ignore_stop_requests`, sits beside `t_end` at the same declaration site.
````

## Finding 5, unit G

Old:

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

New:

````text
The starting inventory holds the `Junction`, with `SumJunction{V, N}`, `Or{N}`
and `And{N}` as its named forms, `UnitDelay{V}`, `Constant{V}`, `Freeze{V}` and
`StopRequest`. The full inventory, and the Simulink mapping that prunes it, live
in `companions/library_inventory.md`. `UnitDelay` is the spelling the second
loop-breaking remedy ([§5.5][s5-5]) needs. `Constant{V}` is the source block ([D-143][d-143]).
`Freeze{V}` is the declared stop-gradient ([D-266][d-266]). `StopRequest` is the library
spelling of a [stop request](#g-stop-request) (an output port of the framework enum `StopFlag`)
([§13.5][s13-5], [D-316][d-316]).
````

## Finding 6, unit F

Old:

````text
What is lost is quarantined. A throw inside the frame leaves the [stores](#g-store) (the
framework-owned homes of a component's `x`, `s` and `m`) possibly holding
mid-boundary values, such as a half-written `m` or integration intermediates.
They are retained on the errored simulation for post-mortem inspection. An
errored simulation is terminal, not resumable, and the reproduction tool is
[trace](#g-trace) [replay](#g-replay) (the ordinary loop re-driven from a recorded trace), not
resurrection ([§12.6][s12-6], [D-059][d-059], [D-387][d-387]). A trace is a session's record of its drained
inputs. The stopped-sim services enforce that non-resumability by refusing an
errored simulation outright (`ServiceLifecycle`, [§14][s14]). Operations on the [roster](#g-roster)
(the list of attached device entries) refuse it with them ([§11.3][s11-3], [D-232][d-232]).
Inspection is reading, but `attach!` configures a run that cannot follow. The
published record (snapshot chain, log, trace) ends at the last consistent
boundary. Nothing downstream of the sim ever sees half a boundary.

````

New:

````text
What is lost is quarantined. A throw inside the frame leaves the [stores](#g-store) (the
framework-owned homes of a component's `x`, `s` and `m`) possibly holding
mid-boundary values, such as a half-written `m` or integration intermediates.
They are retained on the errored simulation for post-mortem inspection. An
errored simulation is terminal, not resumable, and the reproduction tool is
[trace](#g-trace) [replay](#g-replay) (the ordinary loop re-driven from a recorded trace), not
resurrection ([§12.6][s12-6], [D-059][d-059], [D-387][d-387]). A trace is a session's record of its drained
inputs. The stopped-sim services enforce the non-resumability by refusing an
errored simulation outright (`ServiceLifecycle`, [§14][s14]). Operations on the [roster](#g-roster)
(the list of attached device entries) refuse it with them ([§11.3][s11-3], [D-232][d-232]).
Inspection is reading, but `attach!` configures a run that cannot follow. The
published record (snapshot chain, log, trace) ends at the last consistent
boundary. Nothing downstream of the sim ever sees half a boundary.
````

## Finding 7, unit G

Old:

````text
Two uses need `Constant` ([D-143][d-143]), though a listed block needs none to be built
([D-313][d-313]). The zero-contributor configurations ([§6.2][s6-2]) are one. There, a required
aggregate input has no physical contributor, and the zero total must be spelled
as a wire. The rig stub below is the other. The block's value is instance data,
like junction arity, not an overridable default ([D-143][d-143]). A configuration wanting
an externally settable source uses a root input ([§11.3][s11-3]), which keeps the block
from drifting into a back-door input default. A handle that references bulk data
never surfaces as a root input ([D-237][d-237]); a rig holds such a handle through a
[constant source](#g-constant-source) (a `Constant` holding it) instead ([§14.9][s14-9], [D-364][d-364]).
````

New:

````text
Two uses need `Constant` ([D-143][d-143]), though a listed block needs none to be built
([D-313][d-313]). The zero-contributor configurations ([§6.2][s6-2]) are one. There, a required
aggregate input has no physical contributor, and the zero total must be spelled
as a wire. The rig stub below is the other. The block's value is instance data,
like junction arity, not an overridable default ([D-143][d-143]). A configuration wanting
an externally settable source uses a root input ([§11.3][s11-3]), which keeps the block
from drifting into a back-door input default. A handle that references bulk data
never surfaces as a root input ([D-237][d-237]); a rig holds such a handle through a
[constant source](#g-constant-source) (a `Constant`, publishing the value its instance holds) instead
([§14.9][s14-9], [D-364][d-364]).
````

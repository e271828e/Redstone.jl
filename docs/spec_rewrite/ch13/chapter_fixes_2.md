# Chapter 13, step 5: editorial fixes, half 2 (units F and G)

Fixer `fix2`. Applied to `units/F/new.md` and `units/G/new.md` from the verified
commit `5f21eba`. One entry per edited paragraph, in file order; an entry names
every finding applied in it. Old and new are the whole paragraph, verbatim, so
each entry replays as one replacement. Every edited paragraph is rewrapped to
80 rendered columns (link markup collapsed, code spans unbroken). `claims.md`
of both units is updated to match; `build_inventory.py` prints `checks failed: 0`
for A, B, F and G.

Findings applied: P1-12 (unit F half only); P2-1, P2-4, P2-6, P2-7, P2-8, P2-9,
P2-10, P2-11, P2-12, P2-13, P2-14, P2-15, P2-18, P2-19, P2-20, P2-24 (part),
P2-25 (the carried unit G item), P2-28, P2-29.

Left:

- P2-5: RULING. "A substitution that changes when runs end" narrows the old
  claim's scope with words from D-060's Rejected list, which the old text does
  not state.
- P2-24, the component test rig's gloss: not added. The same paragraph defines
  the rig in its own sentence ("The rig is a one-child assembly whose
  `input_wires` surface the child's entire input face set"), so a gloss would
  repeat it four lines earlier. The orchestrator may rule otherwise.
- P2-24, the lost `#g-port` link in §13.5: a question, not an edit. Unit F's
  claims and rulings do not record dropping it (old line 213, "GUI panels
  rendering a component's [ports](#g-port)"). Restoring it at the first use
  would put a link inside the stop request's gloss or inside a bold.
- RULING findings, untouched: P2-2, P2-3, P2-16, P2-17, P2-21, P2-22, P2-23,
  P2-26, P2-27.

Notes on fitting:

- P2-12: both links stay at the first use, "trace replay"; replay keeps a
  parenthetical gloss (P2-15's wording) and trace takes a sentence gloss after
  the citations.
- P2-15, predicate: the glossary's words, "a `Bool`-valued form, or the sign of
  a continuous function", instead of the proposed "the form or sign a guard
  returns", which a guard does not return.
- P2-18, `Freeze`: D-266 stays on the feeding sentence, its claim (D-266 bullet
  2), so no citation's scope changes. Only the repeated clause goes.
- P2-24, conditions: R23's split, one gloss per sentence.

## Edits

### 1. P2-1; unit F, `new.md` line 3 at `5f21eba`

Old:

~~~
This section specifies how a model ends its own run, how an advance chooses
which stop requests to honour, and what the run records when it ends. FlightCore's
`SimulationTermination` idiom (model code throws, and the loop catches and
logs it as informational) **has no counterpart here** ([D-060][d-060]).
**Graceful termination is model state, never an exception** ([D-060][d-060]).
It reaches the loop through declared machinery. The discipline is that
**exceptions from model code are always abnormal** ([D-060][d-060]).
~~~

New:

~~~
This section specifies how a model ends its own run, how an advance chooses
which stop requests to honour, and what the run records when it ends.
FlightCore's `SimulationTermination` idiom (model code throws, and the loop
catches and logs it as informational) **has no counterpart here** ([D-060][d-060]). **Graceful
termination is model state, never an exception** ([D-060][d-060]). It reaches the loop
through declared machinery. The discipline is that **exceptions from model code
are always abnormal** ([D-060][d-060]).
~~~

### 2. P2-6; unit F, `new.md` line 17 at `5f21eba`

Old:

~~~
The section covers, in order, detection and publication, placement and
requesters, the policy per advance, the scan and the source order, unbounded
runs, the termination record, ignored requests and post-terminal dynamics, and
inspection beside the reads a run acts on.
~~~

New:

~~~
The section covers, in order, detection and publication, placement and
requesters, the policy per advance, the scan and the source order, unbounded
runs, the termination record, ignored requests and post-terminal dynamics, and
the rejected mechanisms beside the reads a run acts on.
~~~

### 3. P2-15 (guard; predicate gloss); unit F, `new.md` line 24 at `5f21eba`

Old:

~~~
Detection is ordinary [guard](#g-guard) (the declared function that detects an
event), handler and mode machinery ([D-060][d-060]). If the stop should be
localized, declare the [predicate](#g-predicate) (what a guard defines) as a
sign-form event. Such an event is [localized](#g-localized) (the crossing
instant bracketed by root-finding over trial sweeps). A landing-gear strut's
touchdown overload is precisely a zero-crossing. The [boundary](#g-boundary) (a published
consistency point) is localized to the crossing, and the handler sets
`m.crashed`. The [snapshot](#g-snapshot) (the immutable per-boundary
publication) at the crossing instant carries the touchdown state.
~~~

New:

~~~
Detection is ordinary [guard](#g-guard) (the declared function defining an event's
predicate), handler and mode machinery ([D-060][d-060]). If the stop should be localized,
declare the [predicate](#g-predicate) (a `Bool`-valued form, or the sign of a continuous
function) as a sign-form event. Such an event is [localized](#g-localized) (the crossing instant
bracketed by root-finding over trial sweeps). A landing-gear strut's touchdown
overload is precisely a zero-crossing. The [boundary](#g-boundary) (a published consistency
point) is localized to the crossing, and the handler sets `m.crashed`. The
[snapshot](#g-snapshot) (the immutable per-boundary publication) at the crossing instant
carries the touchdown state.
~~~

### 4. P2-29 (boundary); unit F, `new.md` line 34 at `5f21eba`

Old:

~~~
Publication is a [stop request](#g-stop-request) (an output port of the
framework enum `StopFlag`), declared where the stop's `Bool` is detected.
**A port whose type is exactly `StopFlag` is a stop request**, whoever
publishes it ([D-316][d-316]). The enum is `@enum StopFlag NO_STOP STOP_REQUESTED`.
An enum is one leaf, pinned at every activation ([§4.3][s4-3]), and
[cells](#g-cell) (typed entries of the signal table) are stored per element
type ([§9.7][s9-7]), so every request in the model lands in one `StopFlag`
block. The stop's `Bool` is gathered at its owning boundary in one visible
block. The landing gear `Ldg` from the example of [§6.1][s6-1] ORs its three
legs through a junction (the ownership idiom, [§6.2][s6-2]; the library,
[§13.7][s13-7]). It wires the result into a `StopRequest` child, the
library's spelling of a request, described below. No level above it
re-exports anything, because the loop reads the request where it is.
~~~

New:

~~~
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
~~~

### 5. P2-15 (component); unit F, `new.md` line 65 at `5f21eba`

Old:

~~~
Its output is consumed by nobody, which [§6.1][s6-1] allows silently ([D-084][d-084]).
`StopRequest` is continuous, so it refreshes at every boundary, `t*`
included ([§10.4][s10-4], [D-316][d-316]). Assemblies are virtual for execution and rate
scopes touch discrete children only, so one leaf sits anywhere in the tree
([§10.5][s10-5], [D-019][d-019]). Fed by a discrete detector, it sees the tick
at the tick's own boundary, because the boundary sweep walks the full
execution order in topological order ([§10.5][s10-5], [D-147][d-147]). The
block holds no privilege. Any [component](#g-component) (a leaf or an
assembly of components) may publish a `StopFlag` port directly.
~~~

New:

~~~
Its output is consumed by nobody, which [§6.1][s6-1] allows silently ([D-084][d-084]).
`StopRequest` is continuous, so it refreshes at every boundary, `t*` included
([§10.4][s10-4], [D-316][d-316]). Assemblies are virtual for execution and rate scopes touch
discrete children only, so one leaf sits anywhere in the tree ([§10.5][s10-5], [D-019][d-019]).
Fed by a discrete detector, it sees the tick at the tick's own boundary, because
the boundary sweep walks the full execution order in topological order ([§10.5][s10-5],
[D-147][d-147]). The block holds no privilege. Any [component](#g-component) (the unit of modeling, a
leaf or an assembly of components) may publish a `StopFlag` port directly.
~~~

### 6. P2-1; unit F, `new.md` line 100 at `5f21eba`

Old:

~~~
[§12.6][s12-6] declares the stop policy per advance, with `t_end` and
`ignore_stop_requests` as keywords of `run!`, `replay!` and `step!`, and
gives the value's lifetime. Each of the three calls takes `Inf` and `()` as
the defaults ([D-255][d-255]). The defaults belong to the calls that take the
policy. With no constructor defaults the [trace header](#g-trace-header) (the
trace's fixed preamble) has no policy to record
([§11.5][s11-5]). The [termination record](#g-termination-record) (the
stopped-sim value naming how the run ended) carries the policy that actually
ended the run.
~~~

New:

~~~
[§12.6][s12-6] declares the stop policy per advance, with `t_end` and
`ignore_stop_requests` as keywords of `run!`, `replay!` and `step!`, and gives
the value's lifetime. Each of the three calls takes `Inf` and `()` as the
defaults ([D-255][d-255]). The defaults belong to the calls that take the policy. With no
constructor defaults the [trace header](#g-trace-header) (the trace's fixed preamble) has no policy
to record ([§11.5][s11-5]). The [termination record](#g-termination-record) (the stopped-sim value naming how the
run ended) carries the policy that actually ended the run.
~~~

### 7. P2-14; unit F, `new.md` line 118 at `5f21eba`

Old:

~~~
Each advance builds a [`StopPolicy`](#g-stop-policy) (the immutable value of
`t_end` plus the ignored requester paths), and passes it to the loop with an
ignore mask, one `Bool` per requester, as a second argument ([D-316][d-316]).
A `t*` hit reaches the loop as `frame!`'s return value, a `Bool` saying
whether the frame was abandoned, never as a field of the policy or of the
[execution cursor](#g-execution-cursor) (the field recording where execution
stands) ([D-261][d-261], [D-317][d-317]). The loop then reads the requester
off the snapshot it just published.
~~~

New:

~~~
Each advance builds a [`StopPolicy`](#g-stop-policy) (the immutable value of `t_end` plus the
ignored requester paths), and passes it to the loop with an ignore mask, one
`Bool` per requester, as a second argument ([D-316][d-316]). A `t*` hit reaches the loop
as the return value of the `Model`'s `frame!`, a `Bool` saying whether the frame
was abandoned, never as a field of the policy or of the [execution cursor](#g-execution-cursor) (the
field recording where execution stands) ([D-261][d-261], [D-317][d-317]). The loop then reads the
requester off the snapshot it just published.
~~~

### 8. P2-28; unit F, `new.md` line 148 at `5f21eba`

Old:

~~~
**The sources are consulted in a fixed order** ([D-203][d-203]). The loop
checks a pending control stop at frame top, then `t_end`, then the stop
requests at each publication. When two sources hold at one boundary, the
recorded source is the first in that order ([D-203][d-203]).
~~~

New:

~~~
**The sources are consulted in a fixed order** ([D-203][d-203]). The loop checks a pending
control stop at frame top, then `t_end`, then the stop requests at each
publication. When two sources hold at one boundary, the termination record names
the first in that order ([D-203][d-203]).
~~~

### 9. P2-8; unit F, `new.md` line 153 at `5f21eba`

Old:

~~~
Authors are taught this rule. Stop requests are sampled at completed
boundaries; declare a sign-form event if you need the stop localized. Both
shapes of the stop's `Bool` feeding a request work without framework
latching. A handler-set `m` flag is sticky by nature. A transient stage-2
Bool is caught because the loop reacts to the first request it reads holding.
Compound stop logic composes in-model, as a monitor component reading the
relevant signals and feeding one request. That is the same move
[§12.5][s12-5] made for scripts.
~~~

New:

~~~
Authors are taught that stop requests are sampled at completed boundaries, and
that a stop that must be localized needs a sign-form event. Both shapes of the
stop's `Bool` feeding a request work without framework latching. A handler-set
`m` flag is sticky by nature. A transient stage-2 Bool is caught because the
loop reacts to the first request it reads holding. Compound stop logic composes
in-model, as a monitor component reading the relevant signals and feeding one
request. That is the same move [§12.5][s12-5] made for scripts.
~~~

### 10. P1-12; P2-1; unit F, `new.md` line 164 at `5f21eba`

Old:

~~~
**An unbounded run is allowed** ([D-255][d-255]). `run!(sim)` with
`t_end = Inf` and no honoured request is the interactive session's ordinary
shape, and the [operator interrupt](#g-operator-interrupt) (Ctrl-C, read as a
control-plane stop) is its escape ([§12.4][s12-4]). The model may have no
requester, or the advance may ignore them all. `run!` raises `UnboundedRun`
before the loop starts, into the loop's own
[diagnostic cell](#g-diagnostic-cell) (the per-writer cell for runtime
diagnostics), and the status record carries it ([§11.8][s11-8],
[D-255][d-255], [D-316][d-316]). Its message says which of the two cases
holds. The advisory fires in `:live` only. A `run!` in `:replay` is bounded by
the recording, whatever its policy says ([§12.7][s12-7], [D-218][d-218]).
~~~

New:

~~~
**An unbounded run is allowed** ([D-255][d-255]). `run!(sim)` with `t_end = Inf` and no
honoured request is the interactive session's ordinary shape, and the [operator
interrupt](#g-operator-interrupt) (Ctrl-C, read as a control-plane stop) is its escape ([§12.4][s12-4]). The
model may have no requester, or the advance may ignore them all. `run!` raises
`UnboundedRun` before the loop starts, into the loop's own [diagnostic cell](#g-diagnostic-cell) (the
per-writer cell for runtime diagnostics and liveness), and the status record
carries it ([§11.8][s11-8], [D-255][d-255], [D-316][d-316]). Its message says which of the two cases holds.
The advisory fires in `:live` only. A `run!` in `:replay` is bounded by the
recording, whatever its policy says ([§12.7][s12-7], [D-218][d-218]).
~~~

### 11. P2-7; unit F, `new.md` line 229 at `5f21eba`

Old:

~~~
Post-terminal dynamics are the model's job, and that is a feature. `robot2d`
is FlightApps' self-balancing robot in Flight.jl, which throws `LostBalance`,
a `SimulationTermination`, past 45° of tilt. It *throws* when it falls,
because it has no other way to say "my dynamics are no longer meaningful".
Here it declares the fall as an event, switches to a frozen mode, and feeds
`fallen` to a stop request. The frozen mode is a mode-dependent `x_deriv`,
machinery the model already has. Honoured, the request ends the sim at the
fall. Ignored, the sim integrates a frozen robot, which is well-defined,
unlike an uncaught throw. The discipline forces models to have well-defined
terminal states, which is better modeling ([D-060][d-060]).
~~~

New:

~~~
Post-terminal dynamics are the model's job, and that is a feature. `robot2d`,
FlightApps' self-balancing robot in Flight.jl, *throws* `LostBalance`, a
`SimulationTermination`, past 45° of tilt, because it has no other way to say
"my dynamics are no longer meaningful". Here it declares the fall as an event,
switches to a frozen mode, and feeds `fallen` to a stop request. The frozen mode
is a mode-dependent `x_deriv`, machinery the model already has. Honoured, the
request ends the sim at the fall. Ignored, the sim integrates a frozen robot,
which is well-defined, unlike an uncaught throw. The discipline forces models to
have well-defined terminal states, which is better modeling ([D-060][d-060]).
~~~

### 12. P2-6 (label); unit F, `new.md` line 240 at `5f21eba`

Old:

~~~
#### Inspection and the reads a run acts on
~~~

New:

~~~
#### Rejected mechanisms and the reads a run acts on
~~~

### 13. P2-4; P2-15 (blessed); unit F, `new.md` line 242 at `5f21eba`

Old:

~~~
The rejected mechanisms, litigated in [D-060][d-060] and [D-316][d-316], are
predicate closures such as `stop_when = snap -> …`, root-type-declared stop
policy, which the per-advance policy is not, `terminal` event flags, a
control-plane capability for components, observation-by-path (an advance
naming a deep path into any public output), and the `Bool` face re-exported
level by level to the root and named by the advance, which fell to stop
requests. [D-060][d-060] also rejected [blessed](#g-blessed) (explicitly
sanctioned by the spec) terminal types scanned from the tree, an arm the stop
request supersedes on its own terms.
~~~

New:

~~~
The rejected mechanisms, litigated in [D-060][d-060] and [D-316][d-316], are predicate closures
such as `stop_when = snap -> …`, root-type-declared stop policy, `terminal`
event flags, a control-plane capability for components, observation-by-path (an
advance naming a deep path into any public output), and the `Bool` face
re-exported level by level to the root and named by the advance. The per-advance
policy is not the root-type-declared one, and the re-exported face fell to stop
requests. [D-060][d-060] also rejected [blessed](#g-blessed) (explicitly sanctioned where a neighboring
practice is forbidden) terminal types scanned from the tree, an arm the stop
request supersedes on its own terms.
~~~

### 14. P2-6 (topic sentence); P2-1; unit F, `new.md` line 252 at `5f21eba`

Old:

~~~
The observation-by-path line leaves doctrine behind it, narrowed by
[D-316][d-316]. Inspection is human-facing, has no effect on run semantics,
and legitimately sees every public cell. The log retaining the full table, a
front end's panels rendering a component's ports, and inspection under
[replay](#g-replay) (the ordinary loop re-driven from a recorded trace) are
all inspection. A read the run acts on changes what the run *does*, and it
reads only what the model declared for it, never an arbitrary cell. The stop
scan is the one such read. It reads the `StopFlag` block, which holds nothing
but the requests their authors declared by type. [§13.3][s13-3] scopes path
resolution by client, on a line of its own. The ignore list addresses
the `Build`'s requester roster, a build product like the root-input list. It
binds at an advance, a stopped-sim point where conditions already address
state by path ([§14.1][s14-1]). The requester is loud at inspection, since
the requester roster and the termination record name it. Substitution is
answered by the ignore list, and disabling is one keyword. The trigger is the
author's knowledge and the ignore list the integrator's. Output devices are
the other half of the same doctrine. Their reads are inspection on snapshot
paths ([§11.2][s11-2]), though attach resolves them strictly, as [§13.3][s13-3]'s
service clients ([D-406][d-406]).
~~~

New:

~~~
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
~~~

### 15. P2-10; unit F, `new.md` line 282 at `5f21eba`

Old:

~~~
**The abnormal path discards the failed boundary, promotes the previous
snapshot to final, and rejoins the ordinary tail** ([D-030][d-030]). The
protocol becomes one tail with two entry points. Graceful entry follows a
*completed* final boundary, and abnormal entry follows a *discarded* one.
Everything downstream of "final snapshot" runs identically. That covers
sticky stopped, waiters woken through the boundary-counter plus `Condition`
path, the hooks `unblock!` and `shutdown!`, and named joins with timeout.
Those waiters observe stopped rather than a new boundary, so no task of a
[device](#g-device) (an attached participant in the periphery) hangs.
~~~

New:

~~~
**The abnormal path discards the failed boundary, promotes the previous snapshot
to final, and rejoins the ordinary tail** ([D-030][d-030]). The protocol becomes one tail
with two entry points. Graceful entry follows a *completed* final boundary, and
abnormal entry follows a *discarded* one. Everything downstream of "final
snapshot" runs identically. That covers sticky stopped, waiters woken through
the boundary-counter plus `Condition` path, the hooks `unblock!` and
`shutdown!`, and named joins with timeout. Those waiters observe stopped rather
than a new boundary, so no [device](#g-device) (an attached participant in the periphery) is
left with a hanging task.
~~~

### 16. P2-9; P2-11; P2-1; unit F, `new.md` line 292 at `5f21eba`

Old:

~~~
The abnormal path rests on this. The boundary is all-or-nothing outside the
loop ([D-030][d-030]). That is why a `StepError` cannot break [§12.4][s12-4].
[Sweeps](#g-sweep) (passes through the execution order) write into table
blocks. Integration intermediates live in framework-owned integrator buffers.
They never live in the scratch of a [component](#g-component) (a leaf or an
assembly of components). That scratch is its [workspace](#g-workspace)
(declared by allocation and excluded from state semantics), as [§7.3][s7-3]
defines it. The only externally visible act is
snapshot publication at the very end of the sequence. A boundary that throws
has published nothing. The last *published* snapshot is a complete,
consistent boundary by construction, and it is still the newest thing any
device, logger or waiter has seen.
~~~

New:

~~~
The abnormal path is safe because the boundary is all-or-nothing outside the
loop ([D-030][d-030]). That is why a `StepError` cannot break [§12.4][s12-4]. [Sweeps](#g-sweep) (passes
through the execution order) write into table blocks. Integration intermediates
live in framework-owned integrator buffers, never in the scratch of a [component](#g-component)
(the unit of modeling, a leaf or an assembly of components). That scratch is its
[workspace](#g-workspace) (declared by allocation and excluded from state semantics), as [§7.3][s7-3]
defines it. The only externally visible act is snapshot publication at the very
end of the sequence. A boundary that throws has published nothing. The last
*published* snapshot is a complete, consistent boundary by construction, and it is
still the newest thing any device, logger or waiter has seen.
~~~

### 17. P2-12; P2-13; P2-15 (replay); unit F, `new.md` line 329 at `5f21eba`

Old:

~~~
What is lost is quarantined. A throw inside the frame leaves the
[stores](#g-store) (the framework-owned homes of a component's `x`, `s` and
`m`) possibly holding mid-boundary values, such as a half-written `m` or
integration intermediates. They are retained on the errored simulation for
post-mortem inspection. An errored simulation is terminal, not resumable, and
the reproduction tool is [trace](#g-trace) [replay](#g-replay) (re-driving the
ordinary loop from the session's recorded inputs), not resurrection
([§12.6][s12-6], [D-059][d-059], [D-387][d-387]). The stopped-sim services
enforce that non-resumability by refusing an errored simulation outright
(`ServiceLifecycle`, [§14][s14]). The roster operations refuse it with them
([§11.3][s11-3], [D-232][d-232]). Inspection is reading, but `attach!`
configures a run that cannot follow. The published record (snapshot chain,
log, trace) ends at the last consistent boundary. Nothing downstream of the
sim ever sees half a boundary.

~~~

New:

~~~
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

~~~

### 18. P2-15 (contract; component); unit G, `new.md` line 3 at `5f21eba`

Old:

~~~
Generic-holding [contracts](#g-contract) (the `u_types` and `y_types`
declarations) are a structural customer of computed interface connections,
which are therefore prominent in this section. [D-062][d-062] makes three
tooling commitments for them, namely the passthrough helpers' predicate, the
routes `show(::Structure)` prints for each root [face](#g-face) (the name a
port wears on its component's boundary), and a standard library of
[components](#g-component), the units of modeling. The section covers the
predicate and the face routes first, then the standard component library and
the component test rig.
~~~

New:

~~~
Generic-holding [contracts](#g-contract) (each a component's declared interface) are a
structural customer of computed interface connections, which are therefore
prominent in this section. [D-062][d-062] makes three tooling commitments for them,
namely the passthrough helpers' predicate, the routes `show(::Structure)` prints
for each root [face](#g-face) (the name a port wears on its component's boundary), and a
standard library of [components](#g-component) (the units of modeling, each a leaf or an
assembly of components). The section covers the predicate and the face routes
first, then the standard component library and the component test rig.
~~~

### 19. P2-1; unit G, `new.md` line 24 at `5f21eba`

Old:

~~~
Every artifact renders itself through `show` ([§9.2][s9-2], [D-257][d-257]).
[`Structure`](#g-structure) (the structure step's product, the components,
wires, faces and tiers) has one. **`show(::Structure)` owes face routes** ([D-257][d-257]). For every root face,
that means the resolved chain down to the producing terminal, printed as one
line per chain (`crashed → aircraft/crashed → aircraft/monitor/out`). Once
faces are computed rather than hand-listed, "what does this face actually
reach" is a question the artifact must answer, not the reader.
`show(::Structure)` derives each face's routing chain from the declared wires
and prints the root's routes ([D-257][d-257], [D-315][d-315]). Each line joins
the hops with `→` and ends at the terminal. An input face that fans out prints
one line per consumer. The wiring diagnostics name endpoints in the same slash
form.
~~~

New:

~~~
Every artifact renders itself through `show` ([§9.2][s9-2], [D-257][d-257]). [`Structure`](#g-structure) (the
structure step's product, the components, wires, faces and tiers) has one.
**`show(::Structure)` owes face routes** ([D-257][d-257]). For every root face, that means
the resolved chain down to the producing terminal, printed as one line per chain
(`crashed → aircraft/crashed → aircraft/monitor/out`). Once faces are computed
rather than hand-listed, "what does this face actually reach" is a question the
artifact must answer, not the reader. `show(::Structure)` derives each face's
routing chain from the declared wires and prints the root's routes ([D-257][d-257],
[D-315][d-315]). Each line joins the hops with `→` and ends at the terminal. An input
face that fans out prints one line per consumer. The wiring diagnostics name
endpoints in the same slash form.
~~~

### 20. P2-20 (contract); P2-24 (leaf walk); unit G, `new.md` line 116 at `5f21eba`

Old:

~~~
The junction is a continuous leaf, so its contracts are written at nominal
`Float64` and the leaf walk retypes them ([§8.2][s8-2], [D-263][d-263]). An
input entry at `Wrench{Float64}` is the tolerant form a promoting consumer
writes. Walking, frozen and root-input contributors are all admissible behind
it.
~~~

New:

~~~
The junction is a continuous leaf, so its contract is written at nominal
`Float64` and the [leaf walk](#g-leaf-walk) (the framework's derivation of per-activation types
from a declared nominal type) retypes it ([§8.2][s8-2], [D-263][d-263]). An input entry at
`Wrench{Float64}` is the tolerant form a promoting consumer writes. Walking,
frozen and root-input contributors are all admissible behind it.
~~~

### 21. P2-20 (slots; entries); P2-1; unit G, `new.md` line 122 at `5f21eba`

Old:

~~~
A named site-specific junction documents a fixed contributor set better than
generated slots, at the price of hard-coding it into a type ([D-037][d-037]).
An example is `u_types(::VehicleWrenchSum) = (aero = …, ldg = …, pwp = …)`,
whose entries name the aerodynamics, landing-gear and powerplant children of
the `Systems` assembly ([§6.2][s6-2]).
The generic positional form remains the tool for configuration-variable
sites. Both are plain components, and the framework is not involved.
~~~

New:

~~~
A named site-specific junction documents a fixed contributor set better than
generated input ports, at the price of hard-coding it into a type ([D-037][d-037]). An
example is `u_types(::VehicleWrenchSum) = (aero = …, ldg = …, pwp = …)`, whose
input entries name the aerodynamics, landing-gear and powerplant children of the
`Systems` assembly ([§6.2][s6-2]). The generic positional form remains the tool for
configuration-variable sites. Both are plain components, and the framework is
not involved.
~~~

### 22. P2-20 (class); unit G, `new.md` line 142 at `5f21eba`

Old:

~~~
[Tier](#g-tier)-transparency falls out of settled semantics ([D-062][d-062]),
a tier being the continuous or discrete side of the hybrid formalism. A
stateless continuous `y_direct` recomputes every [sweep](#g-sweep) (one pass
through the execution order). Fed discrete signals held by a zero-order hold,
its output therefore changes only at [ticks](#g-tick) (the instants at which
a discrete component's stages and update run). No tier-neutral class is
needed.
~~~

New:

~~~
[Tier](#g-tier)-transparency falls out of settled semantics ([D-062][d-062]), a tier being the
continuous or discrete side of the hybrid formalism. A stateless continuous
`y_direct` recomputes every [sweep](#g-sweep) (one pass through the execution order). Fed
discrete signals held by a zero-order hold, its output therefore changes only at
[ticks](#g-tick) (the instants at which a discrete component's stages and update run). No
tier-neutral variant is needed.
~~~

### 23. P2-24 (`Δt_base`); unit G, `new.md` line 171 at `5f21eba`

Old:

~~~
`UnitDelay`'s tier semantics are the point, and they must be stated wherever
the remedy is recommended ([D-348][d-348]). Inserting a `UnitDelay` into a
*continuous* loop moves that signal onto the discrete tier and inserts a
`Δt_base`-scale zero-order hold into the model's mathematics. That is a
modeling decision, because the delayed signal is genuinely sampled rather
than a transparent wire. The cycle diagnostic ([§13.8][s13-8]) therefore says
so rather than offering the remedy as free.
~~~

New:

~~~
`UnitDelay`'s tier semantics are the point, and they must be stated wherever the
remedy is recommended ([D-348][d-348]). Inserting a `UnitDelay` into a *continuous* loop
moves that signal onto the discrete tier and inserts a [`Δt_base`](#g-dt_base)-scale
zero-order hold into the model's mathematics, `Δt_base` being the base tick
period. That is a modeling decision, because the delayed signal is genuinely
sampled rather than a transparent wire. The cycle diagnostic ([§13.8][s13-8]) therefore
says so rather than offering the remedy as free.
~~~

### 24. P2-18 (`Constant`); unit G, `new.md` line 179 at `5f21eba`

Old:

~~~
`Constant{V}` is the source block ([D-143][d-143]). It has no inputs, no
state, and a stage-1 body returning the value the instance holds.
~~~

New:

~~~
`Constant{V}` has no inputs, no state, and a stage-1 body returning the value
the instance holds ([D-143][d-143]).
~~~

### 25. P2-24 (constant source); P2-25 = step5_carry.md, unit G; unit G, `new.md` line 205 at `5f21eba`

Old:

~~~
Two uses need `Constant` ([D-143][d-143]), though a listed block needs none
to be built ([D-313][d-313]). The zero-contributor configurations ([§6.2][s6-2]) are one.
There, a required aggregate input has no physical contributor, and the zero
total must be spelled as a wire. The rig stub below is the other. The block's
value is instance data, like junction arity, not an overridable default
([D-143][d-143]). A configuration wanting an externally settable source uses
a root input ([§11.3][s11-3]), which keeps the block from drifting into a
back-door input default. A handle that references bulk data never surfaces as
a root input ([D-237][d-237]); a rig holds bulk data through a constant source instead
([§14.9][s14-9], [D-364][d-364]).
~~~

New:

~~~
Two uses need `Constant` ([D-143][d-143]), though a listed block needs none to be built
([D-313][d-313]). The zero-contributor configurations ([§6.2][s6-2]) are one. There, a required
aggregate input has no physical contributor, and the zero total must be spelled
as a wire. The rig stub below is the other. The block's value is instance data,
like junction arity, not an overridable default ([D-143][d-143]). A configuration wanting
an externally settable source uses a root input ([§11.3][s11-3]), which keeps the block
from drifting into a back-door input default. A handle that references bulk data
never surfaces as a root input ([D-237][d-237]); a rig holds such a handle through a
[constant source](#g-constant-source) (a `Constant` holding it) instead ([§14.9][s14-9], [D-364][d-364]).
~~~

### 26. P2-18 (`Freeze`); unit G, `new.md` line 216 at `5f21eba`

Old:

~~~
`Freeze{V}` is the declared stop-gradient ([D-266][d-266]). It feeds a walking
producer into a pinned entry, which the walk clause ([§6.1][s6-1]) otherwise
refuses.
~~~

New:

~~~
`Freeze{V}` feeds a walking producer into a pinned entry, which the walk clause
([§6.1][s6-1]) otherwise refuses ([D-266][d-266]).
~~~

### 27. P2-19; P2-20 (modelling); unit G, `new.md` line 229 at `5f21eba`

Old:

~~~
At nominal the strip is the identity, so the block costs one gather and one
scatter. **`V` is a `Real` or a `StaticArray` of them, constrained at the
type** ([D-312][d-312]), so a struct-valued freeze is refused at the spelling
until a model needs one. Under a `Dual` activation it drops the partials, and
its output satisfies the pinned entry. What the wire then declares is a zero
coupling in every Jacobian along that path ([D-266][d-266]), the modelling
decision [§14.10][s14-10] asks an author to state on the page rather than bury
mid-expression. A sampler is the other non-walking source, and it changes the
model, holding the value between ticks ([§10.5][s10-5]). The block is for a
continuous value the consumer cannot differentiate through. Where the
coupling matters to the Jacobian, the local rule ([§14.10][s14-10]) is the
answer, not this block.
~~~

New:

~~~
At nominal the strip is the identity, so the block costs one gather and one
scatter. **`V` is a `Real` or a `StaticArray` of them, constrained at the type**
([D-312][d-312]), so a struct-valued freeze is refused at the spelling until a model
needs one. Under a `Dual` activation the block drops the partials, and its
output satisfies the pinned entry. What the wire then declares is a zero
coupling in every Jacobian along that path ([D-266][d-266]), the modeling decision [§14.10][s14-10]
asks an author to state on the page rather than bury mid-expression. A sampler
is the other non-walking source, and it changes the model, holding the value
between ticks ([§10.5][s10-5]). The block is for a continuous value the consumer cannot
differentiate through. Where the coupling matters to the Jacobian, the local
rule ([§14.10][s14-10]) is the answer, not this block.
~~~

### 28. P2-24 (conditions); unit G, `new.md` line 244 at `5f21eba`

Old:

~~~
The [component test rig](#g-component-test-rig) is the library's companion
idiom. Exercising a leaf alone needs no rig of its own. Any component may be
the root of a build, and its input faces then become the model's root inputs
([§8.2][s8-2], [D-208][d-208]). Ordinary conditions and [devices](#g-device)
(attached participants in the periphery) feed them, and every output is
observable in the table of each [snapshot](#g-snapshot), the immutable
per-boundary publication. The rig is a one-child assembly whose
`input_wires` surface the child's entire input face set, as
`input_passthrough(rig, "child")` verbatim ([§8.8][s8-8]). What it buys is a
place to wire something *beside* the component under test.
~~~

New:

~~~
The [component test rig](#g-component-test-rig) is the library's companion idiom. Exercising a leaf alone
needs no rig of its own. Any component may be the root of a build, and its input
faces then become the model's root inputs ([§8.2][s8-2], [D-208][d-208]). Ordinary [conditions](#g-condition)
(path-addressed sparse overlays that set a build's state) feed them. So do
[devices](#g-device) (attached participants in the periphery). Every output is observable in
the table of each [snapshot](#g-snapshot), the immutable per-boundary publication. The rig is a
one-child assembly whose `input_wires` surface the child's entire input face
set, as `input_passthrough(rig, "child")` verbatim ([§8.8][s8-8]). What it buys is a
place to wire something *beside* the component under test.
~~~

### 29. P2-24 (abstract entry, link moved here); unit G, `new.md` line 255 at `5f21eba`

Old:

~~~
The demonstrated need is the root-input rule ([§8.2][s8-2]). An *abstract*
input entry (`terrain = AbstractTerrainField`, an illustrative name) cannot
surface as a root input, because abstract-at-root is a build error,
`AbstractAtRoot` ([§8.2][s8-2], [Appendix C][sC]). The rig therefore
satisfies that entry *inside* the rig ([D-120][d-120]). In the sketch below,
the component under test is `Strut`, an illustrative landing-gear strut whose
terrain input is abstract. **A concrete stub child (a provider of
`SampleTerrainField`, an illustrative concrete terrain) is wired to the
face**, and the concrete remainder is exposed via
`input_passthrough(rig, "strut"; except = ("terrain",))` ([D-120][d-120]).
~~~

New:

~~~
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
~~~

### 30. P2-24 (abstract entry, link moved from here); unit G, `new.md` line 281 at `5f21eba`

Old:

~~~
The rig adds zero new machinery, because wiring and `except` already exist
([D-120][d-120]). It is structural substitutability doing its job. An
[abstract entry](#g-abstract-entry) (an `u_types` entry admitting any
concrete producer face) declares that a substitute must be chosen. The rig
chooses its test double explicitly, as ordinary inspectable code. That is
precisely the isolation the rig exists to provide.
~~~

New:

~~~
The rig adds zero new machinery, because wiring and `except` already exist
([D-120][d-120]). It is structural substitutability doing its job. An abstract entry
declares that a substitute must be chosen. The rig chooses its test double
explicitly, as ordinary inspectable code. That is precisely the isolation the
rig exists to provide.
~~~

### 31. P2-24 (algebraic loop); unit G, `new.md` line 297 at `5f21eba`

Old:

~~~
The build rejects an algebraic loop ([§5.5][s5-5], [D-005][d-005]), and
tracing is diagnostic only, never relied on for correctness ([D-012][d-012]).
Tracing improves error messages and verification. When the build finds a
cycle, it triggers the [feedthrough tracer](#g-feedthrough-tracer) (the
set-propagation instrument that tracks which inputs a value depends on) to
classify that cycle. A genuine cycle gets "break it with a state, a stage-1
(`y_state`) port, or a `UnitDelay`", and an artificial one gets the remedy
ladder ([§5.4][s5-4], [D-140][d-140]). Where the diagnostic recommends a unit
delay, it states the delay's [tier](#g-tier) caveat rather than offering it as
a free remedy ([§5.5][s5-5], [§13.7][s13-7], [D-348][d-348]). A tier is the
continuous or discrete side of the hybrid formalism. The parts below cover,
in order, how a cycle is detected and named, the tracer's two modes, what
tracing touches, how classification runs and decides, and the caveats and
hints the diagnostic carries.
~~~

New:

~~~
The build rejects an [algebraic loop](#g-algebraic-loop) (a genuine cycle in the instantaneous
dependency graph) ([§5.5][s5-5], [D-005][d-005]), and tracing is diagnostic only, never relied on
for correctness ([D-012][d-012]). Tracing improves error messages and verification. When
the build finds a cycle, it triggers the [feedthrough tracer](#g-feedthrough-tracer) (the set-propagation
instrument that tracks which inputs a value depends on) to classify that cycle.
A genuine cycle gets "break it with a state, a stage-1 (`y_state`) port, or a
`UnitDelay`", and an artificial one gets the remedy ladder ([§5.4][s5-4], [D-140][d-140]). Where
the diagnostic recommends a unit delay, it states the delay's [tier](#g-tier) caveat rather
than offering it as a free remedy ([§5.5][s5-5], [§13.7][s13-7], [D-348][d-348]). A tier is the continuous
or discrete side of the hybrid formalism. The parts below cover, in order, how a
cycle is detected and named, the tracer's two modes, what tracing touches, how
classification runs and decides, and the caveats and hints the diagnostic
carries.
~~~

### 32. P2-24 (projections); unit G, `new.md` line 346 at `5f21eba`

Old:

~~~
**Only *inputs* are seeded** ([D-349][d-349]), so branching on state, modes,
parameters or time never interferes. Stage-2 functions also receive state
views, but neither those nor the stage-1 hand-down are ever seeded. Stage-1
functions are never traced, since there is nothing to seed. Derivatives,
[guards](#g-guard) (the declared functions defining each event's predicate),
handlers and [projections](#g-projection) are outside tracing's jurisdiction
entirely.
~~~

New:

~~~
**Only *inputs* are seeded** ([D-349][d-349]), so branching on state, modes, parameters or time
never interferes. Stage-2 functions also receive state views, but neither those
nor the stage-1 hand-down are ever seeded. Stage-1 functions are never traced,
since there is nothing to seed. Derivatives, [guards](#g-guard) (the declared functions
defining each event's predicate), handlers and [projections](#g-projection) (the optional
per-component hook `x ← x_projection(x)`) are outside tracing's jurisdiction
entirely.
~~~

### 33. P2-29 (`Dual`); unit G, `new.md` line 359 at `5f21eba`

Old:

~~~
**Dual-cleanliness in CI effectively guarantees traceability**
([D-349][d-349]). Dual-clean means passing the `T = Dual` sweep of
[§7.2][s7-2]. The guarantee holds because both modes ride the same
`T <: Real` genericity as `Dual`, ForwardDiff's dual number.
~~~

New:

~~~
**Dual-cleanliness in CI effectively guarantees traceability** ([D-349][d-349]). Dual-clean
means passing the `T = Dual` sweep of [§7.2][s7-2], `Dual` being ForwardDiff's dual
number. The guarantee holds because both modes ride the same `T <: Real`
genericity as `Dual`.
~~~

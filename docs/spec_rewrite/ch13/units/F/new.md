### 13.5 Termination is a state, not an exception

This section specifies how a model ends its own run. FlightCore's
`SimulationTermination` idiom (model code throws, and the loop catches and
logs it as informational) **has no counterpart here** ([D-060][d-060]).
**Graceful termination is model state, never an exception** ([D-060][d-060]).
It reaches the loop through declared machinery. The discipline is that
**exceptions from model code are always abnormal** ([D-060][d-060]).

The wall-clock channel, through a front end's stop button ([D-310][d-310]), a
device handle or code, is orthogonal and untouched. That is the operator path
of the [control plane](#g-control-plane) (the separate atomic surface carrying
pause, pace and stop). The sim-time, model-detected channel specified here
meets it at [§12.4][s12-4] and nowhere else.

The section covers, in order, detection and publication, placement and
requesters, the policy per advance, the scan and the source order, unbounded
runs, the termination record, ignored requests and post-terminal dynamics, and
inspection beside the reads a run acts on.

#### Detection and publication

Detection is ordinary [guard](#g-guard) (the declared function that detects an
event), handler and mode machinery ([D-060][d-060]). If the stop should be
localized, declare the [predicate](#g-predicate) (what a guard defines) as a
sign-form event. Such an event is [localized](#g-localized) (the crossing
instant bracketed by root-finding over trial sweeps). Touchdown overload is
precisely a zero-crossing. The [boundary](#g-boundary) (a published
consistency point) is localized to the crossing, and the handler sets
`m.crashed`. The [snapshot](#g-snapshot) (the immutable per-boundary
publication) at the crossing instant carries the touchdown state.

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

**The library spelling is `StopRequest`** ([D-316][d-316]). It is a stateless
continuous leaf in the mould of `Constant` ([§13.7][s13-7]). Its one input is
the stop's `Bool`, its one output the flag, and its reason is instance data.

```julia
# StopRequest — a stateless continuous leaf; its reason is instance data
struct StopRequest <: AbstractComponent
    reason::String
end
StopRequest(; reason = "") = StopRequest(reason)
x_init(::StopRequest) = (;)
u_types(::StopRequest) = (request = Bool,)
y_types(::StopRequest) = (flag = StopFlag,)
y_direct(::StopRequest, (; u)) = (flag = u.request ? STOP_REQUESTED : NO_STOP,)
stop_reason(c::StopRequest) = c.reason
```

Its output is consumed by nobody, which [§6.1][s6-1] allows silently ([D-084][d-084]).
`StopRequest` is continuous, so it refreshes at every boundary, `t*`
included ([D-316][d-316]). Assemblies are virtual for execution and rate
scopes touch discrete children only, so one leaf sits anywhere in the tree
([§10.5][s10-5], [D-019][d-019]). Fed by a discrete detector, it sees the tick
at the tick's own boundary, because the boundary sweep walks the full
execution order in topological order ([§10.5][s10-5], [D-147][d-147]). The
block holds no privilege. Any [component](#g-component) (a leaf or an
assembly of components) may publish a `StopFlag` port directly.

#### Placement and requesters

Placement is checked at build. **Two placements are `IllegalPortType`**
([D-316][d-316]). A `StopFlag` leaf nested inside a port of another type is
refused with reason `:stop_flag_nested`, and a root input whose type carries a
`StopFlag` anywhere with reason `:stop_flag_at_root`. The first is refused
because the build lists requests per port, so a request inside a struct field
or a static array would have no listing of its own. The second is refused
because a request is the model's, never an operator's. The operator's path is
the control plane ([§12.1][s12-1]). A `StopFlag` input port places nothing and
is left alone.

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

#### The policy per advance

[§12.6][s12-6] declares the stop policy per advance, with `t_end` and
`ignore_stop_requests` as keywords of `run!`, `replay!` and `step!`, and
gives the value's lifetime. Each of the three calls takes `Inf` and `()` as
the defaults ([D-255][d-255]). The defaults belong to the calls that take the
policy. With no constructor defaults the [trace header](#g-trace-header) (the
trace's fixed preamble, taken at boundary zero) has no policy to record
([§11.5][s11-5]). The [termination record](#g-termination-record) (the
stopped-sim value naming how the run ended) carries the policy that actually
ended the run.

**Every request is honoured unless the advance ignores it** ([D-316][d-316]).
`ignore_stop_requests = :all` ignores every requester. An iterable of
strings names requesters by component path. Each path is validated against
the requester roster on every call, and duplicates collapse, in the order
given. A path naming no requester is `StopRequestInvalid`, collected over the
given paths ([Appendix C][sC]). A `t_end` that is not a non-negative real is
`ArgumentInvalid`, refused before the ignore list is read.

Each advance builds a [`StopPolicy`](#g-stop-policy) (the immutable value of
`t_end` plus the ignored requester paths), and passes it to the loop with an
ignore mask, one `Bool` per requester, as a second argument ([D-316][d-316]).
A `t*` hit reaches the loop as `frame!`'s return value ([D-261][d-261],
[D-317][d-317]), a `Bool` saying whether the frame was abandoned, never as a
field of the policy or of the [execution cursor](#g-execution-cursor) (the
field recording where execution stands). The loop then reads the requester
off the snapshot it just published.

#### The scan and the source order

**After *every* published boundary the loop scans the `StopFlag` block of the
snapshot it just published**, in requester roster order ([D-316][d-316]).
Grid boundaries, `t*` ([§10.4][s10-4]) and [boundary zero](#g-boundary-zero)
(the initialization boundary at `t₀`) all count ([§14.5][s14-5]). The first
honoured request reading `STOP_REQUESTED` initiates [§12.4][s12-4] shutdown
with *this* snapshot as the final one. The terminal snapshot is the terminal
state. There is no roll-back, and nothing [§12.4][s12-4] does not already do.
That terminal snapshot's status carries the run's final cumulative diagnostic
counters ([§11.8][s11-8]).

Every advance checks the latest snapshot for an honoured request before its
first frame. After `init!` that snapshot is boundary zero's, so an authored
[condition](#g-condition) (the path-addressed sparse overlay that sets a
build's state) already terminal ends the run at `t₀` with that snapshot
final, integrating nothing. A run that starts later ends where it started,
advancing no frame. The request is the author's and the ignore list the
integrator's, and the ignore list sits beside `t_end` at the same
declaration site.

**The sources are consulted in a fixed order** ([D-203][d-203]). The loop
checks a pending control stop at frame top, then `t_end`, then the stop
requests at each publication. When two sources hold at one boundary, the
recorded source is the first in that order ([D-203][d-203]).

The rule authors are taught is this. Stop requests are sampled at completed
boundaries; declare a sign-form event if you need the stop localized. Both
shapes of the stop's `Bool` feeding a request work without framework
latching. A handler-set `m` flag is sticky by nature. A transient stage-2
Bool is caught because the loop reacts to the first request it reads holding.
Compound stop logic composes in-model, as a monitor component reading the
relevant signals and feeding one request. That is the same move
[§12.5][s12-5] made for scripts.

#### Unbounded runs

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

```julia
sim = Simulation(world; h = 1//50)          # no policy here: the deployment has none

init!(sim, cond); run!(sim; t_end = 60)                     # every request honoured
init!(sim, cond); run!(sim; t_end = 60,
                        ignore_stop_requests = ("ldg/stop",))  # one requester ignored, by path
init!(sim, cond); step!(sim; frames = 100)                  # Inf and (), the defaults
init!(sim, cond); run!(sim; ignore_stop_requests = :all)    # unbounded: UnboundedRun, then fly
```

#### The termination record

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

- `EndTimeReached` means `t_end`'s frame completed. It has no payload. The
  record's own `t` is the fact, and the bound that was configured is in the
  record's own policy.
- `ModelRequestedStop` means an honoured stop request read `STOP_REQUESTED`.
  The payload is the requester's component path, its port and its reason.
  When two requests hold at one boundary, the record names the first in
  requester roster order ([D-316][d-316]).
- `ControlRequestedStop` means a control-plane stop. The payload is its
  issuer, the requesting device, `:code` or `:interrupt` ([§12.1][s12-1]).
- `LoopError` means the abnormal entry of [§13.6][s13-6]. The payload is the
  propagated cause. A throw inside the frame reaches the record with the
  `Model` already marked `:inconsistent` by its own catch, and the simulation
  reads `errored`. A loop fault outside the frame, in the pacer, a yield or
  the tail, closes the run as `stopped` with the `Model` consistent at its
  last settled boundary, since only the `Model`'s own catch sites mark it
  ([D-317][d-317]). The record covers both exactly alike.

A `stopped` simulation therefore answers "why did it stop?" without its
consumer reconstructing the answer from the clock. It answers "how did the
stop go?" from the same value. **The operator interrupt is a tag on an
ordinary stop**, not a source type of its own, because nothing failed
([D-203][d-203]). [Appendix C][sC] gains nothing from it.

#### Ignored requests and post-terminal dynamics

An ignored request is still a cell in every snapshot, so the log records when
validity broke even on a run that continued ([D-316][d-316]). Two uses share
the mechanism, validity breakdown and scenario completion. The reason string
is what tells a reader which, and the framework never will.

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

#### Inspection and the reads a run acts on

The rejected mechanisms, litigated in [D-060][d-060] and [D-316][d-316], are
predicate closures such as `stop_when = snap -> …`, root-type-declared stop
policy, which the per-advance policy is not, `terminal` event flags, a
control-plane capability for components, observation-by-path (an advance
naming a deep path into any public output), and the `Bool` face re-exported
level by level to the root and named by the advance, which fell to stop
requests. [D-060][d-060] also rejected [blessed](#g-blessed) (explicitly
sanctioned by the spec) terminal types scanned from the tree, an arm the stop
request supersedes on its own terms.

The observation-by-path line leaves doctrine behind it, narrowed by
[D-316][d-316]. Inspection is human-facing, has no effect on run semantics,
and legitimately sees every public cell. The log retaining the full table, a
front end's panels rendering a component's ports, and inspection under
[replay](#g-replay) (the ordinary loop re-driven from a recorded trace) are
all inspection. A read the run acts on changes what the run *does*, and it
reads only what the model declared for it, never an arbitrary cell. The stop
scan is the one such read. It reads the `StopFlag` block, which holds nothing
but the requests their authors declared by type. [§13.3][s13-3] draws the
same line for path resolution, client by client. The ignore list addresses
the `Build`'s requester roster, a build product like the root-input list. It
binds at an advance, a stopped-sim point where conditions already address
state by path ([§14.1][s14-1]). The requester is loud at inspection, since
the requester roster and the termination record name it. Substitution is
answered by the ignore list, and disabling is one keyword. The trigger is the
author's knowledge and the ignore list the integrator's. Output devices are
the other half of the same doctrine. Their reads are inspection bindings on
snapshot paths ([§11.2][s11-2]).

### 13.6 Abnormal shutdown: one tail, two entries

A failure on the loop's side can arrive in the middle of a
[boundary](#g-boundary) (a published consistency point). The run must still
end through the shutdown tail of [§12.4][s12-4], which starts from a final
[snapshot](#g-snapshot) (the immutable per-boundary publication). This
section gives the abnormal path, the reason it is safe, the two entries
charted, the record it writes, tail hygiene, and what an errored simulation
keeps and refuses.

**The abnormal path discards the failed boundary, promotes the previous
snapshot to final, and rejoins the ordinary tail** ([D-030][d-030]). The
protocol becomes one tail with two entry points. Graceful entry follows a
*completed* final boundary, and abnormal entry follows a *discarded* one.
Everything downstream of "final snapshot" runs identically. That covers
sticky stopped, waiters woken through the boundary-counter plus `Condition`
path, the hooks `unblock!` and `shutdown!`, and named joins with timeout.
Those waiters observe stopped rather than a new boundary, so no task of a
[device](#g-device) (an attached participant in the periphery) hangs.

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

```
  graceful entry                      abnormal entry
  final boundary completes            failed boundary discarded
  final snapshot published            previous snapshot promoted to final
             |                                   |
             +-----------------+-----------------+
                               |
                       "final snapshot"
                               |
       sticky stopped → waiters woken → unblock! and shutdown!
                     → named joins with timeout
```

This fills the seat [§12.4][s12-4] reserved for it. A loop-side failure runs
the same protocol from the catch path ([D-030][d-030]). The
[termination record](#g-termination-record) (the stopped-sim value naming how
the run ended) covers this entry too. Its source is `LoopError`, and the
payload is the propagated cause ([§13.5][s13-5], [D-203][d-203]).

Tail hygiene follows from the hooks being user code too. Each is individually
caught and logged. Shutdown therefore runs to completion even if a device's
hook misbehaves. The join timeout already bounds a hook that hangs rather than
throws.

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

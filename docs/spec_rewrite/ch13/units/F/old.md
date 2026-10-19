### 13.5 Termination is a state, not an exception

FlightCore's `SimulationTermination` idiom (model code throws, and the loop
catches and logs it as informational) has **no counterpart here**
([D-060][d-060]). The discipline is that **exceptions from model code are
always abnormal**. Graceful termination is model *state*, and it reaches the
loop through declared machinery.

- **Detection** is ordinary [guard](#g-guard)/handler/mode machinery. If the
  stop should be localized, declare the [predicate](#g-predicate) as a
  sign-form event. Such an event is [localized](#g-localized) (the crossing
  instant bracketed by root-finding over trial sweeps). Touchdown overload is
  precisely a zero-crossing. The boundary is localized to the crossing, the
  handler sets `m.crashed`, and the [snapshot](#g-snapshot) at the crossing
  instant carries the touchdown state.
- **Publication** is a [stop request](#g-stop-request) (an output port of
  the framework enum `StopFlag`), declared where the condition is detected.
  **A port whose type is exactly `StopFlag` is a stop request, whoever
  publishes it** ([D-316][d-316]). The enum is `@enum StopFlag NO_STOP STOP_REQUESTED`.
  An enum is one leaf, pinned at every activation ([§4.3][s4-3]), and cells are
  stored per element type ([§9.7][s9-7]), so every request in the model lands in one
  `StopFlag` block. The condition is gathered at its owning boundary in one
  visible block. `Ldg` ORs its three legs through a junction (the ownership
  idiom, [§6.2][s6-2]; the library, [§13.7][s13-7]) and wires the result into a `StopRequest`
  child, the library's spelling of a request (below). No level above it
  re-exports anything, because the loop reads the request where it is.
- **Placement** is checked at build. **A `StopFlag` leaf nested inside a
  port of another type is `IllegalPortType`, and so is a root input whose
  type carries a `StopFlag` anywhere** ([D-316][d-316]). The first is refused because the build rosters
  requests per port, so a request inside a struct field or a static array
  would have no entry of its own. The second is refused because a request is
  the model's, never an operator's. The operator's path is the
  [control plane](#g-control-plane) ([§12.1][s12-1]). A `StopFlag` input port places
  nothing and is left alone.
- **The roster** names every request. **The build records one
  `Requester(path, port, reason)` per `StopFlag` output port, as the
  `requesters` of the activation's cell layout, index-aligned with the
  `StopFlag` block** ([D-316][d-316]). Entry `i` owns the block's offset `i - 1`, and
  roster order is build order. The reason is the publishing component's
  `stop_reason`, an optional declaration with default `""` ([§8.2][s8-2]). One
  reason serves all of a component's requests. It is instance data on the
  component, never a port value.
- **Policy** is declared per advance. `t_end` and `ignore_stop_requests` are
  keywords of `run!` and `replay!`, with `Inf` and `()` as defaults, and
  `step!` states the same defaults itself ([D-255][d-255]). **Every request is
  honoured unless the advance ignores it** ([D-316][d-316]).
  `ignore_stop_requests = :all` ignores every requester. An iterable of
  strings names requesters by component path. Each path is validated against
  the roster on every call, and duplicates collapse, in the order given. A
  path naming no requester is `StopRequestInvalid`, collected over the given
  paths ([Appendix C][sC]). Each advance builds a
  **[`StopPolicy`](#g-stop-policy)**,
  the immutable value of `t_end` plus the ignored requester paths, and passes
  it to the loop with an ignore mask, one `Bool` per requester, as a second
  argument ([D-261][d-261]). The value lives as long as the
  call, and afterwards only on the termination record of the advance that
  ended the run ([§12.6][s12-6], [D-260][d-260]). A `t*` hit reaches the
  loop as `frame!`'s return value, a `Bool` saying whether the frame was
  abandoned, never as a field of the policy or of the
  [execution cursor](#g-execution-cursor) ([D-261][d-261], [D-317][d-317]). The loop
  then reads the requester off the snapshot it just published.
  After *every* published boundary the loop scans the `StopFlag` block of
  the snapshot it just published, in roster order. Grid boundaries, `t*`
  ([§10.4][s10-4]) and [boundary zero](#g-boundary-zero) ([§14.5][s14-5]) all count. The first
  honoured request reading `STOP_REQUESTED` initiates [§12.4][s12-4] shutdown with
  *this* snapshot as the final one. The terminal snapshot is the terminal
  state. There is no roll-back, and nothing [§12.4][s12-4] does not already do. That
  terminal snapshot's status carries the run's final cumulative diagnostic
  counters ([§11.8][s11-8]).
  `run!` therefore checks the boundary-zero snapshot before the first step. An
  authored [condition](#g-condition) (the path-addressed sparse overlay that
  sets a build's state) that is already terminal ends the run at `t₀` with
  that snapshot final, integrating nothing. The request is the author's and
  the override the integrator's, and the override sits beside `t_end` at the
  same declaration site.

**The library spelling is `StopRequest`.** It is a stateless continuous
leaf in the mould of `Constant` ([§13.7][s13-7]). Its one input is the `Bool`
condition, its one output the flag, and its reason is instance data.

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
included. Assemblies are virtual for execution and rate scopes touch
discrete children only, so one leaf sits anywhere in the tree ([§10.5][s10-5],
[D-019][d-019]). Fed by a discrete detector, it sees the tick at the tick's own
boundary, because the boundary sweep walks the full execution order in
topological order ([§10.5][s10-5], [D-147][d-147]). The block holds no privilege. Any
component may publish a `StopFlag` port directly.

**An unbounded run is allowed.** `run!(sim)` with `t_end = Inf` and no
honoured request is the interactive session's ordinary shape, and the
[operator interrupt](#g-operator-interrupt) is its escape ([§12.4][s12-4]). The model
may have no requester, or the advance may ignore them all.
The loop raises `UnboundedRun` into its own [diagnostic cell](#g-diagnostic-cell),
and the status record carries it ([§11.8][s11-8], [D-255][d-255], [D-316][d-316]). Its message says
which of the two cases holds. The
advisory fires in `:live` only. A `run!` in `:replay` is bounded by the
recording, whatever its policy says ([§12.7][s12-7], [D-218][d-218]).

```julia
sim = Simulation(world; h = 0.02)          # no policy here: the deployment has none

init!(sim, cond); run!(sim; t_end = 60)                     # every request honoured
init!(sim, cond); run!(sim; t_end = 60,
                        ignore_stop_requests = ("ldg/stop",))  # one requester ignored, by path
init!(sim, cond); step!(sim; frames = 100)                  # Inf and (), the defaults
init!(sim, cond); run!(sim; ignore_stop_requests = :all)    # unbounded: UnboundedRun, then fly
```

**Why one binding site.** A `StopPolicy` is what the caller declares for one
advance, so it is a value that advance builds ([D-255][d-255]). The defaults
belong to the calls that take it. With no constructor defaults the
[trace header](#g-trace-header) has no policy to record ([§11.5][s11-5]), and
the termination record carries the policy that actually ended the run. This is
not the root-declared stop policy rejected below. Binding at the call moves the
policy one notch *later* along the same axis, more deployment-flavored rather
than less ([D-060][d-060]). The `stopped → init! → run!` cycle and the `step!`
idiom ([§12.6][s12-6]) are precisely where one `Simulation` wants different
stopping policies on different runs.

**The termination record names the source, as a typed value.** The run's
[termination record](#g-termination-record) carries its *outcome*, and the
`StopPolicy` of the advance that ended it ([D-255][d-255]). The record
holds four things, the final boundary time, the terminating policy, the source
and the tail residue.
The tail residue is the post-account diagnostics the run's-end sweep folds in
([§11.8][s11-8]). The time is always present, because boundary zero precedes
every record and a throw inside boundary zero writes none ([§12.6][s12-6],
[D-233][d-233]). The source follows the diagnostic convention, so its kind is
its identity and its payload is plain data ([§13.2][s13-2]). It has four
kinds.

- `EndTimeReached` means `t_end`'s frame completed. It has no payload. The
  record's own `t` is the fact, and the bound that was configured is in the
  record's own policy.
- `ModelRequestedStop` means an honoured stop request read `STOP_REQUESTED`.
  The payload is the requester's component path, its port and its reason.
  When two requests hold at one boundary, the record names the first in
  roster order ([D-316][d-316]).
- `ControlRequestedStop` means a control-plane stop. The payload is its issuer
  ([§12.1][s12-1]): the requesting device, `:code`, or `:interrupt`.
- `LoopError` means the abnormal entry of [§13.6][s13-6]. The payload is the
  propagated cause. A throw inside the frame reaches the record with the
  `Model` already marked `:inconsistent` by its own catch, and the simulation
  reads `errored`; a loop fault outside the frame, in the pacer, a yield or
  the tail, closes the run as `stopped` with the `Model` consistent at its
  last settled boundary, since only the `Model`'s own catch sites mark it
  ([D-317][d-317]). The record covers both exactly alike.

A `stopped` simulation therefore answers "why did it stop?" without its
consumer reconstructing the answer from the clock. It answers "how did the
stop go?" from the same value. The
[operator interrupt](#g-operator-interrupt) is a tag on an ordinary stop, not
a [kind](#g-kind) of its own, because nothing failed. [Appendix C][sC] gains
nothing from it.

**Rule.** The sources are consulted in a fixed order. The loop checks a pending
control stop at frame top, then `t_end`, then the stop requests at each
publication. When two sources hold at one boundary, the recorded source is the
first in that order ([D-203][d-203]).

The taught contract is this. **Stop requests are sampled at completed
boundaries; declare a sign-form event if you need the stop localized.** Both
shapes of the condition feeding a request work without framework latching. A
handler-set `m` flag is sticky by nature. A transient stage-2 Bool is caught
because the loop reacts to the first request it reads holding. Compound stop
logic composes in-model, as a monitor [component](#g-component) reading the
relevant signals and feeding one request. That is the same move [§12.5][s12-5] made
for scripts.

An ignored request is still a cell in every snapshot, so the log records when
validity broke even on a run that continued. Two uses share the mechanism,
validity breakdown and scenario completion. The reason string is what tells a
reader which, and the framework never will.

Post-terminal dynamics are the model's job, and that is a feature. Today
`robot2d` *throws* when it falls, because it has no other way to say "my
dynamics are no longer meaningful". Here it declares the fall as an event,
switches to a frozen mode, and feeds `fallen` to a stop request. The frozen
mode is a mode-dependent `x_deriv`, machinery the model already has.
Honoured, the request ends the sim at the fall. Ignored, the sim integrates a
frozen robot, which is well-defined, unlike an uncaught throw. The discipline
forces models to have well-defined terminal states, which is better modeling.

The rejected mechanisms are litigated in [D-060][d-060] and [D-316][d-316]. They are predicate
closures (`stop_when = snap -> …`), root-type-declared stop policy,
`terminal` event flags, a [control-plane](#g-control-plane) capability for
[components](#g-component), and observation-by-path (an advance naming a deep
path into any public output). The `Bool` face re-exported level by level to
the root and named by the advance fell to stop requests ([D-316][d-316]). [D-060][d-060] also
rejected [blessed](#g-blessed) terminal types scanned from the tree. The stop
request supersedes that arm on its own terms. The requester is loud at
inspection, since the roster and the termination record name it.
Substitution is answered by the override, and disabling is one keyword. The
trigger is the author's knowledge and the override the integrator's.

The observation-by-path line leaves doctrine behind it, narrowed by [D-316][d-316].
**Inspection** is human-facing, has no effect on run semantics, and
legitimately sees every public [cell](#g-cell). The log retaining the full
table, GUI panels rendering a component's [ports](#g-port), and
[replay](#g-replay) inspection are all inspection. **A read the run acts on**
changes what the run *does*, and it reads only what the model declared for
it, never an arbitrary cell. The stop scan is the one such read. It reads the
`StopFlag` block, which holds nothing but the requests their authors declared
by type. The ignore list addresses the `Build`'s requester roster, a build
product like the root-input list. It binds at an advance, a stopped-sim point
where conditions already address state by path ([§14.1][s14-1]). Output devices are
the other half of the same doctrine. Their reads are inspection bindings on
snapshot paths ([§11.2][s11-2]).

The wall-clock channel (GUI stop button, device handle, code) is orthogonal
and untouched. That is the [control plane](#g-control-plane)'s operator path.
The sim-time, model-detected channel specified here meets it at
[§12.4][s12-4] and nowhere else.

### 13.6 Abnormal shutdown: one tail, two entries

**The [boundary](#g-boundary) is all-or-nothing outside the sim task.** That is
why a `StepError` cannot break [§12.4][s12-4]. [Sweeps](#g-sweep) write into
table blocks. Integration intermediates live in framework-owned integrator
buffers, never in a [component](#g-component)'s [workspace](#g-workspace) as
[§7.3][s7-3] defines it. The only externally visible act is
[snapshot](#g-snapshot) publication at the very end of the sequence. A
boundary that throws has published nothing. The last *published* snapshot is a
complete, consistent boundary by construction, and it is still the newest
thing any [device](#g-device), logger or waiter has seen.

The abnormal path therefore **discards the failed boundary, promotes the
previous snapshot to final, and rejoins the ordinary tail.** The protocol
becomes one tail with two entry points. Graceful entry follows a *completed*
final boundary, and abnormal entry follows a *discarded* one. Everything
downstream of "final snapshot" runs identically: sticky stopped, waiters woken
through the boundary-counter plus `Condition` path, `unblock!`/close hooks,
and named joins with timeout. Those waiters observe stopped rather than a new
boundary, so no device task hangs.

```
  graceful entry                      abnormal entry
  final boundary completes            failed boundary discarded
  final snapshot published            previous snapshot promoted to final
             |                                   |
             +-----------------+-----------------+
                               |
                       "final snapshot"
                               |
       sticky stopped → waiters woken → unblock!/close hooks
                     → named joins with timeout
```

This fills the seat [§12.4][s12-4] reserved for it. A loop-side failure runs
the same protocol from the catch path. The
[termination record](#g-termination-record) covers this entry too. Its source
is `LoopError`, and the payload is the propagated cause ([§13.5][s13-5],
[D-203][d-203]).

Tail hygiene follows from the hooks being user code too. Each is individually
caught and logged. Shutdown therefore runs to completion even if a device's
hook misbehaves. The join timeout already bounds a hook that hangs rather than
throws.

What is lost is quarantined. The state [stores](#g-store) may hold
mid-boundary values (a half-written `m`, integration intermediates). They are
retained on the errored `Simulation` for post-mortem inspection, but an
errored sim is terminally stopped, not resumable. The reproduction tool is
[trace](#g-trace) [replay](#g-replay), not resurrection. The stopped-sim
services enforce that non-resumability by refusing an errored simulation
outright (`ServiceLifecycle`, [§14][s14]). The roster operations refuse it
with them ([§11.3][s11-3], [D-232][d-232]). Inspection is reading, but
`attach!` configures a run that cannot follow. The published record (snapshot
chain, log, trace) ends at the last consistent boundary. Nothing downstream of
the sim ever sees half a boundary.


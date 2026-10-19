# Unit F claims: §13.5 and §13.6 (old spec lines 10443–10727 at 1fee0fc).

old: ### 13.5 Termination is a state, not an exception
tag: X

added: This section specifies how a model ends its own run, how an advance chooses which stop requests to honour, and what the run records when it ends.

old: FlightCore's `SimulationTermination` idiom (model code throws, and the loop catches and logs it as informational) has no counterpart here (D-060).
tag: R
ruling: R22
note: row 501. One bold on "has no counterpart here", D-060's "no `SimulationTermination` exception type" ruling, with D-060 in the sentence; the history stays plain.

old: The discipline is that exceptions from model code are always abnormal.
new: The discipline is that exceptions from model code are always abnormal (D-060).
tag: C
newcites: D-060
note: row 502; bold kept on the headline clause, D-060's chained ruling 5, cited in its own sentence now.

old: Graceful termination is model state,
new: Graceful termination is model state, never an exception (D-060).
tag: R
ruling: R5
newcites: D-060
note: row 503; D-060's headline ruling, bold here and nowhere else; "never an exception" is R5's dictated wording and D-060's first ruling.

old: and it reaches the loop through declared machinery.
new: It reaches the loop through declared machinery.
tag: F

old: Detection is ordinary guard/handler/mode machinery.
new: Detection is ordinary guard (the declared function defining an event's predicate), handler and mode machinery (D-060).
tag: C
newcites: D-060
note: row 504; bold list lead-in goes (R3); D-060 Position "detection by ordinary guard/handler machinery".

added: (the declared function defining an event's predicate)

old: If the stop should be localized, declare the predicate as a sign-form event.
new: If the stop should be localized, declare the predicate (a `Bool`-valued form, or the sign of a continuous function) as a sign-form event.
tag: F

added: (a `Bool`-valued form, or the sign of a continuous function)

old: Such an event is localized (the crossing instant bracketed by root-finding over trial sweeps).
tag: F

old: Touchdown overload is precisely a zero-crossing.
new: A landing-gear strut's touchdown overload is precisely a zero-crossing.
tag: F
note: verifier's fix; the introducing clause follows spec 4717, "A landing-gear strut model that throws on a touchdown overload".

added: A landing-gear strut's

old: The boundary is localized to the crossing, the handler sets `m.crashed`,
new: The boundary (a published consistency point) is localized to the crossing, and the handler sets `m.crashed`.
tag: F
note: boundary newly linked at its first use in §13.5.

added: (a published consistency point)

old: and the snapshot at the crossing instant carries the touchdown state.
new: The snapshot (the immutable per-boundary publication) at the crossing instant carries the touchdown state.
tag: F

added: (the immutable per-boundary publication)

old: Publication is a stop request (an output port of the framework enum `StopFlag`), declared where the condition is detected.
new: Publication is a stop request, an output port (the addressable unit of the model) of the framework enum `StopFlag`, declared where the stop's `Bool` is detected.
tag: R
ruling: B20
note: "condition" in its first sense becomes "the stop's `Bool`" (R12); bold list lead-in goes (R3). B20 links port at its first use in §13.5 with the glossary's gloss; the stop-request gloss becomes an appositive so the parentheticals do not nest, and the bold after it stays gloss-free.

added: (the addressable unit of the model)

old: A port whose type is exactly `StopFlag` is a stop request, whoever publishes it (D-316).
tag: F
note: bold trimmed to the headline clause, D-316 bullet 1.

old: The enum is `@enum StopFlag NO_STOP STOP_REQUESTED`.
tag: F

old: An enum is one leaf, pinned at every activation (§4.3), and cells are stored per element type (§9.7), so every request in the model lands in one `StopFlag` block.
new: An enum is one leaf, pinned at every activation (§4.3), and cells (typed entries of the signal table) are stored per element type (§9.7), so every request in the model lands in one `StopFlag` block.
tag: F
note: cell linked at its first use (the old link sat late, at 10654).

added: (typed entries of the signal table)

old: The condition is gathered at its owning boundary in one visible block.
new: The stop's `Bool` is gathered at the boundary of the assembly that owns it, in one visible block.
note: step 5 P2-29: *boundary* here is the owning assembly's structural boundary, said in full.
tag: R
ruling: R12

old: `Ldg` ORs its three legs through a junction (the ownership idiom, §6.2; the library, §13.7)
new: The landing gear `Ldg` from the example of §6.1 ORs its three legs through a junction (the ownership idiom, §6.2; the library, §13.7).
tag: R
ruling: R10
newcites: §6.1 §6.2 §13.7
note: R10's introducing clause; `Ldg` is defined at §6.1 (frozen spec 1553).

added: The landing gear

added: from the example of §6.1

old: and wires the result into a `StopRequest` child, the library's spelling of a request (below).
new: It wires the result into a `StopRequest` child, described below.
tag: R
ruling: B17
note: split from the `Ldg` sentence, which held two parentheticals. B17 cuts "the library's spelling of a request"; the bold "The library spelling is `StopRequest`" below holds it.

old: No level above it re-exports anything, because the loop reads the request where it is.
tag: F

old: Placement is checked at build.
tag: F
note: bold list lead-in goes (R3).

old: A `StopFlag` leaf nested inside a port of another type is `IllegalPortType`,
new: Two placements are `IllegalPortType` (D-316). A `StopFlag` leaf nested inside a port of another type is refused with reason `:stop_flag_nested`,
tag: R
ruling: R14
newcites: D-316
note: bold shrinks to D-316 bullet 2's own headline, "Two placements are `IllegalPortType`"; R14 names the reason.

old: and so is a root input whose type carries a `StopFlag` anywhere (D-316).
new: and a root input whose type carries a `StopFlag` anywhere with reason `:stop_flag_at_root`.
tag: R
ruling: R14
note: D-316 cited in the same paragraph, one sentence earlier.

old: The first is refused because the build rosters requests per port, so a request inside a struct field or a static array would have no entry of its own.
new: The first is refused because the build lists requests per port, so a request inside a struct field or a static array would have no listing of its own.
tag: R
ruling: R12
note: bare "roster" goes (R12); bare "entry" is reserved (brief_common), so "no entry of its own" becomes "no listing of its own".

old: The second is refused because a request is the model's, never an operator's.
tag: F

old: The operator's path is the control plane (§12.1).
new: That is the operator path of the control plane
newcites:
tag: R
ruling: B14
note: the control-plane link moves to its first use, in the context (M51). B14 cuts the sentence; the opening (M51) is its home. Its §12.1 cite goes with it; §13.5 still cites §12.1 at `ControlRequestedStop`.

old: A `StopFlag` input port places nothing and is left alone.
tag: F

old: The roster names every request.
new: This list is the requester roster (the build's list of stop requests, one `Requester(path, port, reason)` per `StopFlag` output port, in build order), and it names every request.
tag: R
ruling: B8
note: R12's gloss at first use; bold list lead-in goes (R3). B8 opens the paragraph with the bold, and this sentence follows it.

added: (the build's list of stop requests, one `Requester(path, port, reason)` per `StopFlag` output port, in build order)

old: The build records one `Requester(path, port, reason)` per `StopFlag` output port, as the `requesters` of the activation's cell layout, index-aligned with the `StopFlag` block (D-316).
tag: F
note: bold trimmed to the headline clause, D-316 bullet 4.

old: Entry `i` owns the block's offset `i - 1`, and roster order is build order.
new: The requester at index `i` owns the block's offset `i - 1`.
tag: R
ruling: B8
note: bare "entry" reserved; "roster" in full (R12). B8 drops "and requester roster order is build order"; the roster's gloss, "in build order", carries it.

old: The reason is the publishing component's `stop_reason`, an optional declaration with default `""` (§8.2).
tag: F

old: One reason serves all of a component's requests.
tag: F

old: It is instance data on the component, never a port value.
tag: F

old: Policy is declared per advance.
new: §12.6 declares the stop policy per advance,
tag: R
ruling: R4
newcites: §12.6
note: M55; §12.6 holds the declaration (bold, frozen spec 9581). The pointer sentence.

old: `t_end` and `ignore_stop_requests` are keywords of `run!` and `replay!`,
new: with `t_end` and `ignore_stop_requests` as keywords of `run!`, `replay!` and `step!`, and gives the value's lifetime.
tag: R
ruling: R6
note: F67, row 520; §12.6 lists all three calls (frozen spec 9582). "gives the value's lifetime" is R4's pointer for row 525.

old: with `Inf` and `()` as defaults, and `step!` states the same defaults itself (D-255).
new: Each of the three calls takes `Inf` and `()` as the defaults (D-255).
tag: R
ruling: R6
note: F67; kept here because §12.6 does not state the defaults. D-255 bullet 5, "`step!` states the same defaults itself"; D-316 bullet 6 gives all three `()`.

old: Every request is honoured unless the advance ignores it (D-316).
tag: F
note: bold kept, D-316 Position.

old: `ignore_stop_requests = :all` ignores every requester.
tag: F

old: An iterable of strings names requesters by component path.
tag: F

old: Each path is validated against the roster on every call, and duplicates collapse, in the order given.
new: Each path is validated against the requester roster on every call, and duplicates collapse, in the order given.
tag: R
ruling: R12

old: A path naming no requester is `StopRequestInvalid`, collected over the given paths (Appendix C).
tag: F

added: A `t_end` that is not a non-negative real is `ArgumentInvalid`, refused before the ignore list is read.

old: Each advance builds a `StopPolicy`, the immutable value of `t_end` plus the ignored requester paths, and passes it to the loop with an ignore mask, one `Bool` per requester, as a second argument (D-261).
new: Each advance builds a `StopPolicy` (the immutable value of `t_end` plus the ignored requester paths), and passes it to the loop with an ignore mask, one `Bool` per requester, as a second argument (D-316).
tag: C
newcites: D-316
note: row 524; D-261's bullet is superseded by D-316 (log 13867–13868); D-316's bullet "The binder returns the policy and an ignore mask" states it. The bold glossary link goes plain (R5); the appositive becomes the link's gloss. §12.6's citation of §13.5 for the policy each call builds keeps this referent.

old: The value lives as long as the call, and afterwards only on the termination record of the advance that ended the run (§12.6, D-260).
new: The value lives as long as the call, and afterwards only on the termination record of the advance that ended the run (D-260).
where: docs/design/spec.md
tag: M
note: R4 makes the lifetime §12.6's (frozen spec 9584–9586); the pointer sentence says §12.6 gives it.

old: A `t` hit reaches the loop as `frame!`'s return value, a `Bool` saying whether the frame was abandoned, never as a field of the policy or of the execution cursor (D-261, D-317).
new: A `t` hit reaches the loop as the return value of the `Model`'s `frame!`, a `Bool` saying whether the frame was abandoned, never as a field of the policy or of the execution cursor (the field recording where execution stands) (D-261, D-317).
tag: F
note: citation at the sentence end, covering the cursor clause (verifier's fix); D-261's cited clause stands, its type clause is D-317's.

added: (the field recording where execution stands)

old: The loop then reads the requester off the snapshot it just published.
tag: F

old: After every published boundary the loop scans the `StopFlag` block of the snapshot it just published, in roster order.
new: After every published boundary the loop scans the `StopFlag` block of the snapshot it just published, in requester roster order (D-316).
tag: C
newcites: D-316
note: row 527; D-316's scan bullet ("After every publication the loop scans …"), bold here (R5); "requester roster" in full (R12).

old: Grid boundaries, `t` (§10.4) and boundary zero (§14.5) all count.
new: Grid boundaries, `t` (§10.4) and boundary zero (the initialization boundary at `t₀`) (§14.5) all count.
tag: F

added: (the initialization boundary at `t₀`)

old: The first honoured request reading `STOP_REQUESTED` initiates §12.4 shutdown with this snapshot as the final one.
tag: F

old: The terminal snapshot is the terminal state.
tag: F

old: There is no roll-back, and nothing §12.4 does not already do.
tag: F

old: That terminal snapshot's status carries the run's final cumulative diagnostic counters (§11.8).
tag: F

old: `run!` therefore checks the boundary-zero snapshot before the first step.
new: Every advance checks the latest snapshot for an honoured request before its first frame.
tag: R
ruling: R6
note: F51; `_advance!`'s entry `_stop_hit` on `latest(sim)`.

old: An authored condition (the path-addressed sparse overlay that sets a build's state) that is already terminal ends the run at `t₀` with that snapshot final, integrating nothing.
new: After `init!` that snapshot is boundary zero's, so an authored condition (the path-addressed sparse overlay that sets a build's state) already terminal ends the run at `t₀` with that snapshot final, integrating nothing.
tag: R
ruling: R6
note: F51's wording, keeping the old "with that snapshot final".

added: A run that starts later ends where it started, advancing no frame.

old: The request is the author's and the override the integrator's, and the override sits beside `t_end` at the same declaration site.
new: The ignore list, `ignore_stop_requests`, sits beside `t_end` at the same declaration site.
tag: R
ruling: B13
note: "the ignore list" for "the override" (R12). B13 cuts the first clause, which "The trigger is the author's knowledge and the ignore list the integrator's" carries, and moves the rest to the end of the policy paragraph of "The policy per advance". final_verify_2 finding 4: the moved sentence is the term's first use, so it names the keyword.

added: , `ignore_stop_requests`,

old: The library spelling is `StopRequest`.
new: The library spelling is `StopRequest` (D-316).
tag: C
newcites: D-316
note: M52 moves the block up, after the publication paragraph that says "below" of it; D-316 bullet 5, bold kept on the headline.

old: It is a stateless continuous leaf in the mould of `Constant` (§13.7).
tag: M
note: M52.

old: Its one input is the `Bool` condition, its one output the flag, and its reason is instance data.
new: Its one input is the stop's `Bool`, its one output the flag, and its reason is instance data.
tag: R
ruling: R12
note: M52.

old: `# StopRequest — a stateless continuous leaf; its reason is instance data struct StopRequest <: AbstractComponent reason::String end StopRequest(; reason = "") = StopRequest(reason) x_init(::StopRequest) = (;) u_types(::StopRequest) = (request = Bool,) y_types(::StopRequest) = (flag = StopFlag,) y_direct(::StopRequest, (; u)) = (flag = u.request ? STOP_REQUESTED : NO_STOP,) stop_reason(c::StopRequest) = c.reason`
tag: M
note: M52; the sketch verbatim.

old: Its output is consumed by nobody, which §6.1 allows silently (D-084).
tag: M
note: M52.

old: `StopRequest` is continuous, so it refreshes at every boundary, `t` included.
new: `StopRequest` is continuous, so it refreshes at every boundary, `t` included (§10.4, D-316).
tag: C
newcites: §10.4 D-316
note: M52; D-316 bullet 5, "Continuous, it refreshes at every boundary, `t*` included".

old: Assemblies are virtual for execution and rate scopes touch discrete children only, so one leaf sits anywhere in the tree (§10.5, D-019).
tag: M
note: M52.

old: Fed by a discrete detector, it sees the tick at the tick's own boundary, because the boundary sweep walks the full execution order in topological order (§10.5, D-147).
tag: M
note: M52.

old: The block holds no privilege.
tag: M
note: M52.

old: Any component may publish a `StopFlag` port directly.
new: Any component (the unit of modeling, a leaf or an assembly of components) may publish a `StopFlag` port directly.
tag: M
note: M52; component linked at its first use (the old links sat at 10622 and 10643).

added: (the unit of modeling, a leaf or an assembly of components)

old: An unbounded run is allowed.
new: An unbounded run is allowed (D-255).
tag: C
newcites: D-255
note: bold headline kept; D-255 bullet 5, "A run with `Inf` and no faces is allowed", amended by D-316 bullet 9.

old: `run!(sim)` with `t_end = Inf` and no honoured request is the interactive session's ordinary shape, and the operator interrupt is its escape (§12.4).
new: `run!(sim)` with `t_end = Inf` and no honoured request is the interactive session's ordinary shape, and the operator interrupt (Ctrl-C, read as a control-plane stop) is its escape (§12.4).
tag: F

added: (Ctrl-C, read as a control-plane stop)

old: The model may have no requester, or the advance may ignore them all.
tag: F

old: The loop raises `UnboundedRun` into its own diagnostic cell, and the status record carries it (§11.8, D-255, D-316).
new: `run!` raises `UnboundedRun` before the loop starts, into the loop's own diagnostic cell (the per-writer cell for runtime diagnostics and liveness), and the status record carries it (§11.8, D-255, D-316).
tag: R
ruling: R6
note: F67, row 543; `src/sim.jl` 1107–1108.

added: (the per-writer cell for runtime diagnostics and liveness)

old: Its message says which of the two cases holds.
tag: F

old: The advisory fires in `:live` only.
tag: F

old: A `run!` in `:replay` is bounded by the recording, whatever its policy says (§12.7, D-218).
tag: F

old: `sim = Simulation(world; h = 0.02) # no policy here: the deployment has none
new: sim = Simulation(world; h = 1//50) # no policy here: the deployment has none
tag: R
ruling: R6
note: F52, a ruled code edit; the block is otherwise verbatim.

old: init!(sim, cond); run!(sim; t_end = 60) # every request honoured init!(sim, cond); run!(sim; t_end = 60, ignore_stop_requests = ("ldg/stop",)) # one requester ignored, by path init!(sim, cond); step!(sim; frames = 100) # Inf and (), the defaults init!(sim, cond); run!(sim; ignore_stop_requests = :all) # unbounded: UnboundedRun, then fly`
new: init!(sim, cond); run!(sim; t_end = 60) # every request honoured init!(sim, cond); run!(sim; t_end = 60, ignore_stop_requests = ("ldg/stop",)) # one requester ignored, by path init!(sim, cond); step!(sim; frames = 100) # Inf and (), the defaults init!(sim, cond); run!(sim; ignore_stop_requests = :all) # unbounded: UnboundedRun, then fly
tag: F
note: the block's second half, verbatim; the blank line inside the fence splits it into two units.

old: Why one binding site.
where: units/F/deleted.md
tag: R
ruling: R3
note: the labelled lead-in goes; R4 reduces its paragraph to the policy pointer.

old: A `StopPolicy` is what the caller declares for one advance, so it is a value that advance builds (D-255).
new: §12.6 declares the stop policy per advance,
tag: R
ruling: R4
note: reduced to the pointer sentence, whose paragraph cites D-255; "a value that advance builds" is kept by "Each advance builds a `StopPolicy`" in the next paragraph but one.

old: The defaults belong to the calls that take it.
new: The defaults belong to the calls that take the policy.
tag: F
note: R4 keeps it; "it" was the `StopPolicy`, now named.

old: With no constructor defaults the trace header has no policy to record (§11.5),
new: With no constructor defaults the trace header (the trace's fixed preamble) has no policy to record (§11.5).
tag: F
note: R4 keeps the trace-header clause.

added: (the trace's fixed preamble)

old: and the termination record carries the policy that actually ended the run.
new: The termination record (the stopped-sim value naming how the run ended) carries the policy that actually ended the run.
tag: F
note: termination record linked at its first use (the old link sat at 10577).

added: (the stopped-sim value naming how the run ended)

old: This is not the root-declared stop policy rejected below.
new: The per-advance policy is not the root-type-declared one,
tag: R
ruling: R4
note: R4 and R9 place it as a clause beside the rejected mechanisms.

old: Binding at the call moves the policy one notch later along the same axis, more deployment-flavored rather than less (D-060).
where: units/F/deleted.md
tag: R
ruling: R4
note: cut; its only source is superseded D-091's Rejected list (log 2909–2911).

old: The `stopped → init! → run!` cycle and the `step!` idiom (§12.6) are precisely where one `Simulation` wants different stopping policies on different runs.
new: A second run, or a `step!` sequence between two runs, can therefore stop on a different clock or honour a different set of stop requests without a rebuild.
where: docs/design/spec.md
tag: M
note: R4; §12.6 holds it (frozen spec 9586–9588).

old: The termination record names the source, as a typed value.
new: The termination record names the source, as a typed value (D-203).
tag: C
newcites: D-203
note: bold headline kept; D-203 bullet 1.

old: The run's termination record carries its outcome, and the `StopPolicy` of the advance that ended it (D-255).
new: The run's termination record carries its outcome, and the `StopPolicy` of the advance that ended it (D-255, D-260).
tag: R
ruling: B22
newcites: D-255 D-260
note: B22 cites D-260 beside D-255; D-260 bullet 3, "The termination record is the policy's one lasting home", the old text's cite for the clause R4 relocated.

old: The record holds four things, the final boundary time, the terminating policy, the source and the tail residue.
new: The record holds four things, the final boundary time, the terminating policy, the source and the tail residue (the post-account diagnostics the run's-end sweep folds in).
tag: F

old: The tail residue is the post-account diagnostics the run's-end sweep folds in (§11.8).
new: (the post-account diagnostics the run's-end sweep folds in). §11.8 specifies that sweep.
tag: R
ruling: R12
newcites: §11.8
note: R12's inline gloss where "tail residue" first appears; the citation stays outside the gloss.

old: The time is always present, because boundary zero precedes every record and a throw inside boundary zero writes none (§12.6, D-233).
tag: F
note: row 555; "The time is always present" bold (R5), D-233 Position.

old: The source follows the diagnostic convention, so its kind is its identity and its payload is plain data (§13.2).
new: The source follows the diagnostic convention, so its type is its identity and its payload is plain data (§13.2, D-203).
tag: C
newcites: §13.2 D-203
note: D-203 bullet 1; bare "kind" is reserved and R12 bars the `#g-kind` sense, and the sources are types (`src/sim.jl` 24–42).

old: It has four kinds.
new: There are four source types.
tag: R
ruling: R12

old: `EndTimeReached` means `t_end`'s frame completed.
tag: F

old: It has no payload.
tag: F

old: The record's own `t` is the fact, and the bound that was configured is in the record's own policy.
tag: F

old: `ModelRequestedStop` means an honoured stop request read `STOP_REQUESTED`.
tag: F

old: The payload is the requester's component path, its port and its reason.
tag: F

old: When two requests hold at one boundary, the record names the first in roster order (D-316).
new: When two requests hold at one boundary, the record names the first in requester roster order (D-316).
tag: R
ruling: R12

old: `ControlRequestedStop` means a control-plane stop.
tag: F

old: The payload is its issuer (§12.1): the requesting device, `:code`, or `:interrupt`.
new: The payload is its issuer, the requesting device, `:code` or `:interrupt` (§12.1).
tag: F
note: the mid-sentence colon goes.

old: `LoopError` means the abnormal entry of §13.6.
tag: F

old: The payload is the propagated cause.
tag: F

old: A throw inside the frame reaches the record with the `Model` already marked `:inconsistent` by its own catch, and the simulation reads `errored`;
new: A throw inside the frame reaches the record with the `Model` already marked `:inconsistent` by its own catch, and the simulation reads `errored`.
tag: F

old: a loop fault outside the frame, in the pacer, a yield or the tail, closes the run as `stopped` with the `Model` consistent at its last settled boundary, since only the `Model`'s own catch sites mark it (D-317).
new: A loop fault outside the frame, in the pacer, a yield or the tail, closes the run as `stopped` with the `Model` consistent at its last settled boundary, since only the `Model`'s own catch sites mark it (D-317).
tag: F

old: The record covers both exactly alike.
tag: F

old: A `stopped` simulation therefore answers "why did it stop?" without its consumer reconstructing the answer from the clock.
tag: F

old: It answers "how did the stop go?" from the same value.
tag: F

old: The operator interrupt is a tag on an ordinary stop, not a kind of its own, because nothing failed.
new: The operator interrupt is a tag on an ordinary stop, not a source type of its own, because nothing failed (D-203).
tag: C
newcites: D-203
note: row 563; D-203 bullet 2, bold here (R5); no `#g-kind` link (R12); the second operator-interrupt link goes.

old: Appendix C gains nothing from it.
tag: F

old: Rule.
where: units/F/deleted.md
tag: R
ruling: R3

old: The sources are consulted in a fixed order.
new: The sources are consulted in a fixed order (D-203).
tag: C
newcites: D-203
note: M53 moves the order up, after the scan and the entry check; bold headline, D-203 bullet 5 as amended by D-316 bullet 7.

old: The loop checks a pending control stop at frame top, then `t_end`, then the stop requests at each publication.
tag: M
note: M53.

old: When two sources hold at one boundary, the recorded source is the first in that order (D-203).
new: When two sources hold at one boundary, the termination record names the first in that order (D-203).
tag: M
note: M53.

old: The taught contract is this.
new: Authors are taught that
tag: X
note: M54. *contract* is reserved for a component's declared interface (brief_common), so the touched sentence is reworded.

old: Stop requests are sampled at completed boundaries; declare a sign-form event if you need the stop localized.
new: stop requests are sampled at completed boundaries, and that a stop that must be localized needs a sign-form event.
tag: R
ruling: R5
note: M54; row 565's bold goes plain (R5); step 5 P2-8 folds it into the taught sentence.

old: Both shapes of the condition feeding a request work without framework latching.
new: Both shapes of the stop's `Bool` feeding a request work without framework latching.
tag: R
ruling: R12
note: M54.

old: A handler-set `m` flag is sticky by nature.
tag: M
note: M54.

old: A transient stage-2 Bool is caught because the loop reacts to the first request it reads holding.
tag: M
note: M54.

old: Compound stop logic composes in-model, as a monitor component reading the relevant signals and feeding one request.
tag: M
note: M54.

old: That is the same move §12.5 made for scripts.
tag: M
note: M54.

old: An ignored request is still a cell in every snapshot, so the log records when validity broke even on a run that continued.
new: An ignored request is still a cell in every snapshot, so the log records when validity broke even on a run that continued (D-316).
tag: C
newcites: D-316
note: D-316 Rationale (log 13907–13911); see Rationale-only rulings.

old: Two uses share the mechanism, validity breakdown and scenario completion.
tag: F

old: The reason string is what tells a reader which, and the framework never will.
tag: F

old: Post-terminal dynamics are the model's job, and that is a feature.
tag: F

old: Today `robot2d` throws when it falls, because it has no other way to say "my dynamics are no longer meaningful".
new: `robot2d`, FlightApps' self-balancing robot in Flight.jl, throws `LostBalance`, a `SimulationTermination`, past 45° of tilt, because it has no other way to say "my dynamics are no longer meaningful".
tag: R
ruling: R10
note: R10's introducing clause; "Today" goes. Step 5 P2-7 merges the two sentences; "past 45° of tilt" is the fall.

added: FlightApps' self-balancing robot in Flight.jl, throws `LostBalance`, a `SimulationTermination`, past 45° of tilt,

old: Here it declares the fall as an event, switches to a frozen mode, and feeds `fallen` to a stop request.
tag: F

old: The frozen mode is a mode-dependent `x_deriv`, machinery the model already has.
tag: F

old: Honoured, the request ends the sim at the fall.
tag: F

old: Ignored, the sim integrates a frozen robot, which is well-defined, unlike an uncaught throw.
tag: F

old: The discipline forces models to have well-defined terminal states, which is better modeling.
new: The discipline forces models to have well-defined terminal states, which is better modeling (D-060).
tag: C
newcites: D-060
note: row 569 stays as a verdict with its citation (R9); D-060 Rejected, "models never state their terminal dynamics".

old: The rejected mechanisms are litigated in D-060 and D-316.
new: The rejected mechanisms, litigated in D-060 and D-316, are
tag: R
ruling: R9

old: They are predicate closures (`stop_when = snap -> …`), root-type-declared stop policy, `terminal` event flags, a control-plane capability for components, and observation-by-path (an advance naming a deep path into any public output).
new: predicate closures such as `stop_when = snap -> …`, root-type-declared stop policy, `terminal` event flags, a control-plane capability for components, observation-by-path (an advance naming a deep path into any public output), and
tag: R
ruling: R9
note: one sentence names all seven; the `stop_when` example loses its parentheses so the sentence keeps one parenthetical, observation-by-path's gloss.

old: The `Bool` face re-exported level by level to the root and named by the advance fell to stop requests (D-316).
new: the `Bool` face re-exported level by level to the root and named by the advance. The per-advance policy is not the root-type-declared one, and the re-exported face fell to stop requests.
note: step 5 P2-4 moves both relative clauses into a sentence of their own; this span runs through it.
tag: R
ruling: R9

old: D-060 also rejected blessed terminal types scanned from the tree.
new: D-060 also rejected blessed (explicitly sanctioned where a neighboring practice is forbidden) terminal types scanned from the tree,
tag: R
ruling: R23
note: R23 splits R9's sentence so the `#g-blessed` link keeps its gloss in a sentence of its own; D-060's attribution comes back with it.

added: (explicitly sanctioned where a neighboring practice is forbidden)

old: The stop request supersedes that arm on its own terms.
new: an arm the stop request supersedes on its own terms.
tag: R
ruling: R9

old: The requester is loud at inspection, since the roster and the termination record name it.
new: The requester is loud at inspection, since the requester roster and the termination record name it.
tag: R
ruling: R9
note: folded into the inspection doctrine (R9); "requester roster" in full (R12).

old: Substitution is answered by the override, and disabling is one keyword.
new: A substitution that changes when runs end is answered by the ignore list (D-060), and disabling is one keyword.
tag: R
ruling: B86
newcites: D-060
note: folded (R9); "the ignore list" (R12). B86 names the substitution D-060's Rejected list objects to, "swapping an aircraft silently changes when runs end"; Rationale-only, listed in rulings.md.

old: The trigger is the author's knowledge and the override the integrator's.
new: The trigger is the author's knowledge and the ignore list the integrator's.
tag: R
ruling: R9
note: folded (R9); "the ignore list" (R12).

old: The observation-by-path line leaves doctrine behind it, narrowed by D-316.
new: Rejecting observation-by-path separates inspection from the reads a run acts on, a line D-316 narrows.
tag: F
note: step 5 P2-6; the topic sentence names the doctrine the paragraph states.

old: Inspection is human-facing, has no effect on run semantics, and legitimately sees every public cell.
tag: F
note: bold term goes plain (R3).

old: The log retaining the full table, GUI panels rendering a component's ports, and replay inspection are all inspection.
new: The log retaining the full table, a front end's panels rendering a component's ports, and inspection under replay (the ordinary loop re-driven from a recorded trace) are all inspection.
tag: R
ruling: R6
note: F53; D-310 is cited once in the section, at the stop button (context). The port link goes (it sat late here).

added: (the ordinary loop re-driven from a recorded trace)

old: A read the run acts on changes what the run does, and it reads only what the model declared for it, never an arbitrary cell.
tag: F
note: bold term goes plain (R3).

old: The stop scan is the one such read.
tag: F

old: It reads the `StopFlag` block, which holds nothing but the requests their authors declared by type.
tag: F

added: §13.3 scopes path resolution by client, on a line of its own.

old: The ignore list addresses the `Build`'s requester roster, a build product like the root-input list.
tag: F

old: It binds at an advance, a stopped-sim point where conditions already address state by path (§14.1).
tag: F

old: Output devices are the other half of the same doctrine.
tag: F

old: Their reads are inspection bindings on snapshot paths (§11.2).
new: Their reads are inspection on snapshot paths (§11.2), though attach resolves them strictly, as §13.3's service clients (D-406).
tag: R
ruling: R29
newcites: §11.2 D-406
note: R29's dictated wording; D-406 Position, "Attach resolves a binding's `reads` through the read-selector family's one collecting resolver".

added: , though attach resolves them strictly, as §13.3's service clients (D-406)

old: The wall-clock channel (GUI stop button, device handle, code) is orthogonal and untouched.
new: The wall-clock channel, through a front end's stop button (D-310), a device handle or code, is orthogonal and untouched.
tag: R
ruling: R6
newcites: D-310
note: F53; M51 moves the paragraph into the context.

old: That is the control plane's operator path.
new: That is the operator path of the control plane (the separate atomic surface carrying pause, pace and stop).
tag: M
note: M51; control plane linked at its new first use.

added: (the separate atomic surface carrying pause, pace and stop)

old: The sim-time, model-detected channel specified here meets it at §12.4 and nowhere else.
tag: M
note: M51.

added: The section covers, in order, detection and publication, placement and requesters, the policy per advance, the scan and the source order, unbounded runs, the termination record, ignored requests and post-terminal dynamics, and the rejected mechanisms beside the reads a run acts on.

added: #### Detection and publication

added: #### Placement and requesters

added: #### The policy per advance

added: #### The scan and the source order

added: #### Unbounded runs

added: #### The termination record

added: #### Ignored requests and post-terminal dynamics

added: #### Rejected mechanisms and the reads a run acts on

old: ### 13.6 Abnormal shutdown: one tail, two entries
tag: X

added: A failure on the loop's side can arrive in the middle of a boundary (a published consistency point).

added: The run must still end through the shutdown tail of §12.4, which starts from a final snapshot (the immutable per-boundary publication).

added: This section gives the abnormal path, the reason it is safe, the two entries charted, the record it writes, tail hygiene, and what an errored simulation keeps and refuses.

old: The boundary is all-or-nothing outside the sim task.
new: The abnormal path is safe because the boundary is all-or-nothing outside the loop (D-030).
tag: R
ruling: R6
newcites: D-030
note: F55; M58 moves the reason paragraph after the ruling. The bold goes plain, as a reason after its rule; D-030 Rejected ("Mid-frame abort: torn final snapshot") carries it (Rationale-only rulings).

old: That is why a `StepError` cannot break §12.4.
tag: M
note: M58.

old: Sweeps write into table blocks.
new: Sweeps (passes through the execution order) write into table blocks.
tag: M
note: M58.

added: (passes through the execution order)

old: Integration intermediates live in framework-owned integrator buffers,
new: Integration intermediates live in framework-owned integrator buffers,
tag: M
note: M58.

old: never in a component's workspace as §7.3 defines it.
new: never in the scratch of a component (the unit of modeling, a leaf or an assembly of components). That scratch is its workspace (declared by allocation and excluded from state semantics), as §7.3 defines it.
tag: R
ruling: R23
note: M58; R23 links component at its first use beside workspace, one gloss per sentence. Both glosses from the glossary (`#g-component`, `#g-workspace`).

added: (the unit of modeling, a leaf or an assembly of components). That scratch is its

added: (declared by allocation and excluded from state semantics)

old: The only externally visible act is snapshot publication at the very end of the sequence.
tag: M
note: M58.

old: A boundary that throws has published nothing.
tag: M
note: M58.

old: The last published snapshot is a complete, consistent boundary by construction, and it is still the newest thing any device, logger or waiter has seen.
tag: M
note: M58.

old: The abnormal path therefore discards the failed boundary, promotes the previous snapshot to final, and rejoins the ordinary tail.
new: The abnormal path discards the failed boundary, promotes the previous snapshot to final, and rejoins the ordinary tail (D-030).
tag: C
newcites: D-030
note: row 581; "therefore" goes so the bold heads its sentence (R5); D-030 Position, "loop failure runs the same protocol from the catch path". Now the section's first ruling.

old: The protocol becomes one tail with two entry points.
tag: F

old: Graceful entry follows a completed final boundary, and abnormal entry follows a discarded one.
tag: F

old: Everything downstream of "final snapshot" runs identically: sticky stopped, waiters woken through the boundary-counter plus `Condition` path, `unblock!`/close hooks, and named joins with timeout.
new: Everything downstream of "final snapshot" runs identically. That covers sticky stopped, waiters woken through the boundary-counter plus `Condition` path, the hooks `unblock!` and `shutdown!`, and named joins with timeout.
tag: R
ruling: R6
note: F56; the colon list becomes its own sentence.

old: Those waiters observe stopped rather than a new boundary, so no device task hangs.
new: Those waiters observe stopped rather than a new boundary, so no device (an attached participant in the periphery) is left with a hanging task.
tag: F
note: device linked at its new first use.

added: (an attached participant in the periphery)

old: ``` graceful entry abnormal entry final boundary completes failed boundary discarded final snapshot published previous snapshot promoted to final | | +-----------------+-----------------+ | "final snapshot" | sticky stopped → waiters woken → unblock!/close hooks → named joins with timeout ```
new: ``` graceful entry abnormal entry final boundary completes failed boundary discarded final snapshot published previous snapshot promoted to final | | +-----------------+-----------------+ | "final snapshot" | sticky stopped → waiters woken → unblock! and shutdown! → named joins with timeout ```
tag: R
ruling: R6
note: F56, the ruled chart edit; the chart is otherwise verbatim.

old: This fills the seat §12.4 reserved for it.
tag: F

old: A loop-side failure runs the same protocol from the catch path.
new: A loop-side failure runs the same protocol from the catch path (D-030).
tag: C
newcites: D-030
note: D-030 Position, last clause; plain, since the ruling's bold is the section's first sentence.

old: The termination record covers this entry too.
new: The termination record (the stopped-sim value naming how the run ended) covers this entry too.
tag: F

old: Its source is `LoopError`, and the payload is the propagated cause (§13.5, D-203).
tag: F

old: Tail hygiene follows from the hooks being user code too.
tag: F

old: Each is individually caught and logged.
tag: F

old: Shutdown therefore runs to completion even if a device's hook misbehaves.
tag: F

old: The join timeout already bounds a hook that hangs rather than throws.
tag: F

old: What is lost is quarantined.
tag: F

old: The state stores may hold mid-boundary values (a half-written `m`, integration intermediates).
new: A throw inside the frame leaves the stores (the framework-owned homes of a component's `x`, `s` and `m`) possibly holding mid-boundary values, such as a half-written `m` or integration intermediates.
tag: R
ruling: R6
note: F57; the example list loses its parentheses to make room for the store's gloss.

added: (the framework-owned homes of a component's `x`, `s` and `m`)

old: They are retained on the errored `Simulation` for post-mortem inspection,
new: They are retained on the errored simulation for post-mortem inspection.
tag: R
ruling: R6
note: F57.

old: but an errored sim is terminally stopped, not resumable.
new: An errored simulation is terminal, not resumable,
tag: R
ruling: R6
note: F57, "terminal, not resumable"; R4 and M59 make it a pointer to §12.6, cited in the same sentence.

old: The reproduction tool is trace replay, not resurrection.
new: and the reproduction tool is trace replay (the ordinary loop re-driven from a recorded trace), not resurrection (§12.6, D-059, D-387).
tag: R
ruling: R4
newcites: §12.6 D-059 D-387
note: M59; §12.6 bolds `errored` terminal (D-059) and states the reproduction (D-387).

added: (the ordinary loop re-driven from a recorded trace)

added: A trace is a session's record of its drained inputs.

old: The stopped-sim services enforce that non-resumability by refusing an errored simulation outright (`ServiceLifecycle`, §14).
new: The stopped-sim services enforce the non-resumability by refusing an errored simulation outright (`ServiceLifecycle`, §14).
tag: F
note: final_verify_2 finding 6: "that" becomes "the", since the trace sentence now sits between it and "terminal, not resumable".

old: The roster operations refuse it with them (§11.3, D-232).
new: Operations on the roster (the list of attached device entries) refuse it with them (§11.3, D-232).
tag: F
note: step 5 P2-13; the device roster linked and glossed, so it is not read as the requester roster.

added: (the list of attached device entries)

old: Inspection is reading, but `attach!` configures a run that cannot follow.
tag: F

old: The published record (snapshot chain, log, trace) ends at the last consistent boundary.
tag: F

old: Nothing downstream of the sim ever sees half a boundary.
tag: F

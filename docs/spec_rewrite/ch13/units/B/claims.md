# Unit B (§13.3, §13.4): claims

old: ### 13.3 Build primitives: `resolve` and the face-list accessors
tag: F

old: The `input_passthrough` sketch (§8.8) calls two of the primitives below without defining them.
tag: F

old: All three are normative in the forms given here.
new: All three are normative in the forms given here (D-061).
tag: R
ruling: R5
newcites: D-061
note: D-061 bold on its headline clause. Position: "`resolve(asm, path)` walks declared field types …; `input_faces`/`output_faces` return declaration-ordered face-name strings; the wiring resolver splits a terminal path's final segment"

added: This section gives the three forms, the two duties resolution enforces, which client each duty binds and why, and the standing of `resolve_terminal`.

old: - `resolve(assembly, path::String) → AbstractComponent`
tag: F

old: is the getfield walk along `/`-segments.
new: resolves an immediate child, a container element's key segment included.
tag: R
ruling: R6
note: F3; the public `resolve` is one level (`src/assembly.jl` 345–365)

old: - `input_faces(c)` / `output_faces(c) → Vector{String}` return the stringified keys of a leaf's `u_types` / `y_types` (the key set is `T`-independent).
tag: F

old: For an assembly they return the entries of `input_wires(c)` / `output_wires(c)`.
tag: F
new: For an assembly they return the face names (the names ports wear on their component's boundary) of `input_wires(c)` / `output_wires(c)`.
note: step 5 (P1-14): bare "entries" becomes "the face names"; D-061's Position, "`input_faces`/`output_faces` return declaration-ordered face-name strings"; face linked and glossed here, the section's first prose use (final_verify_1 finding 2); glossary "the name a port wears on its component's boundary"

old: Declaration order is preserved, which gives deterministic printouts and stable diagnostics.
tag: F

old: - `resolve_terminal(assembly, path) → (component, name)` splits off a terminal path's final segment and resolves the prefix through `resolve`.
tag: F

old: The split is unambiguous because face names may contain dots but never slashes (§8.6).
tag: F
note: face's link and gloss moved to the section's first prose use, the `input_faces` bullet (final_verify_1 finding 2)

old: The walk enforces two duties, and they belong to different clients.
new: Resolution enforces two duties, and they belong to different clients.
tag: R
ruling: R6
note: F3 wording; the bold lead-in goes plain (R3, R5: D-061's annotation only)

old: The first is the one-level rule (§6.1).
new: The first is the one-level rule (§6.1, D-207).
tag: R
ruling: R4
newcites: §6.1 D-207
note: R4 homes the one-level rule at §6.1, which bolds D-207; stated here for wiring with its pointer, D-207 plain

old: A connection endpoint resolves to an immediate child and one of its faces.
tag: F
note: the doubled face link goes (F29)

old: A wiring path reaching further is a build error, `PathResolution`, whatever the declared field types along it.
tag: F

old: The second is the generic-holding rule, which governs the deep paths the read side still writes.
new: The second is the generic-holding rule, which governs the deep paths a service or a reader is given.
tag: R
ruling: B1
note: generic holding linked at its first use, no gloss beside the sentence's own definition two sentences on; "the read side still writes" reworded by B1 to name the clients

old: The walk follows declared field types alongside instances.
new: It is enforced by the service walk, which follows declared field types alongside instances.
tag: R
ruling: B1
note: F3 wording (R6); B1 defines the service walk in the next sentence: conditions walk with `resolve_authored` (`src/conditions.jl`), the read resolver walks every path selector with it (`src/readers.jl` `_rebase`)

added: Every service and the read resolver run the walk over an authored path.
# ruling: B1, as amended after application: the definition moves into its own sentence so "which" no longer reads as the path; "run it" becomes "run the walk" (final_verify_1 finding 1).

old: A segment that traverses past a generically-held field (one whose declared type is non-concrete) is a diagnostic, even though the concrete instance in hand would resolve it.
tag: F
note: the bold word "past" becomes italic, as "to" is in the next sentence

old: Resolving to a generic child is port-level access and legal.
new: Resolving to a generic child is legal, as access at the level of a port (one declared input or output).
tag: F

added: (one declared input or output)

old: An unknown segment errors with the sibling field list in hand.
tag: F

old: Paths are validated at build time, and renames break loudly (D-061, D-130).
new: Paths are validated before anything runs on them, and renames break loudly (D-061).
tag: R
ruling: R6
newcites: D-061
note: F33; D-130 dropped, since it carried this only through the inspection-binding clause R2 overturns (R5, R18; verifier)

old: Which rule applies depends on who is resolving.
new: Which rule applies depends on who is resolving (D-130).
tag: R
ruling: R5
newcites: D-130
note: D-130 bold on its headline clause, for the clause-scoping R2 leaves standing. Position: "`resolve`/`resolve_terminal`'s generic-boundary duty is client-scoped — D-083's line carried into resolution"

old: D-083 separates the reads a build's correctness rests on from the reads that only observe it.
tag: F

old: The same line runs through resolution.
tag: F

old: Three kinds of client share one primitive, and each gets the rule its promises require.
new: Three clients share one resolution, and each gets the rule its promises require.
tag: R
ruling: B9
note: after F3 the clients do not share one function (R17); "kinds of client" goes by B9, *kind* being reserved

old: The two ways of applying one plan (§14.4) use the same arrangement.
new: The two ways of applying one plan (§14.4) use the same arrangement and have the same status.
tag: M
note: M5, merged into the internal-fact paragraph, which said it again

old: | client | who resolves | what the walk enforces | |---|---|---|
new: | client | who resolves | what resolution enforces | |---|---|---|
tag: R
ruling: R6
note: F3 leaves "the walk" without an antecedent, since the rows take three rules (verifier, C-026)

old: | wiring | connection declarations, in the structure step | the one-level rule: an immediate child and one of its faces |
tag: F
note: the bold row name goes plain (R3)

old: | service | condition entries (the path-addressed sparse overlay that sets a build's state), trim `reads`, taps (§14.3, §14.7, §14.10) | strict: no traversal past a generic child, checked at the authoring or mount level |
new: | service | condition entries (the path-addressed sparse overlay that sets a build's state), trim `reads`, taps (the three selector lists declaring what linearization seeds and reports), device read bindings (the values passed at `attach!` that make a device framework-legible), log extraction by `series` (§14.3, §14.7, §14.10, §11.2, D-406, D-407) | strict: no traversal past a generic child, checked at the authoring or mount level |
tag: R
ruling: R2, R25
newcites: §14.3 §14.7 §14.10 §11.2 D-406 D-407
note: device read bindings join the service row with §11.2 and D-406 (R2); the bold row name and the bold cell go plain (R3)

added: (the three selector lists declaring what linearization seeds and reports)
# the spec's own taps gloss (glossary `#g-taps`, frozen spec 11542, 12475), final_verify_1 finding 4.

added: (the values passed at `attach!` that make a device framework-legible)

old: | inspection | device read bindings, GUI panels, snapshot and log inspection (§11.2, §11.7) | the instance walk |
new: | inspection | snapshot (the immutable per-boundary publication) and log inspection | the instance walk |
tag: R
ruling: B10
newcites: none
note: device read bindings move to the service row (R2); "GUI panels" goes, and §11.7, cited for the GUI panels, goes with them (R16); D-310 leaves the row by B10, amending R16, since the row no longer names the GUI (F53 cites it in §13.5)

added: (the immutable per-boundary publication)

old: Each client's treatment has its own warrant.
tag: F

old: Wiring is what the law (§6.1) is stated for, so wiring resolution applies that law verbatim.
tag: F

old: Under one-level routing the generic-holding question never arises there, because an endpoint stops before any field it could traverse past.
tag: F

old: Service paths are checked at the authoring or mount level for two reasons.
tag: F

old: First, the locality law is an authoring-level law, and absolute paths are a compiled derivative (§14.2).
tag: F

old: Second, the mount itself checks a mount prefix, where the problem's authored names resolve through the export chain from the mount point (§14.9).
tag: F

old: So the service check covers the authored path below that prefix.
tag: F

old: Inspection walks instances instead.
tag: F

old: A generic seam is not an error for a client that never claimed substitutability.
new: A generic seam (a narrow, named interface kept deliberately thin) is not an error for a client that never claimed substitutability.
tag: F

added: (a narrow, named interface kept deliberately thin)

old: "What is in this build" is inspection's defining question.
tag: F

added: The stop scan, the one read a run acts on, belongs to §13.5.
# ruling: B4, the pointer back to §13.5's stop scan that R4 asked for, as amended after application.

old: Drift still stays loud.
new: Drift stays loud.
tag: R
ruling: R2
note: moves with the attach sentence to the service warrant (R2); "still" goes, since its contrast with the instance walk no longer holds there

old: An unknown path or name is refused at attach, as a `PathResolution` or a `ReadResolution`, with a did-you-mean (the offending name plus the list-in-hand it should have matched) (§13.3, D-406).
new: A binding's unknown path or name is refused at attach, as a `PathResolution` or a `ReadResolution`, with a did-you-mean (the offending name plus the list-in-hand it should have matched) (D-406).
tag: R
ruling: R2
newcites: D-406
note: R2's wording, moved before "Inspection walks instances instead" into the service warrant; the self-citation §13.3 goes (F24)

old: The scoping is one principle, not three concessions.
tag: F
note: the bold lead-in goes plain (R3); a term of art, verbatim

old: What varies across the three clients is not how far a client is trusted.
tag: F

old: It is what a violation costs, and where the cost lands.
tag: F

old: An inspection client claims no substitutability.
tag: F

old: It addresses one build's instances, and a broken binding fails at attach, at its own site, harming only the observer.
new: It addresses one build's instances, and a broken inspection read fails at its own site, harming only the observer.
tag: R
ruling: R18
note: under R2 a binding is a service client; "at attach" goes with the binding

old: A wiring entry is carried by the declaring type and compiled into every instantiation.
tag: F

old: That is why its endpoints stop at the boundary.
tag: F

old: A wire reaching past one would fail at substitution time, at a different site, for whoever exercised the substitution the field advertised.
tag: F

old: That is the non-local failure class the error discipline exists to eliminate (§8.4).
tag: F

old: The rule is strict exactly where a promise depends on it, and relaxed exactly where none is made (D-083, D-130).
tag: F

old: Strictness forbids nothing outright for a service path.
tag: F

old: Declaring the field's concrete type restores the deep read legally, with the hard-coding visible in the declaration itself.
tag: F

old: For wiring there is no deep route left to restore, because the face chain is the route (§6.1).
tag: F

old: Which of the three rules a client resolves under is internal framework fact, never user-facing API.
new: Which of the three treatments a client resolves under is internal framework fact, never user-facing API (D-130).
tag: C
newcites: D-130
note: D-130 Position: "which of the three a client falls under is internal, never user-facing API"

old: The two ways of applying one plan (§14.4) have the same status.
new: The two ways of applying one plan (§14.4) use the same arrangement and have the same status.
tag: M
note: M5, the merged sentence

old: `resolve_terminal` is first-class because five clients share it across the three rules.
where: units/B/deleted.md
tag: R
ruling: R6
note: F2, cut as false; "first-class" goes with it

old: Wiring resolution is one.
new: Inside the framework only wiring resolution calls `resolve_terminal`.
tag: R
ruling: R6
note: F2's replacement paragraph

old: Condition addressing (§14.3) and tap resolution (§14.10) are service clients.
new: Condition addressing (§14.3) and the readers (§14.4, D-406) split their own paths through the service walk.
tag: R
ruling: B1
newcites: §14.3 §14.4 D-406
note: F2's replacement (R6), amended by B1 so each pointer names its client; §14.10 goes with the false client list

old: Device-binding validation (§11.2) and snapshot inspection are inspection clients.
where: units/B/deleted.md
tag: R
ruling: R6
note: F2, cut as false

old: The result is one splitter and one did-you-mean site.
where: units/B/deleted.md
tag: R
ruling: R6
note: F2, cut as false; the did-you-mean stays in R2's moved sentence

old: ### 13.4 Runtime failures: one catch site, an execution cursor
tag: F

added: A runtime failure of model code is a throw inside a frame (one iteration of the loop) or inside boundary zero.

old: (the initialization boundary: the ordinary macro-sequence with an empty integrate)
new: Boundary zero is the initialization boundary (a published consistency point), and it runs the ordinary boundary macro-sequence with an empty integrate.
tag: F
note: boundary zero's link and gloss move to its new first use, the context paragraph; the colon becomes a relative clause; an appositive, since the sentence already holds the frame gloss

added: (a published consistency point)

added: The framework catches the failure at one site, records where execution stood, and names how to reproduce it.

added: The code inside the `Model`'s `try` is the guarded sequence.

added: Ticks are the instants at which discrete leaves run their stages and update.

added: This section covers, in order, where a failure is caught, the runtime carrier, the interrupt, the disposition, reproduction, boundary zero, the nonfinite check and device-side failures.

old: Where caught.
new: #### Where a failure is caught
tag: R
ruling: R3

old: The frame of the `Model`
new: The `Model`'s `frame!` wraps each whole frame, every boundary it settles included, in a single `try`, and its `init!` wraps boundary zero the same way (D-317).
tag: R
ruling: R6
newcites: D-317
note: F16 wording and R7's "the Model's frame!"; D-317 bullet 8 bold, "The model's `frame!` and `init!` host the catch and build the `StepError` through the one constructor"

old: (the deployment and its executor at one scalar)
new: The `Model` is the deployment and its executor at one scalar.
tag: F
note: the gloss moves into its own sentence, off the bold; glossary "a deployment materialized at one scalar type: the deployment, its executor, …"

old: wraps each execution of the boundary macro-sequence
new: The `Model`'s `frame!` wraps each whole frame, every boundary it settles included, in a single `try`, and its `init!` wraps boundary zero the same way (D-317).
tag: R
ruling: R6
newcites: D-317
note: F16

old: (integrate → project → event iteration → ticks → publication)
new: A boundary's macro-sequence runs integrate → project → event iteration → ticks → publication.
tag: F
note: the inline chain kept as its own sentence, since F16 replaces the phrase it glossed

old: in a single `try`.
new: The `Model`'s `frame!` wraps each whole frame, every boundary it settles included, in a single `try`, and its `init!` wraps boundary zero the same way (D-317).
tag: R
ruling: R6
newcites: D-317

old: It never wraps per stage or per component (D-059).
new: `frame!` never wraps per stage or per component (the unit of modeling, a leaf or an assembly of components) (D-059).
tag: R
ruling: R5
note: D-059 bold, Position "Runtime failures are caught at one site, around the boundary macro-sequence"; "It" spelled `frame!` (R7), since the chain sentence now sits between

added: (the unit of modeling, a leaf or an assembly of components)

old: The loop wraps each frame in a `try` of its own, which decides the failure's disposition (below) and builds no carrier (D-317).
tag: F

old: Framing information does not need to be caught into existence.
new: Where execution stood does not need to be caught into existence.
note: step 5 (P1-21): "framing" keeps its §13.2 sense (R7)
tag: F

old: The executor (the compiled form of the stage execution order) maintains an execution cursor, a plain mutable field of the executor recording where execution stands in the compiled order.
new: The executor (the compiled form of the stage execution order) maintains an execution cursor, a plain mutable field of the executor recording where execution stands in the compiled order (D-059).
tag: C
newcites: D-059
note: the bold term goes plain (R3); D-059 Position "against an execution cursor — schedule index, function kind, boundary phase, one plain store per dispatch"

old: The cursor records three facts.
tag: F

old: The first is the component path, an index into the execution order that `Outputs`
new: The first is the component, by its index in the structure's component list, the index the execution order lists (D-261).
tag: R
ruling: R6
newcites: D-261
note: F13 wording; D-261 replaces superseded D-253 (its `Dataflow` clause; D-261 "the execution order beside the rows as component indices")

old: (the nominal evaluation's product, the port classes and the execution order) carries (D-253).
new: That order is the one `Outputs` (the nominal evaluation's product, the output port names each stage produces and the execution order) carries.
tag: R
ruling: B87
newcites: D-261
note: F13 (R6); `Outputs` and its gloss kept in their own sentence; D-253 replaced by D-261 in the sentence before; B87, amending R19's keep, replaces "the port classes" with the glossary's "the output port names each stage produces", *class* being reserved

old: The second is which function is running: `y_state`, `y_direct`, `x_deriv`, `s_update`, a guard, a handler, or `x_projection`.
new: The second is which function is running, one of `y_state`, `y_direct`, `x_deriv`, `s_update`, a guard (the declared function defining an event's predicate), a handler, or `x_projection`.
tag: F
note: the colon becomes "one of"

added: (the declared function defining an event's predicate)

old: The third is the boundary phase: integration stage k, event round r, a localization evaluation at trial time, or tick.
new: The third is the boundary phase, one of the frame-top drain, integration stage k, the arrival sweep (one pass through the execution order), the θ = 0 validation, a localization trial, projection, event round r, or the ticks.
tag: R
ruling: R6
note: F14; sweep linked and glossed at its first use, the arrival sweep, as §10.4 links it

old: Maintaining the cursor costs one cheap store per dispatch on a single-tasked executor, with no allocation and no exception frames.
new: Maintaining the cursor costs one cheap store per dispatch on a single-tasked executor, with no allocation and no exception handlers.
tag: R
ruling: R7

old: It covers every user-code surface uniformly, including the forgettable ones.
tag: F

old: Those are the RHS evaluations at interior RK stage points, the guard evaluations at ITP/Brent trial points, and the environment closures.
new: Those are the evaluations of the RHS (the continuous derivative function) at interior RK stage points and the guard evaluations at the trial points of ITP or Brent root-finding (§10.4).
tag: R
ruling: R6
newcites: §10.4
note: F15 cuts "the environment closures"; R10 introduces ITP/Brent

added: (the continuous derivative function)

old: `# the cursor: one mutable field of the executor, overwritten per dispatch mutable struct ExecutionCursor … # what it records, per the prose above: component path # (execution-order index), which function, and the boundary phase end`
new: `# the cursor: one mutable field of the executor, overwritten per dispatch mutable struct ExecutionCursor … # what it records, per the prose above: component path # (component-list index), which function, and the boundary phase end`
tag: R
ruling: R6
note: F13's comment edit

old: How handled.
new: #### The runtime carrier
tag: R
ruling: R3

old: The catch site wraps the original exception in `StepError`, the runtime counterpart of the `DiagnosticError` carrier.
new: The catch site wraps the original exception in `StepError`, the runtime counterpart of the `DiagnosticError` carrier (the single exception diagnostics travel in when thrown).
tag: F
note: carrier exception linked and glossed at its first use; glossary "the single exception diagnostics travel in when thrown"

old: A `StepError` carries five things:
new: A `StepError` carries five things.
tag: F

old: the cursor's frame, the boundary time,
new: The time is the clock at the failure, a boundary time in a boundary phase, the stage or trial time inside integration.
tag: R
ruling: R6
note: F12; the field list names "the time", and its sentence follows

old: the frame-entry boundary index, the host of the catch, and the original exception as `cause`.
new: They are the cursor frame (the cursor's copy at the catch), the time, the frame-entry boundary index, the host of the catch, and the original exception as `cause`.
tag: R
ruling: R7
note: "the cursor's frame" becomes "the cursor frame", glossed at first use (R7); the count stays five; the bold term goes plain

old: The frame-entry boundary index is the replay pointer.
new: The frame-entry boundary index is the replay pointer (D-128).
tag: R
ruling: R5
newcites: D-128
note: D-128 bold, its second Position sentence "`StepError`'s replay pointer is respelled the frame-entry boundary index"

old: It names the frame-top boundary at which the failing frame began.
new: The pointer names the frame-top boundary at which the failing frame began.
tag: F

added: Replay is the ordinary loop re-driven from a recorded trace.

added: The trace is the primary record of a session.
# trace glossed at §13.4's first use, in its own sentence since the sentence before defines replay (final_verify_1 finding 3); glossary "the primary record of a session".

old: That frame top is a grid boundary or boundary zero
new: That frame top is a grid boundary or boundary zero, and it is always a legal replay halt (§12.7).
tag: F
newcites: §12.7
note: boundary zero's gloss moved to the context paragraph

old: and it is always a legal replay halt (§12.7).
new: That frame top is a grid boundary or boundary zero, and it is always a legal replay halt (§12.7).
tag: F

old: The host names the catch that took the throw.
tag: F

old: It is `:loop` for a throw inside a frame, and `:boundary_zero` for a throw inside the boundary zero that `init!` runs.
tag: F

old: A `StepError` is rendered with compact frames
new: The cursor frame and the reproduction come first, the cause second, and names are strings.
tag: R
ruling: R6
note: F34, split in two since its colon goes; "the frame" spelled "the cursor frame" (R7)

old: per the doctrine (§13.2).
new: A `StepError` renders under the doctrine of §13.2.
tag: R
ruling: R6
note: F34

old: Conformance failure (§9.5) needs no separate path.
tag: F

old: At the table-write point it throws as every fail-fast site does, a `DiagnosticError` holding the one diagnostic, and it arrives at the same catch site.
new: At the table-write point it throws as every fail-fast site does, a `DiagnosticError` holding the one diagnostic, and it arrives at the same catch site (D-235).
tag: C
newcites: D-235
note: D-235 bullet 2 "generates a throw of `ConformanceFailure`, a `StepError` species at runtime"

old: The species rule.
new: That unwrapping is the species rule.
tag: R
ruling: R3
note: the bold label becomes a plain sentence after the rule it names

old: The catch site unwraps a single-diagnostic `DiagnosticError` thrown inside the guarded sequence, and the `StepError`'s `cause` is that diagnostic.
new: The catch site unwraps a single-diagnostic `DiagnosticError` thrown inside the guarded sequence, and the `StepError`'s `cause` is that diagnostic (D-221).
tag: R
ruling: R5
newcites: D-221
note: D-221 bold, Position "The catch site unwraps it, and the `StepError` it constructs carries that diagnostic as `cause`"

old: A species of `StepError` is one whose `cause` is a diagnostic.
tag: F

old: The conformance failure's species carries the field-diff payload.
new: The conformance failure's species carries the field-diff payload (the structured data a diagnostic carries beside its kind).
tag: F
note: payload glossed; glossary "the structured data a diagnostic carries beside its kind"

old: The rule keeps the catch site the only `StepError` constructor.
tag: F

old: A `StepError` arriving at the catch site is therefore an invariant failure, while a runtime check stays a plain thrower of its kind (D-221).
tag: F

old: A collected carrier has no single kind and rides as `cause` unchanged.
tag: F

old: No runtime check throws one.
tag: F

old: The cause's type is the carrier's parameter.
new: The cause's type is the carrier's parameter (D-225).
tag: R
ruling: R5
newcites: D-225
note: D-225 bold, Position "`StepError{C}` carries the type of its `cause`"

old: `StepError{C}` takes the type of its `cause`, bounded to a diagnostic or an exception.
tag: F

old: A species is therefore `StepError{Kind}`, and a raw throw is `StepError{ArgumentError}` and the like.
tag: F

old: `isa StepError` matches both (D-225).
tag: F

old: A test asserts a species as `@test_throws StepError{ConformanceFailure}`, the runtime spelling of the build carrier's idiom (§13.2).
tag: F

old: A collected carrier riding as `cause` is an exception and falls under that arm.
tag: F

old: A bare value thrown deliberately by model code is neither, and the constructor refuses it unframed.
new: A bare value thrown deliberately by model code is neither, and the constructor refuses it, so it propagates from the catch unwrapped.
note: step 5 (P1-21): "unframed" is D-225's word for leaving the catch with no `StepError`; *frame* keeps R7's senses; "leaves the catch unwrapped" becomes "propagates from the catch unwrapped" (final_verify_1 finding 5)
tag: F

old: The framework does not handle that throw (D-225).
tag: F

added: The cursor frame and the pointer are then lost, and the lifecycle does not move as it does when the catch builds a `StepError`.

old: `# the runtime carrier: its parameter the cause's type — a diagnostic's kind # for a species, the exception model code threw otherwise struct StepError{C <: Union{Diagnostic, Exception}} <: Exception cursor # the cursor's frame at the catch t::Float64 # the boundary time boundary::Int # the frame-entry boundary index: the replay pointer host::Symbol # :boundary_zero under init!, :loop inside a frame cause::C end`
new: `# the runtime carrier: its parameter the cause's type — a diagnostic's kind # for a species, the exception model code threw otherwise struct StepError{C <: Union{Diagnostic, Exception}} <: Exception cursor # the cursor frame: the cursor's copy at the catch t::Float64 # the clock at the failure boundary::Int # the frame-entry boundary index: the replay pointer host::Symbol # :boundary_zero under init!, :loop inside a frame cause::C end`
tag: R
ruling: B11
note: F12's comment edit (R6); B11's comment edit puts R7's term "the cursor frame" on the `cursor` field

old: The one exception never wrapped.
new: An `InterruptException` is the one exception the catch site never wraps (D-317).
tag: R
ruling: R3
newcites: D-317
note: M6 moves the interrupt here, after the carrier sketch; the bold label becomes the paragraph's topic sentence; D-317 bullet 8 "An `InterruptException` is never wrapped", plain since the bullet's bold is at the frame! sentence

added: #### The interrupt

old: An `InterruptException` is not model code failing.
new: It is not model code failing.
tag: F
note: M6

old: It is the operator's stop command (§12.4).
tag: F

old: So the catch site discriminates it and routes it to the stop path.
new: So the catch site discriminates it and routes it to the stop path (D-132).
tag: C
newcites: D-132
note: D-132 Rationale only; see rulings.md

old: The run takes the ordinary graceful tail and ends `stopped`, never `errored` under a `StepError`.
tag: F

old: With the boundary masking in force (§12.4) a single interrupt never reaches the branch.
new: With the boundary masking in force (§12.4) a single interrupt never reaches the interrupt branch.
tag: F
note: the catch-site clause M7 keeps; inbound §12.4 "never sees a single interrupt" relies on it

old: It is deferred to a frame-top or wait unmask point, and never raises inside the guarded sequence.
new: It is deferred to a frame-top, wait or pause-block unmask point (§12.4, D-294), and never raises inside the guarded sequence.
tag: R
ruling: R6
newcites: §12.4 D-294
note: F19

old: Julia's forced throw after repeated interrupts does reach it,
new: Julia's forced throw after repeated interrupts does reach it, with the disposition §12.4 gives it (D-398).
tag: R
ruling: R4
newcites: §12.4 D-398
note: M7; D-398 bullet 2 replaces D-268, whose annotation alone stated it (survey part E)

old: and the branch's disposition is `stopped` with the frame abandoned (§12.4, D-268).
new: The arm abandons the frame unpublished and the run ends `stopped`
where: docs/design/spec.md
tag: M
note: M7 under R4, the forced throw's disposition homed at §12.4, which bolds it with D-268 and D-398; a pointer to §12.4 stays

old: The branch is kept for that case and defensively, because the cost of being wrong about the masking is a terminally errored session in place of a clean stop.
tag: F
note: the catch-site clause M7 keeps; inbound §12.4 "the one way the branch §13.4 keeps is reached" relies on it

old: Disposition.
new: #### The disposition
tag: R
ruling: R3
note: M6 moves the disposition here, after the interrupt

old: The `Simulation` ends in a terminal status, `stopped` or `errored`, with the exception retrievable.
new: The `Simulation` ends in a terminal status, `stopped` or `errored`, with the exception retrievable (D-059).
tag: C
newcites: D-059
note: D-059 bullet 4 "Status goes terminal `stopped`/`errored`, and synchronous runs rethrow after the tail", bold at §12.6, plain here

old: A synchronous unattended run (a run with empty staging and no snapshot readers) rethrows after the shutdown tail completes, so CI fails honestly.
tag: F

old: An interactive session logs the rendered error
new: An interactive session logs the rendered error.
tag: F

old: and surfaces the status through the control plane and GUI.
new: An interactive session logs the rendered error.
tag: R
ruling: R6
note: F18 cuts the clause; both claims false (D-310, D-317 bullet 7)

old: `run!` and `replay!` discriminate the two by the roster (D-268).
new: `run!` and `replay!` discriminate the two by the roster (the list of attached device entries) (D-268).
tag: R
ruling: R5
note: D-268 bullet 5 bold, "`run!` discriminates §13.4's two dispositions by the roster"; `replay!` by its 2026-09-26 annotation

added: (the list of attached device entries)

old: With no device rostered the run is unattended and rethrows.
new: With no device (any attached participant in the periphery) rostered the run is unattended and rethrows.
tag: F
note: device linked at its first use in the section, which the move made earlier; glossary "any attached participant in the periphery"

old: With one or more it logs the rendered error through the logging backend and returns, the lifecycle reading `errored` and `termination(sim)` retaining the cause.
tag: F

old: `step!` is deviceless by construction (§12.6) and always rethrows.
new: `step!` is deviceless by construction (§12.6, D-389) and always rethrows.
tag: C
newcites: §12.6 D-389
note: D-389 bullet 2 "A stepping session is deviceless by construction", bold at §12.6

old: Reproducibility holds by construction.
tag: F

added: #### Reproduction

old: Staged inputs are drained and recorded to the trace at the frame top, before the boundary executes.
tag: F
note: trace's link and gloss moved to §13.4's first use, at the replay pointer (final_verify_1 finding 3)

old: So the failing boundary's inputs are already in the trace when it fails.
tag: F

old: The error names the frame-entry boundary `k` to replay to.
tag: F

old: `replay!(sim2, trc; to_boundary = k)` halts exactly at that frame top.
new: `replay!(sim2, trc; to_boundary = k)` halts exactly at that frame top (D-128).
tag: C
newcites: D-128
note: D-128 Position "`replay!(to_boundary = k)` halts precisely there"

old: It halts in `:replay`, the input mode that keeps the recording attached, so the failing frame's record is still ahead of the simulation (§12.7).
new: It halts in `:replay`, the input mode that keeps the recording attached, so the failing frame's record is still ahead of the simulation (§12.7, D-218).
tag: C
newcites: §12.7 D-218
note: input mode linked at its first use, glossed inline; D-218 bullet 1 "`replay!` attaches the recording and enters `:replay`. `step!` and `run!` consume it frame by frame from there"

old: `step!` then applies that record and re-executes the failing frame under instrumentation, localized boundaries included.
tag: F

old: `replay!(sim2, trc; to_boundary = k) # halt at the frame top; still :replay step!(sim2; frames = 1) # re-execute the failing frame, instrumented`
tag: F

added: #### Boundary zero

old: Boundary zero is caught too, under the service's disposition.
new: Boundary zero is caught too, under the service's disposition (D-223).
tag: R
ruling: R5
newcites: D-223
note: D-223 bold; the paragraph split in three repeats D-223 at the first and the last

old: Boundary zero runs inside `init!`, a stopped-sim service, not inside the loop.
tag: F

old: The simulation's `init!` calls `init!` on its `Model`, which runs boundary zero.
tag: F

old: Its macro-sequence executes the same user-code surfaces the frame's does, with the cursor maintained through them, so the `Model`'s `init!` hosts the same catch (D-317).
tag: F

old: A throw inside boundary zero arrives as a `StepError` from the one constructor.
tag: F

old: Its frame comes from the cursor, its time is `t₀`, and the species rule applies.
new: Its cursor frame comes from the cursor, its time is `t₀`, its pointer is `0`, and the species rule applies.
tag: R
ruling: R7

old: Any throw inside boundary zero writes the `Model`'s status back to `:built`, which returns the simulation's lifecycle to `built` (§12.6).
tag: F

old: An `InterruptException` inside boundary zero is not model code failing, and it has no stop path to take in a service.
tag: F
note: now after the interrupt subsection that defines the stop path (M6)

old: The host therefore lets it propagate raw, unwrapped.
tag: F

old: The pointer is `0`.
new: its pointer is `0`
note: step 5 (P1-26): moved into the sentence on the boundary-zero `StepError`'s fields, which it describes
tag: F

old: A throw inside boundary zero leaves no trace and no checkpoint (the `Model`'s state at a frame top as one value).
tag: F

old: The run `init!` opened stays behind, empty and with no trace header, and the run before it is gone.
tag: F

old: Nothing can use it, since `trace(sim)` and the advances refuse a `built` simulation.
tag: F

old: `init!` takes the trace header only after boundary zero publishes (§11.5).
tag: F

old: The reproduction of a boundary-zero failure is `init!` under the same condition (D-274).
new: The reproduction of a boundary-zero failure is `init!` under the same condition (the path-addressed sparse overlay that sets a build's state) (D-274).
tag: R
ruling: R5
note: D-274 bullet 7 bold, "Its reproduction is `init!` under the same condition"; no other chapter of the frozen spec bolds that bullet (§11.5 and §12.7 bold bullet 4)

added: (the path-addressed sparse overlay that sets a build's state)

old: Boundary zero is frame one's entry boundary too, so a frame-one failure carries the same pointer.
tag: F

old: The carrier's `host` tells the two apart, and the rendered recipe reads it.
tag: F

old: A frame-one failure has a trace, and the halt-then-`step!` recipe above holds for it at pointer `0`.
tag: F

old: The halt restores the header and stops there, and `step!` re-executes frame one from the record.
tag: F

old: Boundary zero's disposition differs from the loop's as well.
tag: F
note: the loop's disposition now precedes it (M6)

old: Nothing was published and no advance was under way, so there is no tail to take and no snapshot to promote.
tag: F

old: The simulation returns to `built`.
tag: F

old: `run!` and `step!` refuse it and name `init!` (§12.6), while `init!`, `restore!` and `replay!` remain legal.
tag: F

old: The remedy for a condition that fails at `t₀` is a corrected condition, and `init!` re-establishes every store before it applies one (§14.1).
new: The remedy for a condition that fails at `t₀` is a corrected condition, and `init!` re-establishes every store (the framework-owned home of one of a component's state letters) before it applies one (§14.1).
tag: F
note: store linked and glossed at its first use; glossary "the framework-owned home of one of a component's state letters"

old: No termination record is written.
new: No termination record (the stopped-sim value naming how the run ended) is written.
tag: F

added: (the stopped-sim value naming how the run ended)

old: The stores may hold the half-transitioned `t₀` state until the next `init!` resets them.
new: The stores may hold the half-transitioned `t₀` state until the next `init!`, `restore!` or `replay!` resets them.
tag: R
ruling: R6
note: F17

old: They are retained for inspection, as an errored simulation's are (§13.6).
tag: F

old: `trim!`'s commit is an `init!` (§14.8) and inherits the rule (D-223).
tag: F

old: The nonfinite check.
new: #### The nonfinite check
tag: R
ruling: R3

old: Divergence is not termination.
tag: F

old: Dynamics that blow up (ground penetration, an unstable gain) produce NaNs that defeat guards.
tag: F

old: NaN comparisons are false, so no declared condition will catch them.
new: NaN comparisons are false, so no declared guard will catch them.
tag: R
ruling: R19
note: condition is §14's word

old: A loop-level `isfinite` sweep over `x` at boundaries fails fast as a `StepError` species, naming the offending component's state block and the boundary.
new: An `isfinite` pass over the flat state buffer (the contiguous vector backing all continuous state), run by the model after every return from the integrator backend, fails fast as `NonfiniteState`, a `StepError` species naming the component, the state leaf and the frame-entry boundary.
tag: R
ruling: R6
note: F20 wording, F32's "state leaf", `NonfiniteState` named here; the wrong sweep link goes; buffer linked at this new first use

added: (the contiguous vector backing all continuous state)

old: It catches diverging models generally, not just post-terminal ones.
tag: F

old: Placement is the whole value.
tag: F
new: and that placement is the whole of its value.
note: the italic label became a plain topic sentence; step 5 (P1-28) joins it to the bold, which now heads the paragraph

old: The sweep is the boundary's first act.
new: The pass is the boundary's first act (D-157),
tag: R
ruling: R5
newcites: D-157
note: D-157's first ruling bold, "The nonfinite-`x` check is the boundary's first act"; "sweep" becomes "pass" (F20)

old: It runs immediately after integrate returns, before `x_projection` and before the boundary sweep.
new: The pass runs immediately after integrate returns, before `x_projection` and before the boundary sweep.
tag: F

old: Run there, `NonfiniteState` names the component whose own block diverged.
tag: F

old: Run later, the NaN has already propagated.
tag: F

old: It reaches an innocent downstream component through the ordinary signal path and surfaces as that component's lookup-table `DomainError`, or as an `InexactError` in its conversion.
tag: F

old: That is the error-locality inversion (§8.4), designed out of the build tier and quietly reintroduced at runtime.
new: That is the inversion of error locality (the property that a mistake fails at the site of the mistake) (§8.4), designed out of the build and quietly reintroduced at runtime.
tag: R
ruling: R6
note: F21; error locality linked at its first use

added: (the property that a mistake fails at the site of the mistake)

old: One `isfinite` pass over a flat buffer is cheap enough that placement, not cost, decides.
tag: F

old: Scope: `ẋ` does not participate (D-157).
new: `ẋ` does not participate in the check (D-157).
tag: R
ruling: R5
note: D-157's second ruling bold, "`ẋ` does not participate, with the reason stated"; the italic "Scope" label becomes "in the check"

old: A nonfinite derivative contaminates its own state block's step result within that very step.
tag: F

old: The `x` check at the next boundary is therefore the same detection with identical component attribution.
tag: F

old: And `ẋ` buffers are integrator scratch.
tag: F

old: They are written per stage, meaningful only inside a step, and not boundary-consistent in the sense the check is stated over.
tag: F

added: #### Device-side failures

old: Domain separation.
new: Under domain separation, device-side user code fails in the device's own domain, because loop bodies and mappings run on the device task (§11.4, §11.6).
tag: R
ruling: R3
newcites: §11.4 §11.6
note: the bold label's term of art kept in the topic sentence

old: Device-side user code fails in the device's own domain, because loop bodies and mappings run on the device task (§11.4, §11.6).
new: device-side user code fails in the device's own domain, because loop bodies and mappings run on the device task (§11.4, §11.6).
tag: F

old: It fails in two classes.
new: It fails in two classes (D-105).
tag: C
newcites: D-105
note: D-105 Position "two failure classes, two fates", bold at §11.6, plain here (R5)

old: A genuine bug takes the per-device crash path
tag: F

old: (liveness heartbeat, `DeviceCrash`) while the sim keeps running.
new: The wrapper reports `DeviceCrash`, and the run goes on without the device unless its attachment set `should_abort` (the per-attachment failure policy, an `attach!` keyword) (§11.6).
tag: R
ruling: R6
newcites: §11.6
note: F10 wording, its colon a sentence break; should_abort linked and glossed

old: liveness heartbeat
new: The liveness heartbeat is how a hang shows instead (§12.2).
tag: R
ruling: R6
newcites: §12.2
note: F10, the heartbeat kept as its own clause, off the crash path

old: An unmappable datum is not a failure at all.
tag: F

old: The loop body tolerates and reports it (`MalformedDatum`, §11.6).
new: The loop body tolerates and reports it as `MalformedDatum` (§11.6).
tag: F
note: the kind leaves the citation's parentheses

old: The two failure domains never mix.
new: Device code shares no mutable state with the model (D-022), so the two failure domains never mix.
tag: R
ruling: R6
newcites: D-022
note: F26 wording, D-022 plain (R5)

old: That is exactly what the no-shared-mutable-model decision bought.
new: Device code shares no mutable state with the model (D-022), so the two failure domains never mix.
tag: R
ruling: R6
newcites: D-022
note: F26 and R10 name the decision; D-022 Position "no shared mutable model"

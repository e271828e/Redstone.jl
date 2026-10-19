# Unit A claims: chapter 13 heading and opening, §13.1, §13.2.

old: ## 13. Error discipline
tag: X

old: §8.4 fixed what must be caught and where.
new: taking as given what must be caught and where (§8.4)
tag: R
ruling: R1
note: context sentence in chapter 12's form; §8.4's role as the old opening states it.

old: §9 fixed when each fact is checked.
new: and when each fact is checked (§9).
tag: R
ruling: R1

old: This section fixes how failures are reported.
new: This chapter fixes how a failure is reported once it happens, and what the framework offers around it,
tag: R
ruling: R1
note: "This section" becomes "This chapter"; "once it happens" is the Part IV roadmap's (old 9902–9904); "what the framework offers around it" is R1's dictated clause.

old: It covers the reporting policy, the diagnostic representation, the runtime failure story, the seam between "the model reached a terminal state" and "the run should end", the tooling and component library that follow, and the diagnosis of a rejected cycle.
new: §13.1 covers the reporting policy; §13.2 the diagnostic representation; §13.3 the build primitives and how path resolution is scoped by client; §13.4 how a runtime failure is caught, carried and reproduced; §13.5 the distinction between "the model reached a terminal state" and "the run should end"; §13.6 abnormal shutdown, one tail with two entries; §13.7 the tooling and component library that follow; and §13.8 the diagnosis of a rejected cycle.
tag: R
ruling: R1
newcites: §13.1 §13.2 §13.3 §13.4 §13.5 §13.6 §13.7 §13.8
note: roadmap sentence naming §13.1–§13.8 in order. §13.6 takes its subject from its title ("Abnormal shutdown: one tail, two entries"). Step 5 (P1-1): §13.3's subject is its main one, client-scoped resolution, and §13.4's "the runtime failure story" is named by its parts. "the seam between" becomes "the distinction between": seam is reserved for a narrow, named interface.

old: Two lessons FlightCore paid for ground it.
new: Two lessons FlightCore paid for ground this chapter.
tag: F
note: "it" would now read as §13.8, the roadmap's last item.

old: The first is the compact-backtrace discipline, needed because parameterized model types make rendered output unreadable.
tag: F

old: The second is the `SimulationTermination` machinery, which §13.5 replaces.
tag: F

old: ### 13.1 Reporting policy: collect the checks, fail the evaluations fast
tag: X

old: The build's failure sites split into two populations.
tag: F

old: That split settles the choice between fail-fast and compiler-style reporting.
tag: F

old: Each population takes the policy that fits it.
tag: F

added: This section covers, in order, the two populations and their policies, the step barrier, the dependency rule that decides which passes run past a failure, and the absence of cascade suppression.

old: Declarative checks over collected structure collect.
new: Declarative checks over collected structure collect,
tag: R
ruling: R5
newcites: D-057
note: the two bold list lead-ins join in one bold headline clause for D-057's first ruling, the two populations (R5 counts two D-057 rulings here, the populations and no cascade suppression). D-057 Position, "declarative checking passes batch …; the first user-code exception … aborts the phase".

old: These are the checks for unconnected inputs, two producers, wire typos and type mismatches, face-name uniqueness, `y_types`/state-field consistency and `sample_times` validation.
new: The collecting checks are those for unconnected inputs, two producers, wire typos and type mismatches, face-name uniqueness, `y_types`/state-field consistency and `sample_times` validation.
tag: R
ruling: R3
note: the item's topic sentence now that its lead-in has moved into the bold above.

old: Each is a pass over a list.
tag: F

old: The whole-tree obligation check literally computes the set of inputs whose obligation chain never terminates.
tag: F

old: Reporting every violation is the natural output of such a pass, and truncating to the first would be extra work.
tag: F

old: These failures also cluster in practice.
tag: F

old: A freshly written assembly has five unwired inputs, and a renamed port breaks three wires.
new: A freshly written assembly (pure composition, with no dynamics of its own) has five unwired inputs, and a renamed port breaks three wires.
tag: F

added: (pure composition, with no dynamics of its own)
# the glossary's assembly entry: "pure composition … It has no dynamics of its own."

old: Each of these passes returns its full violation list.
tag: F

old: User-code evaluation fails fast.
new: and user-code evaluation fails fast (D-057).
tag: R
ruling: R5
newcites: D-057
note: the second lead-in, joined to the first in one bold.

old: User code runs in three places.
new: User code runs in the build's first three steps (§9.1).
tag: R
ruling: R6
newcites: §9.1
note: F5.

old: The first is the interface-connection bodies in the structure step (the build's first step, declaration reading only).
new: The structure step reads the declaration bodies, interface-connection bodies among them.
tag: R
ruling: R6
note: F5. "the build's first step, declaration reading only" is carried by "the build's first three steps" and "reads the declaration bodies"; §9's table says "declaration bodies only".

old: The other two are the stage-1 probes and the probe chain of the nominal evaluation (§9.1).
new: The nominal evaluation runs every user function once, through the stage-1 probes (the build's single evaluations of a user function) and the probe chain.
tag: R
ruling: R6
newcites: §9.1
note: F5; §9.1 sits two sentences up in the same item.

added: (the build's single evaluations of a user function)
# the glossary's probe entry: "the build's single evaluation of a user function with real values".

added: The activation at the scalar type `T` runs the continuous tier's functions.
# F5's dictated wording (R6), from §9's step table.

old: When user code throws, there is no meaningful rest of the collection to report.
tag: F

old: A failed `input_wires` leaves the parent's face derivation undefined.
tag: F

old: A failed stage-2 probe starves every downstream probe of its wired inputs, because probe values flow topologically (§9.3).
new: A failed stage-2 probe starves every downstream probe of its wired inputs, because probe values (the fabricated values a build-time probe runs on) flow topologically (§9.3).
tag: F

added: (the fabricated values a build-time probe runs on)
# the glossary's probe value entry, verbatim.

old: The first user-code exception aborts the phase (D-057).
tag: F

old: The build's steps are barriers.
new: The build's steps are barriers (D-259).
tag: C
newcites: D-259
note: D-259 bullet 2, "Each step is a barrier, as each stratum was (§13.1)". Bold at §9; plain here.

old: A step that produced any error-severity diagnostic, of either kind, throws before the next step begins.
new: A step that produced any error-severity diagnostic, from either population, throws before the next step begins.
tag: R
ruling: R6
note: F22.

old: Probing against unresolved wiring would be meaningless.
tag: F

old: Rule. Collection reaches the step barrier, under a dependency rule.
new: Collection reaches the step barrier, under a dependency rule (D-229).
tag: R
ruling: R5
newcites: D-229
note: the Rule. label goes (R3); the bold headline for D-229's dependency rule, its Position's first sentence ("Collected" reaches the stratum barrier).

old: A declarative pass runs when the results it reads are clean.
tag: F

old: It records every violation it finds and returns a total result.
tag: F

old: Every pass that ran merges into the barrier's one throw (D-229).
new: Every pass that ran merges into the barrier's one throw.
tag: C
newcites: D-229
note: the citation moves to the bold sentence of the same paragraph.

old: Whether a pass can run past a failure follows from what it reads.
tag: F

old: The structure step's walk yields two results, the component list and the wiring.
tag: F

old: A wire that fails to resolve is recorded and claims nothing, so the obligation check reports its input as unfed.
tag: F

old: Tier and event checking read only the component list, so they run and merge.
tag: F

old: A structural failure leaves the subtree behind it unknown.
tag: F

old: An unreadable or mixed class or a malformed container is such a failure.
new: An unreadable or mixed class (a component's primitive-vs-assembly status) or a malformed container is such a failure.
tag: F

added: (a component's primitive-vs-assembly status)

old: No pass can read past it, so it throws alone.
tag: F

old: In the two evaluating steps the probe chain consumes each check's subject as it goes.
tag: F

old: A check that reads a failed probe does not run, so the chain's fail-fast follows from the same rule.
tag: F

old: Outside the build the unit is the call.
tag: F

old: Deployment validation (§9.2) runs every check whose premise holds and throws once.
tag: F

old: The only partial results ever carried past a failure are violation lists and a claim table with the failed wires absent.
tag: F

old: None of the three steps therefore needs machinery for carrying partial internal results across a failure.
tag: F

old: That machinery was the cost that kept this decision open, and it never materializes.
tag: F

old: There is no cascade suppression within a step.
new: There is no cascade suppression within a step (D-057).
tag: R
ruling: R5
newcites: D-057
note: bold sentence now cited in its own sentence; D-057 Position, "no cascade suppression within a stratum".

old: This is a deliberate simplification (D-057).
new: This is a deliberate simplification.
tag: C
newcites: D-057
note: the citation moves one sentence back, to the bold.

old: A wire typo'd as `:throtle` produces two errors.
tag: F

old: One is a did-you-mean error (the offending name plus the list-in-hand it should have matched).
tag: F

old: The other is an unconnected-input error for the intended `throttle`.
tag: F

old: Both are reported.
new: Both are reported in the one throw,
tag: R
ruling: R6
note: F4.

old: They render adjacently, because diagnostics sort by path, and the pairing explains itself.
new: and the did-you-mean names the input the other error says is unfed, so the pairing explains itself.
tag: R
ruling: R6
note: F4; the adjacency-by-path claim is cut.

old: ### 13.2 Diagnostics: structured values, one carrier exception
tag: X

old: Both reporting policies move the same thing.
tag: F

old: What a collecting pass returns and what a fail-fast site produces is in either case a diagnostic.
tag: F

old: The shape of that value decides what an acceptance test can assert and what a user reads.
tag: F

added: #### The diagnostic and its carrier
# R3, the first of §13.2's two labels.

old: Rule. A diagnostic is a plain value from a small closed set of kinds (D-058).
new: A diagnostic is a plain value from a small closed set of kinds (D-058).
tag: R
ruling: R5
note: the Rule. label goes (R3); bold headline clause for D-058's first ruling.

old: Appendix C enumerates that set normatively.
tag: R
ruling: R3
note: the bold on the link goes.

old: For each kind it records the kind name, the payload fields, the owning section, the severity, where the kind is raised and under which policy.
new: For each kind it records the kind name, the payload fields (the structured data a diagnostic carries beside its kind), the owning section, the severity, where the kind is raised and under which policy (D-214).
tag: C
newcites: D-214
note: D-214 Position splits the column into severity, raised and policy.

added: (the structured data a diagnostic carries beside its kind)

old: That index is the artifact the §8.4 acceptance tests and the error-message work are written against.
new: That index is the reference the §8.4 walkthroughs, run as acceptance tests, and the error-message work are written against.
tag: M
note: M1. "the artifact" becomes "the reference": artifact is a glossary term (#g-artifact) this section defines later, and an index is not one.

old: The §8.4 walkthroughs, run as acceptance tests, target diagnostics.
new: the §8.4 walkthroughs, run as acceptance tests,
tag: M
note: M1, merged into the index sentence; what they are written against is the index of diagnostic kinds.

old: Tests match on kind plus payload fields, never on message text.
new: Tests match on kind plus payload fields, never on message text,
tag: M
newcites: D-058
note: M1.

old: Messages are therefore pure presentation.
new: so messages are pure presentation (D-058).
tag: M
newcites: D-058
note: M1; D-058 bullet 4, "Tests match kind + payload, never message text".

old: Each kind carries its own structured payload.
tag: F

old: The payload holds endpoint paths, face names, expected and observed types, and the list-in-hand a did-you-mean needs (the offending name plus the list it should have matched).
new: The payload holds endpoint paths, face names, expected and observed types, and the list-in-hand a did-you-mean needs. A did-you-mean is the offending name plus the list-in-hand it should have matched.
note: step 5 (P1-5): the gloss becomes its own sentence in the glossary's words, so it follows did-you-mean.
tag: F

old: A kind is a Julia type.
tag: F

old: Severity is a property of the kind, not of the occurrence.
new: Severity is a property of the kind, not of the occurrence (D-214).
tag: R
ruling: R5
newcites: D-214
note: bold headline clause for D-214, "A kind's severity, a property of the kind".

old: It is `error` or `warning`, and it says whether an occurrence ever throws.
tag: F

old: It is read as `severity(d)` and never stored per occurrence.
tag: F

old: The severity field of Appendix C is derived from it.
tag: F

old: Where an occurrence surfaces (build, service or runtime) and how it is reported (collected, fail-fast, logged or rate-limited) are the raised and policy fields of Appendix C.
tag: F

old: Those two fields describe the occurrence, not the kind.
tag: F

old: `BundleFieldError`, for example, is raised at the probe and as a `StepError` species thereafter.
new: `BundleFieldError`, for example, is raised at the probe and, at runtime, as a species of the runtime carrier `StepError` (§13.4).
newcites: §13.4
note: step 5 (P1-6): "thereafter" is the runtime, and `StepError` is introduced as the runtime carrier with its home.
tag: F

added: A species is a `StepError` whose `cause` is a diagnostic.
# the glossary's species entry: "a `StepError` whose `cause` is a diagnostic".

old: Checking passes return diagnostics.
tag: F

old: The step barrier (each of the build's three steps throws before the next begins) throws a single `DiagnosticError` wrapping the collection.
tag: F

old: A fail-fast site throws the same carrier holding one diagnostic.
new: A fail-fast site throws the same carrier exception (the single exception diagnostics travel in when thrown) holding one diagnostic.
tag: F
note: "carrier exception" takes the section's #g-carrier-exception link, unlinked before (survey part F).

added: (the single exception diagnostics travel in when thrown)

old: The carrier's type parameter spells the policy.
new: The carrier's type parameter spells the policy (D-222).
tag: R
ruling: R5
newcites: D-222
note: D-222 Position, "the diagnostic's kind for a fail-fast throw, `Vector{Diagnostic}` for a collected one".

old: It is the diagnostic's kind for a fail-fast throw and `Vector{Diagnostic}` for a collected one.
tag: F

old: A test therefore asserts policy and kind at once with `@test_throws DiagnosticError{Kind}` (D-222).
new: A test therefore asserts policy and kind at once with `@test_throws DiagnosticError{Kind}`.
tag: C
newcites: D-222
note: the citation moves two sentences back, to the bold.

old: The runtime carrier follows the same rule.
new: The runtime carrier `StepError{C}` takes a parameter of its own,
tag: R
ruling: R4
note: M4. With the species clause gone, "follows the same rule" would read as "the parameter spells the policy"; StepError's parameter is the cause's type (D-225). Verifier's fix.

old: `StepError{C}` carries the type of its `cause`,
new: the type of its `cause` (§13.4, D-225).
tag: R
ruling: R4
newcites: §13.4 D-225
note: M4, the one clause pointing to §13.4.

old: so a species is `StepError{Kind}` (§13.4, D-225).
new: A species is therefore `StepError{Kind}`
where: units/B/old.md
tag: M
note: M4; §13.4 is the home (H1).

old: `showerror` renders a collection compiler-style, grouped by kind and sorted by path.
tag: F

old: It renders a single diagnostic as its own line.
tag: F

old: # a diagnostic value: its kind is its identity, its payload is plain data abstract type Diagnostic end struct WireTypeMismatch <: Diagnostic # one kind of the closed Appendix C set … # payload fields per Appendix C: paths and # names as Strings, port types as types end
tag: F
note: the sketch's first half, verbatim.

old: # the carrier: one exception, its parameter the policy — a kind for a # fail-fast throw, the collection type for a barrier's batch struct DiagnosticError{P <: Union{Diagnostic, Vector{Diagnostic}}} <: Exception carried::P end
new: # the carrier: one exception, its parameter the policy — a kind for a # fail-fast throw, the collection type for a barrier's throw struct DiagnosticError{P <: Union{Diagnostic, Vector{Diagnostic}}} <: Exception carried::P warnings::Vector{Diagnostic} # the build's warnings so far, rendered with the throw end
tag: R
ruling: R6
note: F6 adds the warnings field with its comment; F7 makes "a barrier's batch" "a barrier's throw".

old: Two rendering rules are doctrine, not style.
new: Two rendering rules are doctrine, not style (D-058).
tag: M
newcites: D-058
note: M2, up to directly after the carrier block. D-058 Position, "paths and names as strings", and bullet 3, "The didactic style is policy".

old: Strings, never instances.
new: The first rule is strings, never instances.
tag: M
note: M2; the bold lead-in becomes a plain topic sentence (R3). "strings, never instances" verbatim.

old: Diagnostics carry paths and names as strings, never component instances and never component types.
tag: M
note: M2.

old: This is the `compact_backtrace` lesson.
new: This is the lesson of FlightCore's `compact_backtrace`.
tag: R
ruling: R10
note: M2.

old: Expected and observed port types are the one payload exception, and they are small.
tag: M
note: M2.

old: Examples are a `Float64` against a `Bool`, and a NamedTuple field diff.
tag: M
note: M2.

old: The didactic style is policy.
new: The second rule is that the didactic style is policy.
tag: M
note: M2; the bold lead-in becomes a plain topic sentence (R3). D-058 bullet 3 is a ruling of its own, but R5 bolds only D-058's closed set here.

old: Every diagnostic states the fix or the lists-in-hand, not just the violation.
tag: M
note: M2.

old: Examples are "return `zero(x.ω)`, not `0`" and "no input `throtle`; did you mean `throttle`?", or the child's face list shown alongside the unknown `except` entry.
new: Examples are "return `zero(x.ω)`, not `0`" and "no input `throtle`; did you mean `throttle`?", or the child's face list shown alongside the unknown name given to `except`.
tag: M
note: M2; bare "entry" is reserved.

old: A user-code exception is wrapped in a framing diagnostic, `UserCodeFraming`, with the original exception as `cause`.
tag: F

old: The frame carries the component path, the function that threw, and the probe context, which is the bundle's field names (the bundle is the NamedTuple of zero-copy views a component function receives) and the synthesized inputs as a spelling, never as values (D-248).
new: The framing carries the component path, the function that threw, and the probe context, which is the bundle's field names (the bundle is the NamedTuple of zero-copy views a component function receives) and the synthesized inputs as a spelling, never as values (D-248).
tag: R
ruling: R7

old: The didactic frame therefore renders first and the raw throw second.
new: The didactic framing therefore renders first and the raw throw second.
tag: R
ruling: R7
note: "didactic" now follows its rule (M2).

old: The framed set is every user-authored method the build invokes.
new: The framed set is every user-authored method the build invokes (D-248).
tag: R
ruling: R5
newcites: D-248
note: D-248 Position, "The build frames every user-authored method it invokes through one framing accessor".

old: The declarations of §8.2 and the probed functions of §9.3 are framed alike, each reached through one framing accessor rather than a bare call.
tag: F

old: A declaration takes no bundle, so only the plain frame applies to it.
new: A declaration takes no bundle, so only the plain framing applies to it.
tag: R
ruling: R7

old: Three exceptions pass through the frame unwrapped, because none of them is user code failing.
new: Three exceptions pass through the framing unwrapped, because none of them is user code failing.
tag: R
ruling: R7

old: They are a `DiagnosticError` carrier a check inside the call threw, an `InternalInvariant`, and an `InterruptException`.
new: They are a `DiagnosticError` carrier a check inside the call threw, an `InternalInvariant` (the exception a framework self-check raises, outside the kind set) (D-215), and an `InterruptException`.
tag: R
ruling: R6
newcites: D-215
note: F28; D-215 bullet 4, "they raise a distinct `InternalInvariant` exception outside the kind set".

added: (the exception a framework self-check raises, outside the kind set)

old: At runtime the same throw reaches §13.4's one catch site instead.
new: At runtime the same throw reaches the one runtime catch site (§13.4) instead.
tag: F
note: the possessive citation unwound.

old: There a `FieldError` matched as below becomes a `BundleFieldError` species, and any other exception rides as the `StepError`'s `cause`.
tag: F

old: One class of exception is recognized rather than merely framed.
new: One exception type, the `FieldError`, is recognized rather than merely framed (D-341).
tag: R
ruling: R5
newcites: D-341
note: D-341 bullet 3, "A failed destructuring is diagnosed from the structured `FieldError`". "class" is reserved for primitive versus assembly.

old: A `FieldError` carries its type and field as data (Julia ≥ 1.12).
tag: F

old: At the probe the framework matches them against the bundle's own NamedTuple type, which the accessor holds.
tag: F

old: At the runtime catch site it matches them against the bundle's field names, because the bundle's type there is the activation's and is not in hand (D-248).
tag: F

old: A tuple the author builds with the bundle's own names is indistinguishable from the bundle at either site, and the diagnosis stays true of it.
tag: F

old: The result is the bundle-law did-you-mean (§5.2).
tag: F

old: It carries the legal field set and classifies the miss as an undeclared store, a wrong tier, or a field illegal for this function.
new: It carries the legal field set and classifies the miss as an undeclared store, a wrong tier (the continuous or discrete side of the hybrid formalism), or a field illegal for this function.
tag: F

added: (the continuous or discrete side of the hybrid formalism)
# the glossary's tier entry, verbatim.

old: Nothing is recovered by reading message text.
tag: F

old: The probe raises the result as `BundleFieldError` (Appendix C, D-248).
tag: F

old: An example message is "`systems/plant`: `x_deriv` destructures `m`, but `systems/plant` declares no `m_init`".
tag: F

old: The message names the component by its path.
tag: F

old: One law covers tier facts, stage legality and declarations alike.
tag: F

old: The wrong-tier class covers the state letters too (D-195).
new: The wrong-tier miss covers the state letters too (D-195).
tag: F
note: "class" is reserved; "miss" is the sentence before's word for it.

old: `x` and `m` are continuous-only, and `s` and `Δt` are discrete-only, so destructuring any of the four on the wrong tier is a wrong-tier fact.
tag: F

old: The bundle stays a bare NamedTuple (D-074, D-341).
tag: F

old: A getproperty-wrapper spelling is the recorded fallback, should type-matched interception prove insufficient (D-341).
tag: F

added: #### Where warnings live
# R3, the second of §13.2's two labels.

old: Rule. A warning raised while producing an artifact lives on that artifact.
new: A warning raised while producing an artifact lives on that artifact (D-250).
tag: R
ruling: R5
newcites: D-250
note: the Rule. label goes (R3); bold headline for D-250's artifact criterion, the first of the two sentences that state it.

old: A warning raised while mutating state lives in that state's status.
tag: F

old: Logging is presentation and never a home (D-250).
new: Logging is presentation and never a home.
tag: C
newcites: D-250
note: the citation moves two sentences back, to the bold.

old: An artifact is an immutable pure function of its inputs.
tag: F

old: State is single-owner and mutated in place.
tag: F

old: That one criterion places every warning the framework raises.
tag: F

old: The build produces artifacts, so its warnings live on them.
tag: R
ruling: R4
note: M9, row 59 plain (bold at §9.2).

old: `Build` and `Deployment` (the scalar-free artifact the grid parameters fix) carry `warnings`,
new: `warnings(x)` is defined on `Build` and `Deployment`
where: docs/design/spec.md
tag: M
note: M9, §9.2's Warnings label. The Deployment gloss moves with its link to the GridUtilization sentence below.

old: and `warnings(x)` reads the list (§9.2).
new: §9.2 states which artifacts carry them, how `warnings(x)` reads the list, and how a step that throws or completes presents them.
tag: R
ruling: R4
note: M9, the pointer to §9.2.

old: A step that throws renders its warnings with the collection it throws.
where: docs/design/spec.md
tag: M
note: M9, §9.2.

old: One that completes carries them on the artifact, and the entry point logs each once at return.
new: A step that completes carries its warnings on the artifact, and the entry point logs each one once at return
where: docs/design/spec.md
tag: M
note: M9, §9.2's bold (D-250 bullet 1).

old: The build's warning set holds `EmptyFaceSelection` (§8.8),
new: The build's warning set holds `EmptyFaceSelection` (§8.8, D-251).
tag: C
newcites: §8.8 D-251
note: D-251 bullet 2, "the warning `EmptyFaceSelection`, a build-stage warning through D-250's channel".

old: and the deployment's holds `GridUtilization`.
new: The warning set of the `Deployment` (the scalar-free artifact the grid parameters fix) holds `GridUtilization` (D-254).
tag: C
newcites: D-254
note: D-254 bullet 3, "`GridUtilization`, the last as a deployment warning under D-250". The gloss is row 60's, carried with the Deployment link.

old: The unconnected-output warning stays rejected (§6.1, D-084), so the collected-warning slot stays open and empty.
new: The unconnected-output warning stays rejected (§6.1, D-084), so the collected-warning category stays open and empty.
tag: F
note: D-084 plain (bold at §6.1).

old: A warnings-as-errors CI switch could be added, but is not built.
new: A warnings-as-errors switch is rejected, since a warning is a fact about the model, not a defect (D-250).
tag: R
ruling: R11
newcites: D-250
note: the dictated colon becomes "since". Plain: D-250's Rejected list carries it.

old: A stopped-sim service returns an artifact, so its warnings live on it.
tag: M
note: M3, up between the build and runtime paragraphs; the bold lead-in goes plain (R3).

old: `trim!` returns a `TrimReport`, and `TrimCommitEvents`, `TrimCommitResiduals` and `TrimCommitChecks` are that report's fields (§14.8).
tag: M
note: M3.

old: The line the call prints at return is presentation.
tag: M
note: M3.

old: `attach!` is the other side of the criterion.
tag: M
note: M3.

old: It mutates the roster,
new: It mutates the roster (the list of attached device entries).
tag: M
note: M3; the roster's first use in §13.2 is now here, so its link moves from the ThreadBudget line.

added: (the list of attached device entries)
# the glossary's roster entry: "the list of attached device entries".

old: so `EmptyGreedyClaim` lands in the roster entry's cell (§11.6).
new: `EmptyGreedyClaim` therefore lands in the roster entry's diagnostic cell (the per-writer cell for runtime diagnostics and liveness) (§11.6, D-250).
tag: M
newcites: §11.6 D-250
note: M3; the diagnostic-cell link and its gloss move here from the runtime paragraph. D-250 bullet 5, "`EmptyGreedyClaim` moves … to the roster entry's diagnostic cell, since `attach!` mutates the roster"; repeated since M3 moves the paragraph away from the criterion's citation.


old: The runtime mutates state, so its warnings live in that state's status.
tag: R
ruling: R3
note: the bold lead-in goes plain; D-250's Position is bold at the criterion.

old: The stream is per-occurrence.
new: These warnings form a per-occurrence stream.
tag: F

old: The per-writer diagnostic cells (the single-writer cell each writer owns for diagnostics and heartbeat) carry it (§11.8).
new: The per-writer diagnostic cells carry it (§11.8, D-136).
tag: C
newcites: §11.8 D-136
note: the gloss and link moved up with M3. D-136 Position, "one per-writer diagnostic cell"; plain (bold at §11.8).

old: The rate limit lives in the cells, as a structural bound rather than a policy layered over the stream.
new: The rate limit lives in the diagnostic cells, as a structural bound rather than a policy layered over the stream.
tag: F

old: The bound is a bounded ring plus per-kind suppressed counts, drained at frame top.
tag: F

old: So "rate-limited wherever its source can repeat" holds of every kind below without any kind arranging it.
tag: F

old: The stream surfaces through the published framework status (§11.2).
new: The stream surfaces through the published framework status (the frozen value each snapshot carries beside the signal table) (§11.2).
tag: F

added: (the frozen value each snapshot carries beside the signal table)

old: The §10.7 pacer diagnostics and the §12.2 liveness heartbeats ride in the same cells and surface beside it.
new: The liveness heartbeat (§12.2) rides in the same diagnostic cells, and the pacer's record (§10.7) sits beside the writers' records in the status.
tag: R
ruling: R6
note: F9; the duplicate diagnostic-cell link goes (F29).

old: The stream is never collected, since there is no collection to join.
tag: F

old: Nothing in the argument of D-084 applies to it.
tag: F

old: That decision is about what the build warns on.
tag: F

old: The committed runtime warnings, in one place, are these.
tag: F

old: Chattering, or localization-budget exhaustion (§10.4).
new: `ChatteringBudget`, for chattering or localization-budget exhaustion (§10.4).
tag: R
ruling: R8

old: A localized event's bracketing budget runs out at a boundary.
new: A localized event's crossing instant is bracketed by root-finding. The event's bracketing budget runs out at a boundary (a published consistency point).
tag: F

added: A localized event's crossing instant is bracketed by root-finding.

added: (a published consistency point)
# the glossary's boundary entry: "a published consistency point".

old: Firing-budget exhaustion (§10.6).
new: `FiringBudget`, firing-budget exhaustion (§10.6).
tag: R
ruling: R8

old: An event has spent its `firing_budget` at a boundary, and its further edges there are dropped.
tag: F

old: Forgiven-debt re-anchor (§10.7).
new: `DebtReanchor`, a forgiven-debt re-anchor (§10.7).
tag: R
ruling: R8

old: The pacer abandons its accumulated debt and re-anchors its schedule.
tag: F

old: The write-surface and entry violations (§11.3, §11.4), all raised at staging.
new: The write-surface and batch-entry violations (§11.3, §11.4), all raised at staging.
tag: R
ruling: R8
note: bare "entry" is reserved; these are batch entries (§11.3 "a batch entry outside the surface"). One line for the three kinds, which share the staging clause, each kind with its own section (R24).

old: The drain checks nothing.
new: The drain (the frame-top swap that applies staged writes) checks nothing.
tag: F

added: (the frame-top swap that applies staged writes)

old: `OutOfClaimEntry` is an enumerated surface's binding drift, a name with no position in the attach-compiled schema.
new: `OutOfClaimEntry` (§11.3) is an enumerated surface's binding drift, a name with no position in the attach-compiled schema.
tag: R
ruling: R24
newcites: §11.3
note: Appendix C's section for the kind.

old: `ClaimedFaceEntry` is a harness write to a face claimed in the run's frozen partition, and it names the incumbent.
new: `ClaimedFaceEntry` (§11.3, §11.4) is a harness write to a face claimed in the run's frozen partition, and it names the incumbent.
tag: R
ruling: R24
newcites: §11.3 §11.4
note: Appendix C's sections for the kind.

old: The stopped-sim attach also fires it when it renormalizes a pending batch.
tag: F

old: `EntryTypeMismatch` is a value unconvertible to its root input's declared type, rejected at staging for every writer.
new: `EntryTypeMismatch` (§11.4) is a value unconvertible to the declared type of its root input (the root component's own input face), rejected at staging for every writer.
tag: R
ruling: R24
newcites: §11.4
note: Appendix C's section for the kind.

added: (the root component's own input face)

old: A tolerated device-side datum failure (§11.6, §13.4).
new: `MalformedDatum`, a tolerated datum failure on the side of a device (any attached participant in the periphery) (§11.6, §13.4).
tag: R
ruling: R8

added: (any attached participant in the periphery)

old: `MalformedDatum` is emitted by the author's loop via `report!(handle, …)` into the device's own cell (§11.8).
new: It is emitted by the author's loop via `report!(handle, …)` into the device's own diagnostic cell (§11.8, D-105).
tag: C
newcites: §11.8 D-105
note: D-105 Position, "tolerated in the loop body (catch, stage nothing, `report(handle, MalformedDatum(cause))`, continue)"; plain (bold at §11.6).

old: It succeeds `InputMappingError`.
new: It replaces FlightCore's `InputMappingError`.
tag: R
ruling: R10

old: Staging discarded during replay (§12.7).
new: `ReplayDiscardedStaging`, staging discarded during replay (the ordinary loop re-driven from a recorded trace) (§12.7).
tag: R
ruling: R8

added: (the ordinary loop re-driven from a recorded trace)

old: `ReplayDiscardedStaging` reports a live batch found staged while the trace feeds the drain.
new: It reports a live batch found staged while the trace (the primary record of a session) feeds the drain.
tag: R
ruling: R8
note: the name moved to the line's head.

added: (the primary record of a session)

old: Thread-budget tightness (§12.2).
new: `ThreadBudget`, thread-budget tightness (§12.2, D-401).
tag: R
ruling: R8
newcites: §12.2 D-401
note: D-401 Position, tight below "the run's roster plus one"; cited at the line's head, where the condition is (verifier's fix).

old: Raised once per run, at `run!` or `replay!`, against the frozen roster.
new: It is raised once per run, at `run!` or `replay!`, against the frozen roster.
tag: F

old: Device join timeout (§12.4).
new: `DeviceJoinTimeout`, a device join timeout (§12.4).
tag: R
ruling: R8

old: A device task exceeds the shutdown join timeout and is abandoned by name rather than hanging `run!`.
tag: F

old: It arises after the terminal snapshot.
tag: F

old: It is therefore collected into the termination record and presented through the logging backend, never carried into a status (D-201, D-203).
new: It is therefore collected into the termination record (the stopped-sim value naming how the run ended) and presented through the logging backend, never carried into a status (D-201, D-203).
tag: F

added: (the stopped-sim value naming how the run ended)

old: Device crash (§12.4, §13.4).
new: `DeviceCrash`, a device crash (§12.4, §13.4).
tag: R
ruling: R8

added: A genuine bug takes the per-device crash path.
# F10's dictated wording (R6).

old: The framework wrapper catches a device task's failure,
new: The framework wrapper catches a device task's failure and reports `DeviceCrash`,
tag: R
ruling: R6
note: F10.

old: and the sim continues with the device absent.
new: and the run goes on without the device unless its attachment set `should_abort` (the per-attachment failure policy, an `attach!` keyword) (§11.6).
tag: R
ruling: R6
newcites: §11.6
note: F10; the path in one clause, pointing to §11.6 (R4).

added: (the per-attachment failure policy, an `attach!` keyword)

old: Unbounded run (§13.5).
new: `UnboundedRun`, an unbounded run (§13.5).
tag: R
ruling: R8

old: `run!` is called in `:live` with `t_end = Inf` and no honoured stop request.
new: `run!(sim)` with `t_end = Inf` and no honoured request
where: units/F/old.md
tag: M
note: R4, §13.5 is UnboundedRun's home; §13.5 also says "The advisory fires in `:live` only".

old: A `run!` in `:replay` is bounded by the recording and raises nothing.
new: A `run!` in `:replay` is bounded by the recording
where: units/F/old.md
tag: M
note: R4; §13.5's "The advisory fires in `:live` only" carries "raises nothing".

old: `UnboundedRun` lands in the loop's own cell, because `run!` mutates state (D-255).
new: It lands in the loop's own diagnostic cell, because `run!` mutates state (D-255).
tag: R
ruling: R8
note: kept as the warning criterion's case; the name moved to the line's head. D-255 cited only for the cell clause, which stands.

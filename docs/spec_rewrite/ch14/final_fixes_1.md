# Chapter 14, step 6b: final fixes, half 1 (units A and B)

The fixes of `final_verify_1.md`, applied to `units/A/new.md` and
`units/B/new.md` after `chapter_fixes_1.md` and `ruled_edits_1.md`. Each
entry replaces its old text, which occurs once in the unit's file at that
point, by its new text; replay them in order. Each edited paragraph is
rewrapped to 80 rendered columns.

## 1. Finding 1, unit A

Old:

````text
[§9.6][s9-6] previewed trim and linearization as clients of an [activation](#g-activation) (the build's
typed products at a given scalar type). The stopped-sim services are
initialization, trim, linearization, and `checkpoint` with its partner
`restore!`. The first three share one artifact, the [condition](#g-condition). A condition is
the datum that says "set this build to this state." `checkpoint` returns a
[checkpoint](#g-checkpoint) (the `Model`'s state at a frame top as one value), and `restore!`
puts it back. A checkpoint is a distinct value with no condition algebra
([D-273][d-273]). [§14.1][s14-1] settles the condition's representation, [§14.2][s14-2] its composition,
[§14.3][s14-3] its resolution and [§14.4][s14-4] its application and the read selectors; [§14.5][s14-5]
covers the initialization sequence called [boundary zero](#g-boundary-zero), [§14.6][s14-6]
[root-input totality](#g-root-input-totality) (the requirement that an application establishing a complete
world cover every [root input](#g-root-input)) and `override`, [§14.7][s14-7] the trim problem, [§14.8][s14-8] the
trim service, [§14.9][s14-9] mounting and [§14.10][s14-10] linearization.
````

New:

````text
[§9.6][s9-6] previewed trim and linearization as clients of an [activation](#g-activation) (the build's
typed products at a given scalar type). The stopped-sim services are
initialization, trim, linearization, and `checkpoint` with its partner
`restore!`. The first three share one artifact, the [condition](#g-condition). A condition is
the datum that says "set this build to this state." `checkpoint` returns a
[checkpoint](#g-checkpoint) (the `Model`'s state at a frame top as one value), and `restore!`
puts it back. A checkpoint is a distinct value with no condition algebra
([D-273][d-273]). [§14.1][s14-1] settles the condition's representation, [§14.2][s14-2] its composition,
[§14.3][s14-3] its resolution and [§14.4][s14-4] its application and the read selectors; [§14.5][s14-5]
covers the initialization sequence called [boundary zero](#g-boundary-zero), [§14.6][s14-6]
[root-input totality](#g-root-input-totality) (the requirement that an application establishing a complete
world cover every [root input](#g-root-input)) and `override`, [§14.7][s14-7] the trim problem, [§14.8][s14-8] the
trim service, [§14.9][s14-9] mounting, which together cover the trim service in full, and
[§14.10][s14-10] linearization.
````

## 2. Finding 2, unit A

Old:

````text
[§9.6][s9-6] previewed trim and linearization as clients of an [activation](#g-activation) (the build's
typed products at a given scalar type). The stopped-sim services are
initialization, trim, linearization, and `checkpoint` with its partner
`restore!`. The first three share one artifact, the [condition](#g-condition). A condition is
the datum that says "set this build to this state." `checkpoint` returns a
[checkpoint](#g-checkpoint) (the `Model`'s state at a frame top as one value), and `restore!`
puts it back. A checkpoint is a distinct value with no condition algebra
([D-273][d-273]). [§14.1][s14-1] settles the condition's representation, [§14.2][s14-2] its composition,
[§14.3][s14-3] its resolution and [§14.4][s14-4] its application and the read selectors; [§14.5][s14-5]
covers the initialization sequence called [boundary zero](#g-boundary-zero), [§14.6][s14-6]
[root-input totality](#g-root-input-totality) (the requirement that an application establishing a complete
world cover every [root input](#g-root-input)) and `override`, [§14.7][s14-7] the trim problem, [§14.8][s14-8] the
trim service, [§14.9][s14-9] mounting, which together cover the trim service in full, and
[§14.10][s14-10] linearization.
````

New:

````text
[§9.6][s9-6] previewed trim and linearization as clients of an [activation](#g-activation) (the build's
typed products at a given scalar type). The stopped-sim services are
initialization, trim, linearization, and `checkpoint` with its partner
`restore!`. The first three share one artifact, the [condition](#g-condition). A condition is
the datum that says "set this build to this state." `checkpoint` returns a
[checkpoint](#g-checkpoint) (the `Model`'s state at a frame top as one value), and `restore!`
puts it back. A checkpoint is a distinct value with no condition algebra
([D-273][d-273]). [§14.1][s14-1] settles the condition's representation, [§14.2][s14-2] its composition,
[§14.3][s14-3] its resolution and [§14.4][s14-4] its application and the read selectors; [§14.5][s14-5]
covers the initialization sequence called [boundary zero](#g-boundary-zero), [§14.6][s14-6]
[root-input totality](#g-root-input-totality) (the requirement that an application establishing a complete
world cover every [root input](#g-root-input)) and [`override`](#g-override) (the ordered, asymmetric layering
combinator), [§14.7][s14-7] the trim problem, [§14.8][s14-8] the trim service, [§14.9][s14-9] mounting,
which together cover the trim service in full, and [§14.10][s14-10] linearization.
````

## 3. Finding 2, unit A

Old:

````text
the scratch world is [`override`](#g-override)`(baseline, condition(guess))`
````

New:

````text
the scratch world is `override(baseline, condition(guess))`
````

## 4. Finding 3, unit A

Old:

````text
Init knowledge is [component](#g-component)-local. An engine component knows
`n_eng → ω = n_eng·ω_rated`, and nothing above it should have to. `n_eng` is the
engine speed as a fraction of its rated speed `ω_rated`. Making that locality a
schema entry was rejected ([D-064][d-064]). That spelling would declare
`initialize(::C, spec)`, a declarative rebirth of `f_init!`, FlightCore's
per-model initialization hook. It would also add an [assembly](#g-assembly)-level rule routing
sub-specs to children. This section covers, in order, the condition method,
composition by pull, what `set`'s payloads may name, the inert tree, the
empty-prefix refusal, the locality law, and the collision and blend errors.
````

New:

````text
Init knowledge is [component](#g-component)-local. An engine component knows
`n_eng → ω = n_eng·ω_rated`, where `n_eng` is the engine speed as a fraction of
its rated speed, and nothing above it should have to. Making that locality a
schema entry was rejected ([D-064][d-064]). That spelling would declare
`initialize(::C, spec)`, a declarative rebirth of `f_init!`, FlightCore's
per-model initialization hook. It would also add an [assembly](#g-assembly)-level rule routing
sub-specs to children. This section covers, in order, the condition method,
composition by pull, what `set`'s payloads may name, the inert tree, the
empty-prefix refusal, the locality law, and the collision and blend errors.
````

## 5. Finding 4, unit A

Old:

````text
The blend is still closed explicitly. A `combine(::Fragment, ::NamedTuple)`, or
any other blend of a condition node with a bare NamedTuple, is an error method.
Its message is directive. It says to wrap the NamedTuple in `set(…)` (or
`at(prefix, set(…))`) and to combine nodes with nodes. Like every other, the
rejection carries a [kind](#g-kind) (a diagnostic's identity in a closed, enumerated set).
**The blend rejection is `ConditionNodeMisuse`** ([Appendix C][sC], [D-113][d-113]), carrying the
offending argument's type and the node types in hand. It is raised at
composition time, before any resolution pass runs or any origin exists. That is
why it is its own kind and not a `ConditionResolution` sub-kind ([§14.3][s14-3]). The
explicit, *ordered* layering spelling, `override`, belongs with the use case of
[root-input totality](#g-root-input-totality) (the requirement that an application establishing a complete
world cover every root input) ([§14.6][s14-6]).
````

New:

````text
The blend is still closed explicitly. A `combine(::Fragment, ::NamedTuple)`, or
any other blend of a condition node with a bare NamedTuple, is an error method.
Its message is directive. It says to wrap the NamedTuple in `set(…)` (or
`at(prefix, set(…))`) and to combine nodes with nodes. Like every other, the
rejection carries a [kind](#g-kind) (a diagnostic's identity in a closed, enumerated set).
**The blend rejection is `ConditionNodeMisuse`** ([Appendix C][sC], [D-113][d-113]), carrying the
offending argument's type and the node types in hand. It is raised at
composition time, before any resolution pass runs or any origin exists. That is
why it is its own kind and not a `ConditionResolution` sub-kind ([§14.3][s14-3]). The
explicit, *ordered* layering spelling, `override`, belongs with the use case that
[root-input totality](#g-root-input-totality) (the requirement that an application establishing a complete
world cover every root input) produces ([§14.6][s14-6]).
````

## 6. Finding 5, unit B

Old:

````text
Only stopped-sim service evaluations, [`checkpoint`](#g-checkpoint), and post-run inspection of
the live stores ever hold live stores ([§11.2][s11-2]). That inspection is the
[replay](#g-replay)-to-inspect, where replay is the ordinary loop with its drain reading the
trace. Of these holders, only the service evaluations' readers take a store
selector. The snapshot deliberately carries no state stores ([§11.2][s11-2]), and `ẋ`
[buffers](#g-buffer) (the vectors the integrator fills) are integrator scratch, not
boundary-consistent objects outside a service evaluation. A reader resolving for
a table source that names a store selector is therefore refused at resolution,
as a `ReadResolution` with reason `:store_selector` ([D-406][d-406]). **The resolver takes
the source it resolves for**, so the rule is the resolver's and not a client's
([D-406][d-406]). The honest remedy ([§11.2][s11-2]) is to declare the field in `y_types`, return
it from `y_state`, and read the resulting [port](#g-port) ([§5.3][s5-3]).
````

New:

````text
Only stopped-sim service evaluations, [`checkpoint`](#g-checkpoint), and post-run inspection of
the live stores ever hold live stores ([§11.2][s11-2]). That inspection is the
[replay](#g-replay)-to-inspect ([§11.2][s11-2]), where replay is the ordinary loop with its drain
reading the trace. Of these holders, only the service evaluations' readers take
a store selector. The snapshot deliberately carries no state stores ([§11.2][s11-2]), and
`ẋ` [buffers](#g-buffer) (the vectors the integrator fills) are integrator scratch, not
boundary-consistent objects outside a service evaluation. A reader resolving for
a table source that names a store selector is therefore refused at resolution,
as a `ReadResolution` with reason `:store_selector` ([D-406][d-406]). **The resolver takes
the source it resolves for**, so the rule is the resolver's and not a client's
([D-406][d-406]). The honest remedy ([§11.2][s11-2]) is to declare the field in `y_types`, return
it from `y_state`, and read the resulting [port](#g-port) ([§5.3][s5-3]).
````

## 7. Finding 6, unit B

Old:

````text
In the sequence, a sweep is one pass through the execution order against the
current state, and a guard is the declared function defining an event's
predicate. A due component is a discrete component whose schedule admits the
boundary's tick index, and a snapshot is the immutable per-boundary publication.
After the first snapshot `init!` takes the [trace header](#g-trace-header), the [checkpoint](#g-checkpoint) (the
`Model`'s state at a frame top as one value) of the state the sequence leaves
([§11.5][s11-5], [D-274][d-274]). The parity with an ordinary [boundary](#g-boundary) is exact, not approximate.
The pieces follow one by one, in run order. Projection, the sweep, events and
the due `s_update` calls come first, then the `t₀` argument, then what
[boundary zero](#g-boundary-zero) (the initialization boundary, the ordinary macro-sequence with an
empty integrate) means for trim.
````

New:

````text
In the sequence, a sweep is one pass through the execution order against the
current state, and a guard is the declared function that decides when an event
fires. A due component is a discrete component scheduled to run here, and a
snapshot is the immutable publication that closes the sequence. After the first
snapshot `init!` takes the [trace header](#g-trace-header), the [checkpoint](#g-checkpoint) (the `Model`'s state at
a frame top as one value) of the state the sequence leaves ([§11.5][s11-5], [D-274][d-274]). The
parity with an ordinary [boundary](#g-boundary) is exact, not approximate. The pieces follow
one by one, in run order. Projection, the sweep, events and the due `s_update`
calls come first, then the `t₀` argument, then what [boundary zero](#g-boundary-zero) (the
initialization boundary, the ordinary macro-sequence with an empty integrate)
means for trim.
````

## 8. Finding 7, unit B

Old:

````text
The per-iteration ledger for trim has four terms. They are the user
fragment math, the leaf stores, the folded shape check and the
[sweep](#g-sweep) (one pass through the execution order against the current
state). The fragment math is the domain computations, unchanged from
Flight.jl's, plus building the tree, which with literal prefixes allocates
nothing ([§14.2][s14-2]). The sweep dominates, exactly as `f_ode!` does in
FlightCore, where it is the continuous-dynamics function a model extends.
````

New:

````text
The per-iteration ledger for trim has four terms. They are the user [fragment](#g-fragment)
math, the leaf stores, the folded shape check and the [sweep](#g-sweep) (one pass through
the execution order against the current state). The fragment math is the domain
computations, unchanged from Flight.jl's, plus building the tree, which with
literal prefixes allocates nothing ([§14.2][s14-2]). The sweep dominates, exactly as
`f_ode!` does in FlightCore, where it is the continuous-dynamics function a
model extends.
````

## 9. Finding 7, unit B

Old:

````text
The per-iteration ledger for trim has four terms. They are the user [fragment](#g-fragment)
math, the leaf stores, the folded shape check and the [sweep](#g-sweep) (one pass through
the execution order against the current state). The fragment math is the domain
computations, unchanged from Flight.jl's, plus building the tree, which with
literal prefixes allocates nothing ([§14.2][s14-2]). The sweep dominates, exactly as
`f_ode!` does in FlightCore, where it is the continuous-dynamics function a
model extends.
````

New:

````text
The per-iteration ledger for trim has four terms. They are the user [fragment](#g-fragment)
math, the leaf stores, the folded shape check and the [sweep](#g-sweep) (one pass through
the execution order against the current state). A fragment is the leaf node of
the condition algebra, built by `set`. The fragment math is the domain
computations, unchanged from Flight.jl's, plus building the tree, which with
literal prefixes allocates nothing ([§14.2][s14-2]). The sweep dominates, exactly as
`f_ode!` does in FlightCore, where it is the continuous-dynamics function a
model extends.
````

## 10. Finding 7, unit B

Old:

````text
On top of the source rule sits one piece of authoring guidance ([D-414][d-414]). Trim's
`reads` and linearization's taps name
`get_state`/`get_deriv`/`get_output`/`get_input`/`get_face`. They do so within
the scopes the locality law ([§6.1][s6-1]) and [fragment](#g-fragment) scoping ([§14.2][s14-2]) describe. A
fragment is the leaf node of the condition algebra, built by `set`. A service
read, trim's `reads` or a tap, that should outlive the build reads a face with
`get_face` ([D-125][d-125]). `get_face` resolves through export chains exactly as
mounting resolves [root input](#g-root-input) faces ([§14.9][s14-9], [D-125][d-125]), so the read side mirrors the
write side. An equilibrium equation meant to outlive the build it was posed
against therefore binds the curated face behind a [generically held](#g-generic-holding) child (one
held through a non-concrete field type) rather than a path into it.
````

New:

````text
On top of the source rule sits one piece of authoring guidance ([D-414][d-414]). Trim's
`reads` and linearization's taps name
`get_state`/`get_deriv`/`get_output`/`get_input`/`get_face`. They do so within
the scopes the locality law ([§6.1][s6-1]) and fragment scoping ([§14.2][s14-2]) describe. A
service read, trim's `reads` or a tap, that should outlive the build reads a
face with `get_face` ([D-125][d-125]). `get_face` resolves through export chains exactly
as mounting resolves [root input](#g-root-input) faces ([§14.9][s14-9], [D-125][d-125]), so the read side mirrors
the write side. An equilibrium equation meant to outlive the build it was posed
against therefore binds the curated face behind a [generically held](#g-generic-holding) child (one
held through a non-concrete field type) rather than a path into it.
````

## 11. Finding 8, unit B

Old:

````text
In the sequence, a sweep is one pass through the execution order against the
current state, and a guard is the declared function that decides when an event
fires. A due component is a discrete component scheduled to run here, and a
snapshot is the immutable publication that closes the sequence. After the first
snapshot `init!` takes the [trace header](#g-trace-header), the [checkpoint](#g-checkpoint) (the `Model`'s state at
a frame top as one value) of the state the sequence leaves ([§11.5][s11-5], [D-274][d-274]). The
parity with an ordinary [boundary](#g-boundary) is exact, not approximate. The pieces follow
one by one, in run order. Projection, the sweep, events and the due `s_update`
calls come first, then the `t₀` argument, then what [boundary zero](#g-boundary-zero) (the
initialization boundary, the ordinary macro-sequence with an empty integrate)
means for trim.
````

New:

````text
In the sequence, a sweep is one pass through the execution order against the
current state, and a guard is the declared function that decides when an event
fires. A due component is a discrete component scheduled to run here, and a
snapshot is the immutable publication that closes the sequence. After the first
snapshot `init!` takes the [trace header](#g-trace-header), the [checkpoint](#g-checkpoint) (the `Model`'s state at
a frame top as one value) of the state the sequence leaves ([§11.5][s11-5], [D-274][d-274]). The
parity with an ordinary [boundary](#g-boundary) is exact, not approximate. The pieces follow
one by one, in run order. [Projection](#g-projection) (the optional per-component hook
`x ← x_projection(x)`), the sweep, events and the due `s_update` calls come
first. Then come the `t₀` argument and what [boundary zero](#g-boundary-zero) (the initialization
boundary, the ordinary macro-sequence with an empty integrate) means for trim.
````

## 12. Finding 8, unit B

Old:

````text
- Project runs. Authored `x` can sit off-manifold. A hand-assembled quaternion
  may be ulps off unit norm, or a [condition](#g-condition) (the path-addressed sparse overlay
  that sets a build's state) may write part of a constrained block against fresh
  defaults. After condition writes, [projection](#g-projection) (the optional per-component hook
  `x ← x_projection(x)`) holds the same position it holds after any other `x`
  mutation. And it costs nothing when the state is already clean.
````

New:

````text
- Project runs. Authored `x` can sit off-manifold. A hand-assembled quaternion
  may be ulps off unit norm, or a [condition](#g-condition) (the path-addressed sparse overlay
  that sets a build's state) may write part of a constrained block against fresh
  defaults. Projection after condition writes holds the same position it holds
  after any other `x` mutation. And it costs nothing when the state is already
  clean.
````

## 13. Finding 9, unit B

Old:

````text
[Root inputs](#g-root-input) (the root's own input faces) are the one initialized datum without
declared defaults. That is the bare-types decision ([§11.3][s11-3]), upheld here ([D-068][d-068],
[D-376][d-376]). So a root input's only source before [boundary zero](#g-boundary-zero) is the [condition](#g-condition) (the
path-addressed sparse overlay that sets a build's state). Boundary zero is the
initialization boundary, the ordinary macro-sequence with an empty integrate.
Three consequences follow. They are the totality check, the probe-value barrier,
and baselines layered by [`override`](#g-override) (the ordered, asymmetric layering
combinator).
````

New:

````text
[Root inputs](#g-root-input) (the root's own input faces) are the one initialized datum without
declared defaults. That is the bare-types decision ([§11.3][s11-3]), upheld here ([D-068][d-068],
[D-376][d-376]). So a root input's only source before [boundary zero](#g-boundary-zero) is the [condition](#g-condition) (the
path-addressed sparse overlay that sets a build's state). Boundary zero is the
initialization boundary, the ordinary macro-sequence with an empty integrate.
Three consequences follow. They are the totality check, the probe-value barrier,
and [baselines](#g-baseline) (aircraft-shipped, full-coverage condition functions) layered by
[`override`](#g-override), the ordered, asymmetric layering combinator.
````

## 14. Finding 9, unit B

Old:

````text
**[Baselines](#g-baseline) are aircraft-shipped condition functions**, layered by `override`
([D-068][d-068]). Nobody hand-writes ~20 root-input values per script. In Flight.jl the
`@kwdef` defaults of `SystemsInitializer`, the systems initializer of its Cessna
172 model (`c172.jl`), carry that load. Their successor is ordinary user math in
one authoritative home, such as `ready_for_taxi(ac)` or `cold_and_dark(ac)`,
returning full-coverage conditions. But "baseline plus tweaks" collides with the
duplicate-leaf error ([§14.2][s14-2]) by design. The collision *is* the intent, and **the
fourth node type, `override(base, patch)`, exists for it** ([D-068][d-068]). It is ordered
and asymmetric, where [`combine`](#g-combine) is symmetric and collision-intolerant. At
resolution a leaf present in both takes the patch's value, and the origin names
both layers. Collisions *within* one layer remain errors. Variadic layering
(`override(campaign, aircraft, todays_case)`) composes. Trim uses it on day one.
The committed condition is `override(baseline, condition(d*))`, the solved
condition over full coverage ([D-068][d-068]).
````

New:

````text
**Baselines are aircraft-shipped condition functions**, layered by `override`
([D-068][d-068]). Nobody hand-writes ~20 root-input values per script. In Flight.jl the
`@kwdef` defaults of `SystemsInitializer`, the systems initializer of its Cessna
172 model (`c172.jl`), carry that load. Their successor is ordinary user math in
one authoritative home, such as `ready_for_taxi(ac)` or `cold_and_dark(ac)`,
returning full-coverage conditions. But "baseline plus tweaks" collides with the
duplicate-leaf error ([§14.2][s14-2]) by design. The collision *is* the intent, and **the
fourth node type, `override(base, patch)`, exists for it** ([D-068][d-068]). It is ordered
and asymmetric, where [`combine`](#g-combine) is symmetric and collision-intolerant. At
resolution a leaf present in both takes the patch's value, and the origin names
both layers. Collisions *within* one layer remain errors. Variadic layering
(`override(campaign, aircraft, todays_case)`) composes. Trim uses it on day one.
The committed condition is `override(baseline, condition(d*))`, the solved
condition over full coverage ([D-068][d-068]).
````

## 15. Finding 10, unit B

Old:

````text
- Events run. A condition can land a guard [predicate](#g-predicate), a `Bool`-valued form or
  the sign of a continuous function, in [holding](#g-edge-semantics) territory (firing on not-holding
  → holding transitions, never bare sign changes). An authored stall flag, or a
  strut authored into contact, does exactly that. The event then fires visibly
  at `t₀` rather than one step later. The prior rule grounds that timing ([§10.6][s10-6],
  [D-292][d-292]). Boundary zero establishes every guard [prior](#g-prior) (the event's stored
  predicate sample from the previous boundary) as not-holding. Suppressing those
  firings was rejected ([D-067][d-067]), on the lesson of the [stage-on-interaction](#g-stage-on-interaction) rule
  (when a GUI widget stages a new value) ([§11.7][s11-7]). That lesson is that insurance
  masking invariant violations is anti-diagnostic ([D-026][d-026]). The trace header is
  taken after the sequence ([§11.5][s11-5]). [Replay](#g-replay) restores it and runs no boundary
  zero, so whatever fired at `t₀` comes back as part of the restored state and
  never fires twice ([§12.7][s12-7], [D-274][d-274]). The checkpoint records the post-firing state
  faithfully and suppresses nothing. A [stop request](#g-stop-request) (an output port of the
  framework enum `StopFlag`) already reading `STOP_REQUESTED` is a different
  category. Nothing *fires*. The request simply holds in the published `t₀`
  snapshot and the loop reacts ([§13.5][s13-5], [D-413][d-413]).
````

New:

````text
- Events run. A condition can land a guard [predicate](#g-predicate), a `Bool`-valued form or
  the sign of a continuous function, in [holding](#g-edge-semantics) territory (firing on not-holding
  → holding transitions, never bare sign changes). An authored stall flag, or a
  strut authored into contact, does exactly that. The event then fires visibly
  at `t₀` rather than one step later. The prior rule grounds that timing ([§10.6][s10-6],
  [D-292][d-292]). Boundary zero establishes every guard [prior](#g-prior) (the event's stored
  predicate sample from the previous boundary) as not-holding. Suppressing those
  firings was rejected ([D-067][d-067]), on the lesson of the [stage-on-interaction](#g-stage-on-interaction) rule
  (the rule that a GUI widget stages a new value only on interaction, never per
  render pass) ([§11.7][s11-7]). That lesson is that insurance masking invariant
  violations is anti-diagnostic ([D-026][d-026]). The trace header is taken after the
  sequence ([§11.5][s11-5]). [Replay](#g-replay) restores it and runs no boundary zero, so whatever
  fired at `t₀` comes back as part of the restored state and never fires twice
  ([§12.7][s12-7], [D-274][d-274]). The checkpoint records the post-firing state faithfully and
  suppresses nothing. A [stop request](#g-stop-request) (an output port of the framework enum
  `StopFlag`) already reading `STOP_REQUESTED` is a different category. Nothing
  *fires*. The request simply holds in the published `t₀` snapshot and the loop
  reacts ([§13.5][s13-5], [D-413][d-413]).
````

## Claims and notes

- Finding 1 restores the cut claim: its `claims.md` block keeps the old
  phrase, tagged F, with no ruling.
- Finding 8 splits the run-order sentence in two, so the projection gloss and
  the boundary-zero gloss each sit in their own sentence.
- Finding 9: `override`'s gloss becomes an appositive, so the sentence keeps
  one parenthetical.
- Finding 11 edits only `units/B/claims.md`: B1's note now points at "its own
  plan" and "A compiled plan", since P1-15 cut "the compiled plans".

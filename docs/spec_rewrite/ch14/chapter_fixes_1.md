# Chapter 14, step 5: editorial fixes, half 1 (units A and B)

Applied by fix1 to `units/A/new.md` and `units/B/new.md` from commit
`b187775`. Each entry replaces its old text, which occurs once in the
unit's file at that point, by its new text; replay them in order. A
fenced block holds the text verbatim, with no added newline.

## 1. P1-2, unit A

Old:

````text
[§9.6][s9-6] previewed trim and linearization as clients of an
[activation](#g-activation) (the build's typed products at a given scalar
type). The stopped-sim services
are initialization, trim, linearization, and `checkpoint` with its partner
`restore!`. The first three share one artifact, the
[condition](#g-condition). A condition is the datum that says "set this build
to this state." `checkpoint` returns a [checkpoint](#g-checkpoint) (the
[`Model`](#g-model)'s state at a frame top as one value), and `restore!` puts
it back. A checkpoint is a distinct value with no condition algebra
([D-273][d-273]). [§14.1][s14-1] settles the condition's representation,
[§14.2][s14-2] its composition, [§14.3][s14-3] its resolution and
[§14.4][s14-4] its application; [§14.5][s14-5] covers the
[boundary-zero](#g-boundary-zero) sequence; [§14.6][s14-6] covers
[root-input totality](#g-root-input-totality) (the requirement that an
application establishing a complete world cover every
[root input](#g-root-input)); [§14.7][s14-7] the trim problem,
[§14.8][s14-8] the trim service and [§14.9][s14-9] mounting, which together
cover the trim service in full; and [§14.10][s14-10] covers linearization.
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
[§14.3][s14-3] its resolution and [§14.4][s14-4] its application; [§14.5][s14-5] covers the [boundary-zero](#g-boundary-zero)
sequence; [§14.6][s14-6] covers [root-input totality](#g-root-input-totality) (the requirement that an application
establishing a complete world cover every [root input](#g-root-input)); [§14.7][s14-7] the trim problem,
[§14.8][s14-8] the trim service and [§14.9][s14-9] mounting, which together cover the trim service
in full; and [§14.10][s14-10] covers linearization.
````

## 2. P1-1, unit A

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
[§14.3][s14-3] its resolution and [§14.4][s14-4] its application; [§14.5][s14-5] covers the [boundary-zero](#g-boundary-zero)
sequence; [§14.6][s14-6] covers [root-input totality](#g-root-input-totality) (the requirement that an application
establishing a complete world cover every [root input](#g-root-input)); [§14.7][s14-7] the trim problem,
[§14.8][s14-8] the trim service and [§14.9][s14-9] mounting, which together cover the trim service
in full; and [§14.10][s14-10] covers linearization.
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
covers the [boundary-zero](#g-boundary-zero) sequence, [§14.6][s14-6] [root-input totality](#g-root-input-totality) (the requirement
that an application establishing a complete world cover every [root input](#g-root-input)) and
`override`, [§14.7][s14-7] the trim problem, [§14.8][s14-8] the trim service, [§14.9][s14-9] mounting and
[§14.10][s14-10] linearization.
````

## 3. P1-35, unit A

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
covers the [boundary-zero](#g-boundary-zero) sequence, [§14.6][s14-6] [root-input totality](#g-root-input-totality) (the requirement
that an application establishing a complete world cover every [root input](#g-root-input)) and
`override`, [§14.7][s14-7] the trim problem, [§14.8][s14-8] the trim service, [§14.9][s14-9] mounting and
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
world cover every [root input](#g-root-input)) and `override`, [§14.7][s14-7] the trim problem, [§14.8][s14-8] the
trim service, [§14.9][s14-9] mounting and [§14.10][s14-10] linearization.
````

## 4. P1-3, unit A

Old:

````text
**Every service requires a non-running simulation** ([D-108][d-108]). While a
run exists the loop owns the [stores](#g-store) between [drains](#g-drain)
(the frame-top swap that publishes staged device writes into the root inputs),
and a service reading or writing them would race it. Pause is no exception,
by the doctrine that freezes the [roster](#g-roster) (the list of attached
devices, read once at `run!`). Pause is a [control-plane](#g-control-plane)
state *inside* a run, so a prohibition that holds mid-run holds while paused
([§11.3][s11-3], [§12.1][s12-1]).
````

New:

````text
**Every service requires a non-running simulation** ([D-108][d-108]). While the simulation is
`running`, the loop owns the [stores](#g-store) between [drains](#g-drain) (the frame-top swap that
publishes staged device writes into the root inputs), and a service reading or
writing them would race it. Pause is no exception, by the doctrine that freezes
the [roster](#g-roster) (the list of attached devices, read once at `run!`). Pause is a
[control-plane](#g-control-plane) state *inside* a run, so a prohibition that holds mid-run holds
while paused ([§11.3][s11-3], [§12.1][s12-1]).
````

## 5. P1-35, unit A

Old:

````text
**Every service requires a non-running simulation** ([D-108][d-108]). While the simulation is
`running`, the loop owns the [stores](#g-store) between [drains](#g-drain) (the frame-top swap that
publishes staged device writes into the root inputs), and a service reading or
writing them would race it. Pause is no exception, by the doctrine that freezes
the [roster](#g-roster) (the list of attached devices, read once at `run!`). Pause is a
[control-plane](#g-control-plane) state *inside* a run, so a prohibition that holds mid-run holds
while paused ([§11.3][s11-3], [§12.1][s12-1]).
````

New:

````text
**Every service requires a non-running simulation** ([D-108][d-108]). While the simulation is
`running`, the loop owns the [stores](#g-store) (the framework-owned homes of components'
`x`, `s` and `m` state). It owns them between [drains](#g-drain) (the frame-top swap that
publishes staged device writes into the root inputs), and a service reading or
writing them would race it. Pause is no exception, by the doctrine that freezes
the [roster](#g-roster) (the list of attached devices, read once at `run!`). Pause is a
[control-plane](#g-control-plane) state *inside* a run, so a prohibition that holds mid-run holds
while paused ([§11.3][s11-3], [§12.1][s12-1]).
````

## 6. P1-35, unit A

Old:

````text
**Every service requires a non-running simulation** ([D-108][d-108]). While the simulation is
`running`, the loop owns the [stores](#g-store) (the framework-owned homes of components'
`x`, `s` and `m` state). It owns them between [drains](#g-drain) (the frame-top swap that
publishes staged device writes into the root inputs), and a service reading or
writing them would race it. Pause is no exception, by the doctrine that freezes
the [roster](#g-roster) (the list of attached devices, read once at `run!`). Pause is a
[control-plane](#g-control-plane) state *inside* a run, so a prohibition that holds mid-run holds
while paused ([§11.3][s11-3], [§12.1][s12-1]).
````

New:

````text
**Every service requires a non-running simulation** ([D-108][d-108]). While the simulation is
`running`, the loop owns the [stores](#g-store) (the framework-owned homes of components'
`x`, `s` and `m` state). It owns them between [drains](#g-drain) (the frame-top swap that
publishes staged device writes into the root inputs), and a service reading or
writing them would race it. Pause is no exception, by the doctrine that freezes
the [roster](#g-roster) (the list of attached devices, read once at `run!`). Pause is a state
*inside* a run, carried by the [control plane](#g-control-plane) (the separate atomic surface for
pause, pace and the stop word), so a prohibition that holds mid-run holds while
paused ([§11.3][s11-3], [§12.1][s12-1]).
````

## 7. P1-2, unit A

Old:

````text
**Each row's service also has a form on a `Model`** (a deployment materialized
at one scalar type), gated by the model's status rather than by the lifecycle
([D-319][d-319]). `checkpoint` and the default `linearize` are legal at
`:consistent`. `init!`, `restore!`, `trim!` and `linearize` with an explicit
`about` are legal at any status. A model a simulation has claimed refuses each
form that writes, `init!`, `restore!` and `trim!`, as `ArgumentInvalid` with
reason `:claimed` ([D-318][d-318]).
````

New:

````text
**Each row's service also has a form on a [`Model`](#g-model)** (a deployment materialized at
one scalar type), gated by the model's status rather than by the lifecycle
([D-319][d-319]). `checkpoint` and the default `linearize` are legal at `:consistent`.
`init!`, `restore!`, `trim!` and `linearize` with an explicit `about` are legal
at any status. A model a simulation has claimed refuses each form that writes,
`init!`, `restore!` and `trim!`, as `ArgumentInvalid` with reason `:claimed`
([D-318][d-318]).
````

## 8. P1-4, unit A

Old:

````text
This section covers, in order, what a condition may specify, the overlay base,
why addressing a condition by path is legitimate, the pre-sweep doctrine and
the environment queries a condition may make.
````

New:

````text
A [condition](#g-condition) is the value an author writes to say which state a build starts
from. This section covers, in order, what a condition may specify, the overlay
base, why addressing a condition by path is legitimate, the pre-sweep doctrine
and the environment queries a condition may make.
````

## 9. P1-4, unit A

Old:

````text
A [condition](#g-condition) may specify state fields, `x` on the continuous
[tier](#g-tier) and `s` on the discrete. It may also specify modes, `m`, which
only [continuous components](#g-continuous-component) have ([§3.2][s3-2]). All
three are addressed by a slash path ([§8.6][s8-6]) plus a field name. Beyond
state, a condition may specify [root inputs](#g-root-input), addressed by
[face](#g-face) (the name a port wears on its component's boundary).
**It never specifies outputs**, which are derived data ([D-063][d-063]). It
never specifies [workspace](#g-workspace) (component-declared mutable scratch
arriving as the `ws` bundle field) ([D-306][d-306]). Condition entries are
validated in the collecting form ([§13.1][s13-1]). The full list is checked,
violations are collected, and one `DiagnosticError` is thrown. A condition
entry naming an output or a workspace field is one such violation,
`ConditionResolution` with reason `:undeclared_field` ([Appendix C][sC]).
````

New:

````text
A condition may specify state fields, `x` on the continuous [tier](#g-tier) and `s` on the
discrete. It may also specify modes, `m`, which only [continuous components](#g-continuous-component) have
([§3.2][s3-2]). All three are addressed by a slash path ([§8.6][s8-6]) plus a field name. Beyond
state, a condition may specify [root inputs](#g-root-input), addressed by [face](#g-face) (the name a port
wears on its component's boundary). **It never specifies outputs**, which are
derived data ([D-063][d-063]). It never specifies [workspace](#g-workspace) (component-declared mutable
scratch arriving as the `ws` bundle field) ([D-306][d-306]). Condition entries are
validated in the collecting form ([§13.1][s13-1]). The full list is checked, violations
are collected, and one `DiagnosticError` is thrown. A condition entry naming an
output or a workspace field is one such violation, `ConditionResolution` with
reason `:undeclared_field` ([Appendix C][sC]).
````

## 10. P1-35, unit A

Old:

````text
A condition may specify state fields, `x` on the continuous [tier](#g-tier) and `s` on the
discrete. It may also specify modes, `m`, which only [continuous components](#g-continuous-component) have
([§3.2][s3-2]). All three are addressed by a slash path ([§8.6][s8-6]) plus a field name. Beyond
state, a condition may specify [root inputs](#g-root-input), addressed by [face](#g-face) (the name a port
wears on its component's boundary). **It never specifies outputs**, which are
derived data ([D-063][d-063]). It never specifies [workspace](#g-workspace) (component-declared mutable
scratch arriving as the `ws` bundle field) ([D-306][d-306]). Condition entries are
validated in the collecting form ([§13.1][s13-1]). The full list is checked, violations
are collected, and one `DiagnosticError` is thrown. A condition entry naming an
output or a workspace field is one such violation, `ConditionResolution` with
reason `:undeclared_field` ([Appendix C][sC]).
````

New:

````text
A condition may specify state fields, `x` on the continuous [tier](#g-tier) (one side of
the hybrid formalism) and `s` on the discrete. It may also specify modes, `m`,
which only [continuous components](#g-continuous-component) have ([§3.2][s3-2]). All three are addressed by a slash
path ([§8.6][s8-6]) plus a field name. Beyond state, a condition may specify
[root inputs](#g-root-input), addressed by [face](#g-face) (the name a port wears on its component's
boundary). **It never specifies outputs**, which are derived data ([D-063][d-063]). It never
specifies [workspace](#g-workspace) (component-declared mutable scratch arriving as the `ws`
bundle field) ([D-306][d-306]). Condition entries are validated in the collecting form
([§13.1][s13-1]). The full list is checked, violations are collected, and one
`DiagnosticError` is thrown. A condition entry naming an output or a workspace
field is one such violation, `ConditionResolution` with reason
`:undeclared_field` ([Appendix C][sC]).
````

## 11. P1-35, unit A

Old:

````text
A condition may specify state fields, `x` on the continuous [tier](#g-tier) (one side of
the hybrid formalism) and `s` on the discrete. It may also specify modes, `m`,
which only [continuous components](#g-continuous-component) have ([§3.2][s3-2]). All three are addressed by a slash
path ([§8.6][s8-6]) plus a field name. Beyond state, a condition may specify
[root inputs](#g-root-input), addressed by [face](#g-face) (the name a port wears on its component's
boundary). **It never specifies outputs**, which are derived data ([D-063][d-063]). It never
specifies [workspace](#g-workspace) (component-declared mutable scratch arriving as the `ws`
bundle field) ([D-306][d-306]). Condition entries are validated in the collecting form
([§13.1][s13-1]). The full list is checked, violations are collected, and one
`DiagnosticError` is thrown. A condition entry naming an output or a workspace
field is one such violation, `ConditionResolution` with reason
`:undeclared_field` ([Appendix C][sC]).
````

New:

````text
A condition may specify state fields, `x` on the continuous [tier](#g-tier) (one side of
the hybrid formalism) and `s` on the discrete. It may also specify modes, `m`,
which only [continuous components](#g-continuous-component) have ([§3.2][s3-2]). All three are addressed by a slash
path ([§8.6][s8-6]) plus a field name. Beyond state, a condition may specify [root inputs](#g-root-input)
(the root's own input faces). It addresses them by [face](#g-face) (the name a port wears
on its component's boundary). **It never specifies outputs**, which are derived data
([D-063][d-063]). It never specifies [workspace](#g-workspace) (component-declared mutable scratch
arriving as the `ws` bundle field) ([D-306][d-306]). Condition entries are validated in
the collecting form ([§13.1][s13-1]). The full list is checked, violations are collected,
and one `DiagnosticError` is thrown. A condition entry naming an output or a
workspace field is one such violation, `ConditionResolution` with reason
`:undeclared_field` ([Appendix C][sC]).
````

## 12. P1-6, unit A

Old:

````text
**A would-be init value that depends on swept outputs is either analytically
known to the caller or an equilibrium constraint** ([D-064][d-064]). This is
the pre-sweep doctrine, and it holds because condition writes precede the
first [sweep](#g-sweep) (one pass through the execution order against the
current state) by definition. The first case is trim's `α_filt = α_a`. There
α is a *decision variable*, so the value is known above, not computable below.
The second case is a job for the trim service, not for init.
````

New:

````text
**A would-be init value that depends on swept outputs is either analytically known
to the caller or an equilibrium constraint** ([D-064][d-064]). This is the pre-sweep
doctrine, and it holds because condition writes precede the first [sweep](#g-sweep) (one
pass through the execution order against the current state) by definition. The
first case is trim's `α_filt = α_a` ([§14.2][s14-2]). There α is a *decision variable*, so
the value is known above, not computable below. The second case is a job for the
trim service, not for init.
````

## 13. P1-35, unit A

Old:

````text
**"Caller-computable" reaches past closed-form knowledge to environment
queries** ([D-139][d-139]). A condition needing one constructs the same handle
the sweep will produce, and then calls the same query function the consuming
component calls. There are two routes to that handle. One is the
[value-level constructor](#g-value-level-constructor) (the plain public
function building a field handle from the component and input values) of
[§8.2][s8-2], applied to the same values the [`baseline`](#g-baseline) writes
into the environment [component](#g-component)'s root inputs. The other
applies in a rig where an isbits handle itself is a root-input value
([§4.4][s4-4], [D-364][d-364]). There the condition simply holds the value the
`baseline` wrote. Either way there is one implementation of the field math,
evaluated one level up, with no pre-sweep and no new mechanism. Where
closed-form enforcement of a target is not wanted at all, the second escape
already covers the case ([D-139][d-139]). Promote the eliminated state
coordinates to decision variables and enforce the targets as residuals on
swept outputs. That route needs no environment access at condition time
whatsoever.
````

New:

````text
**"Caller-computable" reaches past closed-form knowledge to environment queries**
([D-139][d-139]). A condition needing one constructs the same handle the sweep will
produce, and then calls the same query function the consuming component calls.
There are two routes to that handle. One is the [value-level constructor](#g-value-level-constructor) (the
plain public function building a field handle from the component and input
values) of [§8.2][s8-2]. The condition applies it to the same values the [`baseline`](#g-baseline) (the
full-coverage condition `trim!` takes as a keyword) writes into the environment
[component](#g-component)'s root inputs. The other applies in a rig where an isbits handle
itself is a root-input value ([§4.4][s4-4], [D-364][d-364]). There the condition simply holds the
value the `baseline` wrote. Either way there is one implementation of the field
math, evaluated one level up, with no pre-sweep and no new mechanism. Where
closed-form enforcement of a target is not wanted at all, the second escape
already covers the case ([D-139][d-139]). Promote the eliminated state coordinates to
decision variables and enforce the targets as residuals on swept outputs. That
route needs no environment access at condition time whatsoever.
````

## 14. P1-5, unit A

Old:

````text
**"Caller-computable" reaches past closed-form knowledge to environment queries**
([D-139][d-139]). A condition needing one constructs the same handle the sweep will
produce, and then calls the same query function the consuming component calls.
There are two routes to that handle. One is the [value-level constructor](#g-value-level-constructor) (the
plain public function building a field handle from the component and input
values) of [§8.2][s8-2]. The condition applies it to the same values the [`baseline`](#g-baseline) (the
full-coverage condition `trim!` takes as a keyword) writes into the environment
[component](#g-component)'s root inputs. The other applies in a rig where an isbits handle
itself is a root-input value ([§4.4][s4-4], [D-364][d-364]). There the condition simply holds the
value the `baseline` wrote. Either way there is one implementation of the field
math, evaluated one level up, with no pre-sweep and no new mechanism. Where
closed-form enforcement of a target is not wanted at all, the second escape
already covers the case ([D-139][d-139]). Promote the eliminated state coordinates to
decision variables and enforce the targets as residuals on swept outputs. That
route needs no environment access at condition time whatsoever.
````

New:

````text
**"Caller-computable" reaches past closed-form knowledge to environment queries**
([D-139][d-139]). A condition needing one constructs the same handle the sweep will
produce, and then calls the same query function the consuming component calls.
There are two routes to that handle. One is the [value-level constructor](#g-value-level-constructor) (the
plain public function building a field handle from the component and input
values) of [§8.2][s8-2]. The condition applies it to the same values the [`baseline`](#g-baseline) (the
full-coverage condition `trim!` takes as a keyword) writes into the environment
[component](#g-component)'s root inputs. The other applies in a rig where an isbits handle
itself is a root-input value ([§4.4][s4-4], [D-364][d-364]). There the condition simply holds the
value the `baseline` wrote. Either way there is one implementation of the field
math, evaluated one level up, with no pre-sweep and no new mechanism. Where
closed-form enforcement of a target is not wanted at all, the doctrine's second
case already covers it ([D-139][d-139]). Promote the eliminated state coordinates to
decision variables and enforce the targets as residuals on swept outputs. That
route needs no environment access at condition time whatsoever.
````

## 15. P1-6, unit A

Old:

````text
Init knowledge is [component](#g-component)-local. An engine component knows
`n_eng → ω = n_eng·ω_rated`, and nothing above it should have to. Making that
locality a schema entry was rejected ([D-064][d-064]). That spelling would
declare `initialize(::C, spec)`, a declarative rebirth of `f_init!`,
FlightCore's per-model initialization hook. It would also add an
[assembly](#g-assembly)-level rule routing sub-specs to children. This section
covers, in order, the condition method, composition by pull, what `set`'s
payloads may name, the inert tree, the empty-prefix refusal, the locality law,
and the collision and blend errors.
````

New:

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

## 16. P1-35, unit A

Old:

````text
**What preserves the locality is an idiom, not schema** ([D-064][d-064]). It
is the [condition](#g-condition) method, a method of the framework's
`condition` generic, shipped beside the component and dispatched on the
component, returning the component's own [fragment](#g-fragment) (the leaf
node of the condition algebra, built by `set`) ([D-405][d-405]). The generic
is framework-owned so that an owner's pull, described below, reaches a
child's fragment when the two live in different packages. A model package
extends it through `import Redstone: condition`, as it extends the declaration
family ([§8.1][s8-1]). No shadowing check covers it, because a method written
to a foreign `condition` fails loudly at the owner's pull, as a `MethodError`
naming the child ([D-316][d-316]). In the first block, the engine is an
illustrative component named after FlightPhysics' `PistonEngine`, and `Phase`
an illustrative enum of its modes.
````

New:

````text
**What preserves the locality is an idiom, not schema** ([D-064][d-064]). It is the condition
method, a method of the framework's `condition` generic, shipped beside the
component and dispatched on the component, returning the component's own
[fragment](#g-fragment) (the leaf node of the condition algebra, built by `set`) ([D-405][d-405]). The
generic is framework-owned so that an owner's pull, described below, reaches a
child's fragment when the two live in different packages. A model package
extends it through `import Redstone: condition`, as it extends the declaration
family ([§8.1][s8-1]). No shadowing check covers it, because a method written to a
foreign `condition` fails loudly at the owner's pull, as a `MethodError` naming
the child ([D-316][d-316]). In the first block, the engine is an illustrative component
named after FlightPhysics' `PistonEngine`, and `Phase` an illustrative enum of
its modes.
````

## 17. P1-6, unit A

Old:

````text
Fragments are composed by *pull* from the structure's owner, here
`C172XSystems` (the C172X aircraft's systems assembly, after FlightApps'
`C172X.Systems`).
````

New:

````text
Fragments are composed by *pull* from the structure's owner, here `C172XSystems`
(the C172X aircraft's systems assembly, after FlightApps' `C172X.Systems`). In
the block, `α_filt` and `β_filt` are the aerodynamics' filtered airflow angles,
set to the angle of attack `α_a` and the sideslip `β_a`.
````

## 18. P1-8, unit A

Old:

````text
Dispatch selects variant-specific methods, so the actuation split between
FlightApps' C172 variants, c172s and c172x, costs no upstream edits.

**Composition builds an inert, lazy [fragment tree](#g-fragment-tree)**
````

New:

````text
**Composition builds an inert, lazy [fragment tree](#g-fragment-tree)**
````

## 19. P1-8 and P1-7, unit A

Old:

````text
    at("aero",       set(x = (α_filt = α_a, β_filt = β_a))))
```
````

New:

````text
    at("aero",       set(x = (α_filt = α_a, β_filt = β_a))))
```

Dispatch selects variant-specific methods, so the actuation split between
Flight.jl's two Cessna 172 variants, c172s and c172x, costs no upstream edits.
````

## 20. P1-35, unit A

Old:

````text
`set`'s payloads speak only about the component at the authoring point.
Addressing children is exclusively the job of [`at`](#g-at) (the scoping
combinator), so there is one way to say everything. A `u` payload names faces
*of the authoring level's [contract](#g-contract)*. **Resolution walks the
export chain to the root input** and errors if the face never surfaces
([D-065][d-065]), as `ConditionResolution` with reason `:no_input_face`, or
`:unexported_face` at the root ([Appendix C][sC]). That walk always has a name
to follow. One-level routing gives every level a declared face for every
signal crossing its boundary, so the chain a sub-assembly's face routes
through is in the `Build` ([§6.1][s6-1], [§9.2][s9-2], [D-207][d-207]). An
internally-wired input has no root input behind it, and writing it would be
meaningless because the first sweep overwrites it. Such a write is
`ConditionResolution` with reason `:internally_wired`. Unexported stays
unpokeable for init exactly as it is for a front end's panels
([§11.7][s11-7]).
````

New:

````text
`set`'s payloads speak only about the component at the authoring point.
Addressing children is exclusively the job of [`at`](#g-at) (the scoping combinator), so
there is one way to say everything. A `u` payload names faces *of the authoring
level's [contract](#g-contract)* (its declared interface). **Resolution walks the export chain to
the root input** and errors if the face never surfaces ([D-065][d-065]), as
`ConditionResolution` with reason `:no_input_face`, or `:unexported_face` at the
root ([Appendix C][sC]). That walk always has a name to follow. One-level routing
gives every level a declared face for every signal crossing its boundary, so the
chain a sub-assembly's face routes through is in the `Build` ([§6.1][s6-1], [§9.2][s9-2],
[D-207][d-207]). An internally-wired input has no root input behind it, and writing it
would be meaningless because the first sweep overwrites it. Such a write is
`ConditionResolution` with reason `:internally_wired`. Unexported stays
unpokeable for init exactly as it is for a front end's panels ([§11.7][s11-7]).
````

## 21. P1-35, unit A

Old:

````text
**Composition builds an inert, lazy [fragment tree](#g-fragment-tree)**
([D-065][d-065]). `set` builds the leaf, `at` and [`combine`](#g-combine)
(the symmetric, collision-intolerant combinator) build the tree's inner nodes,
and `override` builds a fourth node type ([§14.6][s14-6]). No path arithmetic
happens at composition.
````

New:

````text
**Composition builds an inert, lazy [fragment tree](#g-fragment-tree)** (the nested `Fragment`,
`Scoped`, `Combined` and override nodes) ([D-065][d-065]). `set` builds the leaf, `at`
and [`combine`](#g-combine) (the symmetric, collision-intolerant combinator) build the tree's
inner nodes, and `override` builds a fourth node type ([§14.6][s14-6]). No path
arithmetic happens at composition.
````

## 22. P1-9, unit A

Old:

````text
**Composition builds an inert, lazy [fragment tree](#g-fragment-tree)** (the nested `Fragment`,
`Scoped`, `Combined` and override nodes) ([D-065][d-065]). `set` builds the leaf, `at`
and [`combine`](#g-combine) (the symmetric, collision-intolerant combinator) build the tree's
inner nodes, and `override` builds a fourth node type ([§14.6][s14-6]). No path
arithmetic happens at composition.
````

New:

````text
**Composition builds an inert, lazy [fragment tree](#g-fragment-tree)** (the nested `Fragment`,
`Scoped`, `Combined` and override nodes) ([D-065][d-065]). `set` builds the leaf, `at`
and [`combine`](#g-combine) (the symmetric, collision-intolerant combinator) build the tree's
inner nodes, and [`override`](#g-override), the ordered, asymmetric layering combinator, builds
a fourth node type ([§14.6][s14-6]). No path arithmetic happens at composition.
````

## 23. P1-10, unit A

Old:

````text
Every node is isbits except the prefix strings, and a prefix is a reference to
the author's own literal. So, with literal prefixes, rebuilding the tree per
trim iteration allocates nothing. There is no path arithmetic and no copy of
the payloads. Composition checks three things, each by type or length alone,
and none allocates. Each `set` payload is a NamedTuple, each combinator
operand is a node, and each `at` prefix is nonempty. A `set` payload that is
not a NamedTuple is `ConditionNodeMisuse` with reason `:set_payload`
([Appendix C][sC]). The trim of Flight.jl's Cessna 172 model (`c172.jl`)
writes each trial state through FlightPhysics' `assign!`, and the zero-alloc
property of that `assign!` loop holds of the construction with literal
prefixes and of the specialized `apply!` that writes the tree ([§14.4][s14-4])
alike. An evaluation's cost is therefore the sweep it
feeds.
````

New:

````text
Every node is isbits except the prefix strings, and a prefix is a reference to
the author's own literal. So, with literal prefixes, rebuilding the tree per
trim iteration allocates nothing. There is no path arithmetic and no copy of the
payloads. Composition checks three things, each by type or length alone, and
none allocates. Each `set` payload is a NamedTuple, each combinator operand is a
node, and each `at` prefix is nonempty. A `set` payload that is not a NamedTuple
is `ConditionNodeMisuse` with reason `:set_payload` ([Appendix C][sC]). The trim of
Flight.jl's Cessna 172 model (`c172.jl`) writes each trial state through
FlightPhysics' `assign!`, a loop that allocates nothing. That property holds of
the construction with literal prefixes and of the specialized `apply!` that
writes the tree ([§14.4][s14-4]) alike. An evaluation's cost is therefore the sweep it
feeds.
````

## 24. P1-35, unit A

Old:

````text
**`at` refuses an empty prefix when it is called** ([D-278][d-278]). An empty
prefix names no child, and a node meant for the level where it is authored
stays unwrapped. The refusal holds at the root too, because `at` builds an
inert tree and cannot know where it will be mounted. On a condition node it
raises `ConditionNodeMisuse` with reason `:empty_prefix` ([Appendix C][sC])
before any resolution pass runs. The read side's lifts refuse the same way
([§14.9][s14-9], [D-278][d-278]).
````

New:

````text
**`at` refuses an empty prefix when it is called** ([D-278][d-278]). An empty prefix names no
child, and a node meant for the level where it is authored stays unwrapped. The
refusal holds at the root too, because `at` builds an inert tree and cannot know
where it will be mounted. On a node of a [condition](#g-condition) (the path-addressed sparse
overlay that sets a build's state), `at` raises `ConditionNodeMisuse` with
reason `:empty_prefix` ([Appendix C][sC]) before any resolution pass runs. The read
side's lifts refuse the same way ([§14.9][s14-9], [D-278][d-278]).
````

## 25. P1-35, unit A

Old:

````text
**The locality law here is the one [§6.1][s6-1] states for connections**, now
in its third instance ([D-065][d-065]). The three instances are
[local wires](#g-local-wire), computed interface connections and conditions.
Each level speaks its own fields, its declared children's names, and its own
faces. Delegation runs by dispatch at every genericity [seam](#g-seam). An
`at` prefix may stop at *any* child's faces, owned or
[generically held](#g-generic-holding), because the face graph is total
([D-207][d-207]). A deep `at` or condition path resolves wherever the
structure has it ([§13.3][s13-3], [D-414][d-414]). Absolute paths exist only
in the flattened list of condition entries, a *compiled derivative* of the
composition, as [cell](#g-cell) offsets are of `local_wires`. Under the
locality law, substituting a component invalidates only the fragments its
owner shipped. The build checks the law wherever it can see what the law
constrains. Wiring resolves one level ([§6.1][s6-1]). The faces a `u` payload
names resolve through the export chain, under any `at` prefix
([D-207][d-207]). No check refuses a deep path past a generically held field
([D-414][d-414]). An author who ships a fragment for a family scopes it by
dispatch on the holding's type parameter, so a fragment reaching into one
powerplant is defined for the aircraft that hold that powerplant
([D-414][d-414]). Ownership alone is convention. It is a fact about who
maintains the code, and the build cannot see it, so keeping a deep path inside
an owned subtree is idiomatic rather than machine-checked ([D-065][d-065]).
`set`, `at` and `combine` are ordinary functions with no privileges, as the
blocks of [§13.7][s13-7] are ordinary components.
````

New:

````text
**The locality law here is the one [§6.1][s6-1] states for connections**, now in its third
instance ([D-065][d-065]). The three instances are [local wires](#g-local-wire) (wires from one child's
port to a child's face), computed interface connections and conditions. Each
level speaks its own fields, its declared children's names, and its own faces.
Delegation runs by dispatch at every genericity [seam](#g-seam). An `at` prefix may stop at
*any* child's faces, owned or [generically held](#g-generic-holding), because the face graph is total
([D-207][d-207]). A deep `at` or condition path resolves wherever the structure has it
([§13.3][s13-3], [D-414][d-414]). Absolute paths exist only in the flattened list of condition
entries, a *compiled derivative* of the composition, as [cell](#g-cell) offsets are of
`local_wires`. Under the locality law, substituting a component invalidates only
the fragments its owner shipped. The build checks the law wherever it can see
what the law constrains. Wiring resolves one level ([§6.1][s6-1]). The faces a `u`
payload names resolve through the export chain, under any `at` prefix ([D-207][d-207]).
No check refuses a deep path past a generically held field ([D-414][d-414]). An author
who ships a fragment for a family scopes it by dispatch on the holding's type
parameter, so a fragment reaching into one powerplant is defined for the
aircraft that hold that powerplant ([D-414][d-414]). Ownership alone is convention. It is
a fact about who maintains the code, and the build cannot see it, so keeping a
deep path inside an owned subtree is idiomatic rather than machine-checked
([D-065][d-065]). `set`, `at` and `combine` are ordinary functions with no privileges, as
the blocks of [§13.7][s13-7] are ordinary components.
````

## 26. P1-35, unit A

Old:

````text
**The locality law here is the one [§6.1][s6-1] states for connections**, now in its third
instance ([D-065][d-065]). The three instances are [local wires](#g-local-wire) (wires from one child's
port to a child's face), computed interface connections and conditions. Each
level speaks its own fields, its declared children's names, and its own faces.
Delegation runs by dispatch at every genericity [seam](#g-seam). An `at` prefix may stop at
*any* child's faces, owned or [generically held](#g-generic-holding), because the face graph is total
([D-207][d-207]). A deep `at` or condition path resolves wherever the structure has it
([§13.3][s13-3], [D-414][d-414]). Absolute paths exist only in the flattened list of condition
entries, a *compiled derivative* of the composition, as [cell](#g-cell) offsets are of
`local_wires`. Under the locality law, substituting a component invalidates only
the fragments its owner shipped. The build checks the law wherever it can see
what the law constrains. Wiring resolves one level ([§6.1][s6-1]). The faces a `u`
payload names resolve through the export chain, under any `at` prefix ([D-207][d-207]).
No check refuses a deep path past a generically held field ([D-414][d-414]). An author
who ships a fragment for a family scopes it by dispatch on the holding's type
parameter, so a fragment reaching into one powerplant is defined for the
aircraft that hold that powerplant ([D-414][d-414]). Ownership alone is convention. It is
a fact about who maintains the code, and the build cannot see it, so keeping a
deep path inside an owned subtree is idiomatic rather than machine-checked
([D-065][d-065]). `set`, `at` and `combine` are ordinary functions with no privileges, as
the blocks of [§13.7][s13-7] are ordinary components.
````

New:

````text
**The locality law here is the one [§6.1][s6-1] states for connections**, now in its third
instance ([D-065][d-065]). The three instances are [local wires](#g-local-wire) (wires from one child's
port to a child's face), computed interface connections and conditions. Each
level speaks its own fields, its declared children's names, and its own faces.
Delegation runs by dispatch at every genericity [seam](#g-seam) (a narrow, named interface
kept deliberately thin). An `at` prefix may stop at *any* child's faces, owned or
[generically held](#g-generic-holding), because the face graph is total ([D-207][d-207]). A deep `at` or
condition path resolves wherever the structure has it ([§13.3][s13-3], [D-414][d-414]). Absolute
paths exist only in the flattened list of condition entries, a *compiled
derivative* of the composition, as [cell](#g-cell) offsets are of `local_wires`. Under the
locality law, substituting a component invalidates only the fragments its owner
shipped. The build checks the law wherever it can see what the law constrains.
Wiring resolves one level ([§6.1][s6-1]). The faces a `u` payload names resolve through
the export chain, under any `at` prefix ([D-207][d-207]). No check refuses a deep path
past a generically held field ([D-414][d-414]). An author who ships a fragment for a
family scopes it by dispatch on the holding's type parameter, so a fragment
reaching into one powerplant is defined for the aircraft that hold that
powerplant ([D-414][d-414]). Ownership alone is convention. It is a fact about who
maintains the code, and the build cannot see it, so keeping a deep path inside
an owned subtree is idiomatic rather than machine-checked ([D-065][d-065]). `set`, `at`
and `combine` are ordinary functions with no privileges, as the blocks of [§13.7][s13-7]
are ordinary components.
````

## 27. P1-35, unit A

Old:

````text
**The locality law here is the one [§6.1][s6-1] states for connections**, now in its third
instance ([D-065][d-065]). The three instances are [local wires](#g-local-wire) (wires from one child's
port to a child's face), computed interface connections and conditions. Each
level speaks its own fields, its declared children's names, and its own faces.
Delegation runs by dispatch at every genericity [seam](#g-seam) (a narrow, named interface
kept deliberately thin). An `at` prefix may stop at *any* child's faces, owned or
[generically held](#g-generic-holding), because the face graph is total ([D-207][d-207]). A deep `at` or
condition path resolves wherever the structure has it ([§13.3][s13-3], [D-414][d-414]). Absolute
paths exist only in the flattened list of condition entries, a *compiled
derivative* of the composition, as [cell](#g-cell) offsets are of `local_wires`. Under the
locality law, substituting a component invalidates only the fragments its owner
shipped. The build checks the law wherever it can see what the law constrains.
Wiring resolves one level ([§6.1][s6-1]). The faces a `u` payload names resolve through
the export chain, under any `at` prefix ([D-207][d-207]). No check refuses a deep path
past a generically held field ([D-414][d-414]). An author who ships a fragment for a
family scopes it by dispatch on the holding's type parameter, so a fragment
reaching into one powerplant is defined for the aircraft that hold that
powerplant ([D-414][d-414]). Ownership alone is convention. It is a fact about who
maintains the code, and the build cannot see it, so keeping a deep path inside
an owned subtree is idiomatic rather than machine-checked ([D-065][d-065]). `set`, `at`
and `combine` are ordinary functions with no privileges, as the blocks of [§13.7][s13-7]
are ordinary components.
````

New:

````text
**The locality law here is the one [§6.1][s6-1] states for connections**, now in its third
instance ([D-065][d-065]). The three instances are [local wires](#g-local-wire) (wires from one child's
port to a child's face), computed interface connections and conditions. Each
level speaks its own fields, its declared children's names, and its own faces.
Delegation runs by dispatch at every genericity [seam](#g-seam) (a narrow, named interface
kept deliberately thin). An `at` prefix may stop at *any* child's faces, owned or
[generically held](#g-generic-holding) (held through a non-concrete field type), because the face
graph is total ([D-207][d-207]). A deep `at` or condition path resolves wherever the
structure has it ([§13.3][s13-3], [D-414][d-414]). Absolute paths exist only in the flattened list
of condition entries, a *compiled derivative* of the composition, as [cell](#g-cell) offsets
are of `local_wires`. Under the locality law, substituting a component
invalidates only the fragments its owner shipped. The build checks the law
wherever it can see what the law constrains. Wiring resolves one level ([§6.1][s6-1]).
The faces a `u` payload names resolve through the export chain, under any `at`
prefix ([D-207][d-207]). No check refuses a deep path past a generically held field
([D-414][d-414]). An author who ships a fragment for a family scopes it by dispatch on
the holding's type parameter, so a fragment reaching into one powerplant is
defined for the aircraft that hold that powerplant ([D-414][d-414]). Ownership alone is
convention. It is a fact about who maintains the code, and the build cannot see
it, so keeping a deep path inside an owned subtree is idiomatic rather than
machine-checked ([D-065][d-065]). `set`, `at` and `combine` are ordinary functions with
no privileges, as the blocks of [§13.7][s13-7] are ordinary components.
````

## 28. P1-35, unit A

Old:

````text
**The locality law here is the one [§6.1][s6-1] states for connections**, now in its third
instance ([D-065][d-065]). The three instances are [local wires](#g-local-wire) (wires from one child's
port to a child's face), computed interface connections and conditions. Each
level speaks its own fields, its declared children's names, and its own faces.
Delegation runs by dispatch at every genericity [seam](#g-seam) (a narrow, named interface
kept deliberately thin). An `at` prefix may stop at *any* child's faces, owned or
[generically held](#g-generic-holding) (held through a non-concrete field type), because the face
graph is total ([D-207][d-207]). A deep `at` or condition path resolves wherever the
structure has it ([§13.3][s13-3], [D-414][d-414]). Absolute paths exist only in the flattened list
of condition entries, a *compiled derivative* of the composition, as [cell](#g-cell) offsets
are of `local_wires`. Under the locality law, substituting a component
invalidates only the fragments its owner shipped. The build checks the law
wherever it can see what the law constrains. Wiring resolves one level ([§6.1][s6-1]).
The faces a `u` payload names resolve through the export chain, under any `at`
prefix ([D-207][d-207]). No check refuses a deep path past a generically held field
([D-414][d-414]). An author who ships a fragment for a family scopes it by dispatch on
the holding's type parameter, so a fragment reaching into one powerplant is
defined for the aircraft that hold that powerplant ([D-414][d-414]). Ownership alone is
convention. It is a fact about who maintains the code, and the build cannot see
it, so keeping a deep path inside an owned subtree is idiomatic rather than
machine-checked ([D-065][d-065]). `set`, `at` and `combine` are ordinary functions with
no privileges, as the blocks of [§13.7][s13-7] are ordinary components.
````

New:

````text
**The locality law here is the one [§6.1][s6-1] states for connections**, now in its third
instance ([D-065][d-065]). The three instances are [local wires](#g-local-wire) (wires from one child's
port to a child's face), computed interface connections and conditions. Each
level speaks its own fields, its declared children's names, and its own faces.
Delegation runs by dispatch at every genericity [seam](#g-seam) (a narrow, named interface
kept deliberately thin). An `at` prefix may stop at *any* child's faces, owned or
[generically held](#g-generic-holding) (held through a non-concrete field type), because the face
graph is total ([D-207][d-207]). A deep `at` or condition path resolves wherever the
structure has it ([§13.3][s13-3], [D-414][d-414]). Absolute paths exist only in the flattened list
of condition entries, a *compiled derivative* of the composition, as the offsets
of [cells](#g-cell) (the typed entries of the signal table) are of `local_wires`. Under the
locality law, substituting a component invalidates only the fragments its owner
shipped. The build checks the law wherever it can see what the law constrains.
Wiring resolves one level ([§6.1][s6-1]). The faces a `u` payload names resolve through
the export chain, under any `at` prefix ([D-207][d-207]). No check refuses a deep path
past a generically held field ([D-414][d-414]). An author who ships a fragment for a
family scopes it by dispatch on the holding's type parameter, so a fragment
reaching into one powerplant is defined for the aircraft that hold that
powerplant ([D-414][d-414]). Ownership alone is convention. It is a fact about who
maintains the code, and the build cannot see it, so keeping a deep path inside
an owned subtree is idiomatic rather than machine-checked ([D-065][d-065]). `set`, `at`
and `combine` are ordinary functions with no privileges, as the blocks of [§13.7][s13-7]
are ordinary components.
````

## 29. P1-11, unit A

Old:

````text
A `combine` collision is two condition entries on one leaf. **Collisions are
errors at resolution** ([D-065][d-065]). The error is `DuplicateConditionLeaf`
([Appendix C][sC]), and it reports *both* origins. Its message names the
layering combinator. It reads "`combine` is collision-intolerant by design — use
`override(base, patch)` to layer." Last-writer-wins was rejected
([D-065][d-065]). That rejection is also why **the combinator is not
`Base.merge`**, and is no longer named after it ([D-204][d-204]). `Base.merge`
is last-wins on NamedTuples, the exact semantics rejected here, and its own
name should not promise them. Because `combine` is its own function, a bare
NamedTuple blended into a node cannot fall through to any last-wins method.
````

New:

````text
A `combine` collision is two condition entries on one leaf. **Collisions are
errors at resolution** ([D-065][d-065]). The error is `DuplicateConditionLeaf`
([Appendix C][sC]), and it reports *both* origins. Its message names the layering
combinator. It reads "`combine` is collision-intolerant by design — use
`override(base, patch)` to layer." Last-writer-wins was rejected ([D-065][d-065]). **The
combinator is not `Base.merge`**, and is no longer named after it ([D-204][d-204]). The
last-writer-wins rejection is also the reason. `Base.merge` is last-wins on
NamedTuples, the exact semantics rejected here, and its own name should not
promise them. Because `combine` is its own function, a bare NamedTuple blended
into a node cannot fall through to any last-wins method.
````

## 30. P1-35, unit A

Old:

````text
The blend is still closed explicitly. A `combine(::Fragment, ::NamedTuple)`,
or any other blend of a condition node with a bare NamedTuple, is an error
method. Its message is directive. It says to wrap the NamedTuple in `set(…)`
(or `at(prefix, set(…))`) and to combine nodes with nodes. The rejection
carries a [kind](#g-kind) like every other. **It is `ConditionNodeMisuse`**
([Appendix C][sC], [D-113][d-113]), carrying the offending argument's type and
the node types in hand. It is raised at composition time, before any
resolution pass runs or any origin exists. That is why it is its own kind and
not a `ConditionResolution` sub-kind ([§14.3][s14-3]). The explicit,
*ordered* layering spelling, [`override`](#g-override), belongs with the use
case [root-input totality](#g-root-input-totality) produces ([§14.6][s14-6]).
````

New:

````text
The blend is still closed explicitly. A `combine(::Fragment, ::NamedTuple)`, or
any other blend of a condition node with a bare NamedTuple, is an error method.
Its message is directive. It says to wrap the NamedTuple in `set(…)` (or
`at(prefix, set(…))`) and to combine nodes with nodes. Like every other, the
rejection carries a [kind](#g-kind) (a diagnostic's identity in a closed, enumerated set).
**It is `ConditionNodeMisuse`** ([Appendix C][sC], [D-113][d-113]), carrying the offending
argument's type and the node types in hand. It is raised at composition time,
before any resolution pass runs or any origin exists. That is why it is its own
kind and not a `ConditionResolution` sub-kind ([§14.3][s14-3]). The explicit, *ordered*
layering spelling, [`override`](#g-override), belongs with the use case [root-input totality](#g-root-input-totality)
produces ([§14.6][s14-6]).
````

## 31. P1-9, unit A

Old:

````text
The blend is still closed explicitly. A `combine(::Fragment, ::NamedTuple)`, or
any other blend of a condition node with a bare NamedTuple, is an error method.
Its message is directive. It says to wrap the NamedTuple in `set(…)` (or
`at(prefix, set(…))`) and to combine nodes with nodes. Like every other, the
rejection carries a [kind](#g-kind) (a diagnostic's identity in a closed, enumerated set).
**It is `ConditionNodeMisuse`** ([Appendix C][sC], [D-113][d-113]), carrying the offending
argument's type and the node types in hand. It is raised at composition time,
before any resolution pass runs or any origin exists. That is why it is its own
kind and not a `ConditionResolution` sub-kind ([§14.3][s14-3]). The explicit, *ordered*
layering spelling, [`override`](#g-override), belongs with the use case [root-input totality](#g-root-input-totality)
produces ([§14.6][s14-6]).
````

New:

````text
The blend is still closed explicitly. A `combine(::Fragment, ::NamedTuple)`, or
any other blend of a condition node with a bare NamedTuple, is an error method.
Its message is directive. It says to wrap the NamedTuple in `set(…)` (or
`at(prefix, set(…))`) and to combine nodes with nodes. Like every other, the
rejection carries a [kind](#g-kind) (a diagnostic's identity in a closed, enumerated set).
**It is `ConditionNodeMisuse`** ([Appendix C][sC], [D-113][d-113]), carrying the offending
argument's type and the node types in hand. It is raised at composition time,
before any resolution pass runs or any origin exists. That is why it is its own
kind and not a `ConditionResolution` sub-kind ([§14.3][s14-3]). The explicit, *ordered*
layering spelling, `override`, belongs with the use case [root-input totality](#g-root-input-totality)
produces ([§14.6][s14-6]).
````

## 32. P1-35, unit A

Old:

````text
The blend is still closed explicitly. A `combine(::Fragment, ::NamedTuple)`, or
any other blend of a condition node with a bare NamedTuple, is an error method.
Its message is directive. It says to wrap the NamedTuple in `set(…)` (or
`at(prefix, set(…))`) and to combine nodes with nodes. Like every other, the
rejection carries a [kind](#g-kind) (a diagnostic's identity in a closed, enumerated set).
**It is `ConditionNodeMisuse`** ([Appendix C][sC], [D-113][d-113]), carrying the offending
argument's type and the node types in hand. It is raised at composition time,
before any resolution pass runs or any origin exists. That is why it is its own
kind and not a `ConditionResolution` sub-kind ([§14.3][s14-3]). The explicit, *ordered*
layering spelling, `override`, belongs with the use case [root-input totality](#g-root-input-totality)
produces ([§14.6][s14-6]).
````

New:

````text
The blend is still closed explicitly. A `combine(::Fragment, ::NamedTuple)`, or
any other blend of a condition node with a bare NamedTuple, is an error method.
Its message is directive. It says to wrap the NamedTuple in `set(…)` (or
`at(prefix, set(…))`) and to combine nodes with nodes. Like every other, the
rejection carries a [kind](#g-kind) (a diagnostic's identity in a closed, enumerated set).
**It is `ConditionNodeMisuse`** ([Appendix C][sC], [D-113][d-113]), carrying the offending
argument's type and the node types in hand. It is raised at composition time,
before any resolution pass runs or any origin exists. That is why it is its own
kind and not a `ConditionResolution` sub-kind ([§14.3][s14-3]). The explicit, *ordered*
layering spelling, `override`, belongs with the use case of [root-input totality](#g-root-input-totality)
(the requirement that an application establishing a complete world cover every
root input) ([§14.6][s14-6]).
````

## 33. P1-4, unit A

Old:

````text
Resolution takes the root node plus a [`Build`](#g-build) (the artifact
`build(world)` produces). This section covers, in order, flattening, the
collecting checks, the two lookup families, the plan, the converter rule with
its two cases, and overlay partiality.
````

New:

````text
Resolution turns a composed [condition](#g-condition) (the path-addressed sparse overlay that
sets a build's state) into plans the services can apply. It takes the root node
plus a [`Build`](#g-build) (the artifact `build(world)` produces). This section covers, in
order, flattening, the collecting checks, the two lookup families, the plan, the
converter rule with its two cases, and overlay partiality.
````

## 34. P1-35, unit A

Old:

````text
**Flattening is the only place path strings are ever concatenated**
([D-065][d-065]). It is a trivial recursion with a path accumulator, and it
also records each [condition](#g-condition) entry's tree position, its
`getfield`/`getindex` step tuple.
````

New:

````text
**Flattening is the only place path strings are ever concatenated** ([D-065][d-065]). It is a
trivial recursion with a path accumulator, and it also records each condition
entry's tree position, its `getfield`/`getindex` step tuple.
````

## 35. P1-13, unit A

Old:

````text
A leaf already at the activation's scalar type is decision-descended. Under a
`Dual`-seeded evaluation of a type-stable `trim_condition(d)`, every
decision-dependent leaf is `Dual`-typed in the shape ([§14.7][s14-7]). Such a
leaf takes the type's ordinary `convert`/constructor methods *at that eltype*.
An authored `RQuat` (FlightPhysics' rotation quaternion) of `Dual`s becomes
the `SVector{4}` state leaf at `Dual`, with the partials flowing through
untouched. That untouched flow of partials is what makes the seeded decisions
reach the [sweep](#g-sweep) at all. At the [nominal](#g-nominal) activation
the same rule is the ordinary `Float64` conversion. An authored `RQuat` value
becomes the `SVector{4}` state leaf it initializes.
````

New:

````text
A leaf already at the activation's scalar type is decision-descended. Under a
`Dual`-seeded evaluation of a type-stable `trim_condition(d)`, every
decision-descended leaf is `Dual`-typed in the shape ([§14.7][s14-7]). Such a leaf takes
the type's ordinary `convert`/constructor methods *at that eltype*. An authored
`RQuat` (FlightPhysics' rotation quaternion) of `Dual`s becomes the `SVector{4}`
state leaf at `Dual`, with the partials flowing through untouched. That
untouched flow of partials is what makes the seeded decisions reach the [sweep](#g-sweep) at
all. At the [nominal](#g-nominal) activation the same rule is the ordinary `Float64`
conversion. An authored `RQuat` value becomes the `SVector{4}` state leaf it
initializes.
````

## 36. P1-35, unit A

Old:

````text
A leaf already at the activation's scalar type is decision-descended. Under a
`Dual`-seeded evaluation of a type-stable `trim_condition(d)`, every
decision-descended leaf is `Dual`-typed in the shape ([§14.7][s14-7]). Such a leaf takes
the type's ordinary `convert`/constructor methods *at that eltype*. An authored
`RQuat` (FlightPhysics' rotation quaternion) of `Dual`s becomes the `SVector{4}`
state leaf at `Dual`, with the partials flowing through untouched. That
untouched flow of partials is what makes the seeded decisions reach the [sweep](#g-sweep) at
all. At the [nominal](#g-nominal) activation the same rule is the ordinary `Float64`
conversion. An authored `RQuat` value becomes the `SVector{4}` state leaf it
initializes.
````

New:

````text
A leaf already at the activation's scalar type is decision-descended. Under a
`Dual`-seeded evaluation of a type-stable `trim_condition(d)`, every
decision-descended leaf is `Dual`-typed in the shape ([§14.7][s14-7]). Such a leaf takes
the type's ordinary `convert`/constructor methods *at that eltype*. An authored
`RQuat` (FlightPhysics' rotation quaternion) of `Dual`s becomes the `SVector{4}`
state leaf at `Dual`, with the partials flowing through untouched. That
untouched flow of partials is what makes the seeded decisions reach the [sweep](#g-sweep) at
all. At the [nominal](#g-nominal) activation (the `Float64` one), the same rule is the
ordinary `Float64` conversion. An authored `RQuat` value becomes the
`SVector{4}` state leaf it initializes.
````

## 37. P1-35, unit A

Old:

````text
A plain `Float64` leaf against a non-nominal activation's
[scratch](#g-scratch) is a held constant, and it takes the `Float64 → Dual`
zero-partial embedding. That embedding is semantically exact in that case, and
in no other. "Held at the operating point" *is* zero partials. Zero partials
are the whole of a linearization operating-point condition, which is
authored decision-free ([§14.10][s14-10]).
````

New:

````text
A plain `Float64` leaf against a non-nominal activation's [scratch](#g-scratch) (mutable
working storage whose contents are never authoritative) is a held constant, and
it takes the `Float64 → Dual` zero-partial embedding. That embedding is
semantically exact in that case, and in no other. "Held at the operating point"
*is* zero partials. Zero partials are the whole of a linearization operating-point
condition, which is authored decision-free ([§14.10][s14-10]).
````

## 38. P1-36, unit A

Old:

````text
compile time under the overlay-base rule ([§14.1][s14-1]).


````

New:

````text
compile time under the overlay-base rule ([§14.1][s14-1]).

````

## 39. P1-15, unit B

Old:

````text
All string work, validation and addressing are functions of the *shape* of
the condition. Every hot path holds the shape fixed while varying values.
Execution is therefore resolve-once/execute-many, with two ways to apply
the compiled plans ([§14.3][s14-3]).
````

New:

````text
All string work, validation and addressing are functions of the *shape* of the
condition. Every hot path holds the shape fixed while varying values. Execution
is therefore resolve-once/execute-many.
````

## 40. P1-35 and P1-36, unit B

Old:

````text
- **Specialized `apply!` serves the service that iterates**, trim's
  per-evaluation write ([D-066][d-066]). It applies its own plan, whose
  contents [§14.3][s14-3] gives. It unrolls [stores](#g-store) through the
  baked [lenses](#g-lens) and converters. Those are the same machine operations as
  the in-place writes of FlightPhysics' `assign!`, with no allocation, no strings and no
  dispatch. The per-iteration shape check is the mechanism of [§9.5][s9-5]
  transferred. The tree type is proven by dispatch, and it carries the full
  nesting, every field name and leaf type. A `===` comparison of each prefix
  string closes the remainder. `===` on strings compares content, so a
  prefix computed at run time pairs with the compiled one exactly as a
  literal does, at the cost of one short comparison per `at` node. Shape
  drift is a tree of another type, or a prefix that differs at a position.
  It is `ConditionShapeDrift` ([Appendix C][sC]), reason `:tree_type` or
  `:prefix`, a structured error rather than silent corruption. The cost is
  Julia codegen *once per condition shape*, and it grows with the shape's
  writes ([D-066][d-066]). On Julia 1.13 it measures 10 to 50 ms up to 32
  writes, 0.09 s at 64 and 0.2 s at 128
  (`docs/reports/20261002_tuple_walks/`). That cost is noise against the
  model's own first-sweep warmup (seconds). It is paid once per tree type per
  session, so it spreads over every evaluation of every trim of that shape,
  an envelope of trims included.
````

New:

````text
- **Specialized `apply!` serves the service that iterates**, trim's per-evaluation
  write ([D-066][d-066]). It applies its own plan, whose contents [§14.3][s14-3] gives. It unrolls
  [stores](#g-store) (the framework-owned homes of components' `x`, `s` and `m` state)
  through the baked [lenses](#g-lens) and converters. Those are the same machine operations
  as the in-place writes of FlightPhysics' `assign!`, with no allocation, no
  strings and no dispatch. The per-iteration shape check is the mechanism of
  [§9.5][s9-5] transferred. The tree type is proven by dispatch, and it carries the full
  nesting, every field name and leaf type. A `===` comparison of each prefix
  string closes the remainder. `===` on strings compares content, so a prefix
  computed at run time pairs with the compiled one exactly as a literal does, at
  the cost of one short comparison per `at` node. Shape drift is a tree of
  another type, or a prefix that differs at a position. It is
  `ConditionShapeDrift` ([Appendix C][sC]), reason `:tree_type` or `:prefix`, a
  structured error rather than silent corruption. The cost is Julia codegen *once
  per condition shape*, and it grows with the shape's writes ([D-066][d-066]). On Julia
  1.13 it measures 10 to 50 ms up to 32 writes, 0.09 s at 64 and 0.2 s at 128
  (`docs/reports/20261002_tuple_walks/`). That cost is noise against the model's
  own first-sweep warmup (seconds). It is paid once per tree type per session,
  so it spreads over every evaluation of every trim of that shape, an envelope
  of trims included.
````

## 41. P1-16, unit B

Old:

````text
- **Specialized `apply!` serves the service that iterates**, trim's per-evaluation
  write ([D-066][d-066]). It applies its own plan, whose contents [§14.3][s14-3] gives. It unrolls
  [stores](#g-store) (the framework-owned homes of components' `x`, `s` and `m` state)
  through the baked [lenses](#g-lens) and converters. Those are the same machine operations
  as the in-place writes of FlightPhysics' `assign!`, with no allocation, no
  strings and no dispatch. The per-iteration shape check is the mechanism of
  [§9.5][s9-5] transferred. The tree type is proven by dispatch, and it carries the full
  nesting, every field name and leaf type. A `===` comparison of each prefix
  string closes the remainder. `===` on strings compares content, so a prefix
  computed at run time pairs with the compiled one exactly as a literal does, at
  the cost of one short comparison per `at` node. Shape drift is a tree of
  another type, or a prefix that differs at a position. It is
  `ConditionShapeDrift` ([Appendix C][sC]), reason `:tree_type` or `:prefix`, a
  structured error rather than silent corruption. The cost is Julia codegen *once
  per condition shape*, and it grows with the shape's writes ([D-066][d-066]). On Julia
  1.13 it measures 10 to 50 ms up to 32 writes, 0.09 s at 64 and 0.2 s at 128
  (`docs/reports/20261002_tuple_walks/`). That cost is noise against the model's
  own first-sweep warmup (seconds). It is paid once per tree type per session,
  so it spreads over every evaluation of every trim of that shape, an envelope
  of trims included.
````

New:

````text
- **Specialized `apply!` serves the service that iterates**, trim's per-evaluation
  write ([D-066][d-066]). It applies its own plan, whose contents [§14.3][s14-3] gives. It unrolls
  [stores](#g-store) (the framework-owned homes of components' `x`, `s` and `m` state)
  through the baked [lenses](#g-lens) and converters. Those are the same machine operations
  as the in-place writes of FlightPhysics' `assign!`, with no allocation, no
  strings and no dispatch. The per-iteration shape check is the mechanism of
  [§9.5][s9-5] transferred. The tree type is proven by dispatch, and it carries the full
  nesting, every field name and leaf type. A `===` comparison of each prefix
  string closes the remainder. `===` on strings compares content, so a prefix
  computed at run time pairs with the compiled one exactly as a literal does, at
  the cost of one short comparison per `at` node. Shape drift is a tree of
  another type, or a prefix that differs at a position. It is
  `ConditionShapeDrift` ([Appendix C][sC]), reason `:tree_type` or `:prefix`, a
  structured error rather than silent corruption. The cost is Julia codegen *once
  per condition shape*, and it grows with the shape's writes ([D-066][d-066]). On Julia
  1.13 it measures 10 to 50 ms up to 32 writes, 0.09 s at 64 and 0.2 s at 128
  (`docs/reports/20261002_tuple_walks/`). That cost is noise against the model's
  own first-sweep warmup (seconds). It is paid once per tree type per session,
  so it spreads over every evaluation of every trim of that shape, an envelope
  of trims (one trim per point of a grid of flight conditions) included.
````

## 42. P1-36, unit B

Old:

````text
- **The dynamic walk serves the one-shot uses**, `init!`, `linearize`'s
  operating condition and trim's setup write ([§14.8][s14-8],
  [D-066][d-066]). It executes the same validated condition entries by
  runtime dispatch per write, from its own plan ([§14.3][s14-3]). That takes microseconds in total, with allocation permitted,
  since the stopped-sim path was never under the zero-alloc regime
  ([§9.8][s9-8]). It needs no per-shape codegen. Fifty structurally
  different scripted conditions cost fifty walks, not fifty compiles.
````

New:

````text
- **The dynamic walk serves the one-shot uses**, `init!`, `linearize`'s operating
  condition and trim's setup write ([§14.8][s14-8], [D-066][d-066]). It executes the same
  validated condition entries by runtime dispatch per write, from its own plan
  ([§14.3][s14-3]). That takes microseconds in total, with allocation permitted, since
  the stopped-sim path was never under the zero-alloc regime ([§9.8][s9-8]). It needs no
  per-shape codegen. Fifty structurally different scripted conditions cost fifty
  walks, not fifty compiles.
````

## 43. P1-26, unit B

Old:

````text
`apply!` ends at established stores. Making the model *coherent* is the job
of [boundary zero](#g-boundary-zero) (the initialization boundary, the
ordinary macro-sequence with an empty integrate), which [§14.5][s14-5]
specifies.

### 14.5 Boundary zero: an ordinary boundary with authored incoming transitions
````

New:

````text
### 14.5 Boundary zero: an ordinary boundary with authored incoming transitions
````

## 44. P1-26, unit B

Old:

````text
FlightCore, where it is the continuous-dynamics function a model extends.
````

New:

````text
FlightCore, where it is the continuous-dynamics function a model extends.

`apply!` ends at established stores. Making the model *coherent* is the job of
[boundary zero](#g-boundary-zero) (the initialization boundary, the ordinary macro-sequence with an
empty integrate), which [§14.5][s14-5] specifies.
````

## 45. P1-17, unit B

Old:

````text
The read-[selector](#g-selector) family is closed ([D-095][d-095]). Its
members are `get_state(path, leaf)`, `get_deriv(path, leaf)`,
`get_output(path, leaf)`, `get_input(leaf)` and `get_face(leaf)`. They form
one address space for every reader that takes a selector.
````

New:

````text
The family of read [selectors](#g-selector) (values describing a read the compiled gather will
perform) is closed ([D-095][d-095]). Its members are `get_state(path, leaf)`,
`get_deriv(path, leaf)`, `get_output(path, leaf)`, `get_input(leaf)` and
`get_face(leaf)`. They form one address space for every reader that takes a
selector.
````

## 46. P1-18 and P1-36, unit B

Old:

````text
**`leaf` is a [leaf address](#g-leaf-address)** ([D-276][d-276]). It is the
field or [face](#g-face) name (the name a port wears on its component's
boundary), followed by `.name` and `[k]` or `[k,l]` steps in any order, as
in `"pose.q_eb[2]"`, `"ω_eb_b[1]"` or `"J[1,3]"`. **A bare `Symbol` is the
short form of a plain name**, so `get_state("kin", :θ)` reads
`get_state("kin", "θ")` ([D-276][d-276]). A face name is an arbitrary string and may contain
a dot ([§8.6][s8-6]), so on `get_input` and `get_face` the head is matched
rather than parsed. The head is the longest declared face name that is a
prefix of the address and is followed by the end, a `.` or a `[`. A
`Symbol` leaf names the face whole, with no steps. So
`get_input("wing.throttle")` and `get_input("wind[1]")` both resolve, and
where faces `a` and `a.b` both exist, `"a.b"` names the face `a.b`.
**Each step is checked at resolution against the type resolved so far**
([D-276][d-276]). A
`.name` step needs an isbits struct with that field. An index step needs an
`SArray`, with one index or one per dimension, and a vector leaf thereby
yields named scalars. A step never enters an opaque leaf (a field handle or
a `Symbol`), which is read whole. **`get_deriv`, and `get_state` on the continuous
tier, take at most an index step**, since a continuous state field is flat
([§7.1][s7-1], [D-276][d-276]). A discrete `s` field is isbits or a `Symbol`
([§3.2][s3-2]), and `get_state` on it takes the full address. The address
is checked once and baked, and **the read runs as field loads and indexing
unrolled at compile time** ([D-276][d-276]).
````

New:

````text
**`leaf` is a [leaf address](#g-leaf-address)** ([D-276][d-276]). It is the field or [face](#g-face) name (the name a port
wears on its component's boundary), followed by `.name` and `[k]` or `[k,l]`
steps in any order, as in `"pose.q_eb[2]"`, `"ω_eb_b[1]"` or `"J[1,3]"`. **A bare
`Symbol` is the short form of a plain name**, so `get_state("kin", :θ)` reads
`get_state("kin", "θ")` ([D-276][d-276]). A face name is an arbitrary string and may
contain a dot ([§8.6][s8-6]), so on `get_input` and `get_face` the head is matched
rather than parsed. The head is the longest declared face name that is a prefix
of the address and is followed by the end, a `.` or a `[`. A `Symbol` leaf names
the face whole, with no steps. So `get_input("wing.throttle")` and
`get_input("wind[1]")` both resolve, and where faces `a` and `a.b` both exist,
`"a.b"` names the face `a.b`.

**Each step is checked at resolution against the type resolved so far** ([D-276][d-276]). A
`.name` step needs an isbits struct with that field. An index step needs an
`SArray`, with one index or one per dimension, and a vector leaf thereby yields
named scalars. A step never enters an opaque leaf (a field handle or a
`Symbol`), which is read whole. **`get_deriv`, and `get_state` on the continuous
tier, take at most an index step**, since a continuous state field is flat ([§7.1][s7-1],
[D-276][d-276]). A discrete `s` field is isbits or a `Symbol` ([§3.2][s3-2]), and `get_state` on
it takes the full address. The address is checked once and baked, and **the read
runs as field loads and indexing unrolled at compile time** ([D-276][d-276]).
````

## 47. P1-19, unit B

Old:

````text
There is no selector for a value a [component](#g-component) computes
without declaring it, and there cannot be one, because only declared
[cells](#g-cell) and stores are addressable ([§4.2][s4-2], [§8.3][s8-3]).
So a reader that wants one is asking the producing component to declare it
an output ([§8.3][s8-3]). A service evaluation needing an undeclared
intermediate has that one remedy too, and it is the same for every client.
The component exports it ([§14.7][s14-7]).
````

New:

````text
There is no selector for a value a [component](#g-component) computes without declaring it, and
there cannot be one, because only declared [cells](#g-cell) and stores are addressable
([§4.2][s4-2], [§8.3][s8-3]). So a reader that wants one is asking the producing component to
declare it an output ([§8.3][s8-3]). A service evaluation needing an undeclared
intermediate has the same remedy, whatever its client. The component exports it
([§14.7][s14-7]).
````

## 48. P1-20 and P1-36, unit B

Old:

````text
`get_face` addresses an output face of the mount level, the level its read
set is mounted at ([§14.9][s14-9], [D-277][d-277]). [Mounting](#g-mounting)
relocates a whole problem or [tap set](#g-taps) (the three selector lists
declaring what linearization seeds and reports) with `at(prefix, …)`. At the root that
face is root-exported. Either way the read is an *integration* read
([§11.2][s11-2]).
````

New:

````text
[Mounting](#g-mounting) relocates a whole problem or [tap set](#g-taps) (the three selector lists
declaring what linearization seeds and reports) with `at(prefix, …)`. `get_face`
addresses an output face of the mount level, the level a problem's or tap set's
reads are mounted at ([§14.9][s14-9], [D-277][d-277]). At the root that face is root-exported.
Either way the read is an *integration* read ([§11.2][s11-2]).
````

## 49. P1-35 and P1-36, unit B

Old:

````text
**A selector resolves against a source** ([D-098][d-098]). The table selectors (`get_output`, `get_input`,
`get_face`) resolve against a *table source*. A table source is a
[boundary](#g-boundary) [snapshot](#g-snapshot), or the scratch tables a
service evaluation instantiates ([§14.8][s14-8], [D-124][d-124]). The store
selectors (`get_state`, `get_deriv`) resolve only against live stores
([D-098][d-098]). The table/store axis separates table-borne values from
store-borne ones, not snapshots from services.
````

New:

````text
**A selector resolves against a source** ([D-098][d-098]). The table selectors (`get_output`,
`get_input`, `get_face`) resolve against a *table source*. A table source is a
[boundary](#g-boundary) [snapshot](#g-snapshot) (the immutable publication at a published consistency point),
or the scratch tables a service evaluation instantiates ([§14.8][s14-8], [D-124][d-124]). The
store selectors (`get_state`, `get_deriv`) resolve only against live stores
([D-098][d-098]). The table/store axis separates table-borne values from store-borne
ones, not snapshots from services.
````

## 50. P1-35, unit B

Old:

````text
Only stopped-sim service evaluations, [`checkpoint`](#g-checkpoint), and
post-run inspection of the live stores (the [replay](#g-replay)-to-inspect)
ever hold live stores ([§11.2][s11-2]). The snapshot deliberately carries
no state stores ([§11.2][s11-2]), and `ẋ` [buffers](#g-buffer) are
integrator scratch, not boundary-consistent objects outside a service
evaluation. A reader resolving for a table source that names a store
selector is therefore refused at resolution, as a `ReadResolution` with
reason `:store_selector` ([D-406][d-406]). **The resolver takes the source
it resolves for**, so the rule is the resolver's and not a client's
([D-406][d-406]). The honest remedy ([§11.2][s11-2]) is to declare the field
in `y_types`, return it from `y_state`, and read the resulting
[port](#g-port) ([§5.3][s5-3]).
````

New:

````text
Only stopped-sim service evaluations, [`checkpoint`](#g-checkpoint), and post-run inspection of
the live stores ever hold live stores ([§11.2][s11-2]). That inspection is the
[replay](#g-replay)-to-inspect, where replay is the ordinary loop with its drain reading the
trace. The snapshot deliberately carries no state stores ([§11.2][s11-2]), and `ẋ`
[buffers](#g-buffer) are integrator scratch, not boundary-consistent objects outside a
service evaluation. A reader resolving for a table source that names a store
selector is therefore refused at resolution, as a `ReadResolution` with reason
`:store_selector` ([D-406][d-406]). **The resolver takes the source it resolves for**, so the
rule is the resolver's and not a client's ([D-406][d-406]). The honest remedy ([§11.2][s11-2]) is
to declare the field in `y_types`, return it from `y_state`, and read the
resulting [port](#g-port) ([§5.3][s5-3]).
````

## 51. P1-35, unit B

Old:

````text
Only stopped-sim service evaluations, [`checkpoint`](#g-checkpoint), and post-run inspection of
the live stores ever hold live stores ([§11.2][s11-2]). That inspection is the
[replay](#g-replay)-to-inspect, where replay is the ordinary loop with its drain reading the
trace. The snapshot deliberately carries no state stores ([§11.2][s11-2]), and `ẋ`
[buffers](#g-buffer) are integrator scratch, not boundary-consistent objects outside a
service evaluation. A reader resolving for a table source that names a store
selector is therefore refused at resolution, as a `ReadResolution` with reason
`:store_selector` ([D-406][d-406]). **The resolver takes the source it resolves for**, so the
rule is the resolver's and not a client's ([D-406][d-406]). The honest remedy ([§11.2][s11-2]) is
to declare the field in `y_types`, return it from `y_state`, and read the
resulting [port](#g-port) ([§5.3][s5-3]).
````

New:

````text
Only stopped-sim service evaluations, [`checkpoint`](#g-checkpoint), and post-run inspection of
the live stores ever hold live stores ([§11.2][s11-2]). That inspection is the
[replay](#g-replay)-to-inspect, where replay is the ordinary loop with its drain reading the
trace. The snapshot deliberately carries no state stores ([§11.2][s11-2]), and `ẋ`
[buffers](#g-buffer) (the vectors the integrator fills) are integrator scratch, not
boundary-consistent objects outside a service evaluation. A reader resolving for
a table source that names a store selector is therefore refused at resolution,
as a `ReadResolution` with reason `:store_selector` ([D-406][d-406]). **The resolver takes
the source it resolves for**, so the rule is the resolver's and not a client's
([D-406][d-406]). The honest remedy ([§11.2][s11-2]) is to declare the field in `y_types`, return
it from `y_state`, and read the resulting [port](#g-port) ([§5.3][s5-3]).
````

## 52. P1-21, P1-35 and P1-36, unit B

Old:

````text
On top of the source rule sits one piece of authoring guidance
([D-414][d-414]). A service read, trim's `reads` or a tap, that should outlive
the build reads a face with `get_face` ([D-125][d-125]).
`get_face` resolves through export chains exactly as mounting resolves
[root input](#g-root-input) faces ([§14.9][s14-9], [D-125][d-125]), so
the read side mirrors the write side. An equilibrium equation meant to
outlive the build it was posed against therefore binds the curated face
behind a [generically held](#g-generic-holding) child (one held through a
non-concrete field type) rather than a path into it. An inspection read, a binding's or `series`', may
name any cell the structure has, since it promises nothing beyond this
build ([D-083][d-083]). Both reads resolve under the one service walk
([§13.3][s13-3]).

Trim's `reads` and linearization's taps name
`get_state`/`get_deriv`/`get_output`/`get_input`/`get_face`. They do so
within the scopes the locality law ([§6.1][s6-1]) and
[fragment](#g-fragment) scoping ([§14.2][s14-2]) describe, as authoring
guidance ([D-414][d-414]).

Inspection reads admit the whole family, within the source rule.
Output-[device](#g-device) bindings and log extraction by `series` take
deep paths, `get_face` names and leaf addresses alike ([D-406][d-406],
[D-407][d-407], [D-414][d-414]). Snapshot inspection reads a cell by path
and port name instead ([§11.2][s11-2]). A store selector resolves only for
a reader that runs over live stores, which today are the services'
([§14.7][s14-7], [§14.10][s14-10]). A snapshot-bound reader is barred from
it by source, not by client.
````

New:

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

An inspection read, a binding's or `series`', may name any cell the structure
has, since it promises nothing beyond this build ([D-083][d-083]). Both kinds of read
resolve under the one service walk ([§13.3][s13-3]). Inspection reads admit the whole
family, within the source rule. Bindings of an output [device](#g-device) (an attached
participant in the periphery) and log extraction by `series` take deep paths,
`get_face` names and leaf addresses alike ([D-406][d-406], [D-407][d-407], [D-414][d-414]). Snapshot
inspection reads a cell by path and port name instead ([§11.2][s11-2]). A store selector
resolves only for a reader that runs over live stores, which today are the
services' ([§14.7][s14-7], [§14.10][s14-10]). A snapshot-bound reader is barred from it by source,
not by client.
````

## 53. P1-24, unit B

Old:

````text
`ignore_stop_requests` is not a family client. It names requesters from the
`Build`'s [requester roster](#g-requester-roster) (the build's list of stop
requests, one per `StopFlag` output port), period ([§13.5][s13-5],
[D-316][d-316]). Termination is run policy over the requests the model
declares, and no path selector reaches `ignore_stop_requests`
([D-060][d-060], [D-316][d-316]).
````

New:

````text
`ignore_stop_requests` is not a family client. It names requesters from the
`Build`'s [requester roster](#g-requester-roster) (the build's list of stop requests, one per
`StopFlag` output port) and nothing else ([§13.5][s13-5], [D-316][d-316]). Termination is run
policy over the requests the model declares, and no path selector reaches
`ignore_stop_requests` ([D-060][d-060], [D-316][d-316]).
````

## 54. P1-25, unit B

Old:

````text
**Compiled readers are the gather twin** ([D-066][d-066]) over this family
and the [layout](#g-schema-vs-layout) tables (where each value physically
lives). Trim's residual reads (`ẋ` and output fields) and linearization's
Jacobian gather are one primitive run in reverse. It is one machinery, in
both directions, in the `Build`'s client kit.
````

New:

````text
Over this family and the [layout](#g-schema-vs-layout) tables (where each value physically lives),
**compiled readers are the gather twin** ([D-066][d-066]). Trim's residual reads (`ẋ` and
output fields) and linearization's Jacobian gather are one primitive run in
reverse. It is one machinery, in both directions, in the `Build`'s client kit.
````

## 55. P1-35, unit B

Old:

````text
`apply!` establishes the [stores](#g-store) at `t₀`. **The init service then
completes the [§10.6][s10-6] macro-sequence with an empty integrate**
([D-067][d-067]). The sequence is the following.
````

New:

````text
`apply!` establishes the [stores](#g-store) (the framework-owned homes of components' `x`,
`s` and `m` state) at `t₀`. **The init service then completes the [§10.6][s10-6]
macro-sequence with an empty integrate** ([D-067][d-067]). The sequence is the following.
````

## 56. P1-35, unit B

Old:

````text
After the first snapshot `init!` takes the [trace header](#g-trace-header),
the [checkpoint](#g-checkpoint) (the `Model`'s state at a frame top as one
value) of the state the sequence leaves ([§11.5][s11-5], [D-274][d-274]).
The parity with an ordinary [boundary](#g-boundary) is exact, not
approximate. The pieces follow one by one, in run order. Projection, the
sweep, events and the due `s_update` calls come first, then the `t₀`
argument, then what [boundary zero](#g-boundary-zero) (the initialization
boundary at `t₀`) means for trim.
````

New:

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
[boundary zero](#g-boundary-zero) (the initialization boundary at `t₀`) means for trim.
````

## 57. P1-27, unit B

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
[boundary zero](#g-boundary-zero) (the initialization boundary at `t₀`) means for trim.
````

New:

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

## 58. P1-35, unit B

Old:

````text
- Project runs. Authored `x` can sit off-manifold. A hand-assembled
  quaternion may be ulps off unit norm, or a [condition](#g-condition) (the
  path-addressed sparse overlay that sets a build's state) may write part of
  a constrained block against fresh defaults.
  [Projection](#g-projection) after condition writes holds the same position
  it holds after any other `x` mutation. And it costs nothing when the state
  is already clean.
````

New:

````text
- Project runs. Authored `x` can sit off-manifold. A hand-assembled quaternion
  may be ulps off unit norm, or a [condition](#g-condition) (the path-addressed sparse overlay
  that sets a build's state) may write part of a constrained block against fresh
  defaults. After condition writes, [projection](#g-projection) (the optional per-component hook
  `x ← x_projection(x)`) holds the same position it holds after any other `x`
  mutation. And it costs nothing when the state is already clean.
````

## 59. P1-35, unit B

Old:

````text
- The sweep runs, and **every discrete output stage publishes, due or not**
  ([D-205][d-205]). `t₀` is a grid point of every phase-free divisor, so the
  `Φ = 0` components are due in full. An offset [component](#g-component)
  ([§10.5][s10-5]) is *not* due, because its first [tick](#g-tick) is at
  `Φ·Δt_base`. Its output stages run at boundary zero all the same,
  publishing from the authored `s` and the `t₀` table in the ordinary sorted
  walk. That evaluation is establishment, not a scheduled sample. The
  schedule owns every instant after `t₀`, and the first sample the
  component's `s_update` consumes remains its `Φ·Δt_base` tick's. What the
  rule buys is a `t₀` snapshot carrying the authored world fully evaluated.
  No published [cell](#g-cell) holds the [probe](#g-probe)'s synthesized
  values. That is the [§14.6][s14-6] barrier extended from the
  [root inputs](#g-root-input) to the whole table.
````

New:

````text
- The sweep runs, and **every discrete output stage publishes, due or not** ([D-205][d-205]).
  `t₀` is a grid point of every phase-free divisor, so the `Φ = 0` components
  are due in full. An offset [component](#g-component) ([§10.5][s10-5]) is *not* due, because its first
  [tick](#g-tick) (an instant at which its stages and update run) is at `Φ·Δt_base`. Its
  output stages run at boundary zero all the same, publishing from the authored
  `s` and the `t₀` table in the ordinary sorted walk. That evaluation is
  establishment, not a scheduled sample. The schedule owns every instant after
  `t₀`, and the first sample the component's `s_update` consumes remains its
  `Φ·Δt_base` tick's. What the rule buys is a `t₀` snapshot carrying the
  authored world fully evaluated. No published [cell](#g-cell) holds the [probe](#g-probe)'s
  synthesized values. That is the [§14.6][s14-6] barrier extended from the [root inputs](#g-root-input) to
  the whole table.
````

## 60. P1-35, unit B

Old:

````text
- The sweep runs, and **every discrete output stage publishes, due or not** ([D-205][d-205]).
  `t₀` is a grid point of every phase-free divisor, so the `Φ = 0` components
  are due in full. An offset [component](#g-component) ([§10.5][s10-5]) is *not* due, because its first
  [tick](#g-tick) (an instant at which its stages and update run) is at `Φ·Δt_base`. Its
  output stages run at boundary zero all the same, publishing from the authored
  `s` and the `t₀` table in the ordinary sorted walk. That evaluation is
  establishment, not a scheduled sample. The schedule owns every instant after
  `t₀`, and the first sample the component's `s_update` consumes remains its
  `Φ·Δt_base` tick's. What the rule buys is a `t₀` snapshot carrying the
  authored world fully evaluated. No published [cell](#g-cell) holds the [probe](#g-probe)'s
  synthesized values. That is the [§14.6][s14-6] barrier extended from the [root inputs](#g-root-input) to
  the whole table.
````

New:

````text
- The sweep runs, and **every discrete output stage publishes, due or not** ([D-205][d-205]).
  `t₀` is a grid point of every phase-free divisor, so the `Φ = 0` components
  are due in full. An offset [component](#g-component) ([§10.5][s10-5]) is *not* due, because its first
  [tick](#g-tick) (an instant at which its stages and update run) is at `Φ·Δt_base`. Its
  output stages run at boundary zero all the same, publishing from the authored
  `s` and the `t₀` table in the ordinary sorted walk. That evaluation is
  establishment, not a scheduled sample. The schedule owns every instant after
  `t₀`, and the first sample the component's `s_update` consumes remains its
  `Φ·Δt_base` tick's. What the rule buys is a `t₀` snapshot carrying the
  authored world fully evaluated. No published [cell](#g-cell) holds a synthesized
  [probe value](#g-probe-value) (a fabricated value a build-time probe runs on). That is the
  probe-value barrier of [§14.6][s14-6] extended from the [root inputs](#g-root-input) to the whole table.
````

## 61. P1-35, unit B

Old:

````text
- Events run. A condition can land a guard [predicate](#g-predicate) in
  [holding](#g-edge-semantics) territory (firing on not-holding → holding
  transitions, never bare sign changes). An authored stall flag, or a strut
  authored into contact, does exactly that. The event then fires visibly at
  `t₀` rather than one step later. The [prior](#g-prior) rule grounds that
  timing ([§10.6][s10-6], [D-292][d-292]). Boundary zero establishes every
  guard prior (the event's stored predicate sample from the previous
  boundary) as not-holding. Suppressing those firings was rejected
  ([D-067][d-067]), on the lesson of the
  [stage-on-interaction](#g-stage-on-interaction) rule ([§11.7][s11-7]).
  That lesson is that insurance masking invariant violations is
  anti-diagnostic ([D-026][d-026]). The trace header is taken after the
  sequence ([§11.5][s11-5]). [Replay](#g-replay) restores it and runs no
  boundary zero, so whatever fired at `t₀` comes back as part of the
  restored state and never fires twice ([§12.7][s12-7], [D-274][d-274]).
  The checkpoint records the post-firing state faithfully and suppresses
  nothing. A [stop request](#g-stop-request) already reading
  `STOP_REQUESTED` is a different category. Nothing *fires*. The request
  simply holds in the published `t₀` snapshot and the loop reacts
  ([§13.5][s13-5], [D-413][d-413]).
````

New:

````text
- Events run. A condition can land a guard [predicate](#g-predicate), a `Bool`-valued form or
  the sign of a continuous function, in [holding](#g-edge-semantics) territory (firing on not-holding
  → holding transitions, never bare sign changes). An authored stall flag, or a
  strut authored into contact, does exactly that. The event then fires visibly
  at `t₀` rather than one step later. The [prior](#g-prior) rule grounds that timing ([§10.6][s10-6],
  [D-292][d-292]). Boundary zero establishes every guard prior (the event's stored
  predicate sample from the previous boundary) as not-holding. Suppressing those
  firings was rejected ([D-067][d-067]), on the lesson of the [stage-on-interaction](#g-stage-on-interaction) rule
  ([§11.7][s11-7]). That lesson is that insurance masking invariant violations is
  anti-diagnostic ([D-026][d-026]). The trace header is taken after the sequence ([§11.5][s11-5]).
  [Replay](#g-replay) restores it and runs no boundary zero, so whatever fired at `t₀` comes
  back as part of the restored state and never fires twice ([§12.7][s12-7], [D-274][d-274]). The
  checkpoint records the post-firing state faithfully and suppresses nothing. A
  [stop request](#g-stop-request) already reading `STOP_REQUESTED` is a different category. Nothing
  *fires*. The request simply holds in the published `t₀` snapshot and the loop
  reacts ([§13.5][s13-5], [D-413][d-413]).
````

## 62. P1-28, unit B

Old:

````text
- Events run. A condition can land a guard [predicate](#g-predicate), a `Bool`-valued form or
  the sign of a continuous function, in [holding](#g-edge-semantics) territory (firing on not-holding
  → holding transitions, never bare sign changes). An authored stall flag, or a
  strut authored into contact, does exactly that. The event then fires visibly
  at `t₀` rather than one step later. The [prior](#g-prior) rule grounds that timing ([§10.6][s10-6],
  [D-292][d-292]). Boundary zero establishes every guard prior (the event's stored
  predicate sample from the previous boundary) as not-holding. Suppressing those
  firings was rejected ([D-067][d-067]), on the lesson of the [stage-on-interaction](#g-stage-on-interaction) rule
  ([§11.7][s11-7]). That lesson is that insurance masking invariant violations is
  anti-diagnostic ([D-026][d-026]). The trace header is taken after the sequence ([§11.5][s11-5]).
  [Replay](#g-replay) restores it and runs no boundary zero, so whatever fired at `t₀` comes
  back as part of the restored state and never fires twice ([§12.7][s12-7], [D-274][d-274]). The
  checkpoint records the post-firing state faithfully and suppresses nothing. A
  [stop request](#g-stop-request) already reading `STOP_REQUESTED` is a different category. Nothing
  *fires*. The request simply holds in the published `t₀` snapshot and the loop
  reacts ([§13.5][s13-5], [D-413][d-413]).
````

New:

````text
- Events run. A condition can land a guard [predicate](#g-predicate), a `Bool`-valued form or
  the sign of a continuous function, in [holding](#g-edge-semantics) territory (firing on not-holding
  → holding transitions, never bare sign changes). An authored stall flag, or a
  strut authored into contact, does exactly that. The event then fires visibly
  at `t₀` rather than one step later. The prior rule grounds that timing ([§10.6][s10-6],
  [D-292][d-292]). Boundary zero establishes every guard prior (the event's stored
  predicate sample from the previous boundary) as not-holding. Suppressing those
  firings was rejected ([D-067][d-067]), on the lesson of the [stage-on-interaction](#g-stage-on-interaction) rule
  ([§11.7][s11-7]). That lesson is that insurance masking invariant violations is
  anti-diagnostic ([D-026][d-026]). The trace header is taken after the sequence ([§11.5][s11-5]).
  [Replay](#g-replay) restores it and runs no boundary zero, so whatever fired at `t₀` comes
  back as part of the restored state and never fires twice ([§12.7][s12-7], [D-274][d-274]). The
  checkpoint records the post-firing state faithfully and suppresses nothing. A
  [stop request](#g-stop-request) already reading `STOP_REQUESTED` is a different category. Nothing
  *fires*. The request simply holds in the published `t₀` snapshot and the loop
  reacts ([§13.5][s13-5], [D-413][d-413]).
````

## 63. P1-28, unit B

Old:

````text
- Events run. A condition can land a guard [predicate](#g-predicate), a `Bool`-valued form or
  the sign of a continuous function, in [holding](#g-edge-semantics) territory (firing on not-holding
  → holding transitions, never bare sign changes). An authored stall flag, or a
  strut authored into contact, does exactly that. The event then fires visibly
  at `t₀` rather than one step later. The prior rule grounds that timing ([§10.6][s10-6],
  [D-292][d-292]). Boundary zero establishes every guard prior (the event's stored
  predicate sample from the previous boundary) as not-holding. Suppressing those
  firings was rejected ([D-067][d-067]), on the lesson of the [stage-on-interaction](#g-stage-on-interaction) rule
  ([§11.7][s11-7]). That lesson is that insurance masking invariant violations is
  anti-diagnostic ([D-026][d-026]). The trace header is taken after the sequence ([§11.5][s11-5]).
  [Replay](#g-replay) restores it and runs no boundary zero, so whatever fired at `t₀` comes
  back as part of the restored state and never fires twice ([§12.7][s12-7], [D-274][d-274]). The
  checkpoint records the post-firing state faithfully and suppresses nothing. A
  [stop request](#g-stop-request) already reading `STOP_REQUESTED` is a different category. Nothing
  *fires*. The request simply holds in the published `t₀` snapshot and the loop
  reacts ([§13.5][s13-5], [D-413][d-413]).
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
  ([§11.7][s11-7]). That lesson is that insurance masking invariant violations is
  anti-diagnostic ([D-026][d-026]). The trace header is taken after the sequence ([§11.5][s11-5]).
  [Replay](#g-replay) restores it and runs no boundary zero, so whatever fired at `t₀` comes
  back as part of the restored state and never fires twice ([§12.7][s12-7], [D-274][d-274]). The
  checkpoint records the post-firing state faithfully and suppresses nothing. A
  [stop request](#g-stop-request) already reading `STOP_REQUESTED` is a different category. Nothing
  *fires*. The request simply holds in the published `t₀` snapshot and the loop
  reacts ([§13.5][s13-5], [D-413][d-413]).
````

## 64. P1-35, unit B

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
  ([§11.7][s11-7]). That lesson is that insurance masking invariant violations is
  anti-diagnostic ([D-026][d-026]). The trace header is taken after the sequence ([§11.5][s11-5]).
  [Replay](#g-replay) restores it and runs no boundary zero, so whatever fired at `t₀` comes
  back as part of the restored state and never fires twice ([§12.7][s12-7], [D-274][d-274]). The
  checkpoint records the post-firing state faithfully and suppresses nothing. A
  [stop request](#g-stop-request) already reading `STOP_REQUESTED` is a different category. Nothing
  *fires*. The request simply holds in the published `t₀` snapshot and the loop
  reacts ([§13.5][s13-5], [D-413][d-413]).
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
  (when a GUI widget stages a new value) ([§11.7][s11-7]). That lesson is that insurance
  masking invariant violations is anti-diagnostic ([D-026][d-026]). The trace header is
  taken after the sequence ([§11.5][s11-5]). [Replay](#g-replay) restores it and runs no boundary
  zero, so whatever fired at `t₀` comes back as part of the restored state and
  never fires twice ([§12.7][s12-7], [D-274][d-274]). The checkpoint records the post-firing state
  faithfully and suppresses nothing. A [stop request](#g-stop-request) already reading
  `STOP_REQUESTED` is a different category. Nothing *fires*. The request simply
  holds in the published `t₀` snapshot and the loop reacts ([§13.5][s13-5], [D-413][d-413]).
````

## 65. P1-35, unit B

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
  faithfully and suppresses nothing. A [stop request](#g-stop-request) already reading
  `STOP_REQUESTED` is a different category. Nothing *fires*. The request simply
  holds in the published `t₀` snapshot and the loop reacts ([§13.5][s13-5], [D-413][d-413]).
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

## 66. P1-29, unit B

Old:

````text
- Due `s_update` calls run. This follows from an interval-alignment fact
  that is easy to mis-picture. It is hereby a taught contract, sibling to
  the boundary-sampling line ([§8.6][s8-6]). **A boundary's `s_update` is
  the *outgoing* transition** ([D-067][d-067]). At tick `t_k` it consumes
  the completed boundary's samples and produces `s_{k+1}`, the value the
  next tick reads. The transition that carried `s` *into* `t_k` ran at
  `t_{k-1}`. Boundary zero is missing its incoming transitions on *both*
  [tiers](#g-tier) (the continuous and discrete sides of the hybrid
  formalism), and authorship replaces both.
````

New:

````text
- Due `s_update` calls run. This follows from an interval-alignment fact that is
  easy to mis-picture. It is hereby a taught contract, sibling to the
  boundary-sampling contract ([§8.6][s8-6]). **A boundary's `s_update` is the *outgoing*
  transition** ([D-067][d-067]). At tick `t_k` it consumes the completed boundary's samples
  and produces `s_{k+1}`, the value the next tick reads. The transition that
  carried `s` *into* `t_k` ran at `t_{k-1}`. Boundary zero is missing its incoming
  transitions on *both* [tiers](#g-tier) (the continuous and discrete sides of the hybrid
  formalism), and authorship replaces both.
````

## 67. P1-30 and P1-7, unit B

Old:

````text
- A guard firing at commit is a wanted failure signal. The hand-written trim
  asserts of Flight.jl's Cessna 172 models (no weight-on-wheels,
  `ω > ω_idle`) become the model's own event logic, surfaced through the
  ordinary machinery instead of `@assert`. A handler that fires at commit
  moves the committed stores off the solved point. Saying nothing would be
  warn-but-assign relocated. **The channel that says it is the trim report**
  ([§14.8][s14-8], [D-126][d-126]).
````

New:

````text
- A guard firing at commit is a wanted failure signal. The hand-written trim
  asserts (no gear strut in ground contact, engine speed `ω` above `ω_idle`) of
  Flight.jl's two Cessna 172 variants, c172s and c172x, become the model's own
  event logic, surfaced through the ordinary machinery instead of `@assert`. A
  handler that fires at commit moves the committed stores off the solved point.
  Saying nothing would be warn-but-assign relocated. **The channel that says it is
  the trim report** ([§14.8][s14-8], [D-126][d-126]).
````

## 68. P1-30, unit B

Old:

````text
- A guard firing at commit is a wanted failure signal. The hand-written trim
  asserts (no gear strut in ground contact, engine speed `ω` above `ω_idle`) of
  Flight.jl's two Cessna 172 variants, c172s and c172x, become the model's own
  event logic, surfaced through the ordinary machinery instead of `@assert`. A
  handler that fires at commit moves the committed stores off the solved point.
  Saying nothing would be warn-but-assign relocated. **The channel that says it is
  the trim report** ([§14.8][s14-8], [D-126][d-126]).
````

New:

````text
- A guard firing at commit is a wanted failure signal. The hand-written trim
  asserts (no gear strut in ground contact, engine speed `ω` above `ω_idle`) of
  Flight.jl's two Cessna 172 variants, c172s and c172x, become the model's own
  event logic, surfaced through the ordinary machinery instead of `@assert`. A
  handler that fires at commit moves the committed stores off the solved point.
  Saying nothing would relocate warn-but-assign, where the trim of Flight.jl's
  Cessna 172 model (`c172.jl`) warns on a failed optimization and assigns its
  result anyway. **The channel that says it is the trim report** ([§14.8][s14-8], [D-126][d-126]).
````

## 69. P1-32, unit B

Old:

````text
- **A commit-fired handler is not the only mover**, and the second one is
  unconditional ([D-155][d-155]). Boundary zero's *first* act is
  `x_projection`, so the committed `x` is `x_projection(x*)`, not the
  solver's `x*`. An attitude quaternion renormalized by a few ulps is the
  canonical case. That move is legitimate, wanted, and usually invisible in
  the residuals. But the point the stores sit at is no longer the point the
  verdict was read at. Both movers take the same remedy, specified with the
  report in [§14.8][s14-8].
````

New:

````text
- **A commit-fired handler is not the only mover**, and the second one is
  unconditional ([D-155][d-155]). Boundary zero's *first* act is `x_projection`, so the
  committed `x` is `x_projection(x*)`, not the solver's `x*`. An attitude
  quaternion renormalized by a few ulps is the canonical case. That move is
  legitimate, wanted, and usually invisible in the residuals. But the point the
  stores sit at is no longer the point the solver's convergence verdict was read
  at ([§14.8][s14-8]). Both movers take the same remedy, specified with the report in
  [§14.8][s14-8].
````

## 70. P1-35, unit B

Old:

````text
[Root inputs](#g-root-input) are the one initialized datum without declared
defaults. That is the bare-types decision ([§11.3][s11-3]), upheld here
([D-068][d-068], [D-376][d-376]). So a root input's only source before
[boundary zero](#g-boundary-zero) is the [condition](#g-condition) (the
path-addressed sparse overlay that sets a build's state). Boundary zero is
the initialization boundary, the ordinary macro-sequence with an empty
integrate. Three consequences follow. They are the totality check, the
probe-value barrier, and baselines layered by `override`.
````

New:

````text
[Root inputs](#g-root-input) (the root's own input faces) are the one initialized datum without
declared defaults. That is the bare-types decision ([§11.3][s11-3]), upheld here ([D-068][d-068],
[D-376][d-376]). So a root input's only source before [boundary zero](#g-boundary-zero) is the [condition](#g-condition) (the
path-addressed sparse overlay that sets a build's state). Boundary zero is the
initialization boundary, the ordinary macro-sequence with an empty integrate.
Three consequences follow. They are the totality check, the probe-value barrier,
and baselines layered by `override`.
````

## 71. P1-9, unit B

Old:

````text
[Root inputs](#g-root-input) (the root's own input faces) are the one initialized datum without
declared defaults. That is the bare-types decision ([§11.3][s11-3]), upheld here ([D-068][d-068],
[D-376][d-376]). So a root input's only source before [boundary zero](#g-boundary-zero) is the [condition](#g-condition) (the
path-addressed sparse overlay that sets a build's state). Boundary zero is the
initialization boundary, the ordinary macro-sequence with an empty integrate.
Three consequences follow. They are the totality check, the probe-value barrier,
and baselines layered by `override`.
````

New:

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

## 72. P1-35, unit B

Old:

````text
**Totality is a precondition of starting, checked by the service**
([D-068][d-068]). A condition value is legitimately partial.
[Fragments](#g-fragment) compose, and trim iterations write subsets. So
"every root input covered" is not a property of conditions. **Totality is a
property of every application that establishes a complete world over
virgin stores** ([D-149][d-149]). That principle, not an enumeration,
names the sites. They are `init!`, trim's setup application to freshly
allocated scratch stores, trim's commit through boundary zero
([§14.8][s14-8]), and linearization's operating condition under `about`,
applied to its own scratch ([§14.10][s14-10]). That is one group of sites,
one mechanism and one kind. Each compares the resolved plan's root-input
coverage against the `Build`'s `input_faces` before writing anything. A
shortfall is one collected, declaration-ordered diagnostic
(`UninitializedInputs`, [Appendix C][sC]) naming every uncovered face.
Coverage is a *plan-level fact*, because both operands are resolution-time
data. The check is therefore one comparison, and it runs before any
evaluation, not merely before any write. Pre-write means all-or-nothing. A
rejected init leaves the sim exactly as it was, the same posture as failed
trim.
````

New:

````text
**Totality is a precondition of starting, checked by the service** ([D-068][d-068]). A
condition value is legitimately partial. [Fragments](#g-fragment) (the leaf nodes of the
condition algebra, built by `set`) compose, and trim iterations write subsets.
So "every root input covered" is not a property of conditions. **Totality is a
property of every application that establishes a complete world over virgin
stores** ([D-149][d-149]). That principle, not an enumeration, names the sites. They are
`init!`, trim's setup application to freshly allocated scratch stores, trim's
commit through boundary zero ([§14.8][s14-8]), and linearization's operating condition
under `about`, applied to its own scratch ([§14.10][s14-10]). That is one group of sites,
one mechanism and one kind. Each compares the resolved plan's root-input
coverage against the `Build`'s `input_faces` before writing anything. A
shortfall is one collected, declaration-ordered diagnostic
(`UninitializedInputs`, [Appendix C][sC]) naming every uncovered face. Coverage is a
*plan-level fact*, because both operands are resolution-time data. The check is
therefore one comparison, and it runs before any evaluation, not merely before
any write. Pre-write means all-or-nothing. A rejected init leaves the sim
exactly as it was, the same posture as failed trim.
````

## 73. P1-33, unit B

Old:

````text
**The [probe](#g-probe-value)-value barrier is structural**
([D-068][d-068]). The `probe_value` synthesis (zero, false, the first enum
value or `T()`) exists so build-time probes can exercise code with
fabricated inputs ([§9.3][s9-3]). A fabricated zero is a fine probe input
and a terrible flight condition. A silently zeroed `mixture` kills the
engine and sends the user debugging aerodynamics. The services path simply
contains no call to it. A root input gets a condition value or the
application errors, with no third branch. [Replay](#g-replay) likewise
never synthesizes. The [trace header](#g-trace-header) holds every
root-input cell as boundary zero left it, and with totality enforced that
record is complete by construction. That discharges the requirement
([§11.3][s11-3]).
````

New:

````text
**The [probe](#g-probe-value)-value barrier is structural** ([D-068][d-068]). The `probe_value` synthesis
(zero, false, the first enum value or `T()`) exists so build-time probes can
exercise code with fabricated inputs ([§9.3][s9-3]). A fabricated zero is a fine probe
input and a terrible flight condition. A silently zeroed `mixture`, the mixture
setting of FlightPhysics' `PistonEngine`, kills the engine and sends the user
debugging aerodynamics. The services path simply contains no call to it. A root
input gets a condition value or the application errors, with no third branch.
[Replay](#g-replay) likewise never synthesizes. The [trace header](#g-trace-header) holds every root-input cell
as boundary zero left it, and with totality enforced that record is complete by
construction. That discharges the requirement ([§11.3][s11-3]).
````

## 74. P1-35, unit B

Old:

````text
**The [probe](#g-probe-value)-value barrier is structural** ([D-068][d-068]). The `probe_value` synthesis
(zero, false, the first enum value or `T()`) exists so build-time probes can
exercise code with fabricated inputs ([§9.3][s9-3]). A fabricated zero is a fine probe
input and a terrible flight condition. A silently zeroed `mixture`, the mixture
setting of FlightPhysics' `PistonEngine`, kills the engine and sends the user
debugging aerodynamics. The services path simply contains no call to it. A root
input gets a condition value or the application errors, with no third branch.
[Replay](#g-replay) likewise never synthesizes. The [trace header](#g-trace-header) holds every root-input cell
as boundary zero left it, and with totality enforced that record is complete by
construction. That discharges the requirement ([§11.3][s11-3]).
````

New:

````text
**The [probe](#g-probe-value)-value barrier is structural** ([D-068][d-068]). The `probe_value` synthesis
(zero, false, the first enum value or `T()`) exists so build-time probes can
exercise code with fabricated inputs ([§9.3][s9-3]). A fabricated zero is a fine probe
input and a terrible flight condition. A silently zeroed `mixture`, the mixture
setting of FlightPhysics' `PistonEngine`, kills the engine and sends the user
debugging aerodynamics. The services path simply contains no call to it. A root
input gets a condition value or the application errors, with no third branch.
[Replay](#g-replay) (the ordinary loop with its drain reading the trace) likewise never
synthesizes. The [trace header](#g-trace-header) holds every root-input cell as boundary zero left
it, and with totality enforced that record is complete by construction. That
discharges the requirement ([§11.3][s11-3]).
````

## 75. P1-35, unit B

Old:

````text
**The [probe](#g-probe-value)-value barrier is structural** ([D-068][d-068]). The `probe_value` synthesis
(zero, false, the first enum value or `T()`) exists so build-time probes can
exercise code with fabricated inputs ([§9.3][s9-3]). A fabricated zero is a fine probe
input and a terrible flight condition. A silently zeroed `mixture`, the mixture
setting of FlightPhysics' `PistonEngine`, kills the engine and sends the user
debugging aerodynamics. The services path simply contains no call to it. A root
input gets a condition value or the application errors, with no third branch.
[Replay](#g-replay) (the ordinary loop with its drain reading the trace) likewise never
synthesizes. The [trace header](#g-trace-header) holds every root-input cell as boundary zero left
it, and with totality enforced that record is complete by construction. That
discharges the requirement ([§11.3][s11-3]).
````

New:

````text
**The [probe](#g-probe-value)-value barrier is structural** ([D-068][d-068]). The `probe_value` synthesis
(zero, false, the first enum value or `T()`) exists so build-time probes can
exercise code with fabricated inputs ([§9.3][s9-3]). A fabricated zero is a fine probe
input and a terrible flight condition. A silently zeroed `mixture`, the mixture
setting of FlightPhysics' `PistonEngine`, kills the engine and sends the user
debugging aerodynamics. The services path simply contains no call to it. A root
input gets a condition value or the application errors, with no third branch.
[Replay](#g-replay) (the ordinary loop with its drain reading the trace) likewise never
synthesizes. The [trace header](#g-trace-header) (the trace's fixed preamble) holds every
root-input cell as boundary zero left it, and with totality enforced that record
is complete by construction. That discharges the requirement ([§11.3][s11-3]).
````

## 76. P1-34, unit B

Old:

````text
**The [probe](#g-probe-value)-value barrier is structural** ([D-068][d-068]). The `probe_value` synthesis
(zero, false, the first enum value or `T()`) exists so build-time probes can
exercise code with fabricated inputs ([§9.3][s9-3]). A fabricated zero is a fine probe
input and a terrible flight condition. A silently zeroed `mixture`, the mixture
setting of FlightPhysics' `PistonEngine`, kills the engine and sends the user
debugging aerodynamics. The services path simply contains no call to it. A root
input gets a condition value or the application errors, with no third branch.
[Replay](#g-replay) (the ordinary loop with its drain reading the trace) likewise never
synthesizes. The [trace header](#g-trace-header) (the trace's fixed preamble) holds every
root-input cell as boundary zero left it, and with totality enforced that record
is complete by construction. That discharges the requirement ([§11.3][s11-3]).
````

New:

````text
**The [probe](#g-probe-value)-value barrier is structural** ([D-068][d-068]). The `probe_value` synthesis
(zero, false, the first enum value or `T()`) exists so build-time probes can
exercise code with fabricated inputs ([§9.3][s9-3]). A fabricated zero is a fine probe
input and a terrible flight condition. A silently zeroed `mixture`, the mixture
setting of FlightPhysics' `PistonEngine`, kills the engine and sends the user
debugging aerodynamics. The services path simply contains no call to it. A root
input gets a condition value or the application errors, with no third branch.
[Replay](#g-replay) (the ordinary loop with its drain reading the trace) likewise never
synthesizes. The [trace header](#g-trace-header) (the trace's fixed preamble) holds every
root-input cell as boundary zero left it, and with totality enforced that record
is complete by construction. That discharges the requirement that a root input
no device feeds hold a defined value from the first frame ([§11.3][s11-3]).
````

## 77. P1-9, unit B

Old:

````text
**[Baselines](#g-baseline) are aircraft-shipped condition functions**,
layered by `override` ([D-068][d-068]). Nobody hand-writes ~20 root-input
values per script. In Flight.jl the `@kwdef` defaults of
`SystemsInitializer`, the systems initializer of its Cessna 172 model
(`c172.jl`), carry that load. Their successor is ordinary user math in one
authoritative home, such as `ready_for_taxi(ac)` or `cold_and_dark(ac)`,
returning full-coverage conditions. But "baseline plus tweaks" collides
with the duplicate-leaf error ([§14.2][s14-2]) by design. The collision
*is* the intent, and **the fourth node type,
[`override(base, patch)`](#g-override), exists for it** ([D-068][d-068]).
It is ordered and asymmetric, where [`combine`](#g-combine) is symmetric
and collision-intolerant. At resolution a leaf present in both takes the
patch's value, and the origin names both layers. Collisions *within* one
layer remain errors. Variadic layering
(`override(campaign, aircraft, todays_case)`) composes. Trim uses it on day
one. The committed condition is `override(baseline, condition(d*))`, the
solved condition over full coverage ([D-068][d-068]).
````

New:

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

## Findings not applied

- RULING, left untouched: P1-12, P1-14, P1-22, P1-23 and P1-31, and half 2's
  P2-47, which lands in unit B.
- P1-37 and P1-38 are fixed in half 2's units.
- No other half 2 finding falls in units A or B. P2-17's remark on §14.5's
  warn-but-assign is P1-30, applied.

## How the applied fixes differ from the passes' wording

- P1-1: the roadmap stays one sentence, as R1 rules, with a semicolon after
  §14.4. Boundary zero takes its P1-35 gloss as "the initialization sequence
  called boundary zero", since the sentence already holds totality's
  parenthetical.
- P1-6: the `n_eng` sentence sits at its first use, §14.2's context
  paragraph, not after line 154. `"pwp/engine"` and `"aero"` get no clause;
  the finding's fix names none.
- P1-9: in §14.2, `override`'s gloss is an appositive, since its sentence
  already holds `combine`'s parenthetical.
- P1-19: "The component exports it" stays, as R5 keeps that sentence.
- P1-21: the service-read sentence keeps "trim's `reads` or a tap". "Both
  kinds of read resolve under the one service walk" comes second in the
  inspection paragraph, right after the service paragraph it pairs with, so
  "instead" in the snapshot sentence still contrasts with bindings and
  `series`.
- P1-30: warn-but-assign names the trim of Flight.jl's Cessna 172 model
  (`c172.jl` 934–939), since the variants hold the asserts and `c172.jl`
  holds the warning.
- P1-34: "a root input no device feeds", after §11.3's "a root input unfed
  by any device" (frozen spec 7325–7326), in place of "every root input".
- P1-35, per term:
  - the opening's root input sits inside totality's gloss; a gloss there
    would nest, so it stays linked and unglossed;
  - §14.2's condition link moves off "condition method" to the empty-prefix
    paragraph, the section's first use of the value; §14.3's moves to the new
    context sentence (P1-4);
  - §14.3's schema/layout: its sentence defines schema and the next defines
    layout, so it takes no gloss;
  - §14.5's chain keeps its links; a sentence after it glosses sweep, guard,
    due and snapshot. The trace header keeps its appositive gloss, "the
    checkpoint … of the state the sequence leaves";
  - §14.5's probe link becomes `#g-probe-value`, glossed from that entry, as
    P2-13 does for §14.8's twin sentence; "the §14.6 barrier" becomes §14.6's
    name for it, the probe-value barrier;
  - to keep one parenthetical per sentence, some glosses split a sentence
    (the opening's stores, §14.1's root inputs and value-level constructor)
    or reorder it (control plane, kind, projection, device, the replay of
    §14.4).
- P1-36: A's trailing blank line goes, and every edited paragraph is
  rewrapped to 80 rendered columns.

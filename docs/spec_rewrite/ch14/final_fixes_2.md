# Chapter 14, step 6b: the final fixes, half 2 (units F, G and H)

Each entry gives the finding of `final_verify_2.md`, the unit, and the old and
new text of the edited paragraph, verbatim. Replay them in order on commit
`bfcf024`. Every edited paragraph is rewrapped to 80 rendered columns (link
markup collapsed), so the old and new blocks are whole paragraphs.

## 1. 1, unit G, from line 151 of the edited file

The gloss is the glossary's #g-probe.

Old:

````text
This is *not a new obligation*. It is the same activation linearization is
defined on. AD-readiness is also a build-checked property. A
[pinned](#g-walked) intermediate (a value held at `Float64` inside authored
continuous math) makes the Dual probe fail with a culprit-naming
`MethodError` or `InexactError` ([D-307][d-307]). `build(world; activations)`
puts the probe in CI ([D-280][d-280]). The robustness comes from enforcement,
not hope.
````

New:

````text
This is *not a new obligation*. It is the same activation linearization is defined
on. AD-readiness is also a build-checked property. A [pinned](#g-walked) intermediate (a
value held at `Float64` inside authored continuous math) makes the Dual [probe](#g-probe) (the
build's single evaluation of a user function) fail with a culprit-naming
`MethodError` or `InexactError` ([D-307][d-307]). `build(world; activations)` puts the probe in
CI ([D-280][d-280]). The robustness comes from enforcement, not hope.
````

## 2. 2, unit G, from line 228 of the edited file

Old:

````text
**A read set carries its mount chain as data** ([D-277][d-277]). A read set is a `Reads` value.
`at(prefix, read_set)` prepends the prefix to that chain and joins nothing. **A
`Reads` value is no condition node**, so `Scoped` never wraps one ([D-277][d-277]). **Resolution
walks the chain from the root**, each prefix from the level the previous one
reached ([§13.3][s13-3], [D-277][d-277]). It then rebases every [selector](#g-selector) (one of the closed family
of deferred reads) to the root before the selector resolves. A path selector's
path is joined to the mount (`"vehicle/dynamics"` → `"wing/vehicle/dynamics"`).
`get_input` names an input [face](#g-face) (the name a port wears on its [component](#g-component)'s
boundary) of the mount level. It follows the export chain to the [root input](#g-root-input) it
lands on (the root component's own input face). `get_face` names an output face of
the mount level and reads its producer's port ([D-277][d-277]).
````

New:

````text
**A read set carries its mount chain as data** ([D-277][d-277]). A read set is a `Reads` value.
`at(prefix, read_set)` prepends the prefix to the read set's mount chain and joins
nothing. **A `Reads` value is no condition node**, so `Scoped` never wraps one ([D-277][d-277]).
**Resolution walks the chain from the root**, each prefix from the level the
previous one reached ([§13.3][s13-3], [D-277][d-277]). It then rebases every [selector](#g-selector) (one of the
closed family of deferred reads) to the root before the selector resolves. A
path selector's path is joined to the mount (`"vehicle/dynamics"` →
`"wing/vehicle/dynamics"`). `get_input` names an input [face](#g-face) (the name a port wears
on its [component](#g-component)'s boundary) of the mount level. It follows the export chain to
the [root input](#g-root-input) it lands on (the root component's own input face). `get_face` names
an output face of the mount level and reads its producer's port ([D-277][d-277]).
````

## 3. 3, unit H, from line 68 of the edited file

Old:

````text
**The default operating point is the [checkpoint](#g-checkpoint)** of the simulation or the [`Model`](#g-model) (a
deployment materialized at one scalar type) as it stands ([D-274][d-274], [D-319][d-319]). A
checkpoint is the `Model`'s state at a frame top as one value. It is
`checkpoint(sim)` on a simulation and `checkpoint(model)` on a `Model`, each restored
into the scratch world with no boundary zero ([§12.6][s12-6], [D-274][d-274], [D-319][d-319]). The frozen
tier's [cells](#g-cell) (the typed entries of the signal table) are the checkpoint's held
cells. After a `trim!` commit, `linearize(sim, taps)` or `linearize(model, taps)` is
about the trim point with nothing re-specified. **`about = <condition>`, with `t0`
beside it, linearizes anywhere else without touching the sim**, its coverage
checked as [§14.6][s14-6] requires ([D-272][d-272]). `t0` is admitted only there, and a `t0` passed
without `about` is an `ArgumentInvalid`.
````

New:

````text
**The default operating point is the [checkpoint](#g-checkpoint)** of the simulation or the [`Model`](#g-model) (a
deployment materialized at one scalar type) as it stands ([D-274][d-274], [D-319][d-319]). A
checkpoint is the `Model`'s state at a frame top as one value. The default point
is `checkpoint(sim)` on a simulation and `checkpoint(model)` on a `Model`, each
restored into the scratch world with no boundary zero ([§12.6][s12-6], [D-274][d-274], [D-319][d-319]). The
frozen tier's [cells](#g-cell) (the typed entries of the signal table) are the checkpoint's
held cells. After a `trim!` commit, `linearize(sim, taps)` or `linearize(model, taps)`
is about the trim point with nothing re-specified. **`about = <condition>`, with `t0`
beside it, linearizes anywhere else without touching the sim**, its coverage
checked as [§14.6][s14-6] requires ([D-272][d-272]). `t0` is admitted only there, and a `t0` passed
without `about` is an `ArgumentInvalid`.
````

## 4. 4, unit H, from line 68 of the edited file

Old:

````text
**The default operating point is the [checkpoint](#g-checkpoint)** of the simulation or the [`Model`](#g-model) (a
deployment materialized at one scalar type) as it stands ([D-274][d-274], [D-319][d-319]). A
checkpoint is the `Model`'s state at a frame top as one value. The default point
is `checkpoint(sim)` on a simulation and `checkpoint(model)` on a `Model`, each
restored into the scratch world with no boundary zero ([§12.6][s12-6], [D-274][d-274], [D-319][d-319]). The
frozen tier's [cells](#g-cell) (the typed entries of the signal table) are the checkpoint's
held cells. After a `trim!` commit, `linearize(sim, taps)` or `linearize(model, taps)`
is about the trim point with nothing re-specified. **`about = <condition>`, with `t0`
beside it, linearizes anywhere else without touching the sim**, its coverage
checked as [§14.6][s14-6] requires ([D-272][d-272]). `t0` is admitted only there, and a `t0` passed
without `about` is an `ArgumentInvalid`.
````

New:

````text
**The default operating point is the [checkpoint](#g-checkpoint)** of the simulation or the [`Model`](#g-model) (a
deployment materialized at one scalar type) as it stands ([D-274][d-274], [D-319][d-319]). A
checkpoint is the `Model`'s state at a frame top as one value. The default point
is `checkpoint(sim)` on a simulation and `checkpoint(model)` on a `Model`, each
restored into the scratch world with no boundary zero ([§12.6][s12-6], [D-274][d-274], [D-319][d-319]). The
frozen tier's [cells](#g-cell) (the typed entries of the signal table) are the checkpoint's
held cells. After a `trim!` commit, `linearize(sim, taps)` or `linearize(model, taps)`
is about the trim point with nothing re-specified. **`about = <condition>`, with `t0`
beside it, linearizes anywhere else without touching the sim**, the condition's
coverage checked as [§14.6][s14-6] requires ([D-272][d-272]). `t0` is admitted only there, and a `t0`
passed without `about` is an `ArgumentInvalid`.
````

## 5. 5, unit H, from line 214 of the edited file

Worded as the coordinator asked: lowercase *model* is reserved.

Old:

````text
Both halves of non-participation have a spelling ([D-263][d-263]). The output half is the
freeze door, which declares a leaf frozen under differentiation as [§8.2][s8-2] and [§9.5][s9-5]
spell it ([D-286][d-286]). An opaque wrapper, such as an FMU (a Functional Mock-up Unit,
a packaged external model) or a C aerodynamic table, and a deliberately severed
coupling can therefore both say so in the schema, instead of showing up in
Jacobians as unexplained zero rows. The conformance check holds them to it at
every activation ([D-286][d-286]). The input half is the FFI door ([§8.2][s8-2]). A consumer's
`Pinned` input entry declares "never hand me partials", enforced at the wire
([§6.1][s6-1], [D-263][d-263]). At a root input, such an input entry *is* the forbid-seeding marker
itself. That marker carries semantics rather than mere protection, because it
types the root-input cell at every activation. An unseeded root input is
therefore a *choice*, where a `Pinned`-entry root input is a *declaration* ([D-295][d-295]).
````

New:

````text
Both halves of non-participation have a spelling ([D-263][d-263]). The output half is the
freeze door, which declares a leaf frozen under differentiation as [§8.2][s8-2] and [§9.5][s9-5]
spell it ([D-286][d-286]). An opaque wrapper, such as an FMU (a Functional Mock-up Unit,
a packaged simulation unit) or a C aerodynamic table, and a deliberately severed
coupling can therefore both say so in the schema, instead of showing up in
Jacobians as unexplained zero rows. The conformance check holds them to it at
every activation ([D-286][d-286]). The input half is the FFI door ([§8.2][s8-2]). A consumer's
`Pinned` input entry declares "never hand me partials", enforced at the wire
([§6.1][s6-1], [D-263][d-263]). At a root input, such an input entry *is* the forbid-seeding marker
itself. That marker carries semantics rather than mere protection, because it
types the root-input cell at every activation. An unseeded root input is
therefore a *choice*, where a `Pinned`-entry root input is a *declaration* ([D-295][d-295]).
````

## 6. 6, unit F, from line 118 of the edited file

Old:

````text
The gathered reads and the decision NamedTuple arrive as arguments. `d` is the one
value that *cannot* be closed over. `TrimParameters` stays behind the closure,
exactly as `condition` already holds it. Being user-shaped, that record is also
where any environment handles the condition math needs conventionally ride. [§8.2][s8-2]
gives the [value-level constructor](#g-value-level-constructor) that builds such a handle, a plain exported
function of the component and its input values. [§14.1][s14-1] gives the pre-sweep
doctrine. The problem *receives* the environment, and never writes it ([§14.9][s14-9]).
````

New:

````text
The gathered reads and the decision NamedTuple arrive as arguments. `d` is the one
value that *cannot* be closed over. `TrimParameters` stays behind the closure,
exactly as `condition` already holds it. Being user-shaped, that record is also
where any environment handles the condition math needs conventionally ride. [§8.2][s8-2]
gives the [value-level constructor](#g-value-level-constructor), a plain exported function of the component
and its input values, that builds such a handle. [§14.1][s14-1] gives the pre-sweep
doctrine. The problem *receives* the environment, and never writes it ([§14.9][s14-9]).
````

# Chapter 14, step 5: the editorial fixes, half 2 (units F, G and H)

Each entry gives the finding, the unit, and the old and new text of the
edited paragraph or bullet, verbatim. Replay them in order on the verified
commit `b187775`: an entry's old text is the file as the entries before it
left it. Every edited paragraph is rewrapped to 80 rendered columns (link
markup collapsed), so the old and new blocks are whole paragraphs.

The last entry, P2-18, is not a paragraph edit: it deletes the blank line
that ends `units/F/new.md`, so one blank line, not two, falls at the F/G seam
of the assembled chapter.

## 1. P2-2, unit F, from line 31 of the edited file

Old:

````text
[Worked](#g-worked), the cruise case of Flight.jl's Cessna 172 model
(`c172.jl`) reduces to its three-equation core. The real problem is the same
shape with the full 7-variable search, and the θ-constraint elimination
survives inside its condition function, which the worked problem calls
`trim_condition`.
````

New:

````text
The problem below is [worked](#g-worked) (spelled in full against a concrete case). It is the
cruise case of Flight.jl's Cessna 172 model (`c172.jl`), reduced to its
three-equation core. The real problem is the same shape with the full 7-variable
search, and the θ-constraint elimination survives inside its condition function,
which the worked problem calls `trim_condition`.
````

## 2. P2-1, unit F, from line 59 of the edited file

Old:

````text
Decision variables, initial guess and box bounds are plain, same-*named*,
all-`Float64` NamedTuples. FlightPhysics' decision-variable supertype,
`AbstractTrimState{N}`, is dropped. It is an alias of StaticArrays'
`FieldVector{N, Float64}`. Its only job was vectorization, and vectorization
is the service's ([D-069][d-069]). The service packs and unpacks by field order, and
that order is the `guess` NamedTuple's own. This [seam](#g-seam) runs on the
rule [§9.5][s9-5] states, "the names are the pairing, order carries no
semantics" ([D-151][d-151]). `lower` and `upper` are checked at setup for
key-set equality with `guess` and for `Float64` fields. They are then
canonicalized to `guess`'s field order by the same type-level reorder
(`NamedTuple{keys(guess)}(lower)`). A permuted bound spelling is therefore a
non-event, rather than `α`'s bound silently applied to `throttle`. A key-set or
field-type mismatch is `TrimProblemInvalid`. Guess, bounds and the returned
solution share one spelling, and `Base.merge(guess, (throttle = 0.3,))` is free
warm-start tweaking. An author who wants a documented `@kwdef` struct keeps it
privately and converts.
````

New:

````text
FlightPhysics' decision-variable supertype, `AbstractTrimState{N}`, is dropped. It
is an alias of StaticArrays' `FieldVector{N, Float64}`. Its only job was
vectorization, and vectorization is the service's ([D-069][d-069]). The service packs and
unpacks by field order, and that order is the `guess` NamedTuple's own. This [seam](#g-seam)
runs on the rule [§9.5][s9-5] states, "the names are the pairing, order carries no
semantics" ([D-151][d-151]). `lower` and `upper` are checked at setup for key-set equality
with `guess` and for `Float64` fields. They are then canonicalized to `guess`'s field
order by the same type-level reorder (`NamedTuple{keys(guess)}(lower)`). A
permuted bound spelling is therefore a non-event, rather than `α`'s bound silently
applied to `throttle`. A key-set or field-type mismatch is `TrimProblemInvalid`.
Guess, bounds and the returned solution share one spelling, and
`Base.merge(guess, (throttle = 0.3,))` is free warm-start tweaking. An author who
wants a documented `@kwdef` struct keeps it privately and converts.
````

## 3. P2-3, unit F, from line 120 of the edited file

Old:

````text
The gathered reads and the decision NamedTuple arrive as arguments. `d` is the
one value that *cannot* be closed over. `TrimParameters` stays behind the
closure, exactly as `condition` already holds it, and the framework never sees
it. Being user-shaped, that record is also where any environment handles the
condition math needs conventionally ride. [§8.2][s8-2] gives the
[value-level constructor](#g-value-level-constructor) (the plain exported
function building a field handle from the component and input values) that
builds such a handle, and [§14.1][s14-1] the pre-sweep doctrine. The problem
*receives* the environment, and never writes it ([§14.9][s14-9]).
````

New:

````text
The gathered reads and the decision NamedTuple arrive as arguments. `d` is the one
value that *cannot* be closed over. `TrimParameters` stays behind the closure,
exactly as `condition` already holds it. Being user-shaped, that record is also
where any environment handles the condition math needs conventionally ride. [§8.2][s8-2]
gives the [value-level constructor](#g-value-level-constructor) (the plain exported function building a field
handle from the component and input values) that builds such a handle, and [§14.1][s14-1]
the pre-sweep doctrine. The problem *receives* the environment, and never writes
it ([§14.9][s14-9]).
````

## 4. P2-4, unit F, from line 120 of the edited file

Old:

````text
The gathered reads and the decision NamedTuple arrive as arguments. `d` is the one
value that *cannot* be closed over. `TrimParameters` stays behind the closure,
exactly as `condition` already holds it. Being user-shaped, that record is also
where any environment handles the condition math needs conventionally ride. [§8.2][s8-2]
gives the [value-level constructor](#g-value-level-constructor) (the plain exported function building a field
handle from the component and input values) that builds such a handle, and [§14.1][s14-1]
the pre-sweep doctrine. The problem *receives* the environment, and never writes
it ([§14.9][s14-9]).
````

New:

````text
The gathered reads and the decision NamedTuple arrive as arguments. `d` is the one
value that *cannot* be closed over. `TrimParameters` stays behind the closure,
exactly as `condition` already holds it. Being user-shaped, that record is also
where any environment handles the condition math needs conventionally ride. [§8.2][s8-2]
gives the [value-level constructor](#g-value-level-constructor) that builds such a handle, a plain exported
function of the component and its input values. [§14.1][s14-1] gives the pre-sweep
doctrine. The problem *receives* the environment, and never writes it ([§14.9][s14-9]).
````

## 5. P2-5, unit F, from line 128 of the edited file

Old:

````text
**The returned NamedTuple's names are the equation names** the report and the
failure messages use ([D-118][d-118]). The service packs residuals and
tolerances to the solver's vector by field order. The order is `tolerances`'
field order, the declared side again, canonical for the r-side. Each residual
return is reordered to it (`NamedTuple{keys(tolerances)}(r)`) before packing
([D-151][d-151]). An equation list spelled in a different order inside the
lambda therefore pairs correctly and costs nothing. The decisions rule holds
symmetrically on both ends of the seam. Names pair, and order never does.
Names and types are checked at setup, because the guess evaluation the service
performs anyway observes the residual key set. A `tolerances` key-set
mismatch, or any field-type disagreement on either side of the seam, is
`TrimProblemInvalid` ([Appendix C][sC]), with the offending field and the
names or types in hand. Order is never a mismatch.
````

New:

````text
**The returned NamedTuple's names are the equation names** the report and the
failure messages use ([D-118][d-118]). The service packs residuals and tolerances to the
solver's vector by field order. The order is `tolerances`' field order, the
declared side again, canonical for the residuals. Each residual return is
reordered to it (`NamedTuple{keys(tolerances)}(r)`) before packing ([D-151][d-151]). An
equation list spelled in a different order inside the lambda therefore pairs
correctly and costs nothing. The decisions rule holds symmetrically on both ends
of the seam. Names pair, and order never does. Names and types are checked at
setup, because the guess evaluation the service performs anyway observes the
residual key set. A `tolerances` key-set mismatch, or any field-type disagreement
on either side of the seam, is `TrimProblemInvalid` ([Appendix C][sC]), with the
offending field and the names or types in hand. Order is never a mismatch.
````

## 6. P2-7, unit F, from line 219 of the edited file

Old:

````text
The signature is
`trim!(model, problem; baseline, t0 = 0.0, backend = LevenbergMarquardt())`,
where `model` is a [`Model`](#g-model) (a deployment materialized at one
scalar type) at `Float64` ([D-319][d-319]). A `Model` at another scalar is
refused as `ArgumentInvalid` with reason `:non_nominal` ([D-319][d-319]). A
model that a simulation has claimed is refused before any check, as
`ArgumentInvalid` with reason `:claimed`, since the call commits
([D-318][d-318], [D-319][d-319]). The `baseline` keyword takes a [baseline](#g-baseline) (an
aircraft-shipped, full-coverage condition function). `trim!(sim, problem; …)`
gates on the simulation's lifecycle and commits through the simulation's
`init!`.
````

New:

````text
The signature is
`trim!(model, problem; baseline, t0 = 0.0, backend = LevenbergMarquardt())`, where
`model` is a [`Model`](#g-model) (a deployment materialized at one scalar type) at `Float64`
([D-319][d-319]). A `Model` at another scalar is refused as `ArgumentInvalid` with reason
`:non_nominal` ([D-319][d-319]). A `Model` that a simulation has claimed is refused before
any check, as `ArgumentInvalid` with reason `:claimed`, since the call commits
([D-318][d-318], [D-319][d-319]). The `baseline` keyword takes a [baseline](#g-baseline) (an aircraft-shipped,
full-coverage condition function). `trim!(sim, problem; …)` gates on the
simulation's lifecycle and commits through the simulation's `init!`.
````

## 7. P2-8, unit F, from line 219 of the edited file

Old:

````text
The signature is
`trim!(model, problem; baseline, t0 = 0.0, backend = LevenbergMarquardt())`, where
`model` is a [`Model`](#g-model) (a deployment materialized at one scalar type) at `Float64`
([D-319][d-319]). A `Model` at another scalar is refused as `ArgumentInvalid` with reason
`:non_nominal` ([D-319][d-319]). A `Model` that a simulation has claimed is refused before
any check, as `ArgumentInvalid` with reason `:claimed`, since the call commits
([D-318][d-318], [D-319][d-319]). The `baseline` keyword takes a [baseline](#g-baseline) (an aircraft-shipped,
full-coverage condition function). `trim!(sim, problem; …)` gates on the
simulation's lifecycle and commits through the simulation's `init!`.
````

New:

````text
The signature is
`trim!(model, problem; baseline, t0 = 0.0, backend = LevenbergMarquardt())`, where
`model` is a [`Model`](#g-model) (a deployment materialized at one scalar type) at `Float64`
([D-319][d-319]). A `Model` at another scalar is refused as `ArgumentInvalid` with reason
`:non_nominal` ([D-319][d-319]). A `Model` that a simulation has claimed is refused before
any check, as `ArgumentInvalid` with reason `:claimed`, since the call commits
([D-318][d-318], [D-319][d-319]). The `baseline` keyword takes a [baseline](#g-baseline) (a full-coverage
condition, such as an aircraft-shipped function returns). `trim!(sim, problem; …)`
gates on the simulation's lifecycle and commits through the simulation's `init!`.
````

## 8. P2-9, unit F, from line 244 of the edited file

Old:

````text
`eval!(r, J, d)` is in-place and always fills `r`, the residual vector packed
in `tolerances`' field order. It fills `J` iff `J !== nothing`. The Jacobian is
requested by argument, so a Jacobian-free backend simply always passes
`nothing`, and there is still exactly one evaluation method to implement.
````

New:

````text
`eval!(r, J, d)` is in-place and always fills `r`, the residual vector packed in
`tolerances`' field order. It fills `J` exactly when `J !== nothing`. The Jacobian is
requested by argument, so a Jacobian-free backend simply always passes `nothing`,
and there is still exactly one evaluation method to implement.
````

## 9. P2-9, unit F, from line 279 of the edited file

LM is introduced at its first use in §14.8; the bold at the default-backend sentence is left untouched.

Old:

````text
The tolerance translation is the service's too, per backend family
([D-150][d-150]). In least-squares backends the tolerances *are* the stopping
criterion. They feed the per-residual test directly, so LM's damping loop tests
exactly what the service will re-test.
````

New:

````text
The tolerance translation is the service's too, per backend family ([D-150][d-150]). In
least-squares backends the tolerances *are* the stopping criterion. They feed the
per-residual test directly, so the damping loop of Levenberg–Marquardt (LM)
tests exactly what the service will re-test.
````

## 10. P2-10, unit F, from line 284 of the edited file

Rewrap only.

Old:

````text
The derivative-free fallback is designed and not yet built, and `pending.md`
lists it ([D-070][d-070]). In the design it is `NLoptBackend(:LN_BOBYQA)` in a
package extension. It would pass `nothing` for the Jacobian, keep Flight.jl's
algorithm one keyword away, and leave the framework core carrying zero
optimizer dependencies. For that fallback the service would square *and
normalize*. The objective minimized would be $\sum_i (r_i/\mathit{tol}_i)^2$
with `stopval = 1`. That objective is dimensionless where the threshold
in Flight.jl's Cessna 172 model (`c172.jl`) was hand-scaled and absolute ([§14.7][s14-7]). It is a well-scaled
valley where a raw $\|r\|^2$ sums forces against moments.
````

New:

````text
The derivative-free fallback is designed and not yet built, and `pending.md` lists
it ([D-070][d-070]). In the design it is `NLoptBackend(:LN_BOBYQA)` in a package extension.
It would pass `nothing` for the Jacobian, keep Flight.jl's algorithm one keyword
away, and leave the framework core carrying zero optimizer dependencies. For
that fallback the service would square *and normalize*. The objective minimized
would be $\sum_i (r_i/\mathit{tol}_i)^2$ with `stopval = 1`. That objective is
dimensionless where the threshold in Flight.jl's Cessna 172 model (`c172.jl`) was
hand-scaled and absolute ([§14.7][s14-7]). It is a well-scaled valley where a raw
$\|r\|^2$ sums forces against moments.
````

## 11. P2-10, unit F, from line 310 of the edited file

Rewrap only.

Old:

````text
**Box bounds are honored by step projection** ([D-070][d-070]). A decision
variable saturated *at the solution* is listed in the report's saturated list,
as `(:elevator, :upper)`. That is the classic CG-limit diagnostic (CG is the
center of gravity), which Flight.jl's trim leaves inferable only from mysterious residuals.
````

New:

````text
**Box bounds are honored by step projection** ([D-070][d-070]). A decision variable saturated
*at the solution* is listed in the report's saturated list, as
`(:elevator, :upper)`. That is the classic CG-limit diagnostic (CG is the center
of gravity), which Flight.jl's trim leaves inferable only from mysterious
residuals.
````

## 12. P2-12, unit F, from line 318 of the edited file

Old:

````text
Every `trim!` invocation instantiates a fresh working store set. Each half of
it (below) is a scratch `Model` of its own, materialized from the deployment
the service was called on ([D-317][d-317], [D-319][d-319]). The set holds the
`x` backing, the `s` and `m` stores, the [root input](#g-root-input) and
[signal tables](#g-signal-table), and the derivative [buffer](#g-buffer). The
set is built from the [activation](#g-activation)'s *layout* (the build's typed
products at a given scalar type). The layout is the reusable compiled
artifact. The buffers are per-invocation and die with the call (stopped-sim
allocation, [§9.8][s9-8]). Each set also calls every
[workspace](#g-workspace) (component-declared mutable scratch, arriving as
`ws`) allocator once, at the activation's scalar ([D-077][d-077]).
````

New:

````text
Every `trim!` invocation instantiates a fresh working store set. Each half of it
(below) is a scratch `Model` of its own, materialized from the deployment the
service was called on ([D-317][d-317], [D-319][d-319]). The set holds the `x` backing, the `s` and `m`
stores, the [root input](#g-root-input) and [signal tables](#g-signal-table), and the derivative [buffer](#g-buffer). The set is
built from the *layout* of the [activation](#g-activation) (the build's typed products at a given
scalar type). The layout is the reusable compiled artifact. The buffers are
per-invocation and die with the call (stopped-sim allocation, [§9.8][s9-8]). Each set
also calls every [workspace](#g-workspace) (component-declared mutable scratch, arriving as `ws`)
allocator once, at the activation's scalar ([D-077][d-077]).
````

## 13. P2-49, unit F, from line 345 of the edited file

Old:

````text
**The frozen cells are established, not probe-seeded** ([D-213][d-213]). At the
seeded activation the discrete [tier](#g-tier) is frozen ([§9.4][s9-4]). Its
stages never run there, so nothing at that activation can derive a discrete
output cell from the authored `s`. Setup therefore instantiates the scratch set
in two halves. A [nominal](#g-nominal) set (one at the `Float64` activation)
takes the composite first, by the dynamic walk ([§14.4][s14-4]), and runs one
establishment round. That round is boundary zero's sweep with every discrete
output stage admitted, due or not ([D-205][d-205]), with no
[projection](#g-projection), no [guards](#g-guard) and no `s_update`. The
seeded set is then written by the specialized `apply!`. Its frozen cells are
copied from the nominal set, `Float64` values that a continuous consumer reads
as zero-partial constants ([§9.5][s9-5]). Every cell the iterations read is
thus derived from the authored world. A frozen cell holds what the authored
discrete state publishes, which makes "held at the operating point" literal.
No scratch cell holds the [probe](#g-probe)'s synthesized values. That is the
[§14.6][s14-6] barrier reaching the scratch world, as [D-205][d-205] made it
reach the published one. The iterations are untouched. They are raw write →
sweep → read cycles at the seeded activation, over the continuous chain and
`x_deriv` alone ([§14.5][s14-5]). The zero-decision problem (below) is the
nominal half alone ([D-213][d-213]). Its one evaluation is that establishment
round, followed by one derivative evaluation for the reads.
````

New:

````text
**The frozen cells are established, not probe-seeded** ([D-213][d-213]). At the seeded
activation the discrete [tier](#g-tier) (the discrete side of the hybrid formalism) is
frozen ([§9.4][s9-4]). Its stages never run there, so nothing at that activation can
derive a discrete output cell from the authored `s`. Setup therefore instantiates
the scratch set in two halves. A [nominal](#g-nominal) set (one at the `Float64` activation)
takes the composite first, by the dynamic walk ([§14.4][s14-4]), and runs one
establishment round. That round is boundary zero's sweep with every discrete
output stage admitted, due or not ([D-205][d-205]), with no [projection](#g-projection), no [guards](#g-guard) and no
`s_update`. The seeded set is then written by the specialized `apply!`. Its frozen
cells are copied from the nominal set, `Float64` values that a continuous consumer
reads as zero-partial constants ([§9.5][s9-5]). Every cell the iterations read is thus
derived from the authored world. A frozen cell holds what the authored discrete
state publishes, which makes "held at the operating point" literal. No scratch
cell holds the [probe](#g-probe)'s synthesized values. That is the [§14.6][s14-6] barrier reaching
the scratch world, as [D-205][d-205] made it reach the published one. The iterations are
untouched. They are raw write → sweep → read cycles at the seeded activation,
over the continuous chain and `x_deriv` alone ([§14.5][s14-5]). The zero-decision problem
(below) is the nominal half alone ([D-213][d-213]). Its one evaluation is that
establishment round, followed by one derivative evaluation for the reads.
````

## 14. P2-49, unit F, from line 345 of the edited file

Old:

````text
**The frozen cells are established, not probe-seeded** ([D-213][d-213]). At the seeded
activation the discrete [tier](#g-tier) (the discrete side of the hybrid formalism) is
frozen ([§9.4][s9-4]). Its stages never run there, so nothing at that activation can
derive a discrete output cell from the authored `s`. Setup therefore instantiates
the scratch set in two halves. A [nominal](#g-nominal) set (one at the `Float64` activation)
takes the composite first, by the dynamic walk ([§14.4][s14-4]), and runs one
establishment round. That round is boundary zero's sweep with every discrete
output stage admitted, due or not ([D-205][d-205]), with no [projection](#g-projection), no [guards](#g-guard) and no
`s_update`. The seeded set is then written by the specialized `apply!`. Its frozen
cells are copied from the nominal set, `Float64` values that a continuous consumer
reads as zero-partial constants ([§9.5][s9-5]). Every cell the iterations read is thus
derived from the authored world. A frozen cell holds what the authored discrete
state publishes, which makes "held at the operating point" literal. No scratch
cell holds the [probe](#g-probe)'s synthesized values. That is the [§14.6][s14-6] barrier reaching
the scratch world, as [D-205][d-205] made it reach the published one. The iterations are
untouched. They are raw write → sweep → read cycles at the seeded activation,
over the continuous chain and `x_deriv` alone ([§14.5][s14-5]). The zero-decision problem
(below) is the nominal half alone ([D-213][d-213]). Its one evaluation is that
establishment round, followed by one derivative evaluation for the reads.
````

New:

````text
**The frozen cells are established, not probe-seeded** ([D-213][d-213]). At the seeded
activation the discrete [tier](#g-tier) (the discrete side of the hybrid formalism) is
frozen ([§9.4][s9-4]). Its stages never run there, so nothing at that activation can
derive a discrete output cell from the authored `s`. Setup therefore instantiates
the scratch set in two halves. A [nominal](#g-nominal) set (one at the `Float64` activation)
takes the composite first, by the dynamic walk ([§14.4][s14-4]), and runs one
establishment round. That round is boundary zero's sweep with every discrete
output stage admitted, due or not ([D-205][d-205]), with no [projection](#g-projection) (the per-component
`x_projection` hook), no [guards](#g-guard) and no `s_update`. The seeded set is then written by
the specialized `apply!`. Its frozen cells are copied from the nominal set,
`Float64` values that a continuous consumer reads as zero-partial constants
([§9.5][s9-5]). Every cell the iterations read is thus derived from the authored world.
A frozen cell holds what the authored discrete state publishes, which makes
"held at the operating point" literal. No scratch cell holds the [probe](#g-probe)'s
synthesized values. That is the [§14.6][s14-6] barrier reaching the scratch world, as
[D-205][d-205] made it reach the published one. The iterations are untouched. They are
raw write → sweep → read cycles at the seeded activation, over the continuous
chain and `x_deriv` alone ([§14.5][s14-5]). The zero-decision problem (below) is the
nominal half alone ([D-213][d-213]). Its one evaluation is that establishment round,
followed by one derivative evaluation for the reads.
````

## 15. P2-13, unit F, from line 345 of the edited file

Old:

````text
**The frozen cells are established, not probe-seeded** ([D-213][d-213]). At the seeded
activation the discrete [tier](#g-tier) (the discrete side of the hybrid formalism) is
frozen ([§9.4][s9-4]). Its stages never run there, so nothing at that activation can
derive a discrete output cell from the authored `s`. Setup therefore instantiates
the scratch set in two halves. A [nominal](#g-nominal) set (one at the `Float64` activation)
takes the composite first, by the dynamic walk ([§14.4][s14-4]), and runs one
establishment round. That round is boundary zero's sweep with every discrete
output stage admitted, due or not ([D-205][d-205]), with no [projection](#g-projection) (the per-component
`x_projection` hook), no [guards](#g-guard) and no `s_update`. The seeded set is then written by
the specialized `apply!`. Its frozen cells are copied from the nominal set,
`Float64` values that a continuous consumer reads as zero-partial constants
([§9.5][s9-5]). Every cell the iterations read is thus derived from the authored world.
A frozen cell holds what the authored discrete state publishes, which makes
"held at the operating point" literal. No scratch cell holds the [probe](#g-probe)'s
synthesized values. That is the [§14.6][s14-6] barrier reaching the scratch world, as
[D-205][d-205] made it reach the published one. The iterations are untouched. They are
raw write → sweep → read cycles at the seeded activation, over the continuous
chain and `x_deriv` alone ([§14.5][s14-5]). The zero-decision problem (below) is the
nominal half alone ([D-213][d-213]). Its one evaluation is that establishment round,
followed by one derivative evaluation for the reads.
````

New:

````text
**The frozen cells are established, not probe-seeded** ([D-213][d-213]). At the seeded
activation the discrete [tier](#g-tier) (the discrete side of the hybrid formalism) is
frozen ([§9.4][s9-4]). Its stages never run there, so nothing at that activation can
derive a discrete output cell from the authored `s`. Setup therefore instantiates
the scratch set in two halves. A [nominal](#g-nominal) set (one at the `Float64` activation)
takes the composite first, by the dynamic walk ([§14.4][s14-4]), and runs one
establishment round. That round is boundary zero's sweep with every discrete
output stage admitted, due or not ([D-205][d-205]), with no [projection](#g-projection) (the per-component
`x_projection` hook), no [guards](#g-guard) and no `s_update`. The seeded set is then written by
the specialized `apply!`. Its frozen cells are copied from the nominal set,
`Float64` values that a continuous consumer reads as zero-partial constants
([§9.5][s9-5]). Every cell the iterations read is thus derived from the authored world.
A frozen cell holds what the authored discrete state publishes, which makes
"held at the operating point" literal. No scratch cell holds a synthesized
[probe value](#g-probe-value) (a fabricated value a build-time probe runs on). That is the
probe-value barrier of [§14.6][s14-6] reaching the scratch world, as [D-205][d-205] made it reach
the published one. The iterations are untouched. They are raw write → sweep →
read cycles at the seeded activation, over the continuous chain and `x_deriv`
alone ([§14.5][s14-5]). The zero-decision problem (below) is the nominal half alone
([D-213][d-213]). Its one evaluation is that establishment round, followed by one
derivative evaluation for the reads.
````

## 16. P1-37, unit F, from line 345 of the edited file

"At the seeded activation" stays: §14.5 says only "on the activation".

Old:

````text
**The frozen cells are established, not probe-seeded** ([D-213][d-213]). At the seeded
activation the discrete [tier](#g-tier) (the discrete side of the hybrid formalism) is
frozen ([§9.4][s9-4]). Its stages never run there, so nothing at that activation can
derive a discrete output cell from the authored `s`. Setup therefore instantiates
the scratch set in two halves. A [nominal](#g-nominal) set (one at the `Float64` activation)
takes the composite first, by the dynamic walk ([§14.4][s14-4]), and runs one
establishment round. That round is boundary zero's sweep with every discrete
output stage admitted, due or not ([D-205][d-205]), with no [projection](#g-projection) (the per-component
`x_projection` hook), no [guards](#g-guard) and no `s_update`. The seeded set is then written by
the specialized `apply!`. Its frozen cells are copied from the nominal set,
`Float64` values that a continuous consumer reads as zero-partial constants
([§9.5][s9-5]). Every cell the iterations read is thus derived from the authored world.
A frozen cell holds what the authored discrete state publishes, which makes
"held at the operating point" literal. No scratch cell holds a synthesized
[probe value](#g-probe-value) (a fabricated value a build-time probe runs on). That is the
probe-value barrier of [§14.6][s14-6] reaching the scratch world, as [D-205][d-205] made it reach
the published one. The iterations are untouched. They are raw write → sweep →
read cycles at the seeded activation, over the continuous chain and `x_deriv`
alone ([§14.5][s14-5]). The zero-decision problem (below) is the nominal half alone
([D-213][d-213]). Its one evaluation is that establishment round, followed by one
derivative evaluation for the reads.
````

New:

````text
**The frozen cells are established, not probe-seeded** ([D-213][d-213]). At the seeded
activation the discrete [tier](#g-tier) (the discrete side of the hybrid formalism) is
frozen ([§9.4][s9-4]). Its stages never run there, so nothing at that activation can
derive a discrete output cell from the authored `s`. Setup therefore instantiates
the scratch set in two halves. A [nominal](#g-nominal) set (one at the `Float64` activation)
takes the composite first, by the dynamic walk ([§14.4][s14-4]), and runs one
establishment round. That round is boundary zero's sweep with every discrete
output stage admitted, due or not ([D-205][d-205]), with no [projection](#g-projection) (the per-component
`x_projection` hook), no [guards](#g-guard) and no `s_update`. The seeded set is then written by
the specialized `apply!`. Its frozen cells are copied from the nominal set,
`Float64` values that a continuous consumer reads as zero-partial constants
([§9.5][s9-5]). Every cell the iterations read is thus derived from the authored world.
A frozen cell holds what the authored discrete state publishes, which makes
"held at the operating point" literal. No scratch cell holds a synthesized
[probe value](#g-probe-value) (a fabricated value a build-time probe runs on). That is the
probe-value barrier of [§14.6][s14-6] reaching the scratch world, as [D-205][d-205] made it reach
the published one. The iterations are untouched ([§14.5][s14-5]). They run at the seeded
activation, over the continuous chain and `x_deriv` alone. The zero-decision
problem (below) is the nominal half alone ([D-213][d-213]). Its one evaluation is that
establishment round, followed by one derivative evaluation for the reads.
````

## 17. P2-14, unit F, from line 345 of the edited file

Old:

````text
**The frozen cells are established, not probe-seeded** ([D-213][d-213]). At the seeded
activation the discrete [tier](#g-tier) (the discrete side of the hybrid formalism) is
frozen ([§9.4][s9-4]). Its stages never run there, so nothing at that activation can
derive a discrete output cell from the authored `s`. Setup therefore instantiates
the scratch set in two halves. A [nominal](#g-nominal) set (one at the `Float64` activation)
takes the composite first, by the dynamic walk ([§14.4][s14-4]), and runs one
establishment round. That round is boundary zero's sweep with every discrete
output stage admitted, due or not ([D-205][d-205]), with no [projection](#g-projection) (the per-component
`x_projection` hook), no [guards](#g-guard) and no `s_update`. The seeded set is then written by
the specialized `apply!`. Its frozen cells are copied from the nominal set,
`Float64` values that a continuous consumer reads as zero-partial constants
([§9.5][s9-5]). Every cell the iterations read is thus derived from the authored world.
A frozen cell holds what the authored discrete state publishes, which makes
"held at the operating point" literal. No scratch cell holds a synthesized
[probe value](#g-probe-value) (a fabricated value a build-time probe runs on). That is the
probe-value barrier of [§14.6][s14-6] reaching the scratch world, as [D-205][d-205] made it reach
the published one. The iterations are untouched ([§14.5][s14-5]). They run at the seeded
activation, over the continuous chain and `x_deriv` alone. The zero-decision
problem (below) is the nominal half alone ([D-213][d-213]). Its one evaluation is that
establishment round, followed by one derivative evaluation for the reads.
````

New:

````text
**The frozen cells are established, not probe-seeded** ([D-213][d-213]). At the seeded
activation the discrete [tier](#g-tier) (the discrete side of the hybrid formalism) is
frozen ([§9.4][s9-4]). Its stages never run there, so nothing at that activation can
derive a discrete output cell from the authored `s`. Setup therefore instantiates
the scratch set in two halves. A [nominal](#g-nominal) set (one at the `Float64` activation)
takes the composite first, by the dynamic walk ([§14.4][s14-4]), and runs one
establishment round. That round is boundary zero's sweep with every discrete
output stage admitted, due or not ([D-205][d-205]), with no [projection](#g-projection) (the per-component
`x_projection` hook), no [guards](#g-guard) and no `s_update`. The seeded set is then written by
the specialized `apply!`. Its frozen cells are copied from the nominal set,
`Float64` values that a continuous consumer reads as zero-partial constants
([§9.5][s9-5]). Every cell the iterations read is thus derived from the authored world.
A frozen cell holds what the authored discrete state publishes, which makes
"held at the operating point" literal. No scratch cell holds a synthesized
[probe value](#g-probe-value) (a fabricated value a build-time probe runs on). That is the
probe-value barrier of [§14.6][s14-6] reaching the scratch world, as [D-205][d-205] made it reach
the published one. The iterations are untouched ([§14.5][s14-5]). They run at the seeded
activation, over the continuous chain and `x_deriv` alone. The empty problem
(below) is the nominal half alone ([D-213][d-213]). Its one evaluation is that
establishment round, followed by one derivative evaluation for the reads.
````

## 18. P2-15, unit F, from line 366 of the edited file

Fitted: "(below)" sits on "the commit", which "The commit, in full" states, not on `baseline`.

Old:

````text
The commit applies the same composite over the same `baseline`
(`override(baseline, condition(d*))`, [§14.9][s14-9]), so its coverage is
setup's. Commit's totality check is therefore structurally unfailable through
the trim path, and it stands as the shared `init!` defense ([D-149][d-149]). A
converged solve is always committable. `TrimReport` therefore carries no
committed flag, and the no-throw doctrine needs no exception.
````

New:

````text
The commit (below) applies the same composite over the same `baseline`, so its
coverage is setup's. Commit's totality check is therefore structurally
unfailable through the trim path, and it stands as the shared `init!` defense
([D-149][d-149]). A converged solve is always committable. `TrimReport` therefore carries
no committed flag, and the no-throw doctrine needs no exception.
````

## 19. P2-16, unit F, from line 366 of the edited file

Old:

````text
The commit (below) applies the same composite over the same `baseline`, so its
coverage is setup's. Commit's totality check is therefore structurally
unfailable through the trim path, and it stands as the shared `init!` defense
([D-149][d-149]). A converged solve is always committable. `TrimReport` therefore carries
no committed flag, and the no-throw doctrine needs no exception.
````

New:

````text
The commit (below) applies the same composite over the same `baseline`, so its
coverage is setup's. Commit's totality check is therefore structurally
unfailable through the trim path, and it stands as the shared `init!` defense
([D-149][d-149]). A converged solve is always committable. `TrimReport` therefore carries
no committed flag, and the no-throw rule (below) needs no exception.
````

## 20. P2-17, unit F, from line 372 of the edited file

Checked ~/.julia/dev/Flight.jl/lib/FlightApps/src/c172/c172.jl 934-939: @warn on a failed optimization, then AircraftBase.assign!.

Old:

````text
Iterations rewrite the composite's write-set via the compiled plan. The
write-set is `override(baseline, condition(d))`, the same tree setup resolved,
so a store both layers touch merges exactly as it did at setup. An LM
evaluation is one Dual-seeded sweep yielding `r` from the value parts and `J`
from the partials, together ([D-069][d-069]). No convergence means no commit.
Non-convergence is the service's box test failing at the returned point,
whatever status the backend attached to it ([D-150][d-150]). No commit means
the sim is bit-for-bit untouched, including "never initialized". Flight.jl's
warn-but-assign is structurally impossible.
````

New:

````text
Iterations rewrite the composite's write-set via the compiled plan. The
write-set is `override(baseline, condition(d))`, the same tree setup resolved, so
a store both layers touch merges exactly as it did at setup. An LM evaluation is
one Dual-seeded sweep yielding `r` from the value parts and `J` from the partials,
together ([D-069][d-069]). No convergence means no commit. Non-convergence is the
service's box test failing at the returned point, whatever status the backend
attached to it ([D-150][d-150]). No commit means the sim is bit-for-bit untouched,
including "never initialized". Flight.jl's warn-but-assign, where the Cessna 172
trim warns on a failed optimization and assigns its result anyway, is
structurally impossible.
````

## 21. P2-19, unit G, from line 17 of the edited file

Old:

````text
A fresh recording that starts at its own anchor is the natural shape of
unattended mode. Trim is not offered at a point reached by flying. It takes
an authored baseline. Fly-then-retrim is spelled as a `checkpoint` of the
flight, then a trim baseline authored from what the
[checkpoint](#g-checkpoint) (the `Model`'s state at a frame top as one value)
shows ([D-273][d-273]).
````

New:

````text
A fresh recording that starts at its own anchor is the natural shape of an
[unattended run](#g-unattended-run) (a run with empty staging and no snapshot readers). Trim is not
offered at a point reached by flying. It takes an authored baseline.
Fly-then-retrim is spelled as a `checkpoint` of the flight, then a trim baseline
authored from what the [checkpoint](#g-checkpoint) (the `Model`'s state at a frame top as one
value) shows ([D-273][d-273]).
````

## 22. P2-20, unit G, from line 17 of the edited file

Old:

````text
A fresh recording that starts at its own anchor is the natural shape of an
[unattended run](#g-unattended-run) (a run with empty staging and no snapshot readers). Trim is not
offered at a point reached by flying. It takes an authored baseline.
Fly-then-retrim is spelled as a `checkpoint` of the flight, then a trim baseline
authored from what the [checkpoint](#g-checkpoint) (the `Model`'s state at a frame top as one
value) shows ([D-273][d-273]).
````

New:

````text
A fresh recording that starts at its own anchor is the natural shape of an
[unattended run](#g-unattended-run) (a run with empty staging and no snapshot readers). Trim is not
offered at a point reached by flying. It takes an authored baseline.
Fly-then-retrim is spelled as a [checkpoint](#g-checkpoint) (the `Model`'s state at a frame top as
one value) of the flight, then a trim baseline authored from what the checkpoint
shows ([D-273][d-273]).
````

## 23. P2-22, unit G, from line 71 of the edited file

The phase gloss is the glossary's ("a schedule's offset against its grid").

Old:

````text
The committed-state residuals are nearly free ([D-155][d-155]). Boundary
zero's sweep has already run, so the residuals' declared reads need one
derivative evaluation and a gather from it. There is no offset caveat to
carry. Every output stage publishes at boundary zero ([D-205][d-205],
[§14.5][s14-5]). A residual reading the [port](#g-port) (one declared name,
one cell) of an offset [component](#g-component) therefore reads a
commit-refreshed cell like any other. Those committed-state residuals are the
numbers describing the state the simulation is actually *in*, which is the
point a `linearize` at its default operating point reads.
````

New:

````text
The committed-state residuals are nearly free ([D-155][d-155]). Boundary zero's sweep has
already run, so the residuals' declared reads need one derivative evaluation and
a gather from it. There is no offset caveat to carry. Every output stage
publishes at boundary zero ([D-205][d-205], [§14.5][s14-5]). A residual reading the [port](#g-port) (one
declared name, one cell) of a [component](#g-component) whose schedule has a nonzero [phase](#g-phase) (an
offset against its grid) therefore reads a commit-refreshed cell like any other.
Those committed-state residuals are the numbers describing the state the
simulation is actually *in*, which is the point a `linearize` at its default
operating point reads.
````

## 24. P2-23, unit G, from line 71 of the edited file

Old:

````text
The committed-state residuals are nearly free ([D-155][d-155]). Boundary zero's sweep has
already run, so the residuals' declared reads need one derivative evaluation and
a gather from it. There is no offset caveat to carry. Every output stage
publishes at boundary zero ([D-205][d-205], [§14.5][s14-5]). A residual reading the [port](#g-port) (one
declared name, one cell) of a [component](#g-component) whose schedule has a nonzero [phase](#g-phase) (an
offset against its grid) therefore reads a commit-refreshed cell like any other.
Those committed-state residuals are the numbers describing the state the
simulation is actually *in*, which is the point a `linearize` at its default
operating point reads.
````

New:

````text
The committed-state residuals are nearly free ([D-155][d-155]). Boundary zero's sweep has
already run, so the residuals' declared reads need one derivative evaluation and
a gather from it. There is no offset caveat to carry. Every output stage
publishes at boundary zero ([D-205][d-205], [§14.5][s14-5]). A residual reading the [port](#g-port) (one
declared name, one cell) of a [component](#g-component) whose schedule has a nonzero [phase](#g-phase) (an
offset against its grid) therefore reads a commit-refreshed cell like any other.
Those committed-state residuals are the numbers describing the state the
simulation is actually *in*, which is the point a `linearize` at its default
operating point ([§14.10][s14-10]) reads.
````

## 25. P2-23, unit G, from line 81 of the edited file

Fitted: the dictated "the point it reads" leaves "it" with no antecedent.

Old:

````text
A non-empty fired-event set also raises `TrimCommitEvents` ([Appendix C][sC],
[D-126][d-126]). The committed stores then sit at the post-handler point, not
the reported solution, and a `linearize` at its default operating point
([§14.10][s14-10]) reads that point.
````

New:

````text
A non-empty fired-event set also raises `TrimCommitEvents` ([Appendix C][sC], [D-126][d-126]).
The committed stores then sit at the post-handler point, not the reported
solution, and that is the point `linearize` reads by default.
````

## 26. P2-25, unit G, from line 85 of the edited file

Old:

````text
The two residual sets are what make the moved point auditable. **A converged
solve whose committed-state residuals violate the box test raises
`TrimCommitResiduals`**, naming the offending residuals with their committed
values and tolerances ([Appendix C][sC], [D-155][d-155]). The move, whether
`x_projection` or a commit-fired handler ([§14.5][s14-5]), is surfaced rather
than left silent. The verdict itself is not revisited. It gated the commit,
at the solved point, and the numbers ([D-150][d-150]) stand as reported.
````

New:

````text
The two residual sets are what make the moved point auditable. **A converged solve
whose committed-state residuals violate the box test raises `TrimCommitResiduals`**,
naming the offending residuals with their committed values and tolerances
([Appendix C][sC], [D-155][d-155]). The move, whether `x_projection` or a commit-fired handler
([§14.5][s14-5]), is surfaced rather than left silent. The verdict itself is not
revisited. It gated the commit at the solved point, and the numbers stand as
reported ([D-150][d-150]).
````

## 27. P2-26, unit G, from line 103 of the edited file

Fitted: the dictated "a sweep of trims" would bring back *sweep*, which F66 took out of this sentence.

Old:

````text
**Non-convergence never throws** ([D-070][d-070]). It is an expected
*outcome*, not broken machinery ([§13.5][s13-5]). In an envelope of trims,
hitting the infeasible edge is information.
````

New:

````text
**Non-convergence never throws** ([D-070][d-070]). It is an expected *outcome*, not broken
machinery ([§13.5][s13-5]). When trims span the flight envelope, hitting the infeasible
edge is information.
````

## 28. P2-13, unit G, from line 133 of the edited file

Also P2-14 ("the empty problem").

Old:

````text
An *empty* problem is none of them either. **`TrimProblem(guess = (;), …)` is
legal**, not `TrimProblemInvalid` ([D-156][d-156]). With zero decision
variables the solver is bypassed outright. There is nothing to pack, no
seeded activation and no backend call. The service simply evaluates the
residuals once at `override(baseline, condition((;)))`, the baseline with
whatever the problem's condition sets. The ordinary box test decides
`converged`, and the commit runs as usual. The degenerate problem is the "is
this operating point an equilibrium?" probe. It evaluates this condition's
equations and reports, which is useful in its own right and free.
````

New:

````text
An *empty* problem is none of them either. **`TrimProblem(guess = (;), …)` is legal**,
not `TrimProblemInvalid` ([D-156][d-156]). With zero decision variables the solver is
bypassed outright. There is nothing to pack, no seeded activation and no backend
call. The service simply evaluates the residuals once at
`override(baseline, condition((;)))`, the baseline with whatever the problem's
condition sets. The ordinary box test decides `converged`, and the commit runs as
usual. The empty problem asks "is this operating point an equilibrium?" It
evaluates this condition's equations and reports, which is useful in its own
right and free.
````

## 29. P2-11, unit G, from line 160 of the edited file

Fitted to R15, which introduces the audit as Flight.jl's Cessna 172 model: only the repeated (`c172.jl`) goes.

Old:

````text
A migration audit of Flight.jl's Cessna 172 model (`c172.jl`) against this
obligation took one afternoon. Its findings on tables and saturations follow
([D-070][d-070]), and its two Flight.jl-only findings, on the landing gear and the
`norm`-at-zero guards, are in the `migration_outline.md` companion.
````

New:

````text
A migration audit of Flight.jl's Cessna 172 model against this obligation took
one afternoon. Its findings on tables and saturations follow ([D-070][d-070]), and its
two Flight.jl-only findings, on the landing gear and the `norm`-at-zero guards,
are in the `migration_outline.md` companion.
````

## 30. P2-27, unit G, from line 165 of the edited file

Old:

````text
- `Interpolations.jl` tables (propeller coefficient maps, engine maps) must
  accept generic scalars. They do. A call `itp(x::Dual)` works through the
  `BSpline`/`scale`/`extrapolate` compositions in Flight.jl's tables. Prefer
  cubic knots over linear where partials matter, though, since linear knots
  make Jacobian entries piecewise-constant. That is no regression against
  finite differences ([D-307][d-307]). A manual chain rule via
  `Interpolations.gradient` is the escape hatch for anything exotic, and the
  pattern for wrapping non-Julia black boxes ([§14.10][s14-10],
  [D-266][d-266]).
````

New:

````text
- `Interpolations.jl` tables (propeller coefficient maps, engine maps) must accept
  generic scalars. They do. A call `itp(x::Dual)` works through the
  `BSpline`/`scale`/`extrapolate` compositions in Flight.jl's tables. Prefer cubic
  knots over linear where partials matter, though, since linear knots make
  Jacobian elements piecewise-constant. That is no regression against finite
  differences ([D-307][d-307]). A manual chain rule via `Interpolations.gradient` is the
  escape hatch for anything exotic, and the pattern for wrapping non-Julia black
  boxes ([§14.10][s14-10], [D-266][d-266]).
````

## 31. P2-46, unit G, from line 192 of the edited file

Rewrap only.

Old:

````text
**A `TrimProblem` is not a [condition](#g-condition) but an implicitly
specified condition** ([D-071][d-071]). A condition is the datum that says
"set this build to this state". `condition` is a condition-*valued function*
over the decision space. `reads`/`residuals` are the equations that pin the
free variables down. `guess`, `lower` and `upper` say where to search.
Solving makes the implicit condition explicit. The commit is then literally
an init, `override(baseline, condition(d*))` through
[boundary zero](#g-boundary-zero) (the initialization boundary, the ordinary
macro-sequence with an empty integrate). [`override`](#g-override) is the
ordered, asymmetric layering combinator, in which the patch wins on a shared
leaf. The services unify as clients of one
condition algebra. `init!` applies an explicit condition, and `trim!`
searches a family for the member satisfying its equations.
````

New:

````text
**A `TrimProblem` is not a [condition](#g-condition) but an implicitly specified condition** ([D-071][d-071]).
A condition is the datum that says "set this build to this state". `condition` is
a condition-*valued function* over the decision space. `reads`/`residuals` are the
equations that pin the free variables down. `guess`, `lower` and `upper` say where to
search. Solving makes the implicit condition explicit. The commit is then
literally an init, `override(baseline, condition(d*))` through [boundary zero](#g-boundary-zero) (the
initialization boundary, the ordinary macro-sequence with an empty integrate).
[`override`](#g-override) is the ordered, asymmetric layering combinator, in which the patch wins
on a shared leaf. The services unify as clients of one condition algebra. `init!`
applies an explicit condition, and `trim!` searches a family for the member
satisfying its equations.
````

## 32. P2-29, unit G, from line 225 of the edited file

Checked src/conditions.jl 28 and 94: at(prefix, node) returns Scoped(prefix, node).

Old:

````text
The condition side needs nothing new at resolution. The flattening
accumulator of [§14.3][s14-3] enters each `Scoped` wrapper and prefixes every
condition entry below it.
````

New:

````text
The condition side needs nothing new at resolution. The flattening accumulator
of [§14.3][s14-3] enters each `Scoped` wrapper (the node `at` builds over a condition node)
and prefixes every condition entry below it.
````

## 33. P2-29, unit G, from line 229 of the edited file

Also P2-46: the rewrap rejoins the bold split across lines.

Old:

````text
**A read set carries its mount chain as data** ([D-277][d-277]).
`at(prefix, read_set)` prepends the prefix to that chain and joins nothing. **A
`Reads` value is no condition node**, so `Scoped` never wraps one
([D-277][d-277]). **Resolution
walks the chain from the root**, each prefix from the level the previous one
reached ([§13.3][s13-3], [D-277][d-277]). It then rebases every
[selector](#g-selector) (one of the closed family of deferred reads) to the
root before the selector resolves. A path selector's path is joined to the
mount (`"vehicle/dynamics"` → `"wing/vehicle/dynamics"`). `get_input` names
an input [face](#g-face) (the name a port wears on its
[component](#g-component)'s boundary) of the mount level. It follows the
export chain to the [root input](#g-root-input) it lands on (the root
component's own input face). `get_face` names an output face of the mount
level and reads its producer's port ([D-277][d-277]).
````

New:

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

## 34. P2-30, unit G, from line 184 of the edited file

Fitted: the gloss goes at the first use of "thin rig" in §14.9, the context paragraph, which also keeps it out of a sentence that already has a gloss. D-364 does not define the term; the glossary's design_world, the shipped thin world, is the aircraft plus an atmosphere and a terrain.

Old:

````text
This section treats a [`TrimProblem`](#g-trimproblem) (the closed nine-field
value a trim solves) as a relocatable value. [Mounting](#g-mounting)
(relocating a whole problem or tap set to a prefix) is the work of
[`at`](#g-at), the scoping combinator. The section says what a problem is,
then how `at` lifts one, how a mounted read set and mounted input entries
resolve, why a problem never authors the environment, and how worlds, thin
rigs and swarms use the lift.
````

New:

````text
This section treats a [`TrimProblem`](#g-trimproblem) (the closed nine-field value a trim solves) as
a relocatable value. [Mounting](#g-mounting) (relocating a whole problem or tap set to a
prefix) is the work of [`at`](#g-at), the scoping combinator. The section says what a
problem is, then how `at` lifts one, how a mounted read set and mounted input
entries resolve, why a problem never authors the environment, and how worlds,
thin rigs (worlds holding only the aircraft and its environment) and swarms use
the lift.
````

## 35. P2-31, unit G, from line 275 of the edited file

Checked ~/.julia/dev/Flight.jl/lib/FlightPhysics/src/world.jl 49 (Modeling.f_init!(world::Model{<:SimpleWorld}, ...)) and lib/FlightCore/src/modeling.jl.

Old:

````text
**The world wrapper dissolves** ([D-071][d-071]). Flight.jl's
`f_init!(::Model{<:SimpleWorld})` (initialize environment, then call the
aircraft's trim) has no successor method. The environment, the other aircraft
and all root inputs are covered by the `baseline` condition ([§14.6][s14-6]),
applied once at setup. The commit is
`override(baseline, at(mount, condition(d*)))`. Method nesting became value
layering.
````

New:

````text
**The world wrapper dissolves** ([D-071][d-071]). FlightPhysics' world initializer, its
method of FlightCore's `f_init!` on a FlightCore `Model{<:SimpleWorld}` (initialize
environment, then call the aircraft's trim), has no successor method. The
environment, the other aircraft and all root inputs are covered by the `baseline`
condition ([§14.6][s14-6]), applied once at setup. The commit is
`override(baseline, at(mount, condition(d*)))`. Method nesting became value
layering.
````

## 36. P2-30, unit G, from line 283 of the edited file

Old:

````text
"Aircraft as root" is a thin world. **Design tasks use a shipped rig,
[`design_world(ac)`](#g-design_world)** ([D-071][d-071]). They need one because
by default the aircraft is not literally the root. Its environment inputs are
function-valued signals ([§4.4][s4-4]), wired from provider components. The rig
is `design_world(ac)` = aircraft + `SimpleAtmosphere(wind = NoWind())` +
`HorizontalTerrain`, where `SimpleAtmosphere` and `NoWind` are FlightPhysics'
atmosphere types. `design_world` promotes the ad-hoc atmosphere and terrain
FlightCore `Model`s inside Flight.jl's `linearize` to a named artifact. There is
one mechanism. The "root" case is the shallowest world, and the trim problem
mounts at `"aircraft"` like anywhere else.
````

New:

````text
"Aircraft as root" is a thin rig. **Design tasks use a shipped rig,
[`design_world(ac)`](#g-design_world)** ([D-071][d-071]). They need one because by default the aircraft is not
literally the root. Its environment inputs are function-valued signals ([§4.4][s4-4]),
wired from provider components. The rig is `design_world(ac)` = aircraft +
`SimpleAtmosphere(wind = NoWind())` + `HorizontalTerrain`, where `SimpleAtmosphere`
and `NoWind` are FlightPhysics' atmosphere types. `design_world` promotes the ad-hoc
atmosphere and terrain FlightCore `Model`s inside Flight.jl's `linearize` to a named
artifact. There is one mechanism. The "root" case is the shallowest world, and
the trim problem mounts at `"aircraft"` like anywhere else.
````

## 37. P2-33, unit G, from line 306 of the edited file

Old:

````text
The swarm doctrine covers trims of several aircraft. **The service solves
one problem at a time** ([D-071][d-071]). Sequential independent trims (trim
lead, commit, trim wing against the committed world) cover weak or one-way
coupling. A joint trim is user-side value composition. Concatenate decision
NamedTuples under prefixed names, combine the scoped condition trees, and
stack the residuals. If joint trims become routine, **a
`product(p₁ => "lead", p₂ => "wing")` helper is the extension recorded for
them** ([D-071][d-071]). That helper is
[recorded, not built](#g-recorded-not-built) (a worked-out extension
deliberately left unimplemented, its seams named).
````

New:

````text
The swarm doctrine covers trims of several aircraft. **The service solves one
problem at a time** ([D-071][d-071]). Sequential independent trims (trim the lead aircraft,
commit, trim the wingman against the committed world) cover weak or one-way
coupling. A joint trim is user-side value composition. Concatenate decision
NamedTuples under prefixed names, combine the scoped condition trees, and stack
the residuals. If joint trims become routine, **a
`product(p₁ => "lead", p₂ => "wing")` helper is the extension recorded for them**
([D-071][d-071]). That helper is [recorded, not built](#g-recorded-not-built) (a worked-out extension deliberately
left unimplemented, its seams named).
````

## 38. P2-34, unit H, from line 24 of the edited file

Also P2-46: the rewrap evens the ragged lines.

Old:

````text
**A tap names one scalar** ([D-272][d-272]). Its
[leaf address](#g-leaf-address) (the field name with dotted and bracketed
steps below it) resolves to one scalar leaf ([§14.4][s14-4],
[D-276][d-276]). So a vector leaf yields *named scalars*, one tap per
element. A seeded tap, in the `x` or `u` list, reaches its scalar through one
index step at most and never a `.name` step, because a seed is written into a
whole state field or root input, or into one array element of it. A seeded
tap's leaf is exactly `Float64`. A `y` tap is a read and takes any leaf
address. A tap resolving to a vector or a struct
is rejected at resolution as a `TapResolution`, and so is a member in the
wrong list. A second tap resolving to a site already seeded is rejected
naming the earlier label, since one site is one column and a second seed
there would overwrite the first ([D-272][d-272]).
````

New:

````text
**A tap names one scalar** ([D-272][d-272]). Its [leaf address](#g-leaf-address) (the field name with dotted and
bracketed steps below it) resolves to one scalar leaf ([§14.4][s14-4], [D-276][d-276]). So a
vector leaf yields *named scalars*, one tap per element. A seeded tap, in the `x` or
`u` list, reaches its scalar through one index step at most and never a `.name`
step, because a seed is written into a whole state field or [root input](#g-root-input) (the
root's own input face), or into one array element of it. A seeded tap's leaf is
exactly `Float64`. A `y` tap is a read and takes any leaf address. A tap resolving
to a vector or a struct is rejected at resolution as a `TapResolution`, and so is
a member in the wrong list. A second tap resolving to a site already seeded is
rejected naming the earlier label, since one site is one column and a second
seed there would overwrite the first ([D-272][d-272]).
````

## 39. P2-36, unit H, from line 44 of the edited file

Old:

````text
The three lists are validated at resolution, with
[did-you-mean](#g-did-you-mean) errors (the offending name plus the
list-in-hand it should have matched). Those errors are the selectors' own
`ReadResolution` ([D-406][d-406]). The `x` list is validated against the
`x_init` [stores](#g-store) of the continuous [tier](#g-tier) (the continuous
or discrete side of the hybrid formalism), the `u` list against
[faces](#g-face), and the `y` list against `y_types`. **An `x` tap naming a
discrete store is rejected at resolution** as a `TapResolution`, with the tap
and its tier in hand ([D-197][d-197]). That is the no-silent-zeros rule again
([D-197][d-197]). The frozen tier's only possible partials are zeros, and the
rejection's next-move guidance points at the recorded step-map extension
below. The lists compile to offsets once, and relocate whole via
`at(prefix, taps)` ([D-072][d-072]). The shuttle layer's successor is that
compiled writer/reader pair, and **no hand-written state-space mapping
remains** ([§7.1][s7-1], [D-072][d-072]).
````

New:

````text
The three lists are validated at resolution, with [did-you-mean](#g-did-you-mean) errors (the
offending name plus the list-in-hand it should have matched). Those errors are
the selectors' own `ReadResolution` ([D-406][d-406]). The `x` list is validated against the
`x_init` [stores](#g-store) of the continuous [tier](#g-tier) (the continuous or discrete side of the
hybrid formalism), the `u` list against [faces](#g-face), and the `y` list against `y_types`. **An
`x` tap naming a discrete store is rejected at resolution** as a `TapResolution`, with
the tap and its tier in hand ([D-197][d-197]). That is the no-silent-zeros rule again
([D-197][d-197]). The discrete tier is frozen ([§8.2][s8-2]), so its only possible partials are
zeros. The rejection's next-move guidance points at the recorded step-map
extension below. The lists compile to offsets once, and relocate whole via
`at(prefix, taps)` ([D-072][d-072]). The shuttle layer's successor is that compiled
writer/reader pair, and **no hand-written state-space mapping remains** ([§7.1][s7-1],
[D-072][d-072]).
````

## 40. P2-20, unit H, from line 68 of the edited file

Also P1-38 (the shared gloss). Fitted: "the model" becomes `Model`, so the `Model` link and gloss move to that first use, and the checkpoint gloss takes its own sentence so it does not follow the `Model` gloss.

Old:

````text
**The default operating point is the [checkpoint](#g-checkpoint)** (the
model's state at a frame top as one value) of the simulation or the model as
it stands ([D-274][d-274], [D-319][d-319]). It is `checkpoint(sim)` on a
simulation and `checkpoint(model)` on a [`Model`](#g-model) (a deployment
materialized at one scalar type), each restored into the scratch world with
no boundary zero ([§12.6][s12-6], [D-274][d-274], [D-319][d-319]). The frozen
tier's [cells](#g-cell) (the typed entries of the signal table) are the
checkpoint's held cells. After a `trim!` commit, `linearize(sim, taps)` or
`linearize(model, taps)` is about the trim point with nothing re-specified.
**`about = <condition>`, with `t0` beside it, linearizes anywhere else
without touching the sim** ([D-272][d-272]). `t0` is admitted only there,
and a `t0` passed without `about` is an `ArgumentInvalid`.
````

New:

````text
**The default operating point is the [checkpoint](#g-checkpoint)** of the simulation or the [`Model`](#g-model) (a
deployment materialized at one scalar type) as it stands ([D-274][d-274], [D-319][d-319]). A
checkpoint is the `Model`'s state at a frame top as one value. It is
`checkpoint(sim)` on a simulation and `checkpoint(model)` on a `Model`, each restored
into the scratch world with no boundary zero ([§12.6][s12-6], [D-274][d-274], [D-319][d-319]). The frozen
tier's [cells](#g-cell) (the typed entries of the signal table) are the checkpoint's held
cells. After a `trim!` commit, `linearize(sim, taps)` or `linearize(model, taps)` is
about the trim point with nothing re-specified. **`about = <condition>`, with `t0`
beside it, linearizes anywhere else without touching the sim** ([D-272][d-272]). `t0` is
admitted only there, and a `t0` passed without `about` is an `ArgumentInvalid`.
````

## 41. P2-37, unit H, from line 81 of the edited file

D-272 is repeated on the last sentence: the split separates the claims from their citation.

Old:

````text
Each invocation instantiates its own scratch store set, the trim service's
mechanism verbatim ([§14.8][s14-8]), and establishes the operating point in it
(above). **It then runs the seeded `Dual` evaluation**, one direction per `x`
tap and per `u` tap, in groups of `width` directions per pass
([D-072][d-072]). **`width` is a keyword of `linearize`, default 8**, and the
default width's scalar type is public, so a build can pre-materialize its
[activation](#g-activation) (the build's typed products at a given scalar
type) through `activations` ([§9.4][s9-4]) and a tap set of any size then
linearizes with no compile at the keyboard ([D-272][d-272]). Value parts give
`ẋ₀` and `y₀`. Partials give `A` and `B` against the `x`- and `u`-seeds, and
`C` and `D` against the same seeds read at `y`. All four come out
simultaneously, exact to machine precision. `linearization_walkthrough.md`
runs the pass on a two-state model, seed by seed.
````

New:

````text
Each invocation instantiates its own scratch store set, the trim service's
mechanism verbatim ([§14.8][s14-8]), and establishes the operating point in it (above).
**It then runs the seeded `Dual` evaluation**, one direction per `x` tap and per `u` tap,
in groups of `width` directions per pass ([D-072][d-072]). **`width` is a keyword of `linearize`,
default 8** ([D-272][d-272]). The default width's scalar type is public. A build can
therefore pre-materialize its [activation](#g-activation) (the build's typed products at a given
scalar type) through `activations` ([§9.4][s9-4]), and a tap set of any size then
linearizes with no compile at the keyboard ([D-272][d-272]). Value parts give `ẋ₀` and `y₀`.
Partials give `A` and `B` against the `x`- and `u`-seeds, and `C` and `D` against the same
seeds read at `y`. All four come out simultaneously, exact to machine precision.
`linearization_walkthrough.md` runs the pass on a two-state model, seed by seed.
````

## 42. P2-38, unit H, from line 99 of the edited file

Old:

````text
That seeded evaluation replaces Flight.jl's four `FiniteDiff` jacobians, their
step-size heuristics and ~4n perturbed evaluations.
````

New:

````text
That seeded evaluation replaces Flight.jl's four `FiniteDiff` Jacobians, their
step-size heuristics and ~4n perturbed evaluations.
````

## 43. P2-34, unit H, from line 104 of the edited file

Old:

````text
**Unseeded states sit constant at the operating point**, and so do unseeded
[root inputs](#g-root-input) (the root's own input faces) ([D-072][d-072]).
Establishing the operating point embeds their `Float64` values as
zero-partial constants. The discrete tier is frozen with zero partials, which
is precisely "linearize with the discrete state held" ([§8.2][s8-2]).
Partials enter through per-invocation seeding, one rule for `x` and root
inputs alike ([§7.2][s7-2], [D-297][d-297]). [§8.2][s8-2] states which root
inputs the schema leaves seedable ([D-295][d-295]). A root input whose input
entry is declared `Pinned` is declaredly unseedable, and its cell is frozen at
every activation.
````

New:

````text
**Unseeded states sit constant at the operating point**, and so do unseeded root
inputs ([D-072][d-072]). Establishing the operating point embeds their `Float64` values as
zero-partial constants. The discrete tier is frozen with zero partials, which is
precisely "linearize with the discrete state held" ([§8.2][s8-2]). Partials enter
through per-invocation seeding, one rule for `x` and root inputs alike ([§7.2][s7-2],
[D-297][d-297]). [§8.2][s8-2] states which root inputs the schema leaves seedable ([D-295][d-295]). A root
input whose input entry is declared `Pinned` is declaredly unseedable, and its
cell is frozen at every activation.
````

## 44. P2-39, unit H, from line 113 of the edited file

Old:

````text
**Selecting such a root input as a `B`-matrix tap is rejected at tap
resolution** as a `TapResolution`, with the offending input entry in hand,
rather than silently yielding a zero column ([D-295][d-295],
[D-296][d-296]). Under fan-out the rejection names the pinning consumer, not
the face alone. A root input is unseedable whenever any one of its consumers
demands frozen, which is the fan-out meet ([§8.2][s8-2]; [D-168][d-168]). The
author's next move is to promote that leaf to a tolerant input entry, or to
route the tap around it. Either move depends on knowing which leaf froze the
root input. A discrete consumer pins its input entry by tier, not by
declaration ([§8.2][s8-2]), so a root input it reads is unseedable at every
activation with nothing to promote. The rejection then names the tier, and
the next move is to tap the continuous cell that consumer drives, or the
recorded step map below ([D-272][d-272]).
````

New:

````text
**Selecting such a root input as a `B`-matrix tap is rejected at tap resolution** as a
`TapResolution`, with the offending input entry in hand, rather than silently
yielding a zero column ([D-295][d-295], [D-296][d-296]). Under fan-out the rejection names the
pinning consumer, not the face alone. A root input is unseedable whenever any
one of its consumers demands frozen, which is the fan-out meet ([§8.2][s8-2], [D-168][d-168]).
The author's next move is to promote that leaf to a tolerant input entry, or to
route the tap around it. Either move depends on knowing which leaf froze the
root input. A discrete consumer pins its input entry by tier, not by declaration
([§8.2][s8-2]), so a root input it reads is unseedable at every activation with nothing
to promote. The rejection then names the tier, and the next move is to tap the
continuous cell that consumer drives, or the recorded step map below ([D-272][d-272]).
````

## 45. P2-41, unit H, from line 139 of the edited file

Old:

````text
**`linearize` returns a `Linearization` value** ([D-072][d-072],
[D-272][d-272]). It holds `ẋ₀`, `x₀`, `u₀` and `y₀` as NamedTuples under the
tap labels, `A`, `B`, `C` and `D` as matrices, and the three label sets of the
taps ([D-272][d-272]). On that data, FlightPhysics' `subsystem`/`delete_vars`
survive as pure label-indexed matrix slicing, with no model involvement.
Flight.jl's `c172x_ctl` LQR pipeline consumes it with cosmetic changes.
**FlightPhysics' `LinearizedSS` the [*component*](#g-component) survives separately, as an
ordinary [continuous component](#g-continuous-component)** in the migrated
library ([D-072][d-072]). Its `x_init` is the state vector, its faces are
labeled, and the affine update lives in `y_direct`/`x_deriv`. It has no
privileges, and its schema is everyone else's.
````

New:

````text
**`linearize` returns a `Linearization` value** ([D-072][d-072], [D-272][d-272]). It holds `ẋ₀`, `x₀`, `u₀` and
`y₀` as NamedTuples under the tap labels, `A`, `B`, `C` and `D` as matrices, and the three
label sets of the taps ([D-272][d-272]). On that data, FlightPhysics'
`subsystem`/`delete_vars` survive as pure label-indexed matrix slicing, with no
model involvement. Flight.jl's `c172x_ctl` LQR pipeline consumes it with cosmetic
changes. **FlightPhysics' `LinearizedSS`, the [component](#g-component), survives separately, as an
ordinary [continuous component](#g-continuous-component)** in the migrated library ([D-072][d-072]). Its `x_init` is the
state vector, its faces are labeled, and the affine update lives in
`y_direct`/`x_deriv`. It has no privileges, and its schema is everyone else's.
````

## 46. P2-42, unit H, from line 139 of the edited file

Old:

````text
**`linearize` returns a `Linearization` value** ([D-072][d-072], [D-272][d-272]). It holds `ẋ₀`, `x₀`, `u₀` and
`y₀` as NamedTuples under the tap labels, `A`, `B`, `C` and `D` as matrices, and the three
label sets of the taps ([D-272][d-272]). On that data, FlightPhysics'
`subsystem`/`delete_vars` survive as pure label-indexed matrix slicing, with no
model involvement. Flight.jl's `c172x_ctl` LQR pipeline consumes it with cosmetic
changes. **FlightPhysics' `LinearizedSS`, the [component](#g-component), survives separately, as an
ordinary [continuous component](#g-continuous-component)** in the migrated library ([D-072][d-072]). Its `x_init` is the
state vector, its faces are labeled, and the affine update lives in
`y_direct`/`x_deriv`. It has no privileges, and its schema is everyone else's.
````

New:

````text
**`linearize` returns a `Linearization` value** ([D-072][d-072], [D-272][d-272]). It holds `ẋ₀`, `x₀`, `u₀` and
`y₀` as NamedTuples under the tap labels, `A`, `B`, `C` and `D` as matrices, and the three
label sets of the taps ([D-272][d-272]). On that data, FlightPhysics'
`subsystem`/`delete_vars` survive as pure label-indexed matrix slicing, with no
model involvement. Flight.jl's `c172x_ctl` LQR (linear-quadratic regulator)
pipeline consumes it with cosmetic changes. **FlightPhysics' `LinearizedSS`, the
[component](#g-component), survives separately, as an ordinary [continuous component](#g-continuous-component)** in the
migrated library ([D-072][d-072]). Its `x_init` is the state vector, its faces are labeled,
and the affine update lives in `y_direct`/`x_deriv`. It has no privileges, and its
schema is everyone else's.
````

## 47. P2-42, unit H, from line 152 of the edited file

Old:

````text
The recorded guidance is that linearization taps should select
minimal-coordinate mechanizations ([D-072][d-072]). Perturbing Euler-angle
states is meaningful where seeding quaternion components steps off the
unit-norm manifold. This is why Flight.jl's C172X design code linearizes the
aircraft's `{NED}` variant, the one built on NED kinematics.
[`design_world(ac)`](#g-design_world) (the thin world that mounts an aircraft
for trim and linearization) rigs that variant, promoting implicit
practice to stated rule. The coordinate choice belongs to the tap author, not
the framework.
````

New:

````text
The recorded guidance is that linearization taps should select
minimal-coordinate mechanizations ([D-072][d-072]). Perturbing Euler-angle states is
meaningful where seeding quaternion components steps off the unit-norm manifold.
This is why Flight.jl's C172X design code linearizes the aircraft's `{NED}`
variant, the one built on north-east-down (NED) kinematics. [`design_world(ac)`](#g-design_world)
(the thin world that mounts an aircraft for trim and linearization) rigs that
variant, promoting implicit practice to stated rule. The coordinate choice
belongs to the tap author, not the framework.
````

## 48. P2-30, unit H, from line 152 of the edited file

Also P2-46: the rewrap evens the ragged lines.

Old:

````text
The recorded guidance is that linearization taps should select
minimal-coordinate mechanizations ([D-072][d-072]). Perturbing Euler-angle states is
meaningful where seeding quaternion components steps off the unit-norm manifold.
This is why Flight.jl's C172X design code linearizes the aircraft's `{NED}`
variant, the one built on north-east-down (NED) kinematics. [`design_world(ac)`](#g-design_world)
(the thin world that mounts an aircraft for trim and linearization) rigs that
variant, promoting implicit practice to stated rule. The coordinate choice
belongs to the tap author, not the framework.
````

New:

````text
The recorded guidance is that linearization taps should select
minimal-coordinate mechanizations ([D-072][d-072]). Perturbing Euler-angle states is
meaningful where seeding quaternion components steps off the unit-norm manifold.
This is why Flight.jl's C172X design code linearizes the aircraft's `{NED}`
variant, the one built on north-east-down (NED) kinematics. [`design_world(ac)`](#g-design_world)
(the thin rig that mounts an aircraft for trim and linearization) rigs that
variant, promoting implicit practice to stated rule. The coordinate choice
belongs to the tap author, not the framework.
````

## 49. P2-42, unit H, from line 163 of the edited file

Fitted: the abbreviation is spelled out rather than glossed, since a gloss would nest parentheses; also P2-10 and P2-46 (rewrap).

Old:

````text
**The sampled-data `Dual` activation is
[recorded, not built](#g-recorded-not-built)**, a worked-out extension
deliberately left unimplemented with its seams named ([D-073][d-073]). The
frozen-exact doctrine is consumer-scoped, not a capability wall. Trim and
linearization differentiate the continuous dynamics with the discrete state
held, and for that a frozen discrete output (a ZOH constant with zero
partials) is the exact answer, as [§7.2][s7-2] states ([D-072][d-072]). The frozen discrete cell is not an AD
limitation on the signal path. It is the true zero of an instantaneous
dependence that the hybrid semantics never had. The signal flow through a
discrete component is temporal, not instantaneous, and AD
follows the actual data movement. `frozen_discrete_walkthrough.md` works the
three-component chain through.
````

New:

````text
**The sampled-data `Dual` activation is [recorded, not built](#g-recorded-not-built)**, a worked-out extension
deliberately left unimplemented with its seams named ([D-073][d-073]). The frozen-exact
doctrine is consumer-scoped, not a capability wall. Trim and linearization
differentiate the continuous dynamics with the discrete state held, and for that
a frozen discrete output (a zero-order-hold constant with zero partials) is the
exact answer, as [§7.2][s7-2] states ([D-072][d-072]). The frozen discrete cell is not an AD
limitation on the signal path. It is the true zero of an instantaneous
dependence that the hybrid semantics never had. The signal flow through a
discrete component is temporal, not instantaneous, and AD follows the actual
data movement. `frozen_discrete_walkthrough.md` works the three-component chain
through.
````

## 50. P2-42, unit H, from line 199 of the edited file

Old:

````text
The honest limit is that $\Phi$ is differentiable only where the event
pattern is locally constant. Exactness across a firing needs saltation
corrections. The scope is therefore event-quiescent operating points, which
trim points already are, because [guards](#g-guard) at commit see to that
([§14.5][s14-5]). The scope comes with a loud diagnostic if an event fires
inside a differentiated step. Two consumers wait. The first is the closed-loop
trim extension ([§14.7][s14-7]), whose `s_update(s) - s = 0` residuals would
currently need the derivative-free fallback, since a frozen `s_update` has no
Jacobian columns. The second is exact discrete-time linearization of the full
loop, which is digital design on the exact discretized plant instead of
continuous linearization plus Tustin.
````

New:

````text
The honest limit is that $\Phi$ is differentiable only where the event pattern
is locally constant. Exactness across a firing needs saltation corrections (the
jump terms a sensitivity takes across an event). The scope is therefore
event-quiescent operating points, which trim points already are, because [guards](#g-guard)
at commit see to that ([§14.5][s14-5]). The scope comes with a loud diagnostic if an
event fires inside a differentiated step. Two consumers wait. The first is the
closed-loop trim extension ([§14.7][s14-7]), whose `s_update(s) - s = 0` residuals would
currently need the derivative-free fallback, since a frozen `s_update` has no
Jacobian columns. The second is exact discrete-time linearization of the full
loop, which is digital design on the exact discretized plant instead of
continuous linearization plus Tustin.
````

## 51. P2-42, unit H, from line 199 of the edited file

Old:

````text
The honest limit is that $\Phi$ is differentiable only where the event pattern
is locally constant. Exactness across a firing needs saltation corrections (the
jump terms a sensitivity takes across an event). The scope is therefore
event-quiescent operating points, which trim points already are, because [guards](#g-guard)
at commit see to that ([§14.5][s14-5]). The scope comes with a loud diagnostic if an
event fires inside a differentiated step. Two consumers wait. The first is the
closed-loop trim extension ([§14.7][s14-7]), whose `s_update(s) - s = 0` residuals would
currently need the derivative-free fallback, since a frozen `s_update` has no
Jacobian columns. The second is exact discrete-time linearization of the full
loop, which is digital design on the exact discretized plant instead of
continuous linearization plus Tustin.
````

New:

````text
The honest limit is that $\Phi$ is differentiable only where the event pattern
is locally constant. Exactness across a firing needs saltation corrections (the
jump terms a sensitivity takes across an event). The scope is therefore
event-quiescent operating points, which trim points already are, because [guards](#g-guard)
at commit see to that ([§14.5][s14-5]). The scope comes with a loud diagnostic if an
event fires inside a differentiated step. Two consumers wait. The first is the
closed-loop trim extension ([§14.7][s14-7]), whose `s_update(s) - s = 0` residuals would
currently need the derivative-free fallback, since a frozen `s_update` has no
Jacobian columns. The second is exact discrete-time linearization of the full
loop, which is digital design on the exact discretized plant instead of
continuous linearization plus Tustin's discretization.
````

## 52. P2-42, unit H, from line 213 of the edited file

Fitted: the FMU gloss would nest inside the old parentheses, so the examples become a "such as" clause; also P2-10 (rewrap).

Old:

````text
Both halves of non-participation have a spelling ([D-263][d-263]). The output
half is the freeze door, which declares a leaf frozen under differentiation as
[§8.2][s8-2] and [§9.5][s9-5] spell it ([D-286][d-286]). An opaque wrapper (an FMU, a C aerodynamic table)
and a deliberately severed coupling can therefore both say so in the schema,
instead of showing up in Jacobians as unexplained zero rows. The conformance
check holds them to it at every activation ([D-286][d-286]). The input half
is the FFI door ([§8.2][s8-2]). A consumer's `Pinned` input entry declares
"never hand me partials", enforced at the wire ([§6.1][s6-1],
[D-263][d-263]). At a root input, such an input entry *is* the forbid-seeding
marker itself. That marker carries semantics rather than mere protection,
because it types the root-input cell at every activation. An unseeded root
input is therefore a *choice*, where a `Pinned`-entry root input is a
*declaration* ([D-295][d-295]).
````

New:

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

## 53. P2-43, unit H, from line 226 of the edited file

Old:

````text
An implementation that cannot take `Dual`s has a third move. The marker
records that a leaf carries no partials, not that an implementation cannot
propagate them. **A component that must participate keeps its input entry
tolerant and supplies its own local derivative inside the stage**
([D-266][d-266]). A C table or an FMU whose coupling matters to the Jacobian
is such a component. It evaluates at the value, obtains a local Jacobian by
whatever means it has, a finite difference at a step its own grid suggests or
the table's analytic slope, and chains it onto the incoming partials
([D-266][d-266]).
````

New:

````text
An implementation that cannot take `Dual`s has a third move. The marker records
that a leaf carries no partials, not that an implementation cannot propagate
them. **A component that must participate keeps its input entry tolerant and
supplies its own local derivative inside the stage** ([D-266][d-266]). A C table or an FMU
whose coupling matters to the Jacobian is such a component. It evaluates at the
value and obtains a local Jacobian by whatever means it has, such as a finite
difference at a step its own grid suggests or the table's analytic slope. It
then chains that Jacobian onto the incoming partials ([D-266][d-266]).
````

## 54. P2-44, unit H, from line 247 of the edited file

Old:

````text
The stripping happens mid-expression, which [§9.5][s9-5] leaves legal at an
unpinned leaf, and the seeded pass sees the component as an ordinary
differentiable one. The derivative is finite-difference in quality on this
one component and exact everywhere else. **Linearization keeps this one
mechanism and no perturbation-based fallback** ([D-266][d-266]). The
derivative-free trim fallback ([§14.8][s14-8]) would serve problems with
no Jacobian columns, a case linearization does not have.
`handle_walk_walkthrough.md` places the rule beside the `Freeze` block
([§13.7][s13-7]) and the pinned input entry.
````

New:

````text
The block strips the partials with `ForwardDiff.value` mid-expression, which [§9.5][s9-5]
leaves legal at an unpinned leaf, and the seeded pass sees the component as an
ordinary differentiable one. The derivative is finite-difference in quality on
this one component and exact everywhere else. **Linearization keeps this one
mechanism and no perturbation-based fallback** ([D-266][d-266]). The derivative-free trim
fallback ([§14.8][s14-8]) would serve problems with no Jacobian columns, a case
linearization does not have. `handle_walk_walkthrough.md` places the rule beside
the `Freeze` block ([§13.7][s13-7]) and the pinned input entry.
````

## 55. P2-45, unit H, from line 256 of the edited file

Old:

````text
What stays recorded is only the remaining tooling over that visibility. One
piece is pinned-face validation by the tap declaration, where selecting a
declared-frozen output is a warning. The other is a
[feedthrough](#g-feedthrough)-graph lint, where a frozen output fed by
participating inputs names the severed coupling. Both are additive when a
consumer shows up, with no flag day. Until then the declared pins and the
visible zero rows suffice.
````

New:

````text
What stays recorded is only the remaining tooling over the schema's declared
non-participation. One piece is pinned-face validation by the tap declaration,
where selecting a declared-frozen output is a warning. The other is a
[feedthrough](#g-feedthrough)-graph lint, where a frozen output fed by participating inputs names
the severed coupling. Both are additive when a consumer shows up, with no flag
day. Until then the declared pins and the visible zero rows suffice.
````

## 56. P2-18, unit F, the end of the file

Old: the file ends `[D-223][d-223]).`, a newline, then an empty line (`\n\n`).

New: the file ends `[D-223][d-223]).` and one newline (`\n`).

## Not edited

- P2-50: confirmed, no edit. §14.10 names `frozen_discrete_walkthrough.md`
  once.
- RULING, left for the orchestrator: P2-6, P2-21, P2-24, P2-28, P2-32, P2-35,
  P2-40, P2-47 and P2-48.
- P2-8 changes §14.8's baseline gloss away from the glossary's words ("an
  aircraft-shipped, full-coverage condition function"). `src/trim.jl` 481 and
  612 pass `baseline` to `override` as a condition node, so the glossary's
  `#g-baseline` may want the same change at landing.

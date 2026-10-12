### 3.4 Why two leaf classes, not one hybrid primitive

This section asks why there are two leaf classes at all. One all-in-one
primitive could carry continuous state, modes *and* discrete state, with
`x_deriv`, events *and* `s_update`. A purely continuous or discrete
[component](#g-component) would then fall out of whichever facets an author
declares. A component's [class](#g-class), its primitive-vs-assembly status,
is already read off declaration shape ([§8.5][s8-5]). So the question is
whether the two declaration sets should be exclusive. They are
([D-056][d-056], [D-263][d-263]).

**The split is between *time bases*, not state classes** ([D-056][d-056]).
The [continuous component](#g-continuous-component) is already hybrid. It
carries modes `m`, [guards](#g-guard) (functions that define an event's
predicate) and handlers ([§3.1][s3-1]). What separates the two leaf classes is
[sweep](#g-sweep)-driven versus [tick](#g-tick)-driven execution. A sweep is
one pass through the execution order against the current state. A tick is an
instant at which a discrete component's stages and update run.

The settled rules force an all-in-one component's two halves to communicate
exactly as two siblings do ([D-056][d-056]). There is [one home per datum](#g-one-home-per-datum) (no store
mirrors another, [§5.2][s5-2]). `x_deriv` sees only the continuous state, and `s_update`
only the discrete one. And `s⁺` is decoded only at the owner's next tick, because
`s_update` runs last. That deferred decode is what makes ticks→events structurally
impossible ([D-020][d-020]). It is also what terminates the iteration at each [boundary](#g-boundary) (a
published consistency point, [§10.6][s10-6]). Inside an all-in-one component, influence
across [tiers](#g-tier) (the continuous and discrete sides of the formalism) still routes
through [cells](#g-cell) of the published signal table ([D-056][d-056]).

The all-in-one component is therefore an [assembly](#g-assembly) (pure composition) of two
primitives in a trench coat ([D-056][d-056]). It buys no expressiveness. It incurs costs
of its own, which [D-056][d-056] enumerates. One of those costs is not bookkeeping. The
sampling interface is the zero-order hold (ZOH) plus the one-sample `z⁻¹` delay.
It is the most bug-prone boundary in a flight-control stack. A monolith swallows
it. The split keeps it a visible wire.

#### The hardest case: integrate-and-dump

A strapdown inertial measurement unit (IMU) is the strongest challenge
mounted against the split. The IMU's direct formulation integrates raw
increments continuously, as `ẋ.ϑ_c = ω_ic_c`, `ẋ.υ_c = f_c_c`, the coning
attitude increment `q_c_cc` and the sculling integral
`ẋ.υ_c_sc = q_c_cc(f_c_c)`. Then, at the IMU's own `Δt`, a discrete step
reads the integrals, publishes the sample, and *zeroes them*. [§8.6][s8-6]
spells this IMU in full.

In interval terms, these piecewise quantities are integrals over
$[t_{k-1}, t_k]$ with their weights re-anchored at each reset. `ϑ_c`
$= \int_{t_{k-1}}^{t_k} \omega^{c}_{ic} \, dt$ and `υ_c`
$= \int_{t_{k-1}}^{t_k} f^{c} \, dt$ run from zero, `q_c_cc`
$= q_{c_{k-1} \to c(t)}$ runs from identity, and `υ_c_sc`
$= \int_{t_{k-1}}^{t_k} R^{c_{k-1}}_{c} f^{c} \, dt$ has its rotation
anchored at the interval start. The differencing idiom of [§8.6][s8-6]
recovers exactly these forms from the cumulative stores, term by term.

The reset is periodic, not predicate-triggered, so events are the wrong
mechanism ([D-056][d-056]). And the reset is a discrete-tier write into continuous state,
exactly the operation this design forbids ([D-056][d-056]). `s_update` writes only its own
`s`. Guard-driven handlers are the sole resetters of continuous state ([D-141][d-141]).
Integrate-and-dump falls squarely into the crack between the two leaf classes.
It is tightly coupled continuous and periodic dynamics in one physical
instrument.

Algebra removes the reset ([§8.6][s8-6]). Every interval-relative integral becomes a
cumulative one, and a discrete sampler differences consecutive samples against
its latch ([D-056][d-056]). [§8.6][s8-6] also spells that idiom, its exactness condition and the
resulting assembly in full.

The strongest counterexample landed on the two-class taxonomy with *less* code
than the direct formulation. It keeps the same thirteen integral scalars and the
same math, minus the reset block. It brings three structural gains. First, the
sampling interface became a wire. Second, the error model became a discrete
sibling, which makes the truth/corrupted sample pair separately loggable ([§8.6][s8-6]).
Third, linearization got sane. Under a `Dual` [activation](#g-activation) (the build's typed
products at ForwardDiff's dual-number scalar type) the discrete tier is held
([§8.2][s8-2]). And "integrators that never reset" *is* the cumulative formulation. The
framework's rules pushed the IMU into the only form that the framework's own
linearization semantics could coherently handle.

**The recorded, unbuilt escape hatch is a tick-triggered handler on continuous
components** ([D-056][d-056]). Such a handler is a periodic event. It is a [guarded addition](#g-guarded-addition)
(a capability the design admits but does not build), for use if
interval-relative dynamics ever neither factor algebraically nor tolerate the
latch-back wire. In that wire, the integrals consume the sampler's published
latch ([§8.6][s8-6]). No known case needs the escape hatch ([D-056][d-056]).

---

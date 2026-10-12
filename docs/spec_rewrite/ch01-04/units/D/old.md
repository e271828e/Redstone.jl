### 3.4 Why two leaf classes, not one hybrid primitive

Why two leaf classes at all? One all-in-one primitive could carry continuous
state, modes *and* discrete state, with `x_deriv`, events *and*
`s_update`. A purely continuous or discrete [component](#g-component)
would then fall out of whichever facets an author declares.
[Class](#g-class) is already read off declaration shape ([§8.5][s8-5]), so the
question is whether the two declaration sets should be exclusive. They are
([D-056][d-056]).

**Why.** The split is between *time bases*, not state classes. The continuous
primitive is already hybrid, with `m`, [guards](#g-guard) and handlers
([§3.1][s3-1]). What separates the classes is [sweep](#g-sweep)-driven versus
[tick](#g-tick)-driven execution. And the settled rules force a merged
[component](#g-component)'s two halves to communicate exactly as two siblings
do. There is [one home per datum](#g-one-home-per-datum) ([§5.2][s5-2]),
`x_deriv` sees only the continuous state and `s_update` only the
discrete one, and `s⁺` is decoded only at the owner's next tick, because
`s_update` runs last. That deferred decode is what makes ticks→events
structurally impossible and what terminates the [boundary](#g-boundary)
iteration ([§10.6][s10-6]). Cross-[tier](#g-tier) influence inside the merged
class still routes through published table [cells](#g-cell). The all-in-one
component is therefore an [assembly](#g-assembly) of two primitives in a
trench coat. It buys no expressiveness and incurs costs of its own, which
[D-056][d-056] enumerates. One of those costs is not bookkeeping. The sampling
[seam](#g-seam), the ZOH and the `z⁻¹` delay, is the most bug-prone boundary
in a flight-control stack. A monolith swallows it. The split keeps it a
visible wire.

#### The hardest case: integrate-and-dump

A strapdown IMU is the strongest challenge mounted against the split. Its direct
formulation integrates raw increments continuously:
`ẋ.ϑ_c = ω_ic_c`, `ẋ.υ_c = f_c_c`, the coning attitude increment `q_c_cc`
and the sculling integral `ẋ.υ_c_sc = q_c_cc(f_c_c)`. Then, at the IMU's
own `Δt`, a discrete step reads the integrals, publishes the sample, and
**zeroes them**. In interval terms, these piecewise quantities are integrals
over $[t_{k-1}, t_k]$ with their weights re-anchored at each reset. `ϑ_c`
$= \int_{t_{k-1}}^{t_k} \omega^{c}_{ic} \, dt$ and `υ_c`
$= \int_{t_{k-1}}^{t_k} f^{c} \, dt$ run from zero, `q_c_cc`
$= q_{c_{k-1} \to c(t)}$ runs from identity, and `υ_c_sc`
$= \int_{t_{k-1}}^{t_k} R^{c_{k-1}}_{c} f^{c} \, dt$ has its rotation
anchored at the interval start. These are exactly the forms the differencing
idiom of [§8.6][s8-6] recovers from the cumulative stores, term by term. The reset is
periodic, not condition-triggered, so events are the wrong [tier](#g-tier).
And the reset is a discrete-tier write into continuous state, exactly the
operation this design forbids. `s_update` writes only its own `s`, and
handlers are the sole resetters of continuous state, [guard](#g-guard)-driven.
Integrate-and-dump falls squarely into the crack between the classes. It is
tightly coupled continuous and periodic dynamics in one physical instrument.

**Algebra removes the reset.** Every interval-relative integral becomes a
cumulative one, and a discrete sampler differences consecutive samples against
its latch. [§8.6][s8-6] spells that idiom, its exactness condition and the
resulting assembly in full.

**Verdict.** The strongest counterexample landed on the two-class taxonomy
with *less* code than the direct formulation. It keeps the same thirteen integral
scalars and the same math, minus the reset block, and it brings three
structural gains. The sampling [seam](#g-seam) became a wire. The error model
became a discrete sibling, which makes the truth/corrupted sample pair
separately loggable. And linearization got sane. Under a `Dual` [activation](#g-activation) the
discrete tier is held ([§8.2][s8-2]), and "integrators that never reset" *is*
the cumulative formulation. The framework's rules pushed the model into the
only form its own linearization semantics could coherently handle. One escape
hatch is recorded, unbuilt. If interval-relative dynamics ever neither factor
algebraically nor tolerate the latch-back wire, the
[guarded addition](#g-guarded-addition) is a **tick-triggered handler** on
[continuous components](#g-continuous-component) (periodic events). No known
case needs it ([D-056][d-056]).

---


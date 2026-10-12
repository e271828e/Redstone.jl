### 5.3 Structural feedthrough: stage roles, execution order and step boundaries

[§5.2][s5-2] fixes the two-stage surface and the laws that govern it. What remains is
the reading. A stage's role has two halves, what its name asserts and what it
may see. The section takes the names first, then what each stage may see, then
why derivatives may read outputs. The rest of the section orders the stages,
then puts that order inside a step [boundary](#g-boundary) (a published
consistency point). It ends with two supervisory inputs, scheduled gains and
commanded resets.

#### Stage roles: the names

**Mathematical symbols and API names are two vocabularies**, deliberately
([D-220][d-220]). This document's formulas keep the symbols of the traditions
they come from. `f` is the continuous [flow](#g-flow), the derivative function.
`g` is the discrete update. The two form the hybrid-systems flow/jump pair
(Goebel–Sanfelice–Teel). The output map is `h` in `y = h(x, u)`, the
control/estimation convention, as in every navigation filter's measurement
function. The API spells the same objects as words, so that a name bound in an
author's own module is unambiguous evidence of a forgotten import
([D-220][d-220]). The correspondence is one to one.

| symbol | declaration |
|---|---|
| `f`, the flow | `x_deriv` |
| `g`, the jump | `s_update` |
| `y = h(x)` | `y_state` |
| `y = h(x, u)` | `y_direct` |

**A stage's name states the dependence class**, not the argument list
([D-220][d-220]). `y_state` is the `y = h(x)` case and `y_direct` the `y = h(x,
u)` case. So "no `direct` in the name" *is* the no-[feedthrough](#g-feedthrough)
property (no instantaneous input→output dependence), visible at every
definition site.

The names are deliberately non-exhaustive. Modes fold under the state. `m` is
state, and the name states the feedthrough split rather than an argument
inventory ([D-075][d-075]). Ambient facts (`t`, `Δt`) and scratch (`ws`) ride unnamed.

The update law carries the [tier](#g-tier) (the continuous or discrete side of the hybrid
formalism) in its name, `x_deriv` versus `s_update`. The two output stages do
not. One pair of names serves both tiers, over each tier's own state letter
([D-220][d-220]). A stateful leaf's declarations must agree on one tier throughout ([§8.2][s8-2],
[D-112][d-112]). A leaf mixing the update laws, or declaring a [store](#g-store) (the framework-owned
home of a state letter) of one tier and the update law of the other, is a build
error, not a reading. The error is `DeclarationOnWrongTier` ([Appendix C][sC]).

#### Stage roles: what each stage may see

**`y_state` is the no-feedthrough stage**, defined entirely by what it cannot see
([D-035][d-035]). Its [bundle](#g-bundle) (the NamedTuple of zero-copy views a component function
receives) carries no `u`, so "no feedthrough" cannot be violated by
construction. That structural guarantee is what stage-1 [ports](#g-port) (the model's
addressable units, one declared name each) contribute to the feedthrough graph.
Stage-1 ports break would-be loops.

Stage 1 exists when the [component](#g-component) has state-derived ports, including any
state-derived intermediate a later function reads ([§5.2][s5-2]). Otherwise it is simply
absent. An empty stage is unwritable on purpose. A stage that would produce no
port is the `DeadStage` error of [§5.2][s5-2].

A declared output is produced by stage 1 or by stage 2, and by nothing else
([D-252][d-252], [§8.3][s8-3]). **A component exposes a state or mode field by
returning it from `y_state`** ([D-252][d-252]). The line is one method,
`y_state(c, b) = (; q = b.x.q)`. A declared output that no stage produces is
`DeclaredNotProduced` ([§8.3][s8-3]), at every tier and every level of the tree.

`y_direct` receives all wired inputs plus the stage-1 hand-down
([D-006][d-006], [D-194][d-194]). The hand-down is the component's own stage-1 ports. A shared
intermediate is therefore computed once and read, not re-derived. Stage 1
declares it as a port, and stage 2 finds it in `y_x`, or `y_s` on the discrete
tier ([D-194][d-194]). Stage 2 receives the [state views](#g-view)
(zero-copy reconstructions of the component's stores) too.
Conservatively, every stage-2 output is presumed dependent on every wired input.

**`x_deriv` and `s_update` run after the [sweep](#g-sweep)** (one ordered pass through the stage
functions against the current state) ([D-015][d-015]). They run when the full
[signal table](#g-signal-table) (the framework-owned collection of cells holding every produced
signal) is complete and fresh, the component's own stage-2 ports included
([D-015][d-015]). The fused idiom stands. Compute each law once, in a stage. Publish it.
Let `x_deriv`/`s_update` copy from `y`. The interfaces *reward*
single-source-of-truth rather than making duplication unwritable. Nothing ever
needs computing twice ([D-015][d-015], [D-035][d-035]). Computing a law twice invites drift, an
edited law in one place and a stale copy in the other ([D-015][d-015]).

All output stages must be pure, with no side effects ([D-015][d-015]). State
types make mutation impossible anyway ([§7][s7]).

#### Derivatives that read outputs

The design departs from the orthodox formalism, and says so openly. The
textbook form is $\dot{x} = f(x, u)$, $y = h(x, u)$. This design's `f` receives
the orthodox arguments *plus* the published table, $\dot{x} = f(x, m, y, u, t)$.
The composite map $x \mapsto \dot{x}$ is mathematically identical, so
linearization, trim and automatic differentiation (AD) are untouched. The
heterodox element is only that derivatives may read outputs.

The teaching line is this. *"stage 1 publishes what you know from state alone;
stage 2 adds what needs inputs; your dynamics read your own published results
instead of recomputing them."*

The reason for this departure is that derivative/output overlap is the *norm* in
physical and control models. Newton–Euler dynamics computes accelerations that
are at once published outputs and state derivatives. Kinematics, engine models,
gear friction and every discrete compensator show the same overlap. That overlap
is what makes the orthodox split expensive here ([D-015][d-015]). `f_ode!`, FlightCore's
fused in-place derivative function, already embodied the same economics. This
design keeps those economics while adding checked ordering.

Shared expensive computations are solved uniformly by the fused idiom above.
Compute once in stage 2, publish, and let `x_deriv`/`s_update` consume the
ports. External consumers read the same ports, as an accelerometer model reads
`f_c_c` (see the strapdown IMU example in [§3.4][s3-4]). The
computer/integrator split remains fully expressible without framework support
([D-015][d-015]). [§7.4][s7-4] carries the full statement, including when the
factoring earns its keep. Purity rules forbid the classic resolution by mutable
caching, by design ([D-015][d-015]).

#### The execution order

Execution runs all stage-1 functions in any order, then stage 2 in topological
order, then all `x_deriv` calls against the now-consistent signal table
([D-288][d-288], [§9.7][s9-7]).

The systemic consequence is that *evaluating the right-hand side (RHS) means
running the sweep*. The RHS is the flow, `x_deriv`. There is no incremental
`x_deriv`-only re-evaluation. Nothing is lost by that, because implicit solvers,
linearization and trim already work this way. They seed `x` and run the
composite. [§10.3][s10-3] and [§10.4][s10-4] restate that evaluating the RHS runs the sweep, as a
property of the execution model. RHS evaluations and trial evaluations of a
[guard](#g-guard) (the declared function defining an event's predicate) alike run the
*interior* sweep, the continuous-only variant of [§10.5][s10-5] ([D-147][d-147]). Discrete [executor](#g-executor)
entries are absent from it by construction, so discrete [cells](#g-cell) (concretely typed
table entries, one per output port) hold across the step.

### 5.3 Structural feedthrough: stage roles, execution order and step boundaries

[§5.2][s5-2] fixes the two-stage surface and the laws that govern it. What remains is
the reading. A stage's role has two halves, what its name asserts and what it
may see. The rest of the section orders the stages, then puts that order inside
a step [boundary](#g-boundary).

#### Stage roles: the names

**Mathematical symbols and API names are two vocabularies, deliberately.** This
document's formulas keep the symbols of the traditions they come from. `f` is
the continuous [flow](#g-flow) and `g` the discrete update, the hybrid-systems flow/jump
pair (Goebel–Sanfelice–Teel). `h` is the control/estimation convention that the
output map is `y = h(x, u)`, as in every navigation filter's measurement
function. The API spells the same objects as words, so that a name bound in an
author's own module is unambiguous evidence of a forgotten import ([D-220][d-220]). The
correspondence is one to one.

| symbol | declaration |
|---|---|
| `f`, the flow | `x_deriv` |
| `g`, the jump | `s_update` |
| `y = h(x)` | `y_state` |
| `y = h(x, u)` | `y_direct` |

**Rule.** A stage's **name** states the **dependence class**, not the argument
list. `y_state` is the `y = h(x)` case and `y_direct` the `y = h(x,
u)` case. So "no `direct` in the name" *is* the no-[feedthrough](#g-feedthrough) property, visible
at every definition site.

The names are deliberately non-exhaustive. Modes fold under the state. `m` is
state, and the name states the [feedthrough](#g-feedthrough) split rather than an argument
inventory ([D-075][d-075]). Ambient facts (`t`, `Δt`) and scratch (`ws`) ride unnamed.

The update law carries the [tier](#g-tier) in its name, `x_deriv` versus
`s_update`. The two output stages do not. One pair of names serves both
tiers, over each tier's own state letter ([D-220][d-220]). A stateful leaf's declarations
must agree on one tier throughout ([§8.2][s8-2]). A leaf mixing the update laws, or
declaring a store of one tier and the update law of the other, is a build error,
not a reading.

#### Stage roles: what each stage may see

**`y_state` is the no-feedthrough stage**, defined entirely by what it
cannot see. Its [bundle](#g-bundle) (the NamedTuple of zero-copy views a component function
receives) carries no `u`, so "no feedthrough" cannot be violated by
construction. That structural guarantee is what stage-1 [ports](#g-port) contribute to the
[feedthrough](#g-feedthrough) graph. They break would-be loops.

Stage 1 exists when the [component](#g-component) has state-derived ports, including any
state-derived intermediate a later function reads ([§5.2][s5-2]). Otherwise it is simply
absent. A stage that would produce none is the `DeadStage` error. An empty stage
is unwritable on purpose.

**Rule.** A declared output is produced by stage 1 or by stage 2, and by nothing
else ([D-252][d-252]). A component exposes a state or mode field by returning it from
`y_state`. The line is one method, `y_state(c, b) = (; q = b.x.q)`. A
declared output that no stage produces is `DeclaredNotProduced` ([§8.3][s8-3]),
at every tier and every level of the tree.

**`y_direct` receives all wired inputs plus the stage-1 hand-down.** The
hand-down is the component's own stage-1 ports. A shared intermediate is
therefore computed once and read, not
re-derived. Stage 1 declares it as a port, and stage 2 finds it in `y_x`, or
`y_s` on the discrete tier. Stage 2 receives the [state views](#g-view) too.
Conservatively, every stage-2 output is presumed dependent on every wired input.

**`x_deriv` and `s_update` run after the sweep**, when the full
[signal table](#g-signal-table) is complete and fresh, the component's own stage-2 ports included.
The fused idiom stands. Compute each law once, in a stage. Publish it. Let
`x_deriv`/`s_update` copy from `y`.

**Why.** The interfaces *reward* single-source-of-truth rather than making
duplication unwritable. Nothing ever needs computing twice ([D-015][d-015], [D-035][d-035]).

All output stages must be pure, with no side effects. State types make mutation
impossible anyway ([§7][s7]).

#### The execution order

**Rule.** Execution runs all stage-1 functions in any order, then stage 2 in
topological order, then all `x_deriv` calls against the now-consistent
signal table.

The systemic consequence is that *evaluating the [RHS](#g-flow) means running the sweep*.
There is no incremental `x_deriv`-only re-evaluation. Nothing is lost
by that, because implicit solvers, linearization and trim already work this way.
They seed `x` and run the composite. [§10.3][s10-3] and [§10.4][s10-4] restate that consequence as
a property of the execution model. RHS evaluations and guard trial evaluations
alike run the *interior* sweep, the continuous-only variant of [§10.5][s10-5]. Discrete
entries are absent from it by construction, so discrete [cells](#g-cell) hold across the
step.

#### Why derivatives may read outputs

**Departure from the orthodox formalism, stated openly.** The textbook form is
$\dot{x} = f(x, u)$, $y = g(x, u)$. This design's `f` receives the orthodox
arguments *plus* the published table, $\dot{x} = f(x, m, y, u, t)$. The
composite map $x \mapsto \dot{x}$ is mathematically identical, so linearization,
trim and AD are untouched. The heterodox element is only that derivatives may
read outputs.

The teaching line is this. *"stage 1 publishes what you know from state alone;
stage 2 adds what needs inputs; your dynamics read your own published results
instead of recomputing them."*

**Why.** Derivative/output overlap is the *norm* in physical and control
models. Newton–Euler dynamics computes accelerations that are at once
published outputs and state derivatives. Kinematics, engine models, gear
friction and every discrete compensator show the same overlap. That overlap is what makes the orthodox
split expensive here ([D-015][d-015]). FlightCore's fused `f_ode!` already embodied the
same economics. This design keeps them while adding checked ordering.

**Shared expensive computations** are thereby solved uniformly. Compute once in
stage 2, publish, and let `x_deriv`/`s_update` consume the ports.
External consumers read the same ports, as an accelerometer model reads `f_c_c`.
The **computer/integrator split** remains fully expressible without framework
support. [§7.4][s7-4] carries the full statement, including when the factoring earns its
keep. Purity rules forbid the classic resolution by mutable caching, by design.


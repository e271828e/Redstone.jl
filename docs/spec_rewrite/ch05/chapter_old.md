## 5. Evaluation order and feedthrough

### 5.1 The ordering problem

At every evaluation instant, all signals must be computed consistently. Every
consumer reads values already produced at that instant. The build constructs the
directed graph of wiring edges and intra-[component](#g-component) [feedthrough](#g-feedthrough) relations. If the
graph is acyclic, a topological sort yields a **static [execution order](#g-execution-order)**,
computed once at build time. The hot loop runs a flat list of `(component,
stage)` entries, with no runtime graph logic.

### 5.2 Two-stage outputs: signatures, bundles and the hand-off laws

Every [component](#g-component) provides exactly **two output stages**. [Feedthrough](#g-feedthrough) is declared
**structurally, by function signature**. There are no dependency annotations
anywhere in the design.

```julia
# continuous component — maximal legal view set of each bundle in comments
y_x  = y_state(comp, args)       # x, m, t [, ws] — no-feedthrough stage
y_xu = y_direct(comp, args)      # x, m, u, y_x, t [, ws]
ẋ    = x_deriv(comp, args)       # x, m, y, u, t [, ws]

# discrete component — the same two stage names over its own state letter
y_s  = y_state(comp, args)       # s, t, Δt [, ws]
y_su = y_direct(comp, args)      # s, u, y_s, t, Δt [, ws]
s⁺   = s_update(comp, args)       # s, y, u, t, Δt [, ws]

# every output stage returns its port NamedTuple — the return law below

# event system (continuous side only) — same fresh table, same state views:
σ        = guard(comp, args)        # x, m, y, u, t [, ws] — Bool or scalar sign value (§2.1)
(; x, m) = handler(comp, args)      # x, m, y, u, t [, ws] — keys by the return law below (§9.5)
x⁺ = x_projection(comp, x)      # manifold projection; positional (below)
```

The laws that govern that surface follow. They fix how a function receives its
arguments, which names it receives, what an output stage returns, and what a
handler returns.

#### The hand-off: one component, one bundle

**Rule.** Every function receives exactly two arguments, the component and one
NamedTuple [bundle](#g-bundle) of zero-copy views. From that bundle the author **destructures
by name** only what the body reads, as in `x_deriv(c::LowPassFilter, (;
x, u)) = …` and `y_direct(c::PID, (; s, u, Δt)) = …`.

**Why.** The [executor](#g-executor) (the compiled form of the stage execution order) issues
one fixed call shape, `fn(comp, args)`. Language semantics ignore unread fields.
Argument order cannot be confused, because there is no order.

Positional, `kwarg_decl`-reflected and slurping-keyword spellings are all closed
([D-074][d-074]). `x_projection` alone stays positional. It takes one store in and
returns the same store out, so there is nothing to select.

#### The bundle law: which names a component receives

**Rule.** Under the [bundle law](#g-bundle), a name appears in a component's bundle **iff the
corresponding store or fact exists for that component**.

| bundle field | present iff |
|---|---|
| `x` | the component declares `x_init` (continuous [tier](#g-tier)) |
| `s` | the component declares `s_init` (discrete tier) |
| `m` | the component declares `m_init` |
| `ws` | the component declares `ws_init` |
| `u` | the [function family](#g-function-family) (which bundle fields a given function may legally receive) may see inputs **and** the component declares `u_types` |
| `y` | the component produces any table [cell](#g-cell) at all (it declares `y_types`) |
| `y_x` / `y_s` | stage-1 [ports](#g-port) exist, under the tier's own spelling |
| `t` | always |
| `Δt` | the component is on the discrete tier |

**The stage-1 hand-down carries the stage-1 *return*.** `y_x`, or `y_s` on the
discrete tier, comes from the stage-1 [probe](#g-probe)'s return ([D-252][d-252]).
[§9.3][s9-3] already sources the rule. A component with no stage-1 [ports](#g-port)
has no `y_x`/`y_s` in its stage-2 bundle at all.

Undeclared stores are *absent*, never `nothing`-filled. Destructuring a field
that does not exist for the component fails at the probe, inside the [§13.2][s13-2]
framing diagnostic. The diagnostic carries [did-you-mean](#g-did-you-mean) (the offending name plus
the list-in-hand it should have matched) against the legal field set. An example
is "`x_deriv` of `Foo` destructures `m`, but `Foo` declares no
`m_init`". One law covers tier facts, stage legality and declarations alike.

The mechanism is structured, not textual. Destructuring an absent field throws a
`FieldError` carrying the type and the field name as data (Julia ≥ 1.12). The
probe catches it *matched against the bundle's own NamedTuple type* and
synthesizes the framing diagnostic from the legal set. It classifies the field
as an undeclared store, a wrong-tier fact, or a name illegal for this function
family. No message text is scraped, and the bundle stays a bare NamedTuple
([D-074][d-074]). A getproperty-wrapper spelling is the recorded fallback, should
type-matched interception prove insufficient.

The wrong-tier class covers the state letters too ([D-195][d-195]). `x` and `m` are
continuous-only, and `s` and `Δt` are discrete-only, so destructuring any of the
four on the wrong tier lands in that bucket.

The per-function name sets are **closed**, one set per function per [tier](#g-tier). The
update laws carry their tier in the name, so `x_deriv` and
`s_update` have one set each. The two output stages are shared machinery
over both tiers ([D-220][d-220]), so `y_state` and `y_direct` have one set per
tier. On the continuous tier the sets are `x, m, t [, ws]` and `x, m, u, y_x, t
[, ws]`. On the discrete tier they are `s, t, Δt [, ws]` and `s, u, y_s, t, Δt
[, ws]`. Adding a name to any of them is a decision-log entry, not a
convenience. The comments in the signature block above state each function's
maximal legal set at each tier. A given component's bundle narrows that set to
declared reality, and the destructuring narrows it further to actual reads. That
three-level funnel (stage name at its tier ⊇ bundle ⊇ reads) is worth teaching
once, because a stateless component legitimately writes `y_direct` while
owning neither `x` nor `m`.

#### The stage return law

**Rule.** An output stage returns its port NamedTuple, `y`, and nothing else.

`y` scatters into the component's declared cells as always, and every value a
later function needs is one of those cells ([§8.3][s8-3]). Stages are discovered by
method existence, and stage membership is a partition of the declared ports.

An empty `y = (;)` is a `DeadStage` build error at the probe ([§9.3][s9-3]). A stage
returning nothing at all computes nothing any consumer can read. That is the
inert-component check ([§8.1][s8-1]), applied to a single stage.

#### The handler return law

**Rule.** A handler returns a NamedTuple carrying the stores it writes. A key is
present **iff** the corresponding store exists on the component **and** the
handler updates it.

That is the bundle law's *iff* shape, now governing the return side. A pure FSM
(modes and events, no `x`) returns `(; m = (; phase = running))`. An `x`-only
reset map returns `(; x = (; x..., ω = 0.0))`. A handler touching both returns
both. Padding forms such as `((;), m⁺)` and `(x⁺, (;))` do not exist ([D-090][d-090], on
the argument-side ground of [D-074][d-074]).

The semantics per key are these. When `x` is present, the value is complete
against the state field set. When `m` is present, the names-subset predicate
applies. An unknown key gets did-you-mean against `{x, m}`. This is the same
`FieldError`-shaped machinery [§13.2][s13-2] builds for bundles, now running in both
directions ([§9.5][s9-5]).

#### What the views are

The views themselves are unchanged in meaning.

- Own state. On the continuous tier `x` comes from the flat [buffer](#g-buffer) and `m` from
  the mode [stores](#g-store). On the discrete tier `s` comes from its store.
- Own published signals. `y` is gathered from the component's own table cells
  (the declared ports, [§8.2][s8-2]).
- Inputs. `u` is gathered from foreign cells through the wiring's name binding.
- The clock. `t`, and `Δt` ([§10.5][s10-5]).
- Scratch. `ws` ([§7.3][s7-3]).

The [signal table](#g-signal-table) holds only *produced* signals, never transported ones. Each
datum has exactly one home. The buffer holds `x`, the `s` and `m` stores hold
`s` and `m`, and the table holds signals. No store mirrors another. Every
bundle field earns its place as a view genuinely readable, and no minimization
of the set survives without introducing a copy ([D-035][d-035]).

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

#### Step boundaries

**[Guards](#g-guard) and handlers read the same fresh world.** At a step boundary the order
is *integrate → project → [boundary sweep](#g-sweep) → guards*. So by guard and handler time
`y` is a fresh decode of exactly the state being transformed, and the state
views are that state itself. Handlers construct their `x`/`m` returns from raw
state naturally. A reset map is `(; x = (; x..., ω = 0.0))`, with no reassembly
from published fields.

**`x_projection` runs between a state write and its decode.** That is after
integration, and after any handler `x`-reset. Those are the only positions in
the [execution order](#g-execution-order) where no fresh `y` of the new state can exist yet.
`x_projection` is not *unique* in receiving raw state, since every function
gets state views. It is unique in that position of the execution order.

**The boundary sequence.** At each boundary the framework integrates, projects,
runs the boundary sweep, evaluates **all guards once** against that sweep, and
fires the eligible events. Each firing is `handler → x_projection`. The
sweep → guards → handlers phase then iterates to [quiescence](#g-quiescence) (the fixed point
where a round of handlers fires nothing), so newly enabled guards fire within
the *same* boundary.

> integrate → project → **[ sweep → guards → handlers ]** iterated to quiescence

The signal table is written **only by sweeps**, so a transition reaches the
table at the next round's re-sweep ([§10.6][s10-6]). The round that detects quiescence
leaves the table post-transition-consistent for whatever else the boundary does,
such as discrete [ticks](#g-tick) and logging.

**Rule.** Hence the epoch rule ([§10.6][s10-6]). A handler executes against
exactly the world its guard fired on. Own `y`, foreign `u` and own `x`/`m` alike
come from the firing round's sweep, so `y = h(x)` holds at every handler entry.

[§10.6][s10-6] settles the iteration itself, how far it runs and how often each event may
fire under the [firing budget](#g-firing-budget) (the per-boundary cap on how often each event
fires). Two of its rules matter here. Within a round each component fires at
most one event, and declaration order picks among that component's
simultaneously eligible events. Same-component sequential composition happens
*across* rounds. Each later event is re-decided against the post-transition
sweep rather than fired on a stale premise.

#### Supervisory inputs: scheduled gains and commanded resets

A supervisor sits one level above a set of compensators. It schedules their
gains and resets them on mode transitions. Both are ordinary signal flow here,
because the [stores](#g-store)-and-[views](#g-view) rules admit neither
parameter mutation nor hand-ordered resets.

**Scheduled gains are inputs.** A scheduler component owns the lookup tables
as inert parameters, reads the scheduling variables as inputs, and publishes
one gain bundle per compensator. Compensators consume gains as `u`. What
mutation would hide, ports expose. Gain trajectories are observable in log,
[trace](#g-trace) and [replay](#g-replay), where a parameter write would be
invisible to all three. The [feedthrough](#g-feedthrough) graph carries the
dependency. Linearization holds unseeded gain inputs constant with no special
casing ([§14.10][s14-10]). One-shot design-time gains, such as a controller
synthesized at init, are construction-time parameters or stopped-sim service
outputs. They are not a runtime write path.

**Rule.** A commanded reset of a discrete component is a same-tick input,
consumed in the output stage. The supervisor publishes `engage` and the latch
value from its own feedthrough stage. The compensator sits topologically after
the supervisor and honors them **this tick**:

```julia
y_direct(c::PI, (; s, u)) = (; u_cmd = u.engage ? u.u_latch : c.k_p*u.e + s.s_i)
s_update(c::PI, (; s, u, Δt)) = (; s_i = u.engage ? u.u_latch - c.k_p*u.e
                                                      : s.s_i + c.k_i*Δt*u.e)
```

**Why.** Honoring the reset only in `s_update` is legal, and it means
something else. The state still lands correctly at the next tick. But the
*output at the engagement tick* was already published from the stale state
during the [sweep](#g-sweep), and under ZOH the plant integrates a full step
under that stale command. That one-tick-late command is exactly the bump that
bumpless transfer exists to remove. No diagnostic can catch the bump, because
both spellings are meaningful designs. The update stage cannot rescue its own
[boundary](#g-boundary), because republishing from `s⁺` is rejected
([D-067][d-067]). The output stage is therefore the *only* same-tick path.
[Appendix A][sA] carries this as the same-tick reset entry, and the
bumpless-engage answer ([§11.7][s11-7]) presupposes exactly this spelling.

**A continuous component's reset is an event.** The continuous
[tier](#g-tier) admits no input spelling at all, because only handlers write
`x` ([§3.1][s3-1]). A commanded reset of continuous state, whose condition
arrives as an ordinary `Bool` input, is therefore an edge-triggered event
owned by the reset component. A landing gear's friction regulator,
re-initialized at touchdown by weight-on-wheels, is the canonical case
([D-141][d-141]). A flag-gated reset [face](#g-face) on a library PI block is
sugar over exactly that event. [Appendix A][sA] carries the continuous-reset
contract too.

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

### 5.4 Artificial loops and the escape hatch

A [component](#g-component) that bundles a no-[feedthrough](#g-feedthrough) output with a feedthrough output in
one atomic evaluation unit can be **[port](#g-port)-level acyclic yet admit no evaluation
order**. Simulink calls this an "artificial algebraic loop". The canonical
instance in this domain is rigid-body dynamics. Velocity out is pure state, and
acceleration out is feedthrough from total force. The [two-stage split](#g-stage-function) resolves
it, and it is the rung that absorbs most of the class.

What survives the split is the case where a single component's stage-2 outputs
cross-couple through a neighbor. That case is port-level acyclic and stage-level
cyclic. The tracer ([§5.6][s5-6]) labels it **artificial**. Two remedies apply, in this
order.

- **Re-factor the [contract](#g-contract).** Before moving any code, re-examine the cycle's
  wires. An input the neighbor consumes *only in a fallback branch* is the
  archetypal false dependency. The neighbor is computing, on the component's
  behalf, a fallback whose semantics belong on the component's own side of the
  boundary. Move the branch to its natural owner and the wire disappears.

  The canonical instance is the landing gear's strut/steering pair. The steering
  model consumes the contact-point velocity azimuth `ψ_v` only in its
  disengaged, castoring branch. Castoring, however, is free-swiveling wheel
  physics. It is the strut's business, not the steering law's.

  ```
  # before
  strut ──ψ_v──▶ steering        # ψ_v consumed only by the castoring branch
  steering ─────▶ strut          # the pair of wires is the cycle

  # after
  steering ──(engaged, ψ_cmd)──▶ strut
  strut:  ψ_sw = engaged ? ψ_cmd : ψ_v    # nothing flows back
  ```

  Re-factoring the steering contract to emit `(engaged, ψ_cmd)`, and computing
  `ψ_sw = engaged ? ψ_cmd : ψ_v` inside the strut, deletes the backward wire
  outright. The factoring survives substitution, which is the test that it
  records structure rather than dodging the diagnostic. A stateful steering
  actuator produces `ψ_cmd` from its own state and still needs nothing from the
  strut (`migration_outline.md` records the migration).
- **Split the component.** This is the residual remedy, taken when both halves
  genuinely belong to the component and the split documents real structure. Its
  cost is stated where it bites. Visibility ([§8.3][s8-3]) is binary, so every
  intermediate shared across the new boundary becomes `y_types`, which is
  public, connectable and substitution-relevant. The mitigating idiom is the
  granularity guideline ([§4.3][s4-3]), which the split case satisfies trivially, with
  one producing stage and one consumer. The idiom spells out as **one
  struct-valued bundle port**, a `StrutGeometry`-shaped value, not N loose
  ports. The bundle type is then contract. That is a real cost, but a bounded
  and honest one. No visibility level is added for the orphaned
  intermediates. [D-034][d-034] and [D-055][d-055] (`unlisted`, `Private(T)`) stay closed.

The build diagnostic offers both exits explicitly. It reads "cycle through
`systems/aero` is artificial at port level — split the component, or narrow the
neighbor's contract". The dead hop, the member with the input face it does
not route to the output port, is carried as a separate [payload](#g-payload)
field rather than dotted onto the path ([§8.6][s8-6], [§13.2][s13-2]).

The split is rare, and the ladder is what earns that word rather than asserting
it. The two-stage split dissolves the common shapes, and the contract
re-factoring absorbs the false wires. What is left for the split is cycles whose
halves really are one component's own work.

One consequence of stage-2 conservatism is worth recording. An input consumed
only by `x_deriv`, never by `y_direct`, still creates a
feedthrough edge if the component has stage-2 outputs. In practice such
components are integrator-shaped and have no stage-2 outputs. The remedy, if
ever needed, is the same ladder.

### 5.5 Algebraic loop policy: reject at build time

A genuine cycle in the instantaneous dependency graph, an
[algebraic loop](#g-algebraic-loop), is a **build error**. The
diagnostic names every wire of the loop as a terminal pair in the canonical
slash form of [§8.6][s8-6], as in `aero/F → dyn/F, dyn/a → aero/a`.

The user breaks the cycle explicitly, by one of three routes. They can insert
dynamics (the α-filter idiom), insert an explicit unit delay (`UnitDelay`,
[§13.7][s13-7]), or restructure. The α-filter idiom is already standard practice in the
domain. The unit delay carries a caveat. It
changes the model's [tier](#g-tier) structure. The broken signal becomes discrete, sampled
at [`Δt_base`](#g-dt_base) (the base tick period, an integer multiple `N_base·h`). That is a
modeling decision, not a transparent wire. Implicit delays and per-step
numerical loop solving are both closed ([D-005][d-005]).

Implicit *algebraic balances* inside a [component](#g-component), such as a turbomachinery
operating point, remain the component author's business. They are local, owned
and bounded. Rejecting framework-level loops does not forbid such models.

### 5.6 Diagnostics: feedthrough tracing

Tracing is **diagnostic only, never relied on for correctness**. Ordering
correctness comes exclusively from the structural two-stage split. Tracing
improves error messages and verification. The build triggers it when it
finds a cycle, to classify that cycle. A genuine cycle gets "insert a state",
and an artificial one gets the remedy ladder ([§5.4][s5-4]).

**Detection and naming.** A cycle surfaces as a topological-sort stall in the
nominal evaluation (the build's second step, the one evaluation that feeds
structure). The stalled subgraph is decomposed into **strongly connected
components**. Each nontrivial SCC names one cyclic cluster exactly, and each
cluster becomes one diagnostic. The diagnostic presents the cluster's members
and the wires among them as one readable loop of terminal pairs in the canonical
slash form ([§8.6][s8-6], `aero/F → dyn/F, dyn/a → aero/a`). Neither the raw stall
residue nor a single back edge names the cluster correctly ([D-012][d-012]).

**Classification needs no [execution order](#g-execution-order).** It runs inside the nominal
evaluation's failure path, where no execution order exists. None is needed,
because each SCC member is evaluated *once, in isolation*, at the [probe](#g-probe) point.
That evaluation reads state views from `init_*`, out-of-cycle [cells](#g-cell) from the
acyclic prefix's probe values, and in-cycle cells synthesized through
`probe_value` ([§9.3][s9-3]) under tracer tags. The tracer's product is a per-member
dependence set rather than a value, so no ordering has to be valid for the
labels to come out right.

**Rule.** The traced maps decide the verdict as one graph question over the
cluster. Every wire holds. A hop inside a member, from the face one wire
enters to the port the next wire leaves, holds iff that member's map routes
the face to the port. The loop is **real** iff a cycle survives in that graph.
It is **artificial** ([§5.4][s5-4]) iff none does, because every cycle through
the cluster crosses a dead hop, at a component whose stage-2 function does not
in fact route that input to that output. The diagnostic lists every dead hop
under either verdict, so a real loop still shows the chords the trace found
false ([D-245][d-245]). For a simple cycle this reduces to the expected reading: real
iff every hop survives.

No activation machinery is touched. There is no [activation](#g-activation) (the build's typed
products at a given scalar type), no layouts and no table. This is the *local*
variant ([D-012][d-012]), the order-free per-member trace at the probe point, which is
what the cycle classifier uses. The "tracer activation" ([§9.4][s9-4]) names the other
variant ([D-012][d-012]), the global set-tracer run as an ordinary activation. The two
must not be conflated.

**Caveats, carried in the diagnostic rather than assumed away.** The trace
speaks for the branch taken at the probe state (the diagnostic-only doctrine,
[D-012][d-012]). Discrete members trace *structurally*, because the discrete [tier](#g-tier)'s
plain, wholesale-pinning declarations admit no tracer scalar. Structural tracing
is sound as a may-depend answer but never sharp, so the remedy hint is offered
only for continuous members. A continuous face or port declared with no walking
leaf admits no tracer scalar either, so the hops through it trace structurally
too. The diagnostic records, per member, whether its map came from the global
tracer, from sampled states or from structure, so a reader can weigh a dead hop
found on a few sampled paths against one found exactly ([D-245][d-245]). The hint
itself is to split this component, *or* to
narrow the neighbor's [contract](#g-contract) when the dead hop's input is consumed only in a
fallback branch (the ladder, [§5.4][s5-4]). If a member's evaluation itself throws, the
diagnostic ships with its members and wires alone, unclassified. Classification
is a bonus on the cycle error, never its precondition.

There are two modes, and they degrade gracefully.

- **Global (value-blind) set-tracer.** A `Real` subtype carries a set of input
  indices, unioned by every operation. It has **may-depend semantics**, a sound
  over-approximation. A saturated `clamp` still reports, and $u^2$ at $u = 0$
  still reports. It is exact, in one evaluation. It requires the traced stage-2
  code to be free of branches and lookups on *input-tainted* values.
- **Local (primal-carrying) set-tracer at sampled states.** This is the fallback
  whenever the global tracer hits an undecidable branch, such as piecewise
  friction, stall blending or any gridded lookup at an input-tainted coordinate.
  It reports the dependence pattern of the taken paths, sampled across
  randomized states. Its only misses are untaken branches ([D-012][d-012]).

**Boundaries.** Only *inputs* are seeded, so branching on state, modes,
parameters or time never interferes. Stage-2 functions also receive state views,
but neither those nor the stage-1 hand-down are ever seeded. Stage-1 functions
are never traced, since there is nothing to seed. Derivatives, [guards](#g-guard), handlers
and [projections](#g-projection) are outside tracing's jurisdiction entirely. A known tracer
blind spot is documented. Value-severing operations pass dependence through a
bare `Int` index, as a nearest-neighbor lookup does. Linear and cubic
interpolation are immune, because dependence flows through the fractional
weights.

Both modes ride the same `T <: Real` genericity as `Dual`. Dual-cleanliness in
CI effectively guarantees traceability.

---


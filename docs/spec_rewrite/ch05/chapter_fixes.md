# Chapter 5: the editorial fixes (step 5)

The editorial fixer's log. Sources: `chapter_pass.md` (findings 1 to 25;
finding 26 declined by the brief), and the brief's "Rulings after step 5"
(R18, R19, R20). Line numbers in finding ids are `chapter_new.md` lines
before these fixes. Each entry gives the id, unit, old text, new text and the
reason. A rewrap entry changes line breaks only. Inventory changes follow
each entry. After every unit's edits, all six checkers printed
`checks failed: 0`.

## Unit A

### Finding 1, unit A (edit)

Reason: the roadmap's §5.3 entry names the supervisory inputs, which hold the chapter's reset rulings.

Old:

```text
[§5.3][s5-3] the stage roles, the execution order and step boundaries;
```

New:

```text
[§5.3][s5-3] the stage roles, the execution order, step boundaries and supervisory inputs;
```

Inventory: added.

### Finding 1, unit A (rewrap)

Reason: rewrap after the edit above.

Old:

```text
This chapter fixes two output stages per component, what each stage may see,
and how those signatures alone yield a static execution order. The build
derives that order from declared feedthrough and rejects algebraic loops by
naming the cycle. [§5.1][s5-1] states the ordering problem; [§5.2][s5-2] the
two output stages, their signatures, bundles and the hand-off laws;
[§5.3][s5-3] the stage roles, the execution order, step boundaries and supervisory inputs;
[§5.4][s5-4] artificial loops and the escape hatch; [§5.5][s5-5] the policy
that rejects algebraic loops at build time; and [§5.6][s5-6] diagnostics
through feedthrough tracing.
```

New:

```text
This chapter fixes two output stages per component, what each stage may see, and
how those signatures alone yield a static execution order. The build derives
that order from declared feedthrough and rejects algebraic loops by naming the
cycle. [§5.1][s5-1] states the ordering problem; [§5.2][s5-2] the two output stages, their
signatures, bundles and the hand-off laws; [§5.3][s5-3] the stage roles, the execution
order, step boundaries and supervisory inputs; [§5.4][s5-4] artificial loops and the
escape hatch; [§5.5][s5-5] the policy that rejects algebraic loops at build time; and
[§5.6][s5-6] diagnostics through feedthrough tracing.
```

### R18, unit A (edit)

Reason: the build rejects every cycle in the graph, artificial loops included; §5.4 to §5.6 treat cycles, each section cited.

Old:

```text
A cyclic graph is the
subject of [§5.5][s5-5].
```

New:

```text
A cyclic graph is the
subject of [§5.4][s5-4], [§5.5][s5-5] and [§5.6][s5-6].
```

Inventory: added.

### R18, unit A (rewrap)

Reason: rewrap after the edit above.

Old:

```text
At every evaluation instant, all signals must be computed consistently. Every
consumer reads values already produced at that instant. The build constructs
the directed graph of wiring edges and intra-[component](#g-component)
[feedthrough](#g-feedthrough) relations (instantaneous input→output
dependences). If the graph is acyclic, a topological sort yields a static
[execution order](#g-execution-order) (the order in which the stage functions
run), computed once at build time ([D-048][d-048]). A cyclic graph is the
subject of [§5.4][s5-4], [§5.5][s5-5] and [§5.6][s5-6]. The hot loop runs a flat list of `(component,
stage)` pairs, with no runtime graph logic ([D-086][d-086]).
```

New:

```text
At every evaluation instant, all signals must be computed consistently. Every
consumer reads values already produced at that instant. The build constructs the
directed graph of wiring edges and intra-[component](#g-component) [feedthrough](#g-feedthrough) relations
(instantaneous input→output dependences). If the graph is acyclic, a topological
sort yields a static [execution order](#g-execution-order) (the order in which the stage functions
run), computed once at build time ([D-048][d-048]). A cyclic graph is the subject of
[§5.4][s5-4], [§5.5][s5-5] and [§5.6][s5-6]. The hot loop runs a flat list of `(component, stage)`
pairs, with no runtime graph logic ([D-086][d-086]).
```

### R19, unit A (edit)

Reason: the chapter uses stage-1 and stage-2 without saying which stage is which; declared sentence as ruled.

Old:

```text
dependency annotations anywhere in the design ([D-006][d-006]).

```

New:

```text
dependency annotations anywhere in the design ([D-006][d-006]). `y_state` is stage 1 and `y_direct` is stage 2.

```

Inventory: added+.

### R19, unit A (rewrap)

Reason: rewrap after the edit above.

Old:

```text
**Every [component](#g-component) provides exactly two output stages**
([D-006][d-006]). [Feedthrough](#g-feedthrough) (an instantaneous input→output
dependence) is declared structurally, by function signature. There are no
dependency annotations anywhere in the design ([D-006][d-006]). `y_state` is stage 1 and `y_direct` is stage 2.
```

New:

```text
**Every [component](#g-component) provides exactly two output stages** ([D-006][d-006]). [Feedthrough](#g-feedthrough) (an
instantaneous input→output dependence) is declared structurally, by function
signature. There are no dependency annotations anywhere in the design ([D-006][d-006]).
`y_state` is stage 1 and `y_direct` is stage 2.
```

### Finding 4, unit A (edit)

Reason: link view at its first use in §5.2.

Old:

```text
where each view comes from
```

New:

```text
where each [view](#g-view) comes from
```

### Finding 4, unit A (edit)

Reason: the view link moved to its first use above; one link per term per section.

Old:

```text
zero-copy [views](#g-view)
```

New:

```text
zero-copy views
```

### Finding 4, unit A (rewrap)

Reason: rewrap after the edit above.

Old:

```text
**Every function receives exactly two arguments**, the component and one
NamedTuple [bundle](#g-bundle) of zero-copy views
([D-074][d-074]). From that bundle the author destructures by name only what
the body reads, as in `x_deriv(c::LowPassFilter, (; x, u)) = …` and
`y_direct(c::PID, (; s, u, Δt)) = …`. Here `PID` names a
proportional-integral-derivative controller.
```

New:

```text
**Every function receives exactly two arguments**, the component and one NamedTuple
[bundle](#g-bundle) of zero-copy views ([D-074][d-074]). From that bundle the author destructures by
name only what the body reads, as in `x_deriv(c::LowPassFilter, (; x, u)) = …`
and `y_direct(c::PID, (; s, u, Δt)) = …`. Here `PID` names a
proportional-integral-derivative controller.
```

### Finding 4, unit A (edit)

Reason: link store at its first use in §5.2, with §5.3's gloss.

Old:

```text
It takes one
store in and returns the same store out
```

New:

```text
It takes one
[store](#g-store) (the framework-owned home of a state letter) in and returns the same store out
```

Inventory: A-026; added+.

### Finding 4, unit A (rewrap)

Reason: rewrap after the edit above.

Old:

```text
**`x_projection` alone stays positional** ([D-074][d-074]). It takes one
[store](#g-store) (the framework-owned home of a state letter) in and returns the same store out, so there is nothing to select.
```

New:

```text
**`x_projection` alone stays positional** ([D-074][d-074]). It takes one [store](#g-store) (the
framework-owned home of a state letter) in and returns the same store out, so
there is nothing to select.
```

### Finding 4, Finding 5, unit A (edit)

Reason: the store link moved to its first use above (finding 4); the tier gloss names both sides, as §5.3's does (finding 5).

Old:

```text
On the continuous [tier](#g-tier) (the continuous side of the
  hybrid formalism), `x` comes from the flat [buffer](#g-buffer) and `m` from
  the mode [stores](#g-store).
```

New:

```text
On the continuous [tier](#g-tier) (the continuous or discrete side of the
  hybrid formalism), `x` comes from the flat [buffer](#g-buffer) and `m` from
  the mode stores.
```

Inventory: A-029; added.

### Finding 4, Finding 5, unit A (rewrap)

Reason: rewrap after the edit above.

Old:

```text
- Own state. On the continuous [tier](#g-tier) (the continuous or discrete side of the
  hybrid formalism), `x` comes from the flat [buffer](#g-buffer) and `m` from
  the mode stores. On the discrete tier, `s` comes from its store.
```

New:

```text
- Own state. On the continuous [tier](#g-tier) (the continuous or discrete side of the
  hybrid formalism), `x` comes from the flat [buffer](#g-buffer) and `m` from the mode
  stores. On the discrete tier, `s` comes from its store.
```

### Finding 6, unit A (edit)

Reason: bare entry is reserved; one gloss for the cell in §5.2 and §5.3, the glossary's own compound.

Old:

```text
(concretely typed entries, one per output port)
```

New:

```text
(concretely typed table entries, one per output port)
```

Inventory: A-031; added.

### Finding 6, unit A (rewrap)

Reason: rewrap after the edit above.

Old:

```text
- Own published signals. `y` is gathered from the component's own
  [cells](#g-cell) (concretely typed table entries, one per output port) in the
  [signal table](#g-signal-table). Those cells are the declared
  [ports](#g-port) ([§8.2][s8-2]).
```

New:

```text
- Own published signals. `y` is gathered from the component's own [cells](#g-cell)
  (concretely typed table entries, one per output port) in the [signal table](#g-signal-table).
  Those cells are the declared [ports](#g-port) ([§8.2][s8-2]).
```

### Finding 7, unit A (edit)

Reason: the unit ended with a blank line, which doubled the blank line at the A/B seam.

Old:

```text
introducing a copy
([D-035][d-035]).


```

New:

```text
introducing a copy
([D-035][d-035]).

```

## Unit B

### Finding 25, unit B (edit)

Reason: one Appendix C pointer at the first diagnostic kind §5.2 names, as §5.5 and §5.6 do at `AlgebraicCycle`.

Old:

```text
probe with a `BundleFieldError` diagnostic ([D-248][d-248]).
```

New:

```text
probe with a `BundleFieldError` diagnostic ([Appendix C][sC], [D-248][d-248]).
```

Inventory: C-009; C-009 newcites=['Appendix C', 'D-248', '§13.2'].

### Finding 25, unit B (rewrap)

Reason: rewrap after the edit above.

Old:

```text
Destructuring a field that does not exist for the component fails at the
probe with a `BundleFieldError` diagnostic ([Appendix C][sC], [D-248][d-248]). [§13.2][s13-2]
describes the catch that recognizes it. The diagnostic carries
[did-you-mean](#g-did-you-mean) (the offending name plus the list-in-hand it
should have matched) against the legal field set. An example is "`x_deriv` of
`Foo` destructures `m`, but `Foo` declares no `m_init`". One law covers tier
facts, stage legality and declarations alike.
```

New:

```text
Destructuring a field that does not exist for the component fails at the probe
with a `BundleFieldError` diagnostic ([Appendix C][sC], [D-248][d-248]). [§13.2][s13-2] describes the
catch that recognizes it. The diagnostic carries [did-you-mean](#g-did-you-mean) (the offending
name plus the list-in-hand it should have matched) against the legal field set.
An example is "`x_deriv` of `Foo` destructures `m`, but `Foo` declares no
`m_init`". One law covers tier facts, stage legality and declarations alike.
```

### Finding 25, unit B (rulings.md)

Reason: the brief lists every added citation in `rulings.md`.

Added to "Citations added or replaced": Appendix C beside D-248 at the
`BundleFieldError` sentence, with Appendix C's row (spec 12435).

## Unit C

### Finding 25, unit C (edit)

Reason: one Appendix C pointer at the first diagnostic kind §5.3 names, as §5.5 and §5.6 do at `AlgebraicCycle`.

Old:

```text
The error is `DeclarationOnWrongTier`.
```

New:

```text
The error is `DeclarationOnWrongTier` ([Appendix C][sC]).
```

Inventory: C-025; C-025 newcites=['Appendix C']; added.

### Finding 8, Finding 25, unit C (rewrap)

Reason: rewrap: the appended sentence ran to 113 rendered columns (finding 8), and the edit above.

Old:

```text
The update law carries the [tier](#g-tier) (the continuous or discrete side of
the hybrid formalism) in its name, `x_deriv` versus `s_update`. The two output
stages do not. One pair of names serves both tiers, over each tier's own state
letter ([D-220][d-220]). A stateful leaf's declarations must agree on one tier
throughout ([§8.2][s8-2], [D-112][d-112]). A leaf mixing the update laws, or
declaring a [store](#g-store) (the framework-owned home of a state letter) of
one tier and the update law of the other, is a build error, not a reading. The error is `DeclarationOnWrongTier` ([Appendix C][sC]).
```

New:

```text
The update law carries the [tier](#g-tier) (the continuous or discrete side of the hybrid
formalism) in its name, `x_deriv` versus `s_update`. The two output stages do
not. One pair of names serves both tiers, over each tier's own state letter
([D-220][d-220]). A stateful leaf's declarations must agree on one tier throughout ([§8.2][s8-2],
[D-112][d-112]). A leaf mixing the update laws, or declaring a [store](#g-store) (the framework-owned
home of a state letter) of one tier and the update law of the other, is a build
error, not a reading. The error is `DeclarationOnWrongTier` ([Appendix C][sC]).
```

### Finding 8, unit C (rewrap)

Reason: rewrap: a line ran to 86 rendered columns.

Old:

```text
**`y_state` is the no-feedthrough stage**, defined entirely by what it
cannot see ([D-035][d-035]). Its [bundle](#g-bundle) (the NamedTuple of zero-copy views a component function
receives) carries no `u`, so "no feedthrough" cannot be violated by
construction. That structural guarantee is what stage-1 [ports](#g-port)
(the model's addressable units, one declared name each) contribute to the
feedthrough graph. Stage-1 ports break would-be loops.
```

New:

```text
**`y_state` is the no-feedthrough stage**, defined entirely by what it cannot see
([D-035][d-035]). Its [bundle](#g-bundle) (the NamedTuple of zero-copy views a component function
receives) carries no `u`, so "no feedthrough" cannot be violated by
construction. That structural guarantee is what stage-1 [ports](#g-port) (the model's
addressable units, one declared name each) contribute to the feedthrough graph.
Stage-1 ports break would-be loops.
```

### R20, unit C (edit)

Reason: §5.3 names the drift class that inbound citations say it exists to kill; one plain sentence from D-015's Rejected list (log 607-608).

Old:

```text
Nothing ever needs computing twice ([D-015][d-015], [D-035][d-035]).

```

New:

```text
Nothing ever needs computing twice ([D-015][d-015], [D-035][d-035]). Computing a law twice invites drift, an edited law in one place and a stale copy in the other ([D-015][d-015]).

```

Inventory: added+.

### Finding 8, R20, unit C (rewrap)

Reason: rewrap: a line ran to 84 rendered columns (finding 8), and the edit above.

Old:

```text
**`x_deriv` and `s_update` run after the [sweep](#g-sweep)** (one ordered
pass through the stage functions against the current state) ([D-015][d-015]). They
run when the full [signal table](#g-signal-table) (the framework-owned
collection of cells holding every produced signal) is complete and fresh, the
component's own stage-2 ports included ([D-015][d-015]). The fused idiom stands. Compute each
law once, in a stage. Publish it. Let `x_deriv`/`s_update` copy from `y`. The
interfaces *reward* single-source-of-truth rather than making duplication
unwritable. Nothing ever needs computing twice ([D-015][d-015], [D-035][d-035]). Computing a law twice invites drift, an edited law in one place and a stale copy in the other ([D-015][d-015]).
```

New:

```text
**`x_deriv` and `s_update` run after the [sweep](#g-sweep)** (one ordered pass through the stage
functions against the current state) ([D-015][d-015]). They run when the full
[signal table](#g-signal-table) (the framework-owned collection of cells holding every produced
signal) is complete and fresh, the component's own stage-2 ports included
([D-015][d-015]). The fused idiom stands. Compute each law once, in a stage. Publish it.
Let `x_deriv`/`s_update` copy from `y`. The interfaces *reward*
single-source-of-truth rather than making duplication unwritable. Nothing ever
needs computing twice ([D-015][d-015], [D-035][d-035]). Computing a law twice invites drift, an
edited law in one place and a stale copy in the other ([D-015][d-015]).
```

### Finding 8, unit C (rewrap)

Reason: rewrap: a line ran to 93 rendered columns.

Old:

```text
The reason for this departure is that derivative/output overlap is the *norm*
in physical and control models. Newton–Euler dynamics computes accelerations that are at once
published outputs and state derivatives. Kinematics, engine models, gear
friction and every discrete compensator show the same overlap. That overlap is
what makes the orthodox split expensive here ([D-015][d-015]). `f_ode!`,
FlightCore's fused in-place derivative function, already embodied the same
economics. This design keeps those economics while adding checked ordering.
```

New:

```text
The reason for this departure is that derivative/output overlap is the *norm* in
physical and control models. Newton–Euler dynamics computes accelerations that
are at once published outputs and state derivatives. Kinematics, engine models,
gear friction and every discrete compensator show the same overlap. That overlap
is what makes the orthodox split expensive here ([D-015][d-015]). `f_ode!`, FlightCore's
fused in-place derivative function, already embodied the same economics. This
design keeps those economics while adding checked ordering.
```

### Finding 9, unit C (edit)

Reason: RHS was used before its expansion; spell it out at first use.

Old:

```text
*evaluating the RHS means running the sweep*.
The RHS (right-hand side) is the flow, `x_deriv`.
```

New:

```text
*evaluating the right-hand side (RHS) means running the sweep*.
The RHS is the flow, `x_deriv`.
```

Inventory: C-056; added.

### Finding 10, unit C (edit)

Reason: first executor in §5.3 takes its link; no gloss, which would split the glossary's compound executor entry.

Old:

```text
Discrete executor entries
```

New:

```text
Discrete [executor](#g-executor) entries
```

### Finding 6, unit C (edit)

Reason: one gloss for the cell in §5.2 and §5.3, the glossary's own compound table entry.

Old:

```text
(the typed
signal-table slots, one per output port)
```

New:

```text
(concretely typed table entries, one per output port)
```

Inventory: C-062; added.

### Finding 9, Finding 10, Finding 6, unit C (rewrap)

Reason: rewrap after the three edits above.

Old:

```text
The systemic consequence is that *evaluating the right-hand side (RHS) means running the sweep*.
The RHS is the flow, `x_deriv`. There is no incremental
`x_deriv`-only re-evaluation. Nothing is lost by that, because implicit
solvers, linearization and trim already work this way. They seed `x` and run
the composite. [§10.3][s10-3] and [§10.4][s10-4] restate that evaluating the
RHS runs the sweep, as a property of the execution model. RHS evaluations and
trial evaluations of a [guard](#g-guard) (the declared function defining an
event's predicate) alike run the *interior* sweep, the continuous-only
variant of [§10.5][s10-5] ([D-147][d-147]). Discrete [executor](#g-executor) entries are
absent from it by construction, so discrete [cells](#g-cell) (concretely typed table entries, one per output port) hold across the step.
```

New:

```text
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
```

### Finding 7, unit C (edit)

Reason: the unit ended with a blank line, which doubled the blank line at the C/D seam.

Old:

```text
hold across the step.


```

New:

```text
hold across the step.

```

### Finding 25 and R20, unit C (rulings.md)

Reason: the brief lists every added citation in `rulings.md`, and R20 lists
its sentence for track 2.

Added to "Citations added or replaced": Appendix C at the
`DeclarationOnWrongTier` sentence, with Appendix C's row (spec 12348); D-015
at R20's sentence, with D-015's Rejected item (log 607–608). Added to
"Rationale-only rulings": D-015's Rejected item as R20's source, listed for
track 2.

## Unit D

### Finding 12, unit D (edit)

Reason: R4's merge dropped the old label that named the boundary sequence; later sentences and three inbound citations (spec 5062, 5089, 5101) use the name. The sentence is split so the name comes first.

Old:

```text
At each step boundary the framework
integrates, projects,
```

New:

```text
At each step boundary the framework
runs the boundary sequence. It integrates, projects,
```

Inventory: C-003; C-012; C-012 note=the name boundary sequence restored per chapter pass finding 12.

### Finding 13, unit D (edit)

Reason: the gloss claimed due discrete ticks; the glossary's sweep and due gate in due components (spec 12962-12963, 13009-13010), and tick was not yet introduced.

Old:

```text
with the boundary's due discrete ticks gated in
```

New:

```text
including the discrete components due at this boundary
```

Inventory: C-003; C-012; added.

### Finding 8, Finding 12, Finding 13, unit D (rewrap)

Reason: rewrap: a line ran to 82 rendered columns (finding 8), and the two edits above.

Old:

```text
Guards and handlers read the same fresh world. At each step boundary the framework
runs the boundary sequence. It integrates, projects, runs the boundary sweep (the full pass that
refreshes the signal table, including the discrete components due at this boundary),
evaluates *all guards once* against that sweep, and fires the eligible events.
So by guard and handler time `y` is a fresh decode of exactly the state being
transformed, and the state views are that state itself. Handlers construct
their `x`/`m` returns from raw state naturally. A reset map is
`(; x = (; x..., ω = 0.0))`, with no reassembly from published fields.
```

New:

```text
Guards and handlers read the same fresh world. At each step boundary the
framework runs the boundary sequence. It integrates, projects, runs the boundary
sweep (the full pass that refreshes the signal table, including the discrete
components due at this boundary), evaluates *all guards once* against that sweep,
and fires the eligible events. So by guard and handler time `y` is a fresh
decode of exactly the state being transformed, and the state views are that
state itself. Handlers construct their `x`/`m` returns from raw state naturally.
A reset map is `(; x = (; x..., ω = 0.0))`, with no reassembly from published
fields.
```

### Finding 8, unit D (rewrap)

Reason: rewrap: a sentence started on a new line mid-paragraph after a 28-column line (L355-357).

Old:

```text
**`x_projection` runs between a state write and its decode**
([D-016][d-016]). That is after integration, and after any handler `x`-reset.
Those are the only positions in the boundary sequence where no fresh `y` of
the new state can exist yet.
`x_projection` is not *unique* in receiving raw state, since every function
gets state views. It is unique in that position of the boundary sequence.
```

New:

```text
**`x_projection` runs between a state write and its decode** ([D-016][d-016]). That is after
integration, and after any handler `x`-reset. Those are the only positions in
the boundary sequence where no fresh `y` of the new state can exist yet.
`x_projection` is not *unique* in receiving raw state, since every function gets
state views. It is unique in that position of the boundary sequence.
```

### Finding 14, unit D (edit)

Reason: the parenthetical after replay read as replay's gloss alone; gloss trace and replay in a sentence of their own, same claims, links unchanged.

Old:

```text
 (the session's
recorded inputs, and the ordinary loop re-driven from that recorded trace), where a parameter write
would be invisible to all three.
```

New:

```text
, where a parameter write
would be invisible to all three. The trace is the session's recorded inputs, and replay re-drives the ordinary loop from that trace.
```

Inventory: C-033; added.

### Finding 8, Finding 14, unit D (rewrap)

Reason: rewrap: a line ran to 99 rendered columns (finding 8), and the edit above.

Old:

```text
**Scheduled gains are inputs** ([D-089][d-089]). A scheduler component owns
the lookup tables as inert parameters, reads the scheduling variables as
inputs, and publishes one gain bundle per compensator. Compensators consume
gains as `u`. Ports expose what mutation would hide. Gain trajectories are
observable in log, [trace](#g-trace) and [replay](#g-replay), where a parameter write
would be invisible to all three. The trace is the session's recorded inputs, and replay re-drives the ordinary loop from that trace. The feedthrough graph carries the dependency.
Linearization holds unseeded gain inputs constant with no special casing
([§14.10][s14-10]). One-shot design-time gains, such as a controller
synthesized at init, are construction-time parameters or stopped-sim service
outputs ([D-089][d-089]). They are not a runtime write path.
```

New:

```text
**Scheduled gains are inputs** ([D-089][d-089]). A scheduler component owns the lookup tables
as inert parameters, reads the scheduling variables as inputs, and publishes one
gain bundle per compensator. Compensators consume gains as `u`. Ports expose
what mutation would hide. Gain trajectories are observable in log, [trace](#g-trace) and
[replay](#g-replay), where a parameter write would be invisible to all three. The trace is
the session's recorded inputs, and replay re-drives the ordinary loop from that
trace. The feedthrough graph carries the dependency. Linearization holds
unseeded gain inputs constant with no special casing ([§14.10][s14-10]). One-shot
design-time gains, such as a controller synthesized at init, are
construction-time parameters or stopped-sim service outputs ([D-089][d-089]). They are
not a runtime write path.
```

### Finding 15, unit D (edit)

Reason: `PI` was never introduced; §5.2 introduces `PID` the same way.

Old:

```text
The compensator sits topologically
after the supervisor
```

New:

```text
The compensator, here a proportional-integral `PI` block, sits topologically
after the supervisor
```

Inventory: C-040; added+.

### Finding 15, unit D (rewrap)

Reason: rewrap after the edit above.

Old:

```text
**A commanded reset of a discrete component is a same-tick input, consumed in
the output stage** ([D-089][d-089]). The supervisor publishes `engage` and the
latch value from its own feedthrough stage. The compensator, here a proportional-integral `PI` block, sits topologically
after the supervisor and honors them *this tick*:
```

New:

```text
**A commanded reset of a discrete component is a same-tick input, consumed in the
output stage** ([D-089][d-089]). The supervisor publishes `engage` and the latch value from
its own feedthrough stage. The compensator, here a proportional-integral `PI`
block, sits topologically after the supervisor and honors them *this tick*:
```

### Finding 16, unit D (edit)

Reason: the C172X demo was used before the sentence that introduces it; reorder with no new claim.

Old:

```text
[Appendix A][sA] carries this as the same-tick reset entry, and the
bumpless-engage answer of the C172X demo's *Mode engage* frame presupposes
exactly this spelling. The C172X demo is the interactive Flight.jl demo that
section 3 of `companions/flight_case_studies.md` examines.
```

New:

```text
[Appendix A][sA] carries this as the same-tick reset entry. The C172X demo is the interactive Flight.jl demo that
section 3 of `companions/flight_case_studies.md` examines. The
bumpless-engage answer of its *Mode engage* frame presupposes
exactly this spelling.
```

Inventory: C-049; added.

### Finding 16, unit D (rewrap)

Reason: rewrap after the edit above.

Old:

```text
Honoring the reset only in `s_update` is legal, and it means something else
([D-089][d-089]). The state still lands correctly at the next tick. But the
*output at the engagement tick* was already published from the stale state
during the sweep. Under zero-order hold, which keeps a discrete component's
outputs constant between its ticks ([§10.5][s10-5]), the plant integrates a
full step under that stale command. That one-tick-late command is exactly the
bump that bumpless transfer exists to remove. No diagnostic can catch the
bump, because both spellings are meaningful designs. The update stage cannot
rescue its own boundary, because republishing from `s⁺` is rejected
([D-067][d-067]). The output stage is therefore the *only* same-tick path.
[Appendix A][sA] carries this as the same-tick reset entry. The C172X demo is the interactive Flight.jl demo that
section 3 of `companions/flight_case_studies.md` examines. The
bumpless-engage answer of its *Mode engage* frame presupposes
exactly this spelling.
```

New:

```text
Honoring the reset only in `s_update` is legal, and it means something else
([D-089][d-089]). The state still lands correctly at the next tick. But the *output at the
engagement tick* was already published from the stale state during the sweep.
Under zero-order hold, which keeps a discrete component's outputs constant
between its ticks ([§10.5][s10-5]), the plant integrates a full step under that stale
command. That one-tick-late command is exactly the bump that bumpless transfer
exists to remove. No diagnostic can catch the bump, because both spellings are
meaningful designs. The update stage cannot rescue its own boundary, because
republishing from `s⁺` is rejected ([D-067][d-067]). The output stage is therefore the
*only* same-tick path. [Appendix A][sA] carries this as the same-tick reset entry. The
C172X demo is the interactive Flight.jl demo that section 3 of
`companions/flight_case_studies.md` examines. The bumpless-engage answer of its
*Mode engage* frame presupposes exactly this spelling.
```

### Finding 11, unit D (edit)

Reason: first use of continuous component in §5.3 takes its link, inside the bold per R13; the next sentence gives the context, so no gloss.

Old:

```text
**A continuous component's reset is an event**
```

New:

```text
**A [continuous component](#g-continuous-component)'s reset is an event**
```

### Finding 8, Finding 11, unit D (rewrap)

Reason: rewrap: a line ran to 82 rendered columns (finding 8), and the edit above.

Old:

```text
**A [continuous component](#g-continuous-component)'s reset is an event** ([D-141][d-141]). The
continuous tier admits no input spelling at all, because only handlers write
`x` ([§3.1][s3-1]). A commanded reset of continuous state, whose condition
arrives as an ordinary `Bool` input, is therefore an edge-triggered event
owned by the reset component. A landing gear's friction regulator,
re-initialized at touchdown by weight-on-wheels, is the canonical case
([D-141][d-141]). The gear wires the strut's `wow` port to the
regulator `frc`'s `reset` input, `strut.wow → frc.reset`, so the reset fires
on the touchdown edge. A flag-gated reset [face](#g-face) (the
name a port wears on its component's boundary) on a library PI block is sugar over
exactly that event. [Appendix A][sA] carries the continuous-reset contract
too.
```

New:

```text
**A [continuous component](#g-continuous-component)'s reset is an event** ([D-141][d-141]). The continuous tier admits
no input spelling at all, because only handlers write `x` ([§3.1][s3-1]). A commanded
reset of continuous state, whose condition arrives as an ordinary `Bool` input,
is therefore an edge-triggered event owned by the reset component. A landing
gear's friction regulator, re-initialized at touchdown by weight-on-wheels, is
the canonical case ([D-141][d-141]). The gear wires the strut's `wow` port to the
regulator `frc`'s `reset` input, `strut.wow → frc.reset`, so the reset fires on
the touchdown edge. A flag-gated reset [face](#g-face) (the name a port wears on its
component's boundary) on a library PI block is sugar over exactly that event.
[Appendix A][sA] carries the continuous-reset contract too.
```

## Unit E

### Finding 17, unit E (edit)

Reason: §5.4's first feedthrough had a link and no gloss; §5.1 to §5.3 each gloss it.

Old:

```text
with a feedthrough output in
one atomic
```

New:

```text
with a feedthrough output (one with an instantaneous input→output dependence) in
one atomic
```

Inventory: C-002; added+.

### Finding 17, unit E (rewrap)

Reason: rewrap after the edit above.

Old:

```text
A [component](#g-component) that bundles a no-[feedthrough](#g-feedthrough) output with a feedthrough output (one with an instantaneous input→output dependence) in
one atomic evaluation unit can be [port](#g-port)-level acyclic yet admit no evaluation
order. Simulink calls this an "artificial algebraic loop". A genuine cycle in
the instantaneous dependency graph is a different case, the
[algebraic loop](#g-algebraic-loop) of [§5.5][s5-5]. The canonical artificial
loop in this domain is rigid-body dynamics. Velocity out is pure state, and
acceleration out is feedthrough from total force. **The remedy ladder for
artificial loops has three rungs** ([D-140][d-140]). The
[two-stage split](#g-stage-function) (the two output stages every component
provides) resolves the rigid-body case, and it is the rung that absorbs most
artificial loops.
```

New:

```text
A [component](#g-component) that bundles a no-[feedthrough](#g-feedthrough) output with a feedthrough output (one
with an instantaneous input→output dependence) in one atomic evaluation unit can
be [port](#g-port)-level acyclic yet admit no evaluation order. Simulink calls this an
"artificial algebraic loop". A genuine cycle in the instantaneous dependency
graph is a different case, the [algebraic loop](#g-algebraic-loop) of [§5.5][s5-5]. The canonical artificial
loop in this domain is rigid-body dynamics. Velocity out is pure state, and
acceleration out is feedthrough from total force. **The remedy ladder for
artificial loops has three rungs** ([D-140][d-140]). The [two-stage split](#g-stage-function) (the two output
stages every component provides) resolves the rigid-body case, and it is the
rung that absorbs most artificial loops.
```

### Finding 8, unit E (rewrap)

Reason: rewrap: a line ran to 91 rendered columns.

Old:

```text
What survives the split is the case where a single component's stage-2 outputs
cross-couple through a neighbor. That case is port-level acyclic and stage-level
cyclic. The [feedthrough tracer](#g-feedthrough-tracer) (the instrument that
classifies a rejected cycle as real or artificial, [§5.6][s5-6]) labels it artificial. The ladder's
other two rungs are two remedies, and they apply in this order.
```

New:

```text
What survives the split is the case where a single component's stage-2 outputs
cross-couple through a neighbor. That case is port-level acyclic and stage-level
cyclic. The [feedthrough tracer](#g-feedthrough-tracer) (the instrument that classifies a rejected cycle
as real or artificial, [§5.6][s5-6]) labels it artificial. The ladder's other two rungs
are two remedies, and they apply in this order.
```

### Finding 18, unit E (edit)

Reason: the companion's path, spelled as the spec spells companion paths elsewhere (`companions/flight_case_studies.md` in §5.3).

Old:

```text
(the companion document `migration_outline.md`
  records the migration)
```

New:

```text
(`companions/migration_outline.md`
  records the migration)
```

Inventory: C-026.

### Finding 18, unit E (rewrap)

Reason: rewrap after the edit above.

Old:

```text
  Re-factoring the steering contract to emit `(engaged, ψ_cmd)`, and computing
  `ψ_sw = engaged ? ψ_cmd : ψ_v` inside the strut, deletes the backward wire
  outright. The factoring survives substitution. That is the test that it
  records structure rather than dodging the diagnostic ([D-140][d-140]). A
  stateful steering actuator produces `ψ_cmd` from its own state and still
  needs nothing from the strut (`companions/migration_outline.md`
  records the migration).
```

New:

```text
  Re-factoring the steering contract to emit `(engaged, ψ_cmd)`, and computing
  `ψ_sw = engaged ? ψ_cmd : ψ_v` inside the strut, deletes the backward wire
  outright. The factoring survives substitution. That is the test that it
  records structure rather than dodging the diagnostic ([D-140][d-140]). A stateful
  steering actuator produces `ψ_cmd` from its own state and still needs nothing
  from the strut (`companions/migration_outline.md` records the migration).
```

### Finding 17, unit E (edit)

Reason: payload had a link and no gloss; the gloss is the glossary's own (spec 13683).

Old:

```text
as a separate [payload](#g-payload) field rather than dotting
```

New:

```text
as a separate field of its [payload](#g-payload) (the structured data a diagnostic carries) rather than dotting
```

Inventory: C-040; added+.

### Finding 8, Finding 17, unit E (rewrap)

Reason: rewrap: a line ran to 82 rendered columns (finding 8), and the edit above.

Old:

```text
The build diagnostic offers both exits explicitly ([D-140][d-140]). It reads "cycle through
`systems/aero` is artificial at port level — split the component, or narrow the
neighbor's contract". The dead hop is the member with the input
[face](#g-face) (the name a port wears on its component's boundary) that it
does not route to the output port. The diagnostic carries the dead hop
([D-245][d-245]) as a separate field of its [payload](#g-payload) (the structured data a diagnostic carries) rather than dotting
it onto the path ([§8.6][s8-6], [§13.2][s13-2]).
```

New:

```text
The build diagnostic offers both exits explicitly ([D-140][d-140]). It reads "cycle
through `systems/aero` is artificial at port level — split the component, or
narrow the neighbor's contract". The dead hop is the member with the input [face](#g-face)
(the name a port wears on its component's boundary) that it does not route to
the output port. The diagnostic carries the dead hop ([D-245][d-245]) as a separate field
of its [payload](#g-payload) (the structured data a diagnostic carries) rather than dotting it
onto the path ([§8.6][s8-6], [§13.2][s13-2]).
```

### Finding 8, unit E (rewrap)

Reason: rewrap: a line ran to 87 rendered columns.

Old:

```text
The component split is rare, and the ladder is what earns that word rather than
asserting it ([D-140][d-140]). The two-stage split dissolves the common shapes, and the contract
re-factoring absorbs the false wires. What is left for the component split is
cycles whose halves really are one component's own work.
```

New:

```text
The component split is rare, and the ladder is what earns that word rather than
asserting it ([D-140][d-140]). The two-stage split dissolves the common shapes, and the
contract re-factoring absorbs the false wires. What is left for the component
split is cycles whose halves really are one component's own work.
```

### Finding 19, unit E (edit)

Reason: the sentence carried two parentheticals and ran to 120 rendered columns; split with every claim kept, `UnitDelay` and its §13.7 pointer moved to the caveat sentence.

Old:

```text
They can insert
dynamics (the α-filter idiom, a filter state inserted in the loop), insert an
explicit unit delay (`UnitDelay`, [§13.7][s13-7]), or restructure. The α-filter idiom is already standard practice in the domain.
```

New:

```text
They can insert
dynamics, insert an explicit unit delay, or restructure. Inserting dynamics is the α-filter idiom (a filter state inserted in the loop), already standard practice in the domain.
```

Inventory: C-053; C-053 newcites=[]; C-054; C-055.

### Finding 19, unit E (rewrap)

Reason: rewrap after the edit above.

Old:

```text
The user breaks the cycle explicitly, by one of three routes. They can insert
dynamics, insert an explicit unit delay, or restructure. Inserting dynamics is the α-filter idiom (a filter state inserted in the loop), already standard practice in the domain.
```

New:

```text
The user breaks the cycle explicitly, by one of three routes. They can insert
dynamics, insert an explicit unit delay, or restructure. Inserting dynamics is
the α-filter idiom (a filter state inserted in the loop), already standard
practice in the domain.
```

### Finding 19, unit E (edit)

Reason: `UnitDelay` and its §13.7 pointer, moved from the three-routes sentence.

Old:

```text
The unit delay carries a caveat.
```

New:

```text
The unit delay, `UnitDelay` ([§13.7][s13-7]), carries a caveat.
```

Inventory: C-056; C-056 newcites=['§13.7'].

### Finding 17, unit E (edit)

Reason: §5.5's tier had a link and no gloss.

Old:

```text
It changes the model's [tier](#g-tier)
structure.
```

New:

```text
It changes the model's [tier](#g-tier)
structure (its split into continuous and discrete sides).
```

Inventory: C-057; added+.

### Finding 20, unit E (edit)

Reason: `N_base·h` uses h as the step size right after §5.3 made h the output map; the glossary keeps the formula (spec 13001-13002).

Old:

```text
integer multiple `N_base·h`)
```

New:

```text
integer multiple of the continuous step)
```

Inventory: C-058.

### Finding 8, Finding 19, Finding 17, Finding 20, unit E (rewrap)

Reason: rewrap: lines ran to 97 rendered columns and a sentence started on a new line after a lone citation (L540-542) (finding 8), and the three edits above.

Old:

```text
The unit delay, `UnitDelay` ([§13.7][s13-7]), carries a caveat. It changes the model's [tier](#g-tier)
structure (its split into continuous and discrete sides). The broken signal becomes discrete, sampled on a
period on the scale of [`Δt_base`](#g-dt_base) (the base tick period, an
integer multiple of the continuous step). That is a modeling decision, not a transparent wire. The diagnostic
states this caveat rather than offering the delay as a free remedy
([§13.7][s13-7]).
Implicit delays and per-step numerical loop solving are both closed
([D-005][d-005]).
```

New:

```text
The unit delay, `UnitDelay` ([§13.7][s13-7]), carries a caveat. It changes the model's
[tier](#g-tier) structure (its split into continuous and discrete sides). The broken signal
becomes discrete, sampled on a period on the scale of [`Δt_base`](#g-dt_base) (the base tick
period, an integer multiple of the continuous step). That is a modeling
decision, not a transparent wire. The diagnostic states this caveat rather than
offering the delay as a free remedy ([§13.7][s13-7]). Implicit delays and per-step
numerical loop solving are both closed ([D-005][d-005]).
```

## Unit F

### Finding 21, unit F (edit)

Reason: the gloss defined the tracer by the tracing; it now states the job, from §5.6's own tracer-tags sentence and glossary 13672.

Old:

```text
(the set-propagation instrument
that does the tracing)
```

New:

```text
(the set-propagation instrument
that tracks which inputs a value depends on)
```

Inventory: F-005; added.

### Finding 8, Finding 21, unit F (rewrap)

Reason: rewrap: a line ran to 116 rendered columns (finding 8), and the edit above.

Old:

```text
**Tracing is diagnostic only**, never relied on for correctness
([D-012][d-012]). Ordering correctness comes exclusively from the structural
two-stage split. Tracing improves error messages and verification. When the
build finds a cycle, it triggers the
[feedthrough tracer](#g-feedthrough-tracer) (the set-propagation instrument
that tracks which inputs a value depends on) to classify that cycle. A genuine cycle gets "insert a state", and an artificial one gets the
remedy ladder ([§5.4][s5-4]). The parts below cover, in order, how a cycle is
detected and named, the tracer's two modes and what tracing touches, how
classification runs and decides, and the caveats the diagnostic carries.
```

New:

```text
**Tracing is diagnostic only**, never relied on for correctness ([D-012][d-012]). Ordering
correctness comes exclusively from the structural two-stage split. Tracing
improves error messages and verification. When the build finds a cycle, it
triggers the [feedthrough tracer](#g-feedthrough-tracer) (the set-propagation instrument that tracks
which inputs a value depends on) to classify that cycle. A genuine cycle gets
"insert a state", and an artificial one gets the remedy ladder ([§5.4][s5-4]). The parts
below cover, in order, how a cycle is detected and named, the tracer's two modes
and what tracing touches, how classification runs and decides, and the caveats
the diagnostic carries.
```

### Finding 22, unit F (edit)

Reason: the or-from-structure clause and its D-245 citation repeated the bold ruling two paragraphs on, its home; the distinction stays.

Old:

```text
A
member's map may come from either mode, or from structure ([D-245][d-245]).
```

New:

```text
A
member's map may come from either mode.
```

Inventory: added.

### Finding 22, unit F (rewrap)

Reason: rewrap after the edit above.

Old:

```text
Classification touches no activation machinery. There is no
[activation](#g-activation) (the build's typed products at a given scalar
type), no layouts and no table. The cycle classifier uses the *local* variant
of tracing ([D-012][d-012]), the order-free per-member trace at the probe
point. The "tracer activation" ([§9.4][s9-4]) names the other variant
([D-012][d-012]), the global set-tracer run as an ordinary activation. The two
must not be conflated. The local variant is not the local set-tracer mode. A
member's map may come from either mode.
```

New:

```text
Classification touches no activation machinery. There is no [activation](#g-activation) (the
build's typed products at a given scalar type), no layouts and no table. The
cycle classifier uses the *local* variant of tracing ([D-012][d-012]), the order-free
per-member trace at the probe point. The "tracer activation" ([§9.4][s9-4]) names the
other variant ([D-012][d-012]), the global set-tracer run as an ordinary activation. The
two must not be conflated. The local variant is not the local set-tracer mode. A
member's map may come from either mode.
```

### Finding 23, unit F (edit)

Reason: probe point is §5.6's term of art, glossed above as the initial state; one name for one thing.

Old:

```text
at the probe state (the
```

New:

```text
at the probe point (the
```

Inventory: F-052.

### Finding 23, unit F (rewrap)

Reason: rewrap after the edit above.

Old:

```text
The diagnostic carries the tracer's caveats rather than assuming them away. The
trace speaks for the branch taken at the probe point (the diagnostic-only
doctrine, [D-012][d-012]). **Discrete members trace structurally**, because
the discrete [tier](#g-tier)'s plain, wholesale-pinning declarations admit no
tracer scalar ([D-012][d-012]). Structural tracing is sound as a may-depend
answer but never sharp, so the remedy hint is offered only for continuous
members ([D-140][d-140]). A continuous face or port declared with no
[walking](#g-walked) leaf (one whose type follows the activation scalar) admits
no tracer scalar either, so the hops through it trace structurally too
([D-245][d-245]).
```

New:

```text
The diagnostic carries the tracer's caveats rather than assuming them away. The
trace speaks for the branch taken at the probe point (the diagnostic-only
doctrine, [D-012][d-012]). **Discrete members trace structurally**, because the discrete
[tier](#g-tier)'s plain, wholesale-pinning declarations admit no tracer scalar ([D-012][d-012]).
Structural tracing is sound as a may-depend answer but never sharp, so the
remedy hint is offered only for continuous members ([D-140][d-140]). A continuous face or
port declared with no [walking](#g-walked) leaf (one whose type follows the activation
scalar) admits no tracer scalar either, so the hops through it trace
structurally too ([D-245][d-245]).
```

### Finding 24, unit F (edit)

Reason: the sentence carried a gloss and a second parenthetical; the ladder pointer becomes a sentence of its own, restating §5.4's two remedies.

Old:

```text
consumed only in a fallback branch (the ladder, [§5.4][s5-4], [D-140][d-140]).
```

New:

```text
consumed only in a fallback branch. Those are the ladder's two remedies ([§5.4][s5-4], [D-140][d-140]).
```

Inventory: F-058; added+.

### Finding 24, unit F (rewrap)

Reason: rewrap after the edit above.

Old:

```text
**The diagnostic records the source of each member's map** ([D-245][d-245]).
The source is the global tracer, sampled states or structure. A reader can
thus weigh a dead hop found on a few sampled paths against one found exactly.
The hint itself is to split this component, *or* to narrow the neighbor's
[contract](#g-contract) (its declared interface) when the dead hop's input is
consumed only in a fallback branch. Those are the ladder's two remedies ([§5.4][s5-4], [D-140][d-140]).
If a member's evaluation itself throws, the diagnostic ships with its members
and wires alone, unclassified. Classification is a bonus on the cycle
error, never its precondition ([D-012][d-012]).
```

New:

```text
**The diagnostic records the source of each member's map** ([D-245][d-245]). The source is
the global tracer, sampled states or structure. A reader can thus weigh a dead
hop found on a few sampled paths against one found exactly. The hint itself is
to split this component, *or* to narrow the neighbor's [contract](#g-contract) (its declared
interface) when the dead hop's input is consumed only in a fallback branch.
Those are the ladder's two remedies ([§5.4][s5-4], [D-140][d-140]). If a member's evaluation
itself throws, the diagnostic ships with its members and wires alone,
unclassified. Classification is a bonus on the cycle error, never its
precondition ([D-012][d-012]).
```

## Unit E, finding 19 revised

### Finding 19 (revised), unit E (edit)

Reason: the proposed 'Inserting dynamics is the α-filter idiom' made the idiom the only way to insert dynamics; unit E's verifier kept the gloss inside the routes sentence for that reason (units/E/rulings.md). The idiom is now one way, and its standard-practice claim keeps its own clause.

Old:

```text
Inserting dynamics is
the α-filter idiom (a filter state inserted in the loop), already standard
practice in the domain.
```

New:

```text
The α-filter idiom
(a filter state inserted in the loop) is one way to insert dynamics, and it is already standard
practice in the domain.
```

Inventory: C-054; C-055.

### Finding 19 (revised), unit E (rewrap)

Reason: rewrap after the edit above.

Old:

```text
The user breaks the cycle explicitly, by one of three routes. They can insert
dynamics, insert an explicit unit delay, or restructure. The α-filter idiom
(a filter state inserted in the loop) is one way to insert dynamics, and it is already standard
practice in the domain.
```

New:

```text
The user breaks the cycle explicitly, by one of three routes. They can insert
dynamics, insert an explicit unit delay, or restructure. The α-filter idiom (a
filter state inserted in the loop) is one way to insert dynamics, and it is
already standard practice in the domain.
```

### Findings 16, 18, 19, 22 and 23, units D, E and F (rulings.md)

Reason: keep each unit's `rulings.md` in step where it quotes text these
fixes changed.

- `units/D/rulings.md`, R5 F3 entry: appended a note that finding 16 moved
  the introducing sentence before the use ("of its *Mode engage* frame").
- `units/E/rulings.md`, "Names the old text left cold": appended a note on
  finding 18's path and finding 19's split, including why the α-filter
  sentence says "one way to insert dynamics".
- `units/F/rulings.md`, the two added "local" sentences: appended a note that
  finding 22 dropped ", or from structure ([D-245])".
- `units/F/rulings.md`, Rationale-only table, F-052 row: "taken at the probe
  state" now reads "taken at the probe point, "probe state" in the old text,
  renamed by chapter pass finding 23".

### Finding 9, unit C (rulings.md)

Reason: "Inbound citations affected" said log 7046's words were kept
verbatim. Finding 9 put "right-hand side (RHS)" into that sentence. The log
paraphrases §5.3 without quotation marks and cites it, so the citation still
holds. The note now says so.

### R18, R19, findings 1 and 6, unit A (rulings.md)

Reason: keep unit A's `rulings.md` in step with R18, R19 and the two
editorial edits it quotes.

- R1 entry: appended that R18 widened §5.1's clause to §5.4, §5.5 and §5.6,
  and that finding 1 added "supervisory inputs" to the roadmap.
- New bullet for R19 with its sources (the signature block, glossary 12792
  and 12934).
- R13 entry: the quoted cell gloss now reads "(concretely typed table
  entries, one per output port)" (finding 6).
- "Section pointers added": §5.4, §5.5 and §5.6 in §5.1's clause (R18).

## Final verify fixes

Two antecedent slips the final verifier found, with the wording the
coordinator gave.

Unit D:

### Final verify 1, unit D (edit)

Reason: after finding 14's sentence, 'the dependency' sat four sentences from its referent; name it.

Old:

```text
The feedthrough graph carries the dependency.
```

New:

```text
The feedthrough graph carries the compensators' dependence on the gains.
```

Inventory: C-034; added+.

### Final verify 1, unit D (rewrap)

Reason: rewrap after the edit above.

Old:

```text
**Scheduled gains are inputs** ([D-089][d-089]). A scheduler component owns the lookup tables
as inert parameters, reads the scheduling variables as inputs, and publishes one
gain bundle per compensator. Compensators consume gains as `u`. Ports expose
what mutation would hide. Gain trajectories are observable in log, [trace](#g-trace) and
[replay](#g-replay), where a parameter write would be invisible to all three. The trace is
the session's recorded inputs, and replay re-drives the ordinary loop from that
trace. The feedthrough graph carries the compensators' dependence on the gains. Linearization holds
unseeded gain inputs constant with no special casing ([§14.10][s14-10]). One-shot
design-time gains, such as a controller synthesized at init, are
construction-time parameters or stopped-sim service outputs ([D-089][d-089]). They are
not a runtime write path.
```

New:

```text
**Scheduled gains are inputs** ([D-089][d-089]). A scheduler component owns the lookup tables
as inert parameters, reads the scheduling variables as inputs, and publishes one
gain bundle per compensator. Compensators consume gains as `u`. Ports expose
what mutation would hide. Gain trajectories are observable in log, [trace](#g-trace) and
[replay](#g-replay), where a parameter write would be invisible to all three. The trace is
the session's recorded inputs, and replay re-drives the ordinary loop from that
trace. The feedthrough graph carries the compensators' dependence on the gains.
Linearization holds unseeded gain inputs constant with no special casing
([§14.10][s14-10]). One-shot design-time gains, such as a controller synthesized at init,
are construction-time parameters or stopped-sim service outputs ([D-089][d-089]). They
are not a runtime write path.
```

Unit E:

### Final verify 2, unit E (edit)

Reason: finding 17's payload gloss separated 'it' from 'the dead hop'; name the hop.

Old:

```text
rather than dotting it
onto the path
```

New:

```text
rather than dotting the hop
onto the path
```

Inventory: C-040.

### Final verify 2, unit E (rewrap)

Reason: rewrap after the edit above.

Old:

```text
The build diagnostic offers both exits explicitly ([D-140][d-140]). It reads "cycle
through `systems/aero` is artificial at port level — split the component, or
narrow the neighbor's contract". The dead hop is the member with the input [face](#g-face)
(the name a port wears on its component's boundary) that it does not route to
the output port. The diagnostic carries the dead hop ([D-245][d-245]) as a separate field
of its [payload](#g-payload) (the structured data a diagnostic carries) rather than dotting the hop
onto the path ([§8.6][s8-6], [§13.2][s13-2]).
```

New:

```text
The build diagnostic offers both exits explicitly ([D-140][d-140]). It reads "cycle
through `systems/aero` is artificial at port level — split the component, or
narrow the neighbor's contract". The dead hop is the member with the input [face](#g-face)
(the name a port wears on its component's boundary) that it does not route to
the output port. The diagnostic carries the dead hop ([D-245][d-245]) as a separate field
of its [payload](#g-payload) (the structured data a diagnostic carries) rather than dotting
the hop onto the path ([§8.6][s8-6], [§13.2][s13-2]).
```

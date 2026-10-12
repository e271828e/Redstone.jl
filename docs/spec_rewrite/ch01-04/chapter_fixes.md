# Editorial fixes: chapters 1 to 4 (step 5)

The editorial fixer's log. It applies the EDITORIAL findings of
`chapter_pass.md` and rulings R18 to R20 of `brief.md` to the units' `new.md`
files, in the order below. Each entry gives the finding or ruling id, the
unit, the reason, the exact old text and the exact new text. Replaying the
entries in order on the units at commit f8afe64 reproduces the fixed units.
Rewraps are logged as their own entries, whole paragraph or bullet. Inventory
changes are noted per entry; they are not replayed text.

### E1. F34, unit A

Reason: Trim the trailing blank line that doubles the blank line at the A/B seam.

Old:

~~~~
entry there.

---


~~~~

New:

~~~~
entry there.

---

~~~~

### E2. F2, unit B

Reason: Chapter 2 has no 'published table'; chapters 3 and 4 call it the signal table. One word, no claim.

Inventory: added[0] gains 'signal'.

Old:

~~~~
also receives the published table, and
~~~~

New:

~~~~
also receives the published signal table, and
~~~~

### E3. F2 rewrap, unit B

Reason: rewrap to 80 rendered columns

Old:

~~~~
- Continuous dynamics. $\dot{x} = f(x, m, u, t)$ with algebraic outputs. This
  design's `f` also receives the published signal table, and the composite map from
  `x` to $\dot{x}$ is mathematically identical to the textbook form's ([§5.3][s5-3]).
~~~~

New:

~~~~
- Continuous dynamics. $\dot{x} = f(x, m, u, t)$ with algebraic outputs. This
  design's `f` also receives the published signal table, and the composite map
  from `x` to $\dot{x}$ is mathematically identical to the textbook form's ([§5.3][s5-3]).
~~~~

### E4. F3, unit B

Reason: The citation split 'held zero-order ... between ticks', and the tick gloss stacked a second parenthetical in the clause; the gloss becomes its own sentence.

Inventory: B-005 moves D-019 after 'ticks'; the added gloss becomes the sentence 'A tick is an instant ...'.

Old:

~~~~
with outputs held zero-order ([D-019][d-019]) between
  [ticks](#g-tick) (instants at which a discrete component's stages and update
  run).
~~~~

New:

~~~~
with outputs held zero-order between [ticks](#g-tick) ([D-019][d-019]). A tick is an instant at which a discrete component's stages and update run.
~~~~

### E5. F3 rewrap, unit B

Reason: rewrap to 80 rendered columns

Old:

~~~~
- Multi-rate periodic discrete dynamics. $s^{+} = g(s, u, t)$ at declared
  rates, with outputs held zero-order between [ticks](#g-tick) ([D-019][d-019]). A tick is an instant at which a discrete component's stages and update run.
~~~~

New:

~~~~
- Multi-rate periodic discrete dynamics. $s^{+} = g(s, u, t)$ at declared rates,
  with outputs held zero-order between [ticks](#g-tick) ([D-019][d-019]). A tick is an instant at
  which a discrete component's stages and update run.
~~~~

### E6. F4, unit B

Reason: ', stated below' repeated the roadmap sentence that ends the lead.

Inventory: B-006 drops ', stated below'.

Old:

~~~~
under two detection policies, stated below.
~~~~

New:

~~~~
under two detection policies.
~~~~

### E7. F5, unit B

Reason: The prior's appositive gloss nested the boundary's gloss; it becomes its own sentence.

Inventory: B-040's new span ends after 'the prior.' and continues with 'The prior is each event's ...'.

Old:

~~~~
states the bookkeeping of the [prior](#g-prior), each event's
predicate sample stored
~~~~

New:

~~~~
states the bookkeeping of the [prior](#g-prior). The prior is each event's
predicate sample stored
~~~~

### E8. F1, unit B

Reason: Guarded addition took a gloss here unlike its gloss in §1, §3.4 and §4.3, and 'recorded' stood twice; the shared gloss carries 'unbuilt'.

Inventory: added[3] (the D-180 sentence) replaced by the new sentence.

Old:

~~~~
A per-event
`direction` keyword is recorded as a
[guarded addition](#g-guarded-addition) (a capability recorded with its shape
so adoption stays additive), unbuilt ([D-180][d-180]).
~~~~

New:

~~~~
[D-180][d-180] records a per-event `direction` keyword as a [guarded addition](#g-guarded-addition) (a capability the design admits but does not build).
~~~~

### E9. F5, F1, F33 rewrap, unit B

Reason: rewrap to 80 rendered columns

Old:

~~~~
**An event fires when its predicate transitions from not-holding to holding**
([D-082][d-082], [D-001][d-001]). This is
[edge semantics](#g-edge-semantics), and it is uniform across both forms.
[§10.6][s10-6] states the bookkeeping of the [prior](#g-prior). The prior is each event's
predicate sample stored at the previous [boundary](#g-boundary) (a published
consistency point). The opposite crossing
direction is declared as a second event with the negated guard
([D-082][d-082]). Stall entry and exit are one such pair. [D-180][d-180] records a per-event `direction` keyword as a [guarded addition](#g-guarded-addition) (a capability the design admits but does not build).
~~~~

New:

~~~~
**An event fires when its predicate transitions from not-holding to holding**
([D-082][d-082], [D-001][d-001]). This is [edge semantics](#g-edge-semantics), and it is uniform across both forms.
[§10.6][s10-6] states the bookkeeping of the [prior](#g-prior). The prior is each event's predicate
sample stored at the previous [boundary](#g-boundary) (a published consistency point). The
opposite crossing direction is declared as a second event with the negated guard
([D-082][d-082]). Stall entry and exit are one such pair. [D-180][d-180] records a per-event
`direction` keyword as a [guarded addition](#g-guarded-addition) (a capability the design admits but does
not build).
~~~~

### E10. F6, unit B

Reason: 'per iteration round' was reader-cold in §2.1; §10.6 (base 6093-6099) defines a round as one pass of the boundary's event phase.

Inventory: B-018's new span follows.

Old:

~~~~
per event
  per iteration round ([§10.6][s10-6]).
~~~~

New:

~~~~
per event
  per round of the boundary's event iteration ([§10.6][s10-6]).
~~~~

### E11. F6, F33 rewrap, unit B

Reason: rewrap to 80 rendered columns

Old:

~~~~
- Boundary-detected (cheap). The framework checks each guard for a
  not-holding → holding edge against its prior ([§10.6][s10-6]) at step
  boundaries only. There is no
  root-finding and no step rejection. The handler fires at the end of the step
  in which the edge was observed. The cost is one guard evaluation per event
  per round of the boundary's event iteration ([§10.6][s10-6]). This policy is fully compatible with
  fixed-step real-time execution.
~~~~

New:

~~~~
- Boundary-detected (cheap). The framework checks each guard for a not-holding →
  holding edge against its prior ([§10.6][s10-6]) at step boundaries only. There is no
  root-finding and no step rejection. The handler fires at the end of the step
  in which the edge was observed. The cost is one guard evaluation per event per
  round of the boundary's event iteration ([§10.6][s10-6]). This policy is fully
  compatible with fixed-step real-time execution.
~~~~

### E12. F7, unit B

Reason: 'This arrangement' followed the pacing paragraph and read as the pacer's; its referent is the edge-plus-two-policies scheme.

Inventory: B-032's new span follows.

Old:

~~~~
This arrangement gives step-boundary logic
~~~~

New:

~~~~
The two-policy arrangement gives step-boundary logic
~~~~

### E13. F8, unit B

Reason: First use of tier in the spec body, linked inside the bold with no gloss; the gloss is the glossary's wording (base 13288).

Inventory: added gains 'A tier is one side of the hybrid formalism, continuous or discrete.'

Old:

~~~~
([D-220][d-220]). Ticks are declared by
~~~~

New:

~~~~
([D-220][d-220]). A tier is one side of the hybrid formalism, continuous or discrete. Ticks are declared by
~~~~

### E14. F8 rewrap, unit B

Reason: rewrap to 80 rendered columns

Old:

~~~~
Time events and state events differ in how their instants are found. **The
discrete [tier](#g-tier)'s [ticks](#g-tick) are [time events](#g-time-event)**
([D-220][d-220]). A tier is one side of the hybrid formalism, continuous or discrete. Ticks are declared by `sample_times`. Their instants are known
in advance and scheduled ([§10.5][s10-5]). Everything declared through
`StateEvent(guard, handler)` is a [state event](#g-state-event). Its instant is
unknown and must be detected, by boundary check or by localization. That is why
the declaration is named `state_events` ([§8.2][s8-2], [D-220][d-220]). The
criterion is detection versus scheduling, not which fields a guard reads. A
guard over an input is still a state event.
~~~~

New:

~~~~
Time events and state events differ in how their instants are found. **The
discrete [tier](#g-tier)'s [ticks](#g-tick) are [time events](#g-time-event)** ([D-220][d-220]). A tier is one side of the hybrid
formalism, continuous or discrete. Ticks are declared by `sample_times`. Their
instants are known in advance and scheduled ([§10.5][s10-5]). Everything declared through
`StateEvent(guard, handler)` is a [state event](#g-state-event). Its instant is unknown and must be
detected, by boundary check or by localization. That is why the declaration is
named `state_events` ([§8.2][s8-2], [D-220][d-220]). The criterion is detection versus scheduling,
not which fields a guard reads. A guard over an input is still a state event.
~~~~

### E15. F10, unit B

Reason: 'turbulence' stood twice; the fix restores the old text's 'Dryden/von Kármán turbulence' (old 285), which keeps R16's content.

Inventory: B-051's new span follows.

Old:

~~~~
such as sensor noise and turbulence from Dryden/von Kármán
  turbulence models, are
~~~~

New:

~~~~
such as sensor noise and Dryden/von Kármán
  turbulence, are
~~~~

### E16. F10, F33 rewrap, unit B

Reason: rewrap to 80 rendered columns

Old:

~~~~
- No stochastic differential equations (SDEs) or stochastic integrators. Noise
  processes, such as sensor noise and Dryden/von Kármán
  turbulence, are modeled as shaping filters ([D-001][d-001]), that is,
  as ordinary discrete processes driven by a random number generator (RNG).
  That modeling is
  faithful to how the noise processes are specified, and it is cheap. One
  consequence is elevated to a framework guarantee, deterministic
  [replay](#g-replay) (re-running the ordinary loop on a recorded input trace).
  RNG state lives in [component](#g-component) discrete state `s`, never in
  ambient globals, so the same seed gives a bit-identical trajectory
  ([D-231][d-231]).
~~~~

New:

~~~~
- No stochastic differential equations (SDEs) or stochastic integrators. Noise
  processes, such as sensor noise and Dryden/von Kármán turbulence, are modeled
  as shaping filters ([D-001][d-001]), that is, as ordinary discrete processes driven by
  a random number generator (RNG). That modeling is faithful to how the noise
  processes are specified, and it is cheap. One consequence is elevated to a
  framework guarantee, deterministic [replay](#g-replay) (re-running the ordinary loop on a
  recorded input trace). RNG state lives in [component](#g-component) discrete state `s`, never in
  ambient globals, so the same seed gives a bit-identical trajectory ([D-231][d-231]).
~~~~

### E17. F12, unit C

Reason: §3.1's first plain use of component is here, not at 'a component with no continuous state'; the link moves to it.

Old:

~~~~
may reset the
  component's own `x`
~~~~

New:

~~~~
may reset the
  [component](#g-component)'s own `x`
~~~~

### E18. F12 rewrap, unit C

Reason: rewrap to 80 rendered columns

Old:

~~~~
- Events, each a [guard](#g-guard) (the declared function defining an event's
  predicate) plus a handler. A handler may update `m` and may reset the
  [component](#g-component)'s own `x` ([D-090][d-090]). Both guard and handler read the fresh
  [boundary](#g-boundary) [signal table](#g-signal-table) ([§5.3][s5-3],
  [D-154][d-154]).
~~~~

New:

~~~~
- Events, each a [guard](#g-guard) (the declared function defining an event's predicate)
  plus a handler. A handler may update `m` and may reset the [component](#g-component)'s own `x`
  ([D-090][d-090]). Both guard and handler read the fresh [boundary](#g-boundary) [signal table](#g-signal-table) ([§5.3][s5-3],
  [D-154][d-154]).
~~~~

### E19. F12, unit C

Reason: The link moved to the first use; one link per term per section.

Old:

~~~~
In particular, a [component](#g-component) with *no*
~~~~

New:

~~~~
In particular, a component with *no*
~~~~

### E20. F12 rewrap, unit C

Reason: rewrap to 80 rendered columns

Old:

~~~~
Any facet may be empty. In particular, a component with *no*
continuous state, only modes, events and mode-valued outputs, is a finite-state
machine (FSM). **A single primitive supports both factorings of mode logic**
([D-003][d-003]).
~~~~

New:

~~~~
Any facet may be empty. In particular, a component with *no* continuous state,
only modes, events and mode-valued outputs, is a finite-state machine (FSM). **A
single primitive supports both factorings of mode logic** ([D-003][d-003]).
~~~~

### E21. F11, unit C

Reason: R7's clause used the reserved word 'condition' in the log's sense; R7's content and its 'reset of state' are unchanged.

Inventory: added: the R7 sentence follows.

Old:

~~~~
a commanded reset of state, whose
condition arrives as an input, still lands
~~~~

New:

~~~~
a reset of state commanded through an input still lands
~~~~

### E22. F11 rewrap, unit C

Reason: rewrap to 80 rendered columns

Old:

~~~~
The rule of meaning separates a command from a detection. A supervisor
*commanding* a mode change is an ordinary input. A component *detecting* its
own transition is an event. The two mechanisms carry two meanings and do not
overlap. On the continuous [tier](#g-tier), a reset of state commanded through an input still lands through an event whose guard reads
that input ([§5.3][s5-3], [D-141][d-141]).
~~~~

New:

~~~~
The rule of meaning separates a command from a detection. A supervisor
*commanding* a mode change is an ordinary input. A component *detecting* its own
transition is an event. The two mechanisms carry two meanings and do not
overlap. On the continuous [tier](#g-tier), a reset of state commanded through an input
still lands through an event whose guard reads that input ([§5.3][s5-3], [D-141][d-141]).
~~~~

### E23. F33 rewrap, unit C

Reason: rewrap to 80 rendered columns

Old:

~~~~
- An external FSM component feeding modes through a [port](#g-port) (the
  addressable unit of the model) gives maximal
  purity, independent testability and swappable supervision logic.
~~~~

New:

~~~~
- An external FSM component feeding modes through a [port](#g-port) (the addressable unit
  of the model) gives maximal purity, independent testability and swappable
  supervision logic.
~~~~

### E24. F34, unit C

Reason: Trim the trailing blank line that doubles the blank line at the C/D seam. The file's last two bytes '\n\n' become '\n'.

Old:

~~~~
[D-019][d-019]).

<end of file>
~~~~

New:

~~~~
[D-019][d-019]).
<end of file>
~~~~

### E25. F15, unit D

Reason: One hypothetical went by four names in §3.4; D-056 names it 'All-in-one component kind'.

Inventory: C-011's new span follows.

Old:

~~~~
force a merged component's two halves
~~~~

New:

~~~~
force an all-in-one component's two halves
~~~~

### E26. F13, F15, unit D

Reason: The routing ruling's citation sat inside the cell gloss, and the sentence stacked two glosses; 'cells of the published signal table' glosses cell with no parenthetical. 'merged component' becomes 'all-in-one component' (finding 15).

Inventory: C-017's new span follows.

Old:

~~~~
Influence across [tiers](#g-tier) (the continuous and
discrete sides of the formalism) inside a merged component still routes
through published table [cells](#g-cell) (typed entries of the signal table,
[D-056][d-056]).
~~~~

New:

~~~~
Inside an all-in-one component, influence across [tiers](#g-tier) (the continuous and discrete sides of the formalism) still routes through [cells](#g-cell) of the published signal table ([D-056][d-056]).
~~~~

### E27. F13, F15 rewrap, unit D

Reason: rewrap to 80 rendered columns

Old:

~~~~
The settled rules force an all-in-one component's two halves to communicate exactly
as two siblings do ([D-056][d-056]). There is
[one home per datum](#g-one-home-per-datum) (no store mirrors another,
[§5.2][s5-2]). `x_deriv` sees only the continuous state, and `s_update` only
the discrete one. And `s⁺` is decoded only at the owner's next tick, because
`s_update` runs last. That deferred decode is what makes ticks→events
structurally impossible ([D-020][d-020]). It is also what terminates the
iteration at each [boundary](#g-boundary) (a published consistency point,
[§10.6][s10-6]). Inside an all-in-one component, influence across [tiers](#g-tier) (the continuous and discrete sides of the formalism) still routes through [cells](#g-cell) of the published signal table ([D-056][d-056]).
~~~~

New:

~~~~
The settled rules force an all-in-one component's two halves to communicate
exactly as two siblings do ([D-056][d-056]). There is [one home per datum](#g-one-home-per-datum) (no store
mirrors another, [§5.2][s5-2]). `x_deriv` sees only the continuous state, and `s_update`
only the discrete one. And `s⁺` is decoded only at the owner's next tick, because
`s_update` runs last. That deferred decode is what makes ticks→events structurally
impossible ([D-020][d-020]). It is also what terminates the iteration at each [boundary](#g-boundary) (a
published consistency point, [§10.6][s10-6]). Inside an all-in-one component, influence
across [tiers](#g-tier) (the continuous and discrete sides of the formalism) still routes
through [cells](#g-cell) of the published signal table ([D-056][d-056]).
~~~~

### E28. F14, unit D

Reason: The added definition restated §3.3's first sentence, one section earlier, between the verdict and its consequence; it becomes an inline gloss and the pronoun returns (old 'It buys no expressiveness').

Inventory: added 'An assembly is a component of pure composition.' becomes '(pure composition)'; C-018 and C-019 follow.

Old:

~~~~
an [assembly](#g-assembly) of two
primitives in a trench coat ([D-056][d-056]). An assembly is a component of
pure composition. The all-in-one component buys no expressiveness.
~~~~

New:

~~~~
an [assembly](#g-assembly) (pure composition) of two
primitives in a trench coat ([D-056][d-056]). It buys no expressiveness.
~~~~

### E29. F14 rewrap, unit D

Reason: rewrap to 80 rendered columns

Old:

~~~~
The all-in-one component is therefore an [assembly](#g-assembly) (pure composition) of two
primitives in a trench coat ([D-056][d-056]). It buys no expressiveness. It incurs
costs of its own, which [D-056][d-056] enumerates. One of those costs is not
bookkeeping. The sampling interface is the zero-order hold (ZOH) plus the
one-sample `z⁻¹` delay. It is the most bug-prone boundary in a flight-control
stack. A monolith swallows it. The split keeps it a visible wire.
~~~~

New:

~~~~
The all-in-one component is therefore an [assembly](#g-assembly) (pure composition) of two
primitives in a trench coat ([D-056][d-056]). It buys no expressiveness. It incurs costs
of its own, which [D-056][d-056] enumerates. One of those costs is not bookkeeping. The
sampling interface is the zero-order hold (ZOH) plus the one-sample `z⁻¹` delay.
It is the most bug-prone boundary in a flight-control stack. A monolith swallows
it. The split keeps it a visible wire.
~~~~

### E30. F16, unit D

Reason: Unit D touched this sentence (R5), and 'condition' is a reserved word; predicate is the sense §2.1 defines.

Inventory: C-034's new span follows.

Old:

~~~~
The reset is periodic, not condition-triggered,
~~~~

New:

~~~~
The reset is periodic, not predicate-triggered,
~~~~

### E31. F16, F33 rewrap, unit D

Reason: rewrap to 80 rendered columns

Old:

~~~~
The reset is periodic, not predicate-triggered, so events are the wrong
mechanism ([D-056][d-056]). And the reset is a discrete-tier write into
continuous state, exactly the operation this design forbids ([D-056][d-056]).
`s_update` writes only its own `s`. Guard-driven handlers are the sole
resetters of continuous state ([D-141][d-141]). Integrate-and-dump falls
squarely into the crack between the two leaf
classes. It is tightly coupled continuous
and periodic dynamics in one physical instrument.
~~~~

New:

~~~~
The reset is periodic, not predicate-triggered, so events are the wrong
mechanism ([D-056][d-056]). And the reset is a discrete-tier write into continuous state,
exactly the operation this design forbids ([D-056][d-056]). `s_update` writes only its own
`s`. Guard-driven handlers are the sole resetters of continuous state ([D-141][d-141]).
Integrate-and-dump falls squarely into the crack between the two leaf classes.
It is tightly coupled continuous and periodic dynamics in one physical
instrument.
~~~~

### E32. F17, unit D

Reason: The added '`Dual` is ForwardDiff's dual number.' split the third gain from its reason; it folds into the activation gloss, which still claims only the glossary's 'typed products at a given scalar type'.

Inventory: added '`Dual` is ForwardDiff's dual number.' removed; C-049's gloss follows.

Old:

~~~~
Third, linearization got sane. `Dual` is
ForwardDiff's dual number. Under a `Dual`
[activation](#g-activation) (the build's typed products at a given scalar
type) the discrete tier is held
~~~~

New:

~~~~
Third, linearization got sane. Under a `Dual`
[activation](#g-activation) (the build's typed products at ForwardDiff's dual-number scalar
type) the discrete tier is held
~~~~

### E33. F17, F33 rewrap, unit D

Reason: rewrap to 80 rendered columns

Old:

~~~~
The strongest counterexample landed on the two-class taxonomy with *less* code
than the direct formulation. It keeps the same thirteen integral scalars and
the same math, minus the reset block. It brings three structural gains. First,
the sampling interface became a wire. Second, the error model became a
discrete sibling, which makes the truth/corrupted sample pair separately
loggable ([§8.6][s8-6]). Third, linearization got sane. Under a `Dual`
[activation](#g-activation) (the build's typed products at ForwardDiff's dual-number scalar
type) the discrete tier is held ([§8.2][s8-2]). And "integrators that never
reset" *is* the cumulative formulation. The framework's rules pushed the IMU
into the only form that the framework's own linearization semantics could
coherently handle.
~~~~

New:

~~~~
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
~~~~

### E34. F19, unit D

Reason: Two §8.6 pointers four paragraphs apart said the same thing; 'also' marks the second as a continuation (optional fix, as proposed).

Inventory: C-042's new span follows.

Old:

~~~~
[§8.6][s8-6] spells that idiom,
~~~~

New:

~~~~
[§8.6][s8-6] also spells that idiom,
~~~~

### E35. F19 rewrap, unit D

Reason: rewrap to 80 rendered columns

Old:

~~~~
Algebra removes the reset ([§8.6][s8-6]). Every interval-relative integral
becomes a cumulative one, and a discrete sampler differences consecutive
samples against its latch ([D-056][d-056]). [§8.6][s8-6] also spells that idiom,
its exactness condition and the resulting assembly in full.
~~~~

New:

~~~~
Algebra removes the reset ([§8.6][s8-6]). Every interval-relative integral becomes a
cumulative one, and a discrete sampler differences consecutive samples against
its latch ([D-056][d-056]). [§8.6][s8-6] also spells that idiom, its exactness condition and the
resulting assembly in full.
~~~~

### E36. F18, unit D

Reason: 'The one recorded' read as 'the only one'; D-056 bullet 4 says 'the recorded, unbuilt escape hatch'.

Inventory: C-052's new span follows.

Old:

~~~~
**The one recorded, unbuilt escape hatch is a tick-triggered handler on
continuous components**
~~~~

New:

~~~~
**The recorded, unbuilt escape hatch is a tick-triggered handler on
continuous components**
~~~~

### E37. F18 rewrap, unit D

Reason: rewrap to 80 rendered columns

Old:

~~~~
**The recorded, unbuilt escape hatch is a tick-triggered handler on
continuous components** ([D-056][d-056]). Such a handler is a periodic event.
It is a [guarded addition](#g-guarded-addition) (a capability the design
admits but does not build), for use if interval-relative dynamics ever
neither factor algebraically nor tolerate the latch-back wire. In that wire,
the integrals consume the sampler's published latch ([§8.6][s8-6]). No known
case needs the escape hatch ([D-056][d-056]).
~~~~

New:

~~~~
**The recorded, unbuilt escape hatch is a tick-triggered handler on continuous
components** ([D-056][d-056]). Such a handler is a periodic event. It is a [guarded addition](#g-guarded-addition)
(a capability the design admits but does not build), for use if
interval-relative dynamics ever neither factor algebraically nor tolerate the
latch-back wire. In that wire, the integrals consume the sampler's published
latch ([§8.6][s8-6]). No known case needs the escape hatch ([D-056][d-056]).
~~~~

### E38. F34, unit D

Reason: Trim the trailing blank line that doubles the blank line at the D/E seam.

Old:

~~~~
([D-056][d-056]).

---


~~~~

New:

~~~~
([D-056][d-056]).

---

~~~~

### E39. F20, unit E

Reason: 'gives' was a weak verb, and the port was glossed but not linked, though the leads of §2 and §3 link their first terms.

Inventory: added[0] follows.

Old:

~~~~
This chapter gives the port, the addressable unit
~~~~

New:

~~~~
This chapter defines the [port](#g-port), the addressable unit
~~~~

### E40. F20 rewrap, unit E

Reason: rewrap to 80 rendered columns

Old:

~~~~
This chapter defines the [port](#g-port), the addressable unit through which components
exchange immutable values. [§4.1][s4-1] states the immutable value semantics of
signals; [§4.2][s4-2] why consumers see ports, not stages; [§4.3][s4-3] the table
mechanics and port granularity; and [§4.4][s4-4] function-valued signals for
environment access.
~~~~

New:

~~~~
This chapter defines the [port](#g-port), the addressable unit through which components
exchange immutable values. [§4.1][s4-1] states the immutable value semantics of signals;
[§4.2][s4-2] why consumers see ports, not stages; [§4.3][s4-3] the table mechanics and port
granularity; and [§4.4][s4-4] function-valued signals for environment access.
~~~~

### E41. R19, unit E

Reason: R19: the claim returns to the old form, a gloss on `y_state`/`y_direct` with no citation of its own, worded as at old 444-445. The tier gloss cannot nest in it and goes, as old 444-445 had none.

Inventory: C-006 new is the old gloss verbatim, tag R, ruling R19, newcites removed.

Old:

~~~~
Every
[component](#g-component) provides two output stages ([§5.2][s5-2]),
`y_state`/`y_direct`, on either [tier](#g-tier) (the continuous or discrete
side of the hybrid formalism). A producer's output [stage function](#g-stage-function) returns a
named tuple of fresh values.
~~~~

New:

~~~~
A producer's output [stage function](#g-stage-function) (`y_state`/`y_direct`, the two output stages every [component](#g-component) provides, on either [tier](#g-tier)) returns a
named tuple of fresh values.
~~~~

### E42. R19 rewrap, unit E

Reason: rewrap to 80 rendered columns

Old:

~~~~
**[Ports](#g-port) exchange immutable values** ([D-004][d-004]). The values are
typically isbits structs (floats, `SVector`s, enums, nested immutables). The
framework owns a [signal table](#g-signal-table), with one concretely typed
[cell](#g-cell) per output port in the flattened model. A producer's output [stage function](#g-stage-function) (`y_state`/`y_direct`, the two output stages every [component](#g-component) provides, on either [tier](#g-tier)) returns a
named tuple of fresh values. The framework writes each of those values into its
cell, and consumers read cells.
~~~~

New:

~~~~
**[Ports](#g-port) exchange immutable values** ([D-004][d-004]). The values are typically isbits structs
(floats, `SVector`s, enums, nested immutables). The framework owns a [signal table](#g-signal-table),
with one concretely typed [cell](#g-cell) per output port in the flattened model. A
producer's output [stage function](#g-stage-function) (`y_state`/`y_direct`, the two output stages every
[component](#g-component) provides, on either [tier](#g-tier)) returns a named tuple of fresh values. The
framework writes each of those values into its cell, and consumers read cells.
~~~~

### E43. F23, unit E

Reason: Chapter 4's 'named tuple' becomes NamedTuple, the spelling of §3.1, §3.2 and the base spec (plain, as §3.1 and §3.2 write it after F7).

Inventory: C-008 follows.

Old:

~~~~
returns a named tuple of fresh values.
~~~~

New:

~~~~
returns a NamedTuple of fresh values.
~~~~

### E44. F23, unit E

Reason: Chapter 4's 'named tuple' becomes NamedTuple, the spelling of §3.1, §3.2 and the base spec (plain, as §3.1 and §3.2 write it after F7).

Inventory: C-025 follows.

Old:

~~~~
because named tuples of isbits are isbits.
~~~~

New:

~~~~
because NamedTuples of isbits are isbits.
~~~~

### E45. F23, unit E

Reason: Chapter 4's 'named tuple' becomes NamedTuple, the spelling of §3.1, §3.2 and the base spec (plain, as §3.1 and §3.2 write it after F7).

Inventory: C-060 follows.

Old:

~~~~
returns a named tuple on either
~~~~

New:

~~~~
returns a NamedTuple on either
~~~~

### E46. F23 rewrap, unit E

Reason: rewrap to 80 rendered columns

Old:

~~~~
Scatter/gather is the whole protocol. A [stage function](#g-stage-function)
(`y_state`/`y_direct`) returns a NamedTuple on either [tier](#g-tier),
continuous or discrete. The framework scatters each field into that port's
concretely typed cell. Every reader gathers views from cells. The readers are
the next stage, `x_deriv`/`s_update` ([§5.2][s5-2]), [guards](#g-guard), wired consumers and
[snapshot](#g-snapshot) capture. A guard is the function defining an event's
predicate, and the snapshot is the immutable per-boundary publication.
~~~~

New:

~~~~
Scatter/gather is the whole protocol. A [stage function](#g-stage-function) (`y_state`/`y_direct`)
returns a NamedTuple on either [tier](#g-tier), continuous or discrete. The framework
scatters each field into that port's concretely typed cell. Every reader gathers
views from cells. The readers are the next stage, `x_deriv`/`s_update` ([§5.2][s5-2]),
[guards](#g-guard), wired consumers and [snapshot](#g-snapshot) capture. A guard is the function defining
an event's predicate, and the snapshot is the immutable per-boundary
publication.
~~~~

### E47. F33 rewrap, unit E

Reason: rewrap to 80 rendered columns, from the long line on

Old:

~~~~
The [port](#g-port) is the addressable unit. A [component](#g-component)'s
outputs appear to consumers, the GUI and logs as one flat namespace of ports,
such as the illustrative paths `"dyn/vel"` and `"dyn/f_c_c"` ([D-040][d-040]). A reader reaches a leaf
inside a port value through the port's [leaf address](#g-leaf-address) (the
field name with dotted and bracketed steps below it, [§14.4][s14-4],
[D-276][d-276]). Which output stage computes which port is an ordering
annotation, invisible outside the component. Moving an output between stages is
non-breaking *for consumers*. No wire, log or panel sees it. The build does see
it, because the [feedthrough](#g-feedthrough) graph (the graph of instantaneous
input→output dependences) and stage membership change ([§9.1][s9-1]).
~~~~

New:

~~~~
The [port](#g-port) is the addressable unit. A [component](#g-component)'s
outputs appear to consumers, the GUI and logs as one flat namespace of ports,
such as the illustrative paths `"dyn/vel"` and `"dyn/f_c_c"` ([D-040][d-040]). A reader
reaches a leaf inside a port value through the port's [leaf address](#g-leaf-address) (the field
name with dotted and bracketed steps below it, [§14.4][s14-4], [D-276][d-276]). Which output stage
computes which port is an ordering annotation, invisible outside the component.
Moving an output between stages is non-breaking *for consumers*. No wire, log or
panel sees it. The build does see it, because the [feedthrough](#g-feedthrough) graph (the graph
of instantaneous input→output dependences) and stage membership change ([§9.1][s9-1]).
~~~~

### E48. F25, unit E

Reason: 'class-blind' (F9) uses class in its glossary sense, first in §4.3; the next sentence glosses it (optional fix, as proposed).

Old:

~~~~
The distinction is class-blind ([D-172][d-172]).
~~~~

New:

~~~~
The distinction is [class](#g-class)-blind ([D-172][d-172]).
~~~~

### E49. R18, unit E

Reason: R18: no entry rules the requirement (D-243's Rationale and D-231's Position point back at §4.1); the bold goes and the sentence stays, citing D-243 plain. Bold-only edit; units/E/new_pretrim.md holds the text before it.

Inventory: C-019 ruling R6 becomes R18.

Old:

~~~~
Stated precisely, **the signal requirement is immutability plus frozen
references** ([D-243][d-243]).
~~~~

New:

~~~~
Stated precisely, the signal requirement is immutability plus frozen
references ([D-243][d-243]).
~~~~

### E50. R18, R19, unit E rulings.md

Reason: Record the step-5 rulings applied to this unit.

Old:

~~~~
  citation are a declared addition tagged R15.

~~~~

New:

~~~~
  citation are a declared addition tagged R15.
- **R18** (step 5). Row 99, "the signal requirement is immutability plus
  frozen references", goes plain and keeps its D-243 citation. No entry rules
  the requirement; whether the log owes a Position goes to the owner.
- **R19** (step 5). "Every component provides two output stages" returns to
  the old form, a gloss on `y_state`/`y_direct` with no citation of its own,
  worded as at old 444–445. The §5.2 citation goes. The claim, here, at §5.2
  old 696, glossary old 12951 and old 1111, goes to the owner.

~~~~

### E51. R19, unit E rulings.md

Reason: R19 removes the §5.2 citation.

Old:

~~~~
- §5.2 at row 93, "Every component provides two output stages": §5.2 old 696,
  "Every component provides exactly two output stages" (D-006).

~~~~

New:

~~~~
- §5.2 at row 93, "Every component provides two output stages": removed by
  R19; the claim is a gloss again, uncited as at old 444–445.

~~~~

### E52. R18, unit E rulings.md

Reason: R18 makes row 99 plain.

Old:

~~~~
- Row 99, "the signal requirement is immutability plus frozen references",
  bold. D-243 Rationale
~~~~

New:

~~~~
- Row 99, "the signal requirement is immutability plus frozen references",
  plain since R18, cited to D-243. D-243 Rationale
~~~~

### E53. R18, unit E rulings.md

Reason: R18 makes row 99 plain.

Old:

~~~~
128); unit E's row 99 bold cites D-243 for its Rationale. Both are R6's
  choices and state different rulings.
~~~~

New:

~~~~
128); unit E's row 99 cites D-243 for its Rationale, plain since R18.
~~~~

### E54. R19, unit E rulings.md

Reason: R19 settles the wording here.

Old:

~~~~
   and §5.2 old 696 says the same of every component. Wording kept, now cited
   to §5.2; the owner may want "every leaf" in both places.
~~~~

New:

~~~~
   and §5.2 old 696 says the same of every component. R19 returns it to the
   old gloss, uncited; the claim in all four places goes to the owner.
~~~~

### E55. F23, unit F

Reason: Chapter 4's 'named tuple' becomes NamedTuple, the spelling of §3.1, §3.2 and the base spec (plain, as §3.1 and §3.2 write it after F7).

Inventory: C-002 follows.

Old:

~~~~
**Stage returns are named tuples of port values, period**
~~~~

New:

~~~~
**Stage returns are NamedTuples of port values, period**
~~~~

### E56. F24, unit F

Reason: The leaf address gloss repeated §4.2's, one section earlier, in the same sentence shape; §4.3 keeps its link and the example glosses it. 'through the port's' stays, so the claim is unchanged.

Inventory: C-006's new span drops the gloss.

Old:

~~~~
through the
port's [leaf address](#g-leaf-address) (the field name with dotted and
bracketed steps below it), as in `"pose.q_eb"`
~~~~

New:

~~~~
through the
port's [leaf address](#g-leaf-address), as in `"pose.q_eb"`
~~~~

### E57. F23, F24 rewrap, unit F

Reason: rewrap to 80 rendered columns

Old:

~~~~
**Stage returns are NamedTuples of port values, period** ([D-036][d-036]).
**A custom struct is a first-class port value** ([D-036][d-036]). It is one
field of the returned tuple, one declared port, one cell
(`pose = KinPose{T}`, where `KinPose` is an illustrative struct). Nested
fields get no cells of their own. A reader reaches a nested field through the
port's [leaf address](#g-leaf-address), as in `"pose.q_eb"` ([§14.4][s14-4], [D-276][d-276]). A wired
consumer takes the bundle (the struct-valued port) whole. Bare-struct returns
are rejected ([D-036][d-036]).
~~~~

New:

~~~~
**Stage returns are NamedTuples of port values, period** ([D-036][d-036]). **A custom struct is
a first-class port value** ([D-036][d-036]). It is one field of the returned tuple, one
declared port, one cell (`pose = KinPose{T}`, where `KinPose` is an illustrative
struct). Nested fields get no cells of their own. A reader reaches a nested
field through the port's [leaf address](#g-leaf-address), as in `"pose.q_eb"` ([§14.4][s14-4], [D-276][d-276]). A wired
consumer takes the bundle (the struct-valued port) whole. Bare-struct returns
are rejected ([D-036][d-036]).
~~~~

### E58. F26, unit F

Reason: The gloss and the citation sat back to back, and the gloss repeated 'it is not built'; the gloss carries it.

Inventory: C-030 ends at the gloss's comma; C-031 becomes 'and its shape is obvious (D-036).'

Old:

~~~~
A field-projection connector is a [guarded
addition](#g-guarded-addition) (a capability the design admits but does not
build) ([D-036][d-036]). Its shape is obvious, and it is not built.
~~~~

New:

~~~~
A field-projection connector is a [guarded addition](#g-guarded-addition) (a capability the design admits but does not build), and its shape is obvious ([D-036][d-036]).
~~~~

### E59. F26 rewrap, unit F

Reason: rewrap to 80 rendered columns

Old:

~~~~
A field-projection connector is a [guarded addition](#g-guarded-addition) (a capability the design admits but does not build), and its shape is obvious ([D-036][d-036]).
~~~~

New:

~~~~
A field-projection connector is a [guarded addition](#g-guarded-addition) (a capability the design
admits but does not build), and its shape is obvious ([D-036][d-036]).
~~~~

### E60. F27, unit F

Reason: The KinPose introduction repeated the one in the same section ('where `KinPose` is an illustrative struct'), and the line rendered at 87 columns.

Inventory: added: the sentence becomes '`Kinematics` and `Vehicle` are illustrative names.'

Old:

~~~~
illustrative names, and `KinPose` is the illustrative struct above. An `output_wires` entry
~~~~

New:

~~~~
illustrative names. An `output_wires` entry
~~~~

### E61. F27, F33 rewrap, unit F

Reason: rewrap to 80 rendered columns

Old:

~~~~
The sketch below shows the bundle, the loose hot field and a face aliasing an
interior port, in declaration form. `Kinematics` and `Vehicle` are
illustrative names. An `output_wires` entry
sources a face from an immediate child's face ([§6.1][s6-1]). `RQuat` is
FlightPhysics' rotation quaternion. `RQuat{Float64}` is the spec's form of it,
since FlightPhysics' `RQuat` takes no type parameter.
~~~~

New:

~~~~
The sketch below shows the bundle, the loose hot field and a face aliasing an
interior port, in declaration form. `Kinematics` and `Vehicle` are illustrative
names. An `output_wires` entry sources a face from an immediate child's face
([§6.1][s6-1]). `RQuat` is FlightPhysics' rotation quaternion. `RQuat{Float64}` is the
spec's form of it, since FlightPhysics' `RQuat` takes no type parameter.
~~~~

### E62. F28, unit G

Reason: The port gloss split the bold clause from its own 'called field handles', and the line rendered at 89 columns; the gloss becomes its own sentence.

Inventory: C-004 drops the gloss; added '(a port is one declared name with its cell)' becomes 'A port is one declared name with its cell.'

Old:

~~~~
**Ordinary [ports](#g-port) carry them as immutable query objects** (a port
is one declared name with its cell), called [field handles](#g-field-handle),
because of that shape ([D-008][d-008]).
~~~~

New:

~~~~
**Ordinary [ports](#g-port) carry them as immutable query objects**, called [field handles](#g-field-handle), because of that shape ([D-008][d-008]). A port is one declared name with its cell.
~~~~

### E63. F28, F33 rewrap, unit G

Reason: rewrap to 80 rendered columns

Old:

~~~~
Atmosphere and terrain are query-shaped. Consumers evaluate them at arguments
of their own choosing, such as each gear strut at its own contact point, or
airflow at the vehicle pose. **Ordinary [ports](#g-port) carry them as immutable query objects**, called [field handles](#g-field-handle), because of that shape ([D-008][d-008]). A port is one declared name with its cell.
~~~~

New:

~~~~
Atmosphere and terrain are query-shaped. Consumers evaluate them at arguments of
their own choosing, such as each gear strut at its own contact point, or airflow
at the vehicle pose. **Ordinary [ports](#g-port) carry them as immutable query objects**,
called [field handles](#g-field-handle), because of that shape ([D-008][d-008]). A port is one declared name
with its cell.
~~~~

### E64. F32, unit G

Reason: The abstract input entry was linked with no gloss, so 'below the bound' was reader-cold. The gloss uses the glossary's words (base 12829). It is a sentence of its own after the link's sentence, not the proposed parenthetical, because that sentence already carries the face gloss (one parenthetical per sentence); it sits after 'That is structural substitutability' so 'That' keeps its antecedent.

Inventory: added gains 'An abstract input entry is an input whose declared type is abstract.'

Old:

~~~~
([§8.2][s8-2], [D-296][d-296]). The consumer wires
~~~~

New:

~~~~
([§8.2][s8-2], [D-296][d-296]). An abstract input entry is an input whose declared type is abstract. The consumer wires
~~~~

### E65. F32, F33 rewrap, unit G

Reason: rewrap to 80 rendered columns

Old:

~~~~
The field-handle mechanism replaces Flight.jl's threading of
`atmosphere`/`terrain` as arguments through every update signature. Flight.jl's
landing-gear model finds contact through a bounded ray query to the terrain
model, the query a terrain field handle's `ray_intersect` serves. Substitutability
behind a stable [face](#g-face) (the name a port wears on its component's
boundary) is declared with an
[abstract input entry](#g-abstract-entry), here the illustrative
`terrain = AbstractTerrainField`. That is structural substitutability
([§8.2][s8-2], [D-296][d-296]). An abstract input entry is an input whose declared type is abstract. The consumer wires to any concrete field type
below the bound ([D-078][d-078]). That preserves FlightPhysics' `AbstractTerrain`
polymorphism at the declaration layer.
~~~~

New:

~~~~
The field-handle mechanism replaces Flight.jl's threading of `atmosphere`/`terrain`
as arguments through every update signature. Flight.jl's landing-gear model
finds contact through a bounded ray query to the terrain model, the query a
terrain field handle's `ray_intersect` serves. Substitutability behind a stable
[face](#g-face) (the name a port wears on its component's boundary) is declared with an
[abstract input entry](#g-abstract-entry), here the illustrative `terrain = AbstractTerrainField`. That
is structural substitutability ([§8.2][s8-2], [D-296][d-296]). An abstract input entry is an
input whose declared type is abstract. The consumer wires to any concrete field
type below the bound ([D-078][d-078]). That preserves FlightPhysics' `AbstractTerrain`
polymorphism at the declaration layer.
~~~~

### E66. R20, unit G rulings.md

Reason: R20: record the geoid gloss's source in place of 'the standard definition'.

Old:

~~~~
  geoid's height above the reference ellipsoid)" (part F's reader-cold list;
  the standard definition of geoid undulation).
~~~~

New:

~~~~
  geoid's height above the reference ellipsoid)" (part F's reader-cold list;
  source, R20: FlightPhysics `geodesy.jl` 163, where the EGM96 grid holds
  "geoid height measured from the WGS84 ellipsoid" (163–164), and 226–228,
  which relate ellipsoidal and orthometric altitude "by the geoid's height",
  `HEllip(h._val + get_geoid_height(loc))`).
~~~~

### E67. F32, unit G rulings.md

Reason: Record the source of finding 32's gloss.

Old:

~~~~
  old text left it unlinked. It takes no gloss beyond the sentence's own
~~~~

New:

~~~~
  old text left it unlinked. After step 5 (chapter pass finding 32) it takes
  the gloss sentence "An abstract input entry is an input whose declared type
  is abstract", from glossary 12829 ("an `u_types` entry whose declared type
  is abstract"). Before that it took no gloss beyond the sentence's own
~~~~

### E68. R22, unit F

Reason: R22: the stop-request gloss gains its override, in D-316's Position's words.

Inventory: C-012's new span gains ', unless the advance ignores it'; tag R, ruling R22.

Old:

~~~~
reads `STOP_REQUESTED`), and a `StopFlag`
~~~~

New:

~~~~
reads `STOP_REQUESTED`, unless the advance ignores it), and a `StopFlag`
~~~~

### E69. R22 rewrap, unit F

Reason: rewrap to 80 rendered columns

Old:

~~~~
A port value's leaves are what the [leaf walk](#g-leaf-walk) (the framework's
derivation of per-activation types) reaches through `Real`s, static arrays and
isbits structs ([D-237][d-237]). An enum is one leaf, pinned ([§8.2][s8-2],
[D-316][d-316]). `StopFlag` is the one enum with a framework meaning. An
output port of that type is a [stop request](#g-stop-request) (a port that ends the run when it
reads `STOP_REQUESTED`, unless the advance ignores it), and a `StopFlag` nested in a port of another type or
declared as a root input is refused (`IllegalPortType`, [§13.5][s13-5],
[D-316][d-316]).
~~~~

New:

~~~~
A port value's leaves are what the [leaf walk](#g-leaf-walk) (the framework's derivation of
per-activation types) reaches through `Real`s, static arrays and isbits structs
([D-237][d-237]). An enum is one leaf, pinned ([§8.2][s8-2], [D-316][d-316]). `StopFlag` is the one enum
with a framework meaning. An output port of that type is a [stop request](#g-stop-request) (a port
that ends the run when it reads `STOP_REQUESTED`, unless the advance ignores it),
and a `StopFlag` nested in a port of another type or declared as a root input is
refused (`IllegalPortType`, [§13.5][s13-5], [D-316][d-316]).
~~~~

### E70. R23, unit B

Reason: R23: D-101's Position rules replay exact; it is cited beside D-231 at the deterministic-replay sentence.

Inventory: B-054 newcites gain D-101; tag R, ruling R23.

Old:

~~~~
a bit-identical trajectory ([D-231][d-231]).
~~~~

New:

~~~~
a bit-identical trajectory ([D-231][d-231], [D-101][d-101]).
~~~~

### E71. R23 rewrap, unit B

Reason: rewrap to 80 rendered columns

Old:

~~~~
- No stochastic differential equations (SDEs) or stochastic integrators. Noise
  processes, such as sensor noise and Dryden/von Kármán turbulence, are modeled
  as shaping filters ([D-001][d-001]), that is, as ordinary discrete processes driven by
  a random number generator (RNG). That modeling is faithful to how the noise
  processes are specified, and it is cheap. One consequence is elevated to a
  framework guarantee, deterministic [replay](#g-replay) (re-running the ordinary loop on a
  recorded input trace). RNG state lives in [component](#g-component) discrete state `s`, never in
  ambient globals, so the same seed gives a bit-identical trajectory ([D-231][d-231], [D-101][d-101]).
~~~~

New:

~~~~
- No stochastic differential equations (SDEs) or stochastic integrators. Noise
  processes, such as sensor noise and Dryden/von Kármán turbulence, are modeled
  as shaping filters ([D-001][d-001]), that is, as ordinary discrete processes driven by
  a random number generator (RNG). That modeling is faithful to how the noise
  processes are specified, and it is cheap. One consequence is elevated to a
  framework guarantee, deterministic [replay](#g-replay) (re-running the ordinary loop on a
  recorded input trace). RNG state lives in [component](#g-component) discrete state `s`, never in
  ambient globals, so the same seed gives a bit-identical trajectory ([D-231][d-231],
  [D-101][d-101]).
~~~~

### E72. R24 (P1), unit B

Reason: R24 P1: D-101's Position rules replay exact, so its citation goes inside the replay gloss, not on the seed sentence.

Inventory: B-053 gains newcites D-101, tag R, ruling R24; the added gloss gains ', D-101'.

Old:

~~~~
(re-running the ordinary loop on a
  recorded input trace).
~~~~

New:

~~~~
(re-running the ordinary loop on a
  recorded input trace, [D-101][d-101]).
~~~~

### E73. R24 (P1), unit B

Reason: R24 P1: the RNG sentence keeps D-231 alone; D-101 says nothing of seeds.

Inventory: B-054 back to newcites D-231, tag R, ruling R24.

Old:

~~~~
trajectory ([D-231][d-231],
  [D-101][d-101]).
~~~~

New:

~~~~
trajectory ([D-231][d-231]).
~~~~

### E74. R24 (P1) rewrap, unit B

Reason: rewrap to 80 rendered columns

Old:

~~~~
- No stochastic differential equations (SDEs) or stochastic integrators. Noise
  processes, such as sensor noise and Dryden/von Kármán turbulence, are modeled
  as shaping filters ([D-001][d-001]), that is, as ordinary discrete processes driven by
  a random number generator (RNG). That modeling is faithful to how the noise
  processes are specified, and it is cheap. One consequence is elevated to a
  framework guarantee, deterministic [replay](#g-replay) (re-running the ordinary loop on a
  recorded input trace, [D-101][d-101]). RNG state lives in [component](#g-component) discrete state `s`, never in
  ambient globals, so the same seed gives a bit-identical trajectory ([D-231][d-231]).
~~~~

New:

~~~~
- No stochastic differential equations (SDEs) or stochastic integrators. Noise
  processes, such as sensor noise and Dryden/von Kármán turbulence, are modeled
  as shaping filters ([D-001][d-001]), that is, as ordinary discrete processes driven by
  a random number generator (RNG). That modeling is faithful to how the noise
  processes are specified, and it is cheap. One consequence is elevated to a
  framework guarantee, deterministic [replay](#g-replay) (re-running the ordinary loop on a
  recorded input trace, [D-101][d-101]). RNG state lives in [component](#g-component) discrete state `s`,
  never in ambient globals, so the same seed gives a bit-identical trajectory
  ([D-231][d-231]).
~~~~

### E75. R24 (P2), unit E

Reason: R24 P2: §4.1's first tier regains a gloss inside R19's parenthetical, in §4.3's wording.

Inventory: C-006 new gains ', continuous or discrete'; tag R, ruling R24.

Old:

~~~~
provides, on either [tier](#g-tier)) returns
~~~~

New:

~~~~
provides, on either [tier](#g-tier), continuous or discrete) returns
~~~~

### E76. R24 (P2) rewrap, unit E

Reason: rewrap to 80 rendered columns

Old:

~~~~
**[Ports](#g-port) exchange immutable values** ([D-004][d-004]). The values are typically isbits structs
(floats, `SVector`s, enums, nested immutables). The framework owns a [signal table](#g-signal-table),
with one concretely typed [cell](#g-cell) per output port in the flattened model. A
producer's output [stage function](#g-stage-function) (`y_state`/`y_direct`, the two output stages every
[component](#g-component) provides, on either [tier](#g-tier), continuous or discrete) returns a NamedTuple of fresh values. The
framework writes each of those values into its cell, and consumers read cells.
~~~~

New:

~~~~
**[Ports](#g-port) exchange immutable values** ([D-004][d-004]). The values are typically isbits structs
(floats, `SVector`s, enums, nested immutables). The framework owns a [signal table](#g-signal-table),
with one concretely typed [cell](#g-cell) per output port in the flattened model. A
producer's output [stage function](#g-stage-function) (`y_state`/`y_direct`, the two output stages every
[component](#g-component) provides, on either [tier](#g-tier), continuous or discrete) returns a NamedTuple
of fresh values. The framework writes each of those values into its cell, and
consumers read cells.
~~~~

### E77. R24 (P3), unit F

Reason: R24 P3: D-036's citation moves before the gloss, so it does not cover the old text's uncited 'Its shape is obvious'.

Inventory: C-030 new 'A field-projection connector is a guarded addition (D-036), a capability the design admits but does not build.', newcites D-036, tag R, ruling R24; C-031 new 'Its shape is obvious.', newcites dropped, tag R, ruling R24.

Old:

~~~~
A field-projection connector is a [guarded addition](#g-guarded-addition) (a capability the design
admits but does not build), and its shape is obvious ([D-036][d-036]).
~~~~

New:

~~~~
A field-projection connector is a [guarded addition](#g-guarded-addition) ([D-036][d-036]), a capability the design
admits but does not build. Its shape is obvious.
~~~~

### E78. R24 (P3) rewrap, unit F

Reason: rewrap to 80 rendered columns

Old:

~~~~
A field-projection connector is a [guarded addition](#g-guarded-addition) ([D-036][d-036]), a capability the design
admits but does not build. Its shape is obvious.
~~~~

New:

~~~~
A field-projection connector is a [guarded addition](#g-guarded-addition) ([D-036][d-036]), a capability the
design admits but does not build. Its shape is obvious.
~~~~

### E79. R24 (stale records), unit E rulings.md

Reason: The R6 bullet still listed row 99 among the bolds; row 99 is plain since R18. Rewrapped.

Old:

~~~~
- **R6.** Bolds: D-004 (row 91), D-121 (row 95), row 99 (D-243 alone; D-231
  moved to the next plain sentence at the verifier's request), D-172 (row 114, on the faces sentence), D-036's second ruling
  (row 118).
~~~~

New:

~~~~
- **R6.** Bolds: D-004 (row 91), D-121 (row 95), row 99 (D-243 alone; D-231
  moved to the next plain sentence at the verifier's request; row 99 is plain
  since R18), D-172 (row 114, on the faces sentence), D-036's second ruling
  (row 118).
~~~~

### E80. R24 (stale records), unit E rulings.md

Reason: Rewrap the line E52 left at 95 columns.

Old:

~~~~
- Row 99, "the signal requirement is immutability plus frozen references",
  plain since R18, cited to D-243. D-243 Rationale, log 9210 ("[§4.1] requires of a port value
  immutability plus frozen references"). D-231's Position presupposes it,
  log 8691–8692, and is cited at the next sentence instead. The log owes a Position stating the requirement.
~~~~

New:

~~~~
- Row 99, "the signal requirement is immutability plus frozen references",
  plain since R18, cited to D-243. D-243 Rationale, log 9210 ("[§4.1]
  requires of a port value immutability plus frozen references"). D-231's
  Position presupposes it, log 8691–8692, and is cited at the next sentence
  instead. The log owes a Position stating the requirement.
~~~~

### E81. R24 (stale records), unit E rulings.md

Reason: Row 99 is plain since R18.

Old:

~~~~
- D-231: cited plain at row 100, not at row 99's bold.
~~~~

New:

~~~~
- D-231: cited plain at row 100, not at row 99 (plain since R18).
~~~~

### E82. R24 (stale records), unit F rulings.md

Reason: Unit E's row 99 is plain since R18, not bold.

Old:

~~~~
- **D-243**: bold nowhere else in the base spec. Unit E is to bold row 99
  (immutability plus frozen references), which rests on D-243's Rationale,
  a different ruling from the Position this unit bolds.
~~~~

New:

~~~~
- **D-243**: bold nowhere else in the base spec. Unit E's row 99
  (immutability plus frozen references) rests on D-243's Rationale, a
  different ruling from the Position this unit bolds, and is plain since R18.
~~~~

### E83. R24 (stale records) rewrap, unit E rulings.md

Reason: Rewrap the bullet touched by E81.

Old:

~~~~
- D-231: cited plain at row 100, not at row 99 (plain since R18). Unit C bolds "`m` is continuous-only" citing
  D-231; §7.3 bolds D-231 at old 1880, 1892, 1975 and 3975. Old 1892, "**The
  frozen-reference latitude stays with signals** ([§4.1], [D-231])", is the
  store-side face of row 99's requirement. The owner may judge whether row 99
  and old 1892 state one ruling twice.
~~~~

New:

~~~~
- D-231: cited plain at row 100, not at row 99 (plain since R18). Unit C
  bolds "`m` is continuous-only" citing D-231; §7.3 bolds D-231 at old 1880,
  1892, 1975 and 3975. Old 1892, "**The frozen-reference latitude stays with
  signals** ([§4.1], [D-231])", is the store-side face of row 99's
  requirement. The owner may judge whether row 99 and old 1892 state one
  ruling twice.
~~~~


### O1. Orchestrator touch: units/E/new_pretrim.md (final verifier re-check)

The bold-only reference copy predates E75 and E76, so `boldcheck.py ch01-04 E`
saw a text change beyond bold markers. Rebuilt it as the current new.md with
R18's removed bold restored on "the signal requirement is immutability plus
frozen references", so the check compares exactly R18's bold-only edit. The
copy is a check reference and never lands.

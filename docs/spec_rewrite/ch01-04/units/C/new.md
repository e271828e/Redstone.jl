## 3. Component taxonomy

**The taxonomy has three categories of [component](#g-component)** ([D-003][d-003]).
Two of them are leaves with crisp, closed semantics, and one is pure
composition. [§3.1][s3-1] describes the continuous component, [§3.2][s3-2] the
periodic discrete component and [§3.3][s3-3] the assembly, and [§3.4][s3-4]
justifies the two-leaf split.

### 3.1 Continuous component (the hybrid primitive)

A continuous component is a classical hybrid automaton. It has these facets.

- Continuous state `x`, a NamedTuple whose leaves are real scalars and
  `SArray`s ([§7.1][s7-1], [D-094][d-094], [D-247][d-247]).
- Mode variables `m`. These are piecewise-constant values (enums, integers,
  flags) that parametrize the [flow](#g-flow) and change *only* through event
  handlers.
- Flow $\dot{x} = f(x, m, u, t)$.
- Two output stages ([§5.2][s5-2]).
- Events, each a [guard](#g-guard) (the declared function defining an event's predicate)
  plus a handler. A handler may update `m` and may reset the [component](#g-component)'s own `x`
  ([D-090][d-090]). Both guard and handler read the fresh [boundary](#g-boundary) [signal table](#g-signal-table) ([§5.3][s5-3],
  [D-154][d-154]).
- An optional [projection](#g-projection) (the per-component hook
  `x_projection`).

Any facet may be empty. In particular, a component with *no* continuous state,
only modes, events and mode-valued outputs, is a finite-state machine (FSM). **A
single primitive supports both factorings of mode logic** ([D-003][d-003]).

- Internal modes suit tightly coupled cases, such as stall hysteresis inside
  the aero component. They preserve cohesion and enable reset maps
  ([D-003][d-003]).
- An external FSM component feeding modes through a [port](#g-port) (the addressable unit
  of the model) gives maximal purity, independent testability and swappable
  supervision logic.

The rule of meaning separates a command from a detection. A supervisor
*commanding* a mode change is an ordinary input. A component *detecting* its own
transition is an event. The two mechanisms carry two meanings and do not
overlap. On the continuous [tier](#g-tier), a reset of state commanded through an input
still lands through an event whose guard reads that input ([§5.3][s5-3], [D-141][d-141]).

### 3.2 Periodic discrete component

A periodic discrete component has these facets.

- Discrete state `s`, a NamedTuple whose fields are each isbits or a `Symbol`
  ([§7.3][s7-3], [D-231][d-231], [D-247][d-247]).
- Update $s^{+} = g(s, u, t)$ at a declared rate.
- Two output stages, with [feedthrough](#g-feedthrough) (an instantaneous
  input→output dependence) applying at update instants. A proportional path is
  direct feedthrough. A state-only output is not.

**Each [tier](#g-tier) carries its own state letter** ([D-195][d-195]). `x` is
the argument of the [flow](#g-flow) map under `f`, and `s` is the argument of
the jump map under `g`. The two are different objects. `x` has a derivative and
lives in the flat [buffer](#g-buffer). `s` has none and is latched in a
[store](#g-store) (the framework-owned home of a state letter) between
[ticks](#g-tick). Nothing is lost by splitting the letter, because a leaf is
strictly one tier ([D-056][d-056]) and no [component](#g-component) ever reads another's
state. A discrete component's `s` influences continuous dynamics only through
signals ([D-056][d-056]). Those outputs are held zero-order between ticks
([D-019][d-019]).

**`m` is continuous-only** ([D-231][d-231], [D-249][d-249]). A discrete
component has no mode store. Its finite-state machine (FSM) enums, flags and
counters are ordinary `s` fields. `m` exists on the continuous side because
modes must change *between* flow evaluations, which is what handlers do. On the
discrete side `g` already runs at the only instants at which anything may
change. A second store would duplicate the discrete tier's own state semantics
under another name.

### 3.3 Assembly

An [assembly](#g-assembly) is pure composition. It holds child components,
[local wires](#g-local-wire) and boundary [faces](#g-face) (the names ports
wear on a component's boundary). It has no dynamics of its own. Hybridness
emerges at the assembly level. An aircraft is continuous vehicle parts plus
discrete avionics parts. The two-leaf split was upheld against the
integrate-and-dump challenge ([§3.4][s3-4], [D-056][d-056]). Assemblies are
flattened away for ordering ([D-019][d-019]). They are retained as the
navigation and introspection hierarchy (GUI, logging, paths) and as
declaration-level [rate scopes](#g-rate-scope) ([§10.5][s10-5],
[D-019][d-019]).

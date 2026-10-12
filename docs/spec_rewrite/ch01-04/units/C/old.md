## 3. Component taxonomy

There are three classes. Two of them are leaves with crisp, closed semantics,
and one is pure composition.

### 3.1 Continuous component (the hybrid primitive)

A continuous component is a classical hybrid automaton. It has these facets.

- **Continuous state** `x`, an isbits struct of real scalars ([§7][s7]).
- **Mode variables** `m`. These are piecewise-constant values (enums, integers,
  flags) that parametrize the [flow](#g-flow) and change *only* through event handlers.
- **Flow** $\dot{x} = f(x, m, u, t)$.
- **Two output stages** ([§5.2][s5-2]).
- **Events**, each a [guard](#g-guard) plus a handler. A handler may update `m` and may
  reset the component's own `x`. Both guard and handler read the fresh [boundary](#g-boundary)
  [signal table](#g-signal-table) ([§5.3][s5-3]).
- An optional **[projection](#g-projection)**.

Any facet may be empty. In particular, a [component](#g-component) with *no* continuous state,
only modes, events and mode-valued outputs, is an FSM. A single primitive
therefore supports both factorings of mode logic.

- **Internal modes** suit tightly coupled cases, such as stall hysteresis inside
  the aero component. They preserve cohesion and enable reset maps.
- An **external FSM component** feeding modes through a [port](#g-port) gives maximal
  purity, independent testability and swappable supervision logic.

**Rule of meaning.** A supervisor *commanding* a mode change is an ordinary
**input**. A component *detecting* its own transition is an **event**. The two
mechanisms carry two meanings and do not overlap.

### 3.2 Periodic discrete component

A periodic discrete component has these facets.

- **Discrete state** `s`, any isbits value ([§7][s7]).
- **Update** $s^{+} = g(s, u, t)$ at a declared rate.
- **Two output stages**, with [feedthrough](#g-feedthrough) applying at update instants. A
  proportional path is direct feedthrough. A state-only output is not.

Each [tier](#g-tier) carries its own state letter. `x` is the argument of the [flow](#g-flow) map
under `f`, and `s` is the argument of the jump map under `g`. The two are
different objects. `x` has a derivative and lives in the flat [buffer](#g-buffer). `s` has
none and is latched in a [store](#g-store) between [ticks](#g-tick). So they are spelled differently
([D-195][d-195]). Nothing is lost by the split, because a leaf is strictly one tier
([D-056][d-056]) and no [component](#g-component) ever reads another's state. A discrete component's `s`
influences continuous dynamics only **through signals**. Those outputs are held
zero-order between ticks.

**`m` is continuous-only.** A discrete component has no mode store. Its FSM
enums, flags and counters are ordinary `s` fields.

**Why.** `m` exists on the continuous side because modes must change *between*
flow evaluations, which is what handlers do. On the discrete side `g` already
runs at the only instants at which anything may change. A second store would
duplicate the discrete tier's own state semantics under another name.

### 3.3 Assembly

An assembly is pure composition. It holds submodels, [local wires](#g-local-wire) and
boundary [faces](#g-face). **It has no dynamics of its own.** Hybridness emerges at the
[assembly](#g-assembly) level. An aircraft is continuous vehicle parts plus discrete avionics
parts. The two-leaf split was upheld against the integrate-and-dump challenge
([§3.4][s3-4], [D-056][d-056]). Assemblies are flattened away for ordering. They are
retained as the navigation and introspection hierarchy (GUI, logging, paths) and
as declaration-level [rate scopes](#g-rate-scope) ([§10.5][s10-5]).


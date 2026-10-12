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


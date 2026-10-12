## 5. Evaluation order and feedthrough

This chapter fixes two output stages per component, what each stage may see, and
how those signatures alone yield a static execution order. The build derives
that order from declared feedthrough and rejects algebraic loops by naming the
cycle. [§5.1][s5-1] states the ordering problem; [§5.2][s5-2] the two output stages, their
signatures, bundles and the hand-off laws; [§5.3][s5-3] the stage roles, the execution
order, step boundaries and supervisory inputs; [§5.4][s5-4] artificial loops and the
escape hatch; [§5.5][s5-5] the policy that rejects algebraic loops at build time; and
[§5.6][s5-6] diagnostics through feedthrough tracing.

### 5.1 The ordering problem

At every evaluation instant, all signals must be computed consistently. Every
consumer reads values already produced at that instant. The build constructs the
directed graph of wiring edges and intra-[component](#g-component) [feedthrough](#g-feedthrough) relations
(instantaneous input→output dependences). If the graph is acyclic, a topological
sort yields a static [execution order](#g-execution-order) (the order in which the stage functions
run), computed once at build time ([D-048][d-048]). A cyclic graph is the subject of
[§5.4][s5-4], [§5.5][s5-5] and [§5.6][s5-6]. The hot loop runs a flat list of `(component, stage)`
pairs, with no runtime graph logic ([D-086][d-086]).

### 5.2 Two-stage outputs: signatures, bundles and the hand-off laws

**Every [component](#g-component) provides exactly two output stages** ([D-006][d-006]). [Feedthrough](#g-feedthrough) (an
instantaneous input→output dependence) is declared structurally, by function
signature. There are no dependency annotations anywhere in the design ([D-006][d-006]).
`y_state` is stage 1 and `y_direct` is stage 2.

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
arguments, where each [view](#g-view) comes from, which names it receives, what an output
stage returns, and what a handler returns.

#### The hand-off: one component, one bundle

**Every function receives exactly two arguments**, the component and one NamedTuple
[bundle](#g-bundle) of zero-copy views ([D-074][d-074]). From that bundle the author destructures by
name only what the body reads, as in `x_deriv(c::LowPassFilter, (; x, u)) = …`
and `y_direct(c::PID, (; s, u, Δt)) = …`. Here `PID` names a
proportional-integral-derivative controller.

The rule exists so that the [executor](#g-executor) (the compiled form of
the stage execution order) issues one fixed call shape, `fn(comp, args)`. Two
more reasons support it. Language semantics ignore unread fields. Argument
order cannot be confused, because there is no order.

Positional, `kwarg_decl`-reflected and slurping-keyword spellings are all
closed ([D-074][d-074]). A `kwarg_decl`-reflected spelling takes keyword
arguments whose names the framework reads through Julia's internal
`Base.kwarg_decl`. A slurping-keyword spelling takes keyword arguments and ends
its keyword list with a `_...` slurp.

**`x_projection` alone stays positional** ([D-074][d-074]). It takes one [store](#g-store) (the
framework-owned home of a state letter) in and returns the same store out, so
there is nothing to select.

#### What the views are

The views come from the sources below.

- Own state. On the continuous [tier](#g-tier) (the continuous or discrete side of the
  hybrid formalism), `x` comes from the flat [buffer](#g-buffer) and `m` from the mode
  stores. On the discrete tier, `s` comes from its store.
- Own published signals. `y` is gathered from the component's own [cells](#g-cell)
  (concretely typed table entries, one per output port) in the [signal table](#g-signal-table).
  Those cells are the declared [ports](#g-port) ([§8.2][s8-2]).
- Inputs. `u` is gathered from foreign cells through the wiring, by name.
- The clock. `t`, and `Δt` ([§10.5][s10-5]).
- Scratch. `ws` ([§7.3][s7-3]).

**The signal table holds only *produced* signals, never transported ones**
([D-035][d-035]). Each datum has exactly one home. The buffer holds `x`, the
`s` and `m` stores hold `s` and `m`, and the table holds signals. No store
mirrors another. Every bundle field earns its place as a view genuinely
readable. No minimization of the set survives without introducing a copy
([D-035][d-035]).

<a id="g-cell"></a>**cell** — one concretely typed entry of the signal table,
one per output port of the flattened model, written by its producing stage and
read by every gatherer ([§4.1][s4-1]). Every cell is public, and private
intermediates are never cells ([§8.3][s8-3]). Bare "cell" means only this.
See [staging cell](#g-staging-cell) and [store](#g-store).

<a id="g-entry"></a>**entry** — a word with no single sense. Each section's
compound names a different thing. They are table entry (a [cell](#g-cell)),
contract entry ([§8.2][s8-2]) with its [abstract entry](#g-abstract-entry),
executor entry ([§9.7][s9-7]), roster entry and batch entry
([§11.3][s11-3]), and condition entry ([§14.3][s14-3]).

<a id="g-face"></a>**face** — the name a port wears on its component's
boundary. For a leaf it is the port's own name. For an assembly it is a name
declared in `input_wires` or `output_wires`, aliasing an interior port. Face
names are opaque tokens, and the periphery's write side speaks only face names
([§8.6][s8-6], [§11.2][s11-2], [§14.4][s14-4]).

<a id="g-scratch"></a>**scratch** — mutable working storage whose contents are
never authoritative. There are three kinds. One is a component's workspace
(`ws`, [§7.3][s7-3]). Another is the integrator's buffers and the mid-step
table ([§10.3][s10-3], [§13.6][s13-6]). The third is the store set a service
invocation instantiates from the activation's layout and discards with the
call ([§9.4][s9-4], [§14.8][s14-8]). The simulation's own buffer set is the
authoritative one.

<a id="g-store"></a>**store** — the framework-owned home of one of a
component's state letters, `x`, `s` or `m`. An `x` store is a range of the
[buffer](#g-buffer). An `s` or `m` store is a typed value of isbits or
`Symbol` fields. The framework overwrites it when a handler or update returns
a new value ([§7.3][s7-3]). A store is never a [cell](#g-cell)
([§4.1][s4-1]).

<a id="g-summing-junction"></a>**summing junction** — an ordinary library
component performing N-to-1 aggregation through explicit wires
(`SumJunction{V, N}`, the generic `Junction` at `+`, or a named site-specific
variant, [§13.7][s13-7]). There is no framework aggregation mechanism, and
fold order is the junction's positional input order ([§6.2][s6-2]).

<a id="g-view"></a>**view** — one of the named, zero-copy values a function
receives through its [bundle](#g-bundle), such as its own state, `y` or `u`
([§5.2][s5-2]). A **state view** reconstructs a store ([§7.1][s7-1]). It
materializes in the caller's frame for the duration of the call, and is
value-identical on re-materialization within a sweep ([§9.7][s9-7]).

<a id="g-algebraic-loop"></a>**algebraic loop** — a genuine cycle in the
instantaneous dependency graph. It is a build error whose diagnostic names the
loop in slash form ([§13.8][s13-8]). The author breaks it with
inserted dynamics, a `UnitDelay`, which samples the signal on the discrete
tier, or restructuring ([§5.5][s5-5], [D-348][d-348]). Not to be confused
with an **artificial loop** ([§5.4][s5-4]), port-level acyclic but
stage-level cyclic.

<a id="g-execution-order"></a>**execution order** — the order in which the
stage functions run, fixed once at build time from wiring edges plus
intra-component feedthrough. All stage-1 functions run in any order, then
stage 2 in topological order, then `x_deriv` ([§5.1][s5-1], [§5.3][s5-3]).
[`Outputs`](#g-outputs) carries it ([§9.1][s9-1]). The loop runs it as a flat
list of `(component, stage)` pairs ([§9.7][s9-7]).

<a id="g-sweep"></a>**sweep** — one pass through the execution order against
the current state, in one of two variants compiled from one entry list. The
**interior sweep** walks continuous entries only. RK stages and guard trial
evaluations run it. The **boundary sweep** walks the full list, gating in the
boundary's due discrete entries ([§5.3][s5-3], [§10.5][s10-5]). The
**arrival sweep** closes an integration step ([§10.4][s10-4]).

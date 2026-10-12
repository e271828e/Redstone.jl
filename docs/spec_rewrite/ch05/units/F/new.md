### 5.6 Diagnostics: feedthrough tracing

**Tracing is diagnostic only**, never relied on for correctness ([D-012][d-012]). Ordering
correctness comes exclusively from the structural two-stage split. Tracing
improves error messages and verification. When the build finds a cycle, it
triggers the [feedthrough tracer](#g-feedthrough-tracer) (the set-propagation instrument that tracks
which inputs a value depends on) to classify that cycle. A genuine cycle gets
"insert a state", and an artificial one gets the remedy ladder ([§5.4][s5-4]). The parts
below cover, in order, how a cycle is detected and named, the tracer's two modes
and what tracing touches, how classification runs and decides, and the caveats
the diagnostic carries.

#### Detection and naming

A cycle surfaces as a topological-sort stall in the [nominal](#g-nominal)
evaluation (the build's second step, the one evaluation that feeds structure).
The stalled subgraph is decomposed into strongly connected components (SCCs).
**Each nontrivial SCC names one cyclic cluster exactly** ([D-012][d-012]).
Each cluster becomes one diagnostic, an `AlgebraicCycle` error
([Appendix C][sC]). The diagnostic presents the cluster's members and the wires
among them as one readable loop of terminal pairs in the canonical slash form
([§8.6][s8-6], `aero/F → dyn/F, dyn/a → aero/a`). Neither the raw stall residue
nor a single back edge names the cluster correctly ([D-012][d-012]).

#### The tracer's two modes

The feedthrough tracer has two modes, and they degrade gracefully. Both are
set-tracers. A traced value carries a set of input indices, its tracer tags.

- The *global* (value-blind) set-tracer is a `Real` subtype that carries a set
  of input indices, unioned by every operation. It has
  may-depend semantics, a sound over-approximation. A saturated `clamp` still
  reports, and $u^2$ at $u = 0$ still reports. It is exact, in one evaluation.
  It requires the traced stage-2 code to be free of branches and lookups on
  *input-tainted* values.
- The *local* (primal-carrying) set-tracer at sampled states is the fallback
  whenever the global tracer hits an undecidable branch, such as piecewise
  friction, stall blending or any gridded lookup at an input-tainted
  coordinate. It reports the dependence pattern of the taken paths, sampled
  across randomized states. Its only misses are untaken branches
  ([D-012][d-012]).

#### What tracing touches

Only *inputs* are seeded, so branching on state, modes, parameters or time
never interferes. Stage-2 functions also receive state views, but neither those
nor the stage-1 hand-down are ever seeded. Stage-1 functions are never traced,
since there is nothing to seed. Derivatives, [guards](#g-guard) (the declared
functions defining each event's predicate), handlers and
[projections](#g-projection) are outside tracing's jurisdiction entirely.

A known tracer blind spot is documented. Value-severing operations pass
dependence through a bare `Int` index, as a nearest-neighbor lookup does.
Linear and cubic interpolation are immune, because dependence flows through the
fractional weights.

Both modes ride the same `T <: Real` genericity as `Dual`, ForwardDiff's dual
number. Dual-cleanliness in CI (passing the `T = Dual` sweep of
[§7.2][s7-2]) effectively guarantees traceability.

#### Classification

Classification needs no [execution order](#g-execution-order), the order in
which the stage functions run ([D-012][d-012]). It runs inside the nominal
evaluation's failure path, where no execution order exists. None is needed,
because each SCC member is evaluated *once, in isolation*, at the
[probe](#g-probe) point (the initial state, where the build probes every user
function). That evaluation reads state views from the `x_init`, `s_init` and
`m_init` declarations, out-of-cycle cell values from the acyclic prefix's probe
values, and in-cycle cell values synthesized through `probe_value`
([§9.3][s9-3]) under tracer tags. The tracer's product is a per-member
dependence set rather than a value, so no ordering has to be valid for the
labels to come out right.

**The traced maps decide the verdict as one graph question over the cluster**
([D-245][d-245]). Every wire holds. A hop inside a member runs from the
[face](#g-face) (the name a port wears on its component's boundary) that one
wire enters to the port the next wire leaves. The hop holds iff that member's
map routes the face to the port. The loop is real iff a cycle survives in that
graph. It is artificial ([§5.4][s5-4]) iff none does, because every cycle
through the cluster crosses a dead hop, at a component whose stage-2 function
does not in fact route that input to that output. **The diagnostic lists every
dead hop under either verdict**, so a real loop still shows the chords the
trace found false ([D-245][d-245]). For a simple cycle this reduces to the
expected reading, that the loop is real iff every hop survives.

Classification touches no activation machinery. There is no [activation](#g-activation) (the
build's typed products at a given scalar type), no layouts and no table. The
cycle classifier uses the *local* variant of tracing ([D-012][d-012]), the order-free
per-member trace at the probe point. The "tracer activation" ([§9.4][s9-4]) names the
other variant ([D-012][d-012]), the global set-tracer run as an ordinary activation. The
two must not be conflated. The local variant is not the local set-tracer mode. A
member's map may come from either mode.

#### Caveats the diagnostic carries

The diagnostic carries the tracer's caveats rather than assuming them away. The
trace speaks for the branch taken at the probe point (the diagnostic-only
doctrine, [D-012][d-012]). **Discrete members trace structurally**, because the discrete
[tier](#g-tier)'s plain, wholesale-pinning declarations admit no tracer scalar ([D-012][d-012]).
Structural tracing is sound as a may-depend answer but never sharp, so the
remedy hint is offered only for continuous members ([D-140][d-140]). A continuous face or
port declared with no [walking](#g-walked) leaf (one whose type follows the activation
scalar) admits no tracer scalar either, so the hops through it trace
structurally too ([D-245][d-245]).

**The diagnostic records the source of each member's map** ([D-245][d-245]). The source is
the global tracer, sampled states or structure. A reader can thus weigh a dead
hop found on a few sampled paths against one found exactly. The hint itself is
to split this component, *or* to narrow the neighbor's [contract](#g-contract) (its declared
interface) when the dead hop's input is consumed only in a fallback branch.
Those are the ladder's two remedies ([§5.4][s5-4], [D-140][d-140]). If a member's evaluation
itself throws, the diagnostic ships with its members and wires alone,
unclassified. Classification is a bonus on the cycle error, never its
precondition ([D-012][d-012]).

---


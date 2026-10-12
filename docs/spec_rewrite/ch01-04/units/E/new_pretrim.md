## 4. Ports and signals

This chapter defines the [port](#g-port), the addressable unit through which components
exchange immutable values. [§4.1][s4-1] states the immutable value semantics of signals;
[§4.2][s4-2] why consumers see ports, not stages; [§4.3][s4-3] the table mechanics and port
granularity; and [§4.4][s4-4] function-valued signals for environment access.

### 4.1 Immutable value semantics

**[Ports](#g-port) exchange immutable values** ([D-004][d-004]). The values are typically isbits structs
(floats, `SVector`s, enums, nested immutables). The framework owns a [signal table](#g-signal-table),
with one concretely typed [cell](#g-cell) per output port in the flattened model. A
producer's output [stage function](#g-stage-function) (`y_state`/`y_direct`, the two output stages every
[component](#g-component) provides, on either [tier](#g-tier)) returns a NamedTuple of fresh values. The
framework writes each of those values into its cell, and consumers read cells.

These names are binding throughout this document.

- **A bare *cell* is the table entry, and only that** ([D-121][d-121]).
- A *[store](#g-store)* is the framework-owned home of one of a component's
  state letters, `x`, `s` or `m` ([§7.1][s7-1], [§7.3][s7-3], [D-302][d-302]).
  An `x` store is a range of the [buffer](#g-buffer) (the contiguous vector
  backing all continuous state). Stores are not cells.
- A *[staging cell](#g-staging-cell)* is a distinct compound term
  ([D-121][d-121]). It is the inbound register of [§11.4][s11-4], one per
  [device](#g-device) (any attached participant outside the loop, such as the
  GUI). Unlike a table cell it is mutated frame by frame, and it sits
  outside the table's publish-once discipline.
- A *[root input](#g-root-input)* is a source cell fed by the
  [periphery](#g-periphery) (everything outside the loop that exchanges data
  with it) rather than by a producer ([§11.3][s11-3]).

Stated precisely, **the signal requirement is immutability plus frozen
references** ([D-243][d-243]). Signals may reference bulk data
([§4.4][s4-4]) provided that data is read-only for the duration of the run
([D-231][d-231]). `isbits` is the common case, not the rule.

The signal requirement has four consequences.

- There is no aliasing, ever. Nothing can be mutated under a consumer's feet.
- Concurrent reads from the GUI and logging threads are safe by construction.
- Isbits payloads allocate nothing, because NamedTuples of isbits are isbits.
- Each cell has a definite freshness, tied to its producer's position in the
  [execution order](#g-execution-order), the order in which the stage
  functions run ([D-004][d-004]).

### 4.2 Consumers see ports, not stages

The [port](#g-port) is the addressable unit. A [component](#g-component)'s
outputs appear to consumers, the GUI and logs as one flat namespace of ports,
such as the illustrative paths `"dyn/vel"` and `"dyn/f_c_c"` ([D-040][d-040]). A reader
reaches a leaf inside a port value through the port's [leaf address](#g-leaf-address) (the field
name with dotted and bracketed steps below it, [§14.4][s14-4], [D-276][d-276]). Which output stage
computes which port is an ordering annotation, invisible outside the component.
Moving an output between stages is non-breaking *for consumers*. No wire, log or
panel sees it. The build does see it, because the [feedthrough](#g-feedthrough) graph (the graph
of instantaneous input→output dependences) and stage membership change ([§9.1][s9-1]).

Which ports exist at all is a declaration-layer decision. The output
[contract](#g-contract) (the ports a component declares in `y_types`) *is* the
public interface ([D-034][d-034]). There are no private intermediates. A value
a later function needs is a declared port like any other ([§5.2][s5-2], [D-194][d-194]). A
stage result outside the contract is a build error (`UndeclaredReturnField`,
[§8.3][s8-3]). A presentational *unlisted* flag, skipped in logs
and GUI but still connectable, is closed ([D-016][d-016], [D-034][d-034]).

### 4.3 Table mechanics and port granularity

[§4.2][s4-2] fixed the [port](#g-port) as the addressable unit. Four questions
remain. What is a port on a [component](#g-component)'s boundary? How do values
travel into [cells](#g-cell) (the typed entries of the signal table) and out of
them? What may a port hold? And how much should a single port carry? The last
question has two answers, one owed to the parties that read a port and one to
the parties that write it.

#### Ports and faces

A component's ports are its signal endpoints, one cell and one producer each.
**Its [faces](#g-face) are the names those ports wear on the component's
boundary** ([D-172][d-172]). For a leaf the two coincide. For an
[assembly](#g-assembly) (pure composition of child components) every face
aliases an interior port through its boundary declarations ([§8.6][s8-6]) and
never creates an endpoint. The distinction is [class](#g-class)-blind ([D-172][d-172]).
Wiring and the [periphery](#g-periphery) (everything outside the loop that
exchanges data with it) address a child's faces without knowing whether it is
primitive or composite.

The port is the atomic unit of the entire periphery. It is each of the
following.

- One cell.
- One [root input](#g-root-input) (a source cell the periphery feeds).
- One staged write.
- One [device](#g-device) [claim](#g-claim) (the set of faces a device may
  write, [§11.3][s11-3]).
- One [trace](#g-trace) address (the trace is the primary record of a
  session).
- One GUI liveness verdict ([§11.7][s11-7]).

#### Scatter and gather

Scatter/gather is the whole protocol. A [stage function](#g-stage-function) (`y_state`/`y_direct`)
returns a NamedTuple on either [tier](#g-tier), continuous or discrete. The framework
scatters each field into that port's concretely typed cell. Every reader gathers
views from cells. The readers are the next stage, `x_deriv`/`s_update` ([§5.2][s5-2]),
[guards](#g-guard), wired consumers and [snapshot](#g-snapshot) capture. A guard is the function defining
an event's predicate, and the snapshot is the immutable per-boundary
publication.

**The aggregate `y` is a merge semantically and virtual physically**
([D-036][d-036]). Semantically, a component's `y` is the merge of its stage
products, `merge(y_x, y_xu)` on the continuous tier and `merge(y_s, y_su)` on
the discrete ([§5.2][s5-2]). It carries declared ports only. Physically no such
object exists. `y` is reconstructed per call from cells, as register-level
field loads at zero cost for isbits, and is never stored as an object.

Name collisions across a component's stages are a build error
(`ProducedByTwoStages`, [§8.3][s8-3]).

## 4. Ports and signals

### 4.1 Immutable value semantics

[Ports](#g-port) exchange **immutable values**, typically isbits structs (floats,
`SVector`s, enums, nested immutables). The framework owns a **[signal table](#g-signal-table)**,
with one concretely typed **[cell](#g-cell)** per output port in the flattened model. A
producer's output [stage function](#g-stage-function) (`y_state`/`y_direct`, the two output
stages every component provides, on either [tier](#g-tier)) returns a named tuple of fresh
values. The framework writes each of those values into its cell, and consumers
read cells.

**Vocabulary.** These names are binding throughout this document.

- A bare *cell* is the table entry, and only that.
- A *store* is the framework-owned home of one of a component's state letters,
  `x`, `s` or `m` ([§7.1][s7-1], [§7.3][s7-3], [D-302][d-302]). An `x` store is a range of
  the [buffer](#g-buffer). Stores are not cells.
- A *[staging cell](#g-staging-cell)* is a distinct compound term. It is the per-[device](#g-device) inbound
  register of [§11.4][s11-4]. Unlike a table cell it is mutated frame by frame, and it
  sits outside the table's publish-once discipline.
- A *[root input](#g-root-input)* is a source cell fed by the [periphery](#g-periphery) rather than by a producer
  ([§11.3][s11-3]).

Stated precisely, the signal requirement is **immutability plus frozen
references**. Signals may reference bulk data ([§4.4][s4-4]) provided that data is
read-only for the duration of the run. `isbits` is the common case, not the
rule.

This requirement has four consequences.

- There is no aliasing, ever. Nothing can be mutated under a consumer's feet.
- Concurrent reads from the GUI and logging threads are safe by construction.
- Isbits payloads allocate nothing, because named tuples of isbits are isbits.
- Each cell has a definite freshness, tied to its producer's position in the
  [execution order](#g-execution-order) ([D-004][d-004]).

### 4.2 Consumers see ports, not stages

The [port](#g-port) is the addressable unit. A [component](#g-component)'s outputs appear to consumers, the
GUI and logs as one flat namespace of ports (`dyn.vel`, `dyn.f_c_c`). A
reader reaches a leaf inside a port value through the port's
[leaf address](#g-leaf-address) (the field name with dotted and bracketed
steps below it, [§14.4][s14-4]). Which output stage computes which port is an
ordering annotation, invisible outside the component. Moving an output between
stages is non-breaking *for consumers*. No wire, log or panel sees it. The build
does see it, because the [feedthrough](#g-feedthrough) graph and stage membership change ([§9.1][s9-1]).

**Visibility.** Which ports exist at all is a declaration-layer decision. The
output [contract](#g-contract) *is* the public interface. There are no private intermediates. A
value a later function needs is a declared port like any other, and a stage
result outside the contract is a build error ([§5.2][s5-2], [§8.3][s8-3]). A presentational
*unlisted* flag, skipped in logs and GUI but still connectable, is closed
([D-016][d-016]).

### 4.3 Table mechanics and port granularity

[§4.2][s4-2] fixed the [port](#g-port) as the addressable unit. Four questions remain. What is a
port on a [component](#g-component)'s boundary? How do values travel into cells and out of them?
What may a port hold? And how much should a single port carry? The last question
has two answers, one owed to the parties that read a port and one to the parties
that write it.

#### Ports and faces

A component's **ports** are its signal endpoints, one [cell](#g-cell) and one producer
each. Its **[faces](#g-face)** are the names those ports wear on the component's boundary.
For a leaf the two coincide. For an [assembly](#g-assembly) every face aliases an interior port
through its boundary declarations ([§8.6][s8-6]) and never creates an endpoint. The
distinction is kind-blind. Wiring and the [periphery](#g-periphery) address a child's faces
without knowing whether it is primitive or composite.

**Rule.** The port is the atomic unit of the entire periphery. It is one cell,
one [root input](#g-root-input), one staged write, one [device](#g-device) [claim](#g-claim) ([§11.3][s11-3]), one [trace](#g-trace) address
and one GUI liveness verdict ([§11.7][s11-7]).

#### Scatter and gather

**Scatter/gather is the whole protocol.** A [stage function](#g-stage-function)
(`y_state`/`y_direct`, on either [tier](#g-tier)) returns a named tuple. The
framework scatters each field into that port's concretely typed cell. Every
reader gathers views from cells. The readers are the next stage,
`x_deriv`/`s_update`, [guards](#g-guard), wired consumers and [snapshot](#g-snapshot) capture.

**The aggregate `y` is a merge semantically and virtual physically.**
Semantically, a component's `y` is the merge of its stage products, `merge(y_x,
y_xu)` on the continuous [tier](#g-tier) and `merge(y_s, y_su)` on the discrete. It carries
declared ports only. Physically no such object exists. `y` is reconstructed per
call from cells, as register-level field loads at zero cost for isbits, and is
never stored as an object.

Name collisions across a component's stages are a build error.


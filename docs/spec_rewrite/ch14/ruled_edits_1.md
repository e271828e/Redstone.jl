# Chapter 14, step 6: the ruled edits, half 1 (units A and B)

Each entry gives the ruling, the unit, and the old and new text of the edited
heading or paragraph, verbatim. Replay them in order on the units as
`chapter_fixes_1.md` left them: an entry's old text is the file as the entries
before it left it, and occurs once there. Every edited paragraph or bullet is
rewrapped to 80 rendered columns (link markup collapsed), so the old and new
blocks are whole paragraphs. A fenced block holds the text verbatim, with no
added newline.

## 1. B1, unit B

Old:

````text
### 14.4 One plan, two ways to apply it
````

New:

````text
### 14.4 Two ways to apply a resolved condition
````

## 2. B2, unit B

Old:

````text
Only stopped-sim service evaluations, [`checkpoint`](#g-checkpoint), and post-run inspection of
the live stores ever hold live stores ([§11.2][s11-2]). That inspection is the
[replay](#g-replay)-to-inspect, where replay is the ordinary loop with its drain reading the
trace. The snapshot deliberately carries no state stores ([§11.2][s11-2]), and `ẋ`
[buffers](#g-buffer) (the vectors the integrator fills) are integrator scratch, not
boundary-consistent objects outside a service evaluation. A reader resolving for
a table source that names a store selector is therefore refused at resolution,
as a `ReadResolution` with reason `:store_selector` ([D-406][d-406]). **The resolver takes
the source it resolves for**, so the rule is the resolver's and not a client's
([D-406][d-406]). The honest remedy ([§11.2][s11-2]) is to declare the field in `y_types`, return
it from `y_state`, and read the resulting [port](#g-port) ([§5.3][s5-3]).
````

New:

````text
Only stopped-sim service evaluations, [`checkpoint`](#g-checkpoint), and post-run inspection of
the live stores ever hold live stores ([§11.2][s11-2]). That inspection is the
[replay](#g-replay)-to-inspect, where replay is the ordinary loop with its drain reading the
trace. Of these holders, only the service evaluations' readers take a store
selector. The snapshot deliberately carries no state stores ([§11.2][s11-2]), and `ẋ`
[buffers](#g-buffer) (the vectors the integrator fills) are integrator scratch, not
boundary-consistent objects outside a service evaluation. A reader resolving for
a table source that names a store selector is therefore refused at resolution,
as a `ReadResolution` with reason `:store_selector` ([D-406][d-406]). **The resolver takes
the source it resolves for**, so the rule is the resolver's and not a client's
([D-406][d-406]). The honest remedy ([§11.2][s11-2]) is to declare the field in `y_types`, return
it from `y_state`, and read the resulting [port](#g-port) ([§5.3][s5-3]).
````

## 3. B2, unit B

Old:

````text
An inspection read, a binding's or `series`', may name any cell the structure
has, since it promises nothing beyond this build ([D-083][d-083]). Both kinds of read
resolve under the one service walk ([§13.3][s13-3]). Inspection reads admit the whole
family, within the source rule. Bindings of an output [device](#g-device) (an attached
participant in the periphery) and log extraction by `series` take deep paths,
`get_face` names and leaf addresses alike ([D-406][d-406], [D-407][d-407], [D-414][d-414]). Snapshot
inspection reads a cell by path and port name instead ([§11.2][s11-2]). A store selector
resolves only for a reader that runs over live stores, which today are the
services' ([§14.7][s14-7], [§14.10][s14-10]). A snapshot-bound reader is barred from it by source,
not by client.
````

New:

````text
An inspection read, a binding's or `series`', may name any cell the structure
has, since it promises nothing beyond this build ([D-083][d-083]). Both kinds of read
resolve under the one service walk ([§13.3][s13-3]). Inspection reads admit the whole
family, within the source rule. Bindings of an output [device](#g-device) (an attached
participant in the periphery) and log extraction by `series` take deep paths,
`get_face` names and leaf addresses alike ([D-406][d-406], [D-407][d-407], [D-414][d-414]). Snapshot
inspection reads a cell by path and port name instead ([§11.2][s11-2]). A store selector
resolves only for a reader that runs over live stores, which today are the
services' ([§14.8][s14-8], [§14.10][s14-10]). A snapshot-bound reader is barred from it by source,
not by client.
````

## 4. B3, unit B

Old:

````text
An inspection read, a binding's or `series`', may name any cell the structure
has, since it promises nothing beyond this build ([D-083][d-083]). Both kinds of read
resolve under the one service walk ([§13.3][s13-3]). Inspection reads admit the whole
family, within the source rule. Bindings of an output [device](#g-device) (an attached
participant in the periphery) and log extraction by `series` take deep paths,
`get_face` names and leaf addresses alike ([D-406][d-406], [D-407][d-407], [D-414][d-414]). Snapshot
inspection reads a cell by path and port name instead ([§11.2][s11-2]). A store selector
resolves only for a reader that runs over live stores, which today are the
services' ([§14.8][s14-8], [§14.10][s14-10]). A snapshot-bound reader is barred from it by source,
not by client.
````

New:

````text
An inspection read, a binding's or `series`', may name any cell the structure
has, since it promises nothing beyond this build ([D-083][d-083]). Both kinds of read
resolve under the one service walk ([§13.3][s13-3]). Inspection reads admit the whole
family, within the source rule. Bindings of an output [device](#g-device) (an attached
participant in the periphery) and log extraction by `series` take deep paths,
`get_face` names and leaf addresses alike ([D-406][d-406], [D-407][d-407], [D-414][d-414]). Snapshot
inspection ([§11.2][s11-2]) reads a cell by path and port name instead. A store selector
resolves only for a reader that runs over live stores, which today are the
services' ([§14.8][s14-8], [§14.10][s14-10]). A snapshot-bound reader is barred from it by source,
not by client.
````

## 5. B5, unit A

Old:

````text
The blend is still closed explicitly. A `combine(::Fragment, ::NamedTuple)`, or
any other blend of a condition node with a bare NamedTuple, is an error method.
Its message is directive. It says to wrap the NamedTuple in `set(…)` (or
`at(prefix, set(…))`) and to combine nodes with nodes. Like every other, the
rejection carries a [kind](#g-kind) (a diagnostic's identity in a closed, enumerated set).
**It is `ConditionNodeMisuse`** ([Appendix C][sC], [D-113][d-113]), carrying the offending
argument's type and the node types in hand. It is raised at composition time,
before any resolution pass runs or any origin exists. That is why it is its own
kind and not a `ConditionResolution` sub-kind ([§14.3][s14-3]). The explicit, *ordered*
layering spelling, `override`, belongs with the use case of [root-input totality](#g-root-input-totality)
(the requirement that an application establishing a complete world cover every
root input) ([§14.6][s14-6]).
````

New:

````text
The blend is still closed explicitly. A `combine(::Fragment, ::NamedTuple)`, or
any other blend of a condition node with a bare NamedTuple, is an error method.
Its message is directive. It says to wrap the NamedTuple in `set(…)` (or
`at(prefix, set(…))`) and to combine nodes with nodes. Like every other, the
rejection carries a [kind](#g-kind) (a diagnostic's identity in a closed, enumerated set).
**The blend rejection is `ConditionNodeMisuse`** ([Appendix C][sC], [D-113][d-113]), carrying the
offending argument's type and the node types in hand. It is raised at
composition time, before any resolution pass runs or any origin exists. That is
why it is its own kind and not a `ConditionResolution` sub-kind ([§14.3][s14-3]). The
explicit, *ordered* layering spelling, `override`, belongs with the use case of
[root-input totality](#g-root-input-totality) (the requirement that an application establishing a complete
world cover every root input) ([§14.6][s14-6]).
````

## 6. B6, unit B

Old:

````text
- **A commit-fired handler is not the only mover**, and the second one is
  unconditional ([D-155][d-155]). Boundary zero's *first* act is `x_projection`, so the
  committed `x` is `x_projection(x*)`, not the solver's `x*`. An attitude
  quaternion renormalized by a few ulps is the canonical case. That move is
  legitimate, wanted, and usually invisible in the residuals. But the point the
  stores sit at is no longer the point the solver's convergence verdict was read
  at ([§14.8][s14-8]). Both movers take the same remedy, specified with the report in
  [§14.8][s14-8].
````

New:

````text
- A commit-fired handler is not the only mover. **Projection is the second, and it
  is unconditional** ([D-155][d-155]). Boundary zero's *first* act is `x_projection`, so the
  committed `x` is `x_projection(x*)`, not the solver's `x*`. An attitude
  quaternion renormalized by a few ulps is the canonical case. That move is
  legitimate, wanted, and usually invisible in the residuals. But the point the
  stores sit at is no longer the point the solver's convergence verdict was read
  at ([§14.8][s14-8]). Both movers take the same remedy, specified with the report in
  [§14.8][s14-8].
````


# The edit list engine.py replays from the verified commit, in order.
OPS = [
# ---------------- unit A: the opening ----------------
("span", "P1-2", "A",
 "the [`Model`](#g-model)'s state at a frame top as one value), and `restore!`",
 "the `Model`'s state at a frame top as one value), and `restore!`"),
("span", "P1-1", "A",
 "[§14.4][s14-4] its application; [§14.5][s14-5] covers the [boundary-zero](#g-boundary-zero) sequence; [§14.6][s14-6] covers [root-input totality](#g-root-input-totality) (the requirement that an application establishing a complete world cover every [root input](#g-root-input)); [§14.7][s14-7] the trim problem, [§14.8][s14-8] the trim service and [§14.9][s14-9] mounting, which together cover the trim service in full; and [§14.10][s14-10] covers linearization.",
 "[§14.4][s14-4] its application and the read selectors; [§14.5][s14-5] covers the [boundary-zero](#g-boundary-zero) sequence, [§14.6][s14-6] [root-input totality](#g-root-input-totality) (the requirement that an application establishing a complete world cover every [root input](#g-root-input)) and `override`, [§14.7][s14-7] the trim problem, [§14.8][s14-8] the trim service, [§14.9][s14-9] mounting and [§14.10][s14-10] linearization."),
("span", "P1-35", "A",
 "covers the [boundary-zero](#g-boundary-zero) sequence,",
 "covers the initialization sequence called [boundary zero](#g-boundary-zero),"),
("span", "P1-3", "A",
 "While a run exists the loop owns",
 "While the simulation is `running`, the loop owns"),
("span", "P1-35", "A",
 "the loop owns the [stores](#g-store) between [drains](#g-drain)",
 "the loop owns the [stores](#g-store) (the framework-owned homes of components' `x`, `s` and `m` state). It owns them between [drains](#g-drain)"),
("span", "P1-35", "A",
 "Pause is a [control-plane](#g-control-plane) state *inside* a run, so",
 "Pause is a state *inside* a run, carried by the [control plane](#g-control-plane) (the separate atomic surface for pause, pace and the stop word), so"),
("span", "P1-2", "A",
 "**Each row's service also has a form on a `Model`**",
 "**Each row's service also has a form on a [`Model`](#g-model)**"),
# ---------------- unit A: §14.1 ----------------
("span", "P1-4", "A",
 "This section covers, in order, what a condition may specify,",
 "A [condition](#g-condition) is the value an author writes to say which state a build starts from. This section covers, in order, what a condition may specify,"),
("span", "P1-4", "A",
 "A [condition](#g-condition) may specify state fields,",
 "A condition may specify state fields,"),
("span", "P1-35", "A",
 "`x` on the continuous [tier](#g-tier) and `s` on the discrete.",
 "`x` on the continuous [tier](#g-tier) (one side of the hybrid formalism) and `s` on the discrete."),
("span", "P1-35", "A",
 "a condition may specify [root inputs](#g-root-input), addressed by [face](#g-face)",
 "a condition may specify [root inputs](#g-root-input) (the root's own input faces). It addresses them by [face](#g-face)"),
("span", "P1-6", "A",
 "The first case is trim's `α_filt = α_a`.",
 "The first case is trim's `α_filt = α_a` ([§14.2][s14-2])."),
("span", "P1-35", "A",
 "of [§8.2][s8-2], applied to the same values the [`baseline`](#g-baseline) writes into",
 "of [§8.2][s8-2]. The condition applies it to the same values the [`baseline`](#g-baseline) (the full-coverage condition `trim!` takes as a keyword) writes into"),
("span", "P1-5", "A",
 "the second escape already covers the case ([D-139][d-139]).",
 "the doctrine's second case already covers it ([D-139][d-139])."),
# ---------------- unit A: §14.2 ----------------
("span", "P1-6", "A",
 "and nothing above it should have to.",
 "and nothing above it should have to. `n_eng` is the engine speed as a fraction of its rated speed `ω_rated`."),
("span", "P1-35", "A",
 "It is the [condition](#g-condition) method,",
 "It is the condition method,"),
("span", "P1-6", "A",
 "after FlightApps' `C172X.Systems`).",
 "after FlightApps' `C172X.Systems`). In the block, `α_filt` and `β_filt` are the aerodynamics' filtered airflow angles, set to the angle of attack `α_a` and the sideslip `β_a`."),
("delete", "P1-8", "A",
 "Dispatch selects variant-specific methods, so the actuation split"),
("insert_after", "P1-8 and P1-7", "A",
 '    at("aero",       set(x = (α_filt = α_a, β_filt = β_a))))\n```',
 "Dispatch selects variant-specific methods, so the actuation split between Flight.jl's two Cessna 172 variants, c172s and c172x, costs no upstream edits."),
("span", "P1-35", "A",
 "*of the authoring level's [contract](#g-contract)*.",
 "*of the authoring level's [contract](#g-contract)* (its declared interface)."),
("span", "P1-35", "A",
 "lazy [fragment tree](#g-fragment-tree)** ([D-065][d-065]).",
 "lazy [fragment tree](#g-fragment-tree)** (the nested `Fragment`, `Scoped`, `Combined` and override nodes) ([D-065][d-065])."),
("span", "P1-9", "A",
 "and `override` builds a fourth node type ([§14.6][s14-6]).",
 "and [`override`](#g-override), the ordered, asymmetric layering combinator, builds a fourth node type ([§14.6][s14-6])."),
("span", "P1-10", "A",
 "writes each trial state through FlightPhysics' `assign!`, and the zero-alloc property of that `assign!` loop holds of the construction",
 "writes each trial state through FlightPhysics' `assign!`, a loop that allocates nothing. That property holds of the construction"),
("span", "P1-35", "A",
 "On a condition node it raises `ConditionNodeMisuse`",
 "On a node of a [condition](#g-condition) (the path-addressed sparse overlay that sets a build's state), `at` raises `ConditionNodeMisuse`"),
("span", "P1-35", "A",
 "are [local wires](#g-local-wire), computed interface connections and conditions.",
 "are [local wires](#g-local-wire) (wires from one child's port to a child's face), computed interface connections and conditions."),
("span", "P1-35", "A",
 "at every genericity [seam](#g-seam).",
 "at every genericity [seam](#g-seam) (a narrow, named interface kept deliberately thin)."),
("span", "P1-35", "A",
 "owned or [generically held](#g-generic-holding), because",
 "owned or [generically held](#g-generic-holding) (held through a non-concrete field type), because"),
("span", "P1-35", "A",
 "as [cell](#g-cell) offsets are of `local_wires`.",
 "as the offsets of [cells](#g-cell) (the typed entries of the signal table) are of `local_wires`."),
("span", "P1-11", "A",
 "That rejection is also why **the combinator is not `Base.merge`**, and is no longer named after it ([D-204][d-204]).",
 "**The combinator is not `Base.merge`**, and is no longer named after it ([D-204][d-204]). The last-writer-wins rejection is also the reason."),
("span", "P1-35", "A",
 "The rejection carries a [kind](#g-kind) like every other.",
 "Like every other, the rejection carries a [kind](#g-kind) (a diagnostic's identity in a closed, enumerated set)."),
("span", "P1-9", "A",
 "layering spelling, [`override`](#g-override), belongs with the use case [root-input totality](#g-root-input-totality) produces ([§14.6][s14-6]).",
 "layering spelling, `override`, belongs with the use case [root-input totality](#g-root-input-totality) produces ([§14.6][s14-6])."),
("span", "P1-35", "A",
 "belongs with the use case [root-input totality](#g-root-input-totality) produces ([§14.6][s14-6]).",
 "belongs with the use case of [root-input totality](#g-root-input-totality) (the requirement that an application establishing a complete world cover every root input) ([§14.6][s14-6])."),
# ---------------- unit A: §14.3 ----------------
("span", "P1-4", "A",
 "Resolution takes the root node plus a [`Build`](#g-build)",
 "Resolution turns a composed [condition](#g-condition) (the path-addressed sparse overlay that sets a build's state) into plans the services can apply. It takes the root node plus a [`Build`](#g-build)"),
("span", "P1-35", "A",
 "records each [condition](#g-condition) entry's tree position",
 "records each condition entry's tree position"),
("span", "P1-13", "A",
 "every decision-dependent leaf is `Dual`-typed",
 "every decision-descended leaf is `Dual`-typed"),
("span", "P1-35", "A",
 "At the [nominal](#g-nominal) activation the same rule",
 "At the [nominal](#g-nominal) activation (the `Float64` one), the same rule"),
("span", "P1-35", "A",
 "activation's [scratch](#g-scratch) is a held constant,",
 "activation's [scratch](#g-scratch) (mutable working storage whose contents are never authoritative) is a held constant,"),
("raw", "P1-36", "A",
 "compile time under the overlay-base rule ([§14.1][s14-1]).\n\n",
 "compile time under the overlay-base rule ([§14.1][s14-1]).\n"),
# ---------------- unit B: §14.4 ----------------
("span", "P1-15", "B",
 "Execution is therefore resolve-once/execute-many, with two ways to apply the compiled plans ([§14.3][s14-3]).",
 "Execution is therefore resolve-once/execute-many."),
("span", "P1-35 and P1-36", "B",
 "It unrolls [stores](#g-store) through the baked",
 "It unrolls [stores](#g-store) (the framework-owned homes of components' `x`, `s` and `m` state) through the baked"),
("span", "P1-16", "B",
 "an envelope of trims included.",
 "an envelope of trims (one trim per point of a grid of flight conditions) included."),
("rewrap", "P1-36", "B",
 "runtime dispatch per write, from its own plan"),
("delete", "P1-26", "B",
 "`apply!` ends at established stores."),
("insert_after", "P1-26", "B",
 "FlightCore, where it is the continuous-dynamics function a model extends.",
 "`apply!` ends at established stores. Making the model *coherent* is the job of [boundary zero](#g-boundary-zero) (the initialization boundary, the ordinary macro-sequence with an empty integrate), which [§14.5][s14-5] specifies."),
("span", "P1-17", "B",
 "The read-[selector](#g-selector) family is closed ([D-095][d-095]).",
 "The family of read [selectors](#g-selector) (values describing a read the compiled gather will perform) is closed ([D-095][d-095])."),
("split", "P1-18 and P1-36", "B",
 "**Each step is checked at resolution against the type resolved so far**"),
("span", "P1-19", "B",
 "has that one remedy too, and it is the same for every client.",
 "has the same remedy, whatever its client."),
("span", "P1-20 and P1-36", "B",
 "`get_face` addresses an output face of the mount level, the level its read set is mounted at ([§14.9][s14-9], [D-277][d-277]). [Mounting](#g-mounting) relocates a whole problem or [tap set](#g-taps) (the three selector lists declaring what linearization seeds and reports) with `at(prefix, …)`.",
 "[Mounting](#g-mounting) relocates a whole problem or [tap set](#g-taps) (the three selector lists declaring what linearization seeds and reports) with `at(prefix, …)`. `get_face` addresses an output face of the mount level, the level a problem's or tap set's reads are mounted at ([§14.9][s14-9], [D-277][d-277])."),
("span", "P1-35 and P1-36", "B",
 "A table source is a [boundary](#g-boundary) [snapshot](#g-snapshot), or",
 "A table source is a [boundary](#g-boundary) [snapshot](#g-snapshot) (the immutable publication at a published consistency point), or"),
("span", "P1-35", "B",
 "post-run inspection of the live stores (the [replay](#g-replay)-to-inspect) ever hold live stores ([§11.2][s11-2]).",
 "post-run inspection of the live stores ever hold live stores ([§11.2][s11-2]). That inspection is the [replay](#g-replay)-to-inspect, where replay is the ordinary loop with its drain reading the trace."),
("span", "P1-35", "B",
 "and `ẋ` [buffers](#g-buffer) are integrator scratch,",
 "and `ẋ` [buffers](#g-buffer) (the vectors the integrator fills) are integrator scratch,"),
("replace_units", "P1-21, P1-35 and P1-36", "B",
 "On top of the source rule sits one piece of authoring guidance",
 "A snapshot-bound reader is barred from it by source, not by client.",
 ["On top of the source rule sits one piece of authoring guidance ([D-414][d-414]). Trim's `reads` and linearization's taps name `get_state`/`get_deriv`/`get_output`/`get_input`/`get_face`. They do so within the scopes the locality law ([§6.1][s6-1]) and [fragment](#g-fragment) scoping ([§14.2][s14-2]) describe. A fragment is the leaf node of the condition algebra, built by `set`. A service read, trim's `reads` or a tap, that should outlive the build reads a face with `get_face` ([D-125][d-125]). `get_face` resolves through export chains exactly as mounting resolves [root input](#g-root-input) faces ([§14.9][s14-9], [D-125][d-125]), so the read side mirrors the write side. An equilibrium equation meant to outlive the build it was posed against therefore binds the curated face behind a [generically held](#g-generic-holding) child (one held through a non-concrete field type) rather than a path into it.",
  "An inspection read, a binding's or `series`', may name any cell the structure has, since it promises nothing beyond this build ([D-083][d-083]). Both kinds of read resolve under the one service walk ([§13.3][s13-3]). Inspection reads admit the whole family, within the source rule. Bindings of an output [device](#g-device) (an attached participant in the periphery) and log extraction by `series` take deep paths, `get_face` names and leaf addresses alike ([D-406][d-406], [D-407][d-407], [D-414][d-414]). Snapshot inspection reads a cell by path and port name instead ([§11.2][s11-2]). A store selector resolves only for a reader that runs over live stores, which today are the services' ([§14.7][s14-7], [§14.10][s14-10]). A snapshot-bound reader is barred from it by source, not by client."]),
("span", "P1-24", "B",
 "one per `StopFlag` output port), period ([§13.5][s13-5],",
 "one per `StopFlag` output port) and nothing else ([§13.5][s13-5],"),
("span", "P1-25", "B",
 "**Compiled readers are the gather twin** ([D-066][d-066]) over this family and the [layout](#g-schema-vs-layout) tables (where each value physically lives).",
 "Over this family and the [layout](#g-schema-vs-layout) tables (where each value physically lives), **compiled readers are the gather twin** ([D-066][d-066])."),
# ---------------- unit B: §14.5 ----------------
("span", "P1-35", "B",
 "`apply!` establishes the [stores](#g-store) at `t₀`.",
 "`apply!` establishes the [stores](#g-store) (the framework-owned homes of components' `x`, `s` and `m` state) at `t₀`."),
("span", "P1-35", "B",
 "After the first snapshot `init!` takes the [trace header](#g-trace-header),",
 "In the sequence, a sweep is one pass through the execution order against the current state, and a guard is the declared function defining an event's predicate. A due component is a discrete component whose schedule admits the boundary's tick index, and a snapshot is the immutable per-boundary publication. After the first snapshot `init!` takes the [trace header](#g-trace-header),"),
("span", "P1-27", "B",
 "[boundary zero](#g-boundary-zero) (the initialization boundary at `t₀`) means for trim.",
 "[boundary zero](#g-boundary-zero) (the initialization boundary, the ordinary macro-sequence with an empty integrate) means for trim."),
("span", "P1-35", "B",
 "[Projection](#g-projection) after condition writes holds the same position",
 "After condition writes, [projection](#g-projection) (the optional per-component hook `x ← x_projection(x)`) holds the same position"),
("span", "P1-35", "B",
 "because its first [tick](#g-tick) is at",
 "because its first [tick](#g-tick) (an instant at which its stages and update run) is at"),
("span", "P1-35", "B",
 "No published [cell](#g-cell) holds the [probe](#g-probe)'s synthesized values. That is the [§14.6][s14-6] barrier extended",
 "No published [cell](#g-cell) holds a synthesized [probe value](#g-probe-value) (a fabricated value a build-time probe runs on). That is the probe-value barrier of [§14.6][s14-6] extended"),
("span", "P1-35", "B",
 "land a guard [predicate](#g-predicate) in [holding](#g-edge-semantics) territory",
 "land a guard [predicate](#g-predicate), a `Bool`-valued form or the sign of a continuous function, in [holding](#g-edge-semantics) territory"),
("span", "P1-28", "B",
 "The [prior](#g-prior) rule grounds that timing",
 "The prior rule grounds that timing"),
("span", "P1-28", "B",
 "establishes every guard prior (the event's stored predicate sample",
 "establishes every guard [prior](#g-prior) (the event's stored predicate sample"),
("span", "P1-35", "B",
 "[stage-on-interaction](#g-stage-on-interaction) rule ([§11.7][s11-7]).",
 "[stage-on-interaction](#g-stage-on-interaction) rule (when a GUI widget stages a new value) ([§11.7][s11-7])."),
("span", "P1-35", "B",
 "A [stop request](#g-stop-request) already reading",
 "A [stop request](#g-stop-request) (an output port of the framework enum `StopFlag`) already reading"),
("span", "P1-29", "B",
 "sibling to the boundary-sampling line ([§8.6][s8-6]).",
 "sibling to the boundary-sampling contract ([§8.6][s8-6])."),
("span", "P1-30 and P1-7", "B",
 "The hand-written trim asserts of Flight.jl's Cessna 172 models (no weight-on-wheels, `ω > ω_idle`) become",
 "The hand-written trim asserts (no gear strut in ground contact, engine speed `ω` above `ω_idle`) of Flight.jl's two Cessna 172 variants, c172s and c172x, become"),
("span", "P1-30", "B",
 "Saying nothing would be warn-but-assign relocated.",
 "Saying nothing would relocate warn-but-assign, where the trim of Flight.jl's Cessna 172 model (`c172.jl`) warns on a failed optimization and assigns its result anyway."),
("span", "P1-32", "B",
 "no longer the point the verdict was read at.",
 "no longer the point the solver's convergence verdict was read at ([§14.8][s14-8])."),
# ---------------- unit B: §14.6 ----------------
("span", "P1-35", "B",
 "[Root inputs](#g-root-input) are the one initialized datum",
 "[Root inputs](#g-root-input) (the root's own input faces) are the one initialized datum"),
("span", "P1-9", "B",
 "and baselines layered by `override`.",
 "and baselines layered by [`override`](#g-override) (the ordered, asymmetric layering combinator)."),
("span", "P1-35", "B",
 "[Fragments](#g-fragment) compose, and trim iterations",
 "[Fragments](#g-fragment) (the leaf nodes of the condition algebra, built by `set`) compose, and trim iterations"),
("span", "P1-33", "B",
 "A silently zeroed `mixture` kills the engine",
 "A silently zeroed `mixture`, the mixture setting of FlightPhysics' `PistonEngine`, kills the engine"),
("span", "P1-35", "B",
 "[Replay](#g-replay) likewise never synthesizes.",
 "[Replay](#g-replay) (the ordinary loop with its drain reading the trace) likewise never synthesizes."),
("span", "P1-35", "B",
 "The [trace header](#g-trace-header) holds every",
 "The [trace header](#g-trace-header) (the trace's fixed preamble) holds every"),
("span", "P1-34", "B",
 "That discharges the requirement ([§11.3][s11-3]).",
 "That discharges the requirement that a root input no device feeds hold a defined value from the first frame ([§11.3][s11-3])."),
("span", "P1-9", "B",
 "**the fourth node type, [`override(base, patch)`](#g-override), exists for it**",
 "**the fourth node type, `override(base, patch)`, exists for it**"),
]

NOTES = """## Findings not applied

- RULING, left untouched: P1-12, P1-14, P1-22, P1-23 and P1-31, and half 2's
  P2-47, which lands in unit B.
- P1-37 and P1-38 are fixed in half 2's units.
- No other half 2 finding falls in units A or B. P2-17's remark on §14.5's
  warn-but-assign is P1-30, applied.

## How the applied fixes differ from the passes' wording

- P1-1: the roadmap stays one sentence, as R1 rules, with a semicolon after
  §14.4. Boundary zero takes its P1-35 gloss as "the initialization sequence
  called boundary zero", since the sentence already holds totality's
  parenthetical.
- P1-6: the `n_eng` sentence sits at its first use, §14.2's context
  paragraph, not after line 154. `"pwp/engine"` and `"aero"` get no clause;
  the finding's fix names none.
- P1-9: in §14.2, `override`'s gloss is an appositive, since its sentence
  already holds `combine`'s parenthetical.
- P1-19: "The component exports it" stays, as R5 keeps that sentence.
- P1-21: the service-read sentence keeps "trim's `reads` or a tap". "Both
  kinds of read resolve under the one service walk" comes second in the
  inspection paragraph, right after the service paragraph it pairs with, so
  "instead" in the snapshot sentence still contrasts with bindings and
  `series`.
- P1-30: warn-but-assign names the trim of Flight.jl's Cessna 172 model
  (`c172.jl` 934–939), since the variants hold the asserts and `c172.jl`
  holds the warning.
- P1-34: "a root input no device feeds", after §11.3's "a root input unfed
  by any device" (frozen spec 7325–7326), in place of "every root input".
- P1-35, per term:
  - the opening's root input sits inside totality's gloss; a gloss there
    would nest, so it stays linked and unglossed;
  - §14.2's condition link moves off "condition method" to the empty-prefix
    paragraph, the section's first use of the value; §14.3's moves to the new
    context sentence (P1-4);
  - §14.3's schema/layout: its sentence defines schema and the next defines
    layout, so it takes no gloss;
  - §14.5's chain keeps its links; a sentence after it glosses sweep, guard,
    due and snapshot. The trace header keeps its appositive gloss, "the
    checkpoint … of the state the sequence leaves";
  - §14.5's probe link becomes `#g-probe-value`, glossed from that entry, as
    P2-13 does for §14.8's twin sentence; "the §14.6 barrier" becomes §14.6's
    name for it, the probe-value barrier;
  - to keep one parenthetical per sentence, some glosses split a sentence
    (the opening's stores, §14.1's root inputs and value-level constructor)
    or reorder it (control plane, kind, projection, device, the replay of
    §14.4).
- P1-36: A's trailing blank line goes, and every edited paragraph is
  rewrapped to 80 rendered columns.
"""

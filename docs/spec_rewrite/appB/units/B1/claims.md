# Unit B1 claims. Spans are normalized (check_unit.py show-old / show-new).

old: ## Appendix B. API synopsis: the entry points
tag: X

old: The user-facing surface on one page, under the same rule as Appendix A: an index, not a second home.
tag: F
note: index, not a second home linked to #g-normative at its first use in B (R12)

old: Each signature is normative only where its owning section settles it.
tag: F

old: Every name here is public by being here, reached by qualified name or by per-name `import`.
new: Every name here is public by being here, reached by qualified name or by per-name `import` (D-226).
tag: C
newcites: D-226
note: R6, R1-04; D-226's Position states it

old: The module exports nothing until the exported-name audit (`pending.md`) fixes the list (D-226).
tag: F

old: The author-side declaration surface comes first, then the operator surface by lifecycle.
tag: F

old: Authoring,
new: #### Authoring
tag: R
ruling: R4

old: what a component or assembly defines (§8.2, §8.5–§8.7):
new: What a component or assembly defines (§8.2, §8.5–§8.7):
tag: F

old: Continuous leaf. `x_init` (by value,
new: Continuous leaf. `x_init` and `m_init` (by value)
tag: F
note: the two by-value declarations share one parenthetical

old: mandatory, `(;)` when stateless)
new: Every leaf declares exactly one of `x_init` and `s_init`, and a stateless leaf declares it empty (D-263)
tag: M
where: homes.md
note: R1, R1-08 and R1-15, both leaves; "mandatory" is §8.2's next sentence, "It is therefore mandatory even when empty"

old: and `m_init` (by value),
new: `x_init` and `m_init` (by value),
tag: F

old: `ws_init(::C, ::Type{T})` (by allocation),
tag: F

old: `u_types` and `y_types` (by type,
tag: F

old: walked,
new: A by-type declaration walks by the same rule.
tag: M
where: homes.md
note: R1, R1-11

old: `Pinned{P}` marking a frozen leaf), and `state_events`.
tag: F

old: Its stage and event functions are `y_state`, `y_direct` and `x_deriv`, guard/handler pairs (`StateEvent(guard, handler)`
new: Its stages are `y_state` and `y_direct`, its update law `x_deriv`, and its event functions guard/handler pairs (`StateEvent(guard, handler)`
tag: R
ruling: coordinator 2026-10-20
note: §5.2 (frozen 1040), every leaf provides exactly two output stages; §8.2 (frozen 2281), "the stage and update-law names"

old: ; the detection policy comes from the guard's return type, §10.4)
new: The guard's return type declares its detection policy (D-179).
tag: M
where: homes.md
note: R1, R1-14

old: and `x_projection`.
tag: F

old: Discrete leaf. `s_init` (by value,
new: Discrete leaf. `s_init` (by value)
tag: F

old: `ws_init(::C, ::Type{T})` (always
new: `ws_init(::C, ::Type{T})` and `u_types`/`y_types`
tag: F
note: the discrete leaf's allocator; its parenthetical moves, next block

old: (always called at `Float64`)
new: A discrete allocator receives `Float64` at every activation
tag: M
where: homes.md
note: R1, R1-16

old: and `u_types`/`y_types`
new: `ws_init(::C, ::Type{T})` and `u_types`/`y_types`
tag: F

old: (pinned wholesale).
new: The discrete side pins wholesale.
tag: M
where: homes.md
note: R1, R1-17

old: Its stages are `y_state`, `y_direct` and `s_update`.
new: Its stages are `y_state` and `y_direct`, and its update law `s_update`.
tag: R
ruling: coordinator 2026-10-20
note: §5.2 and §8.2, as for the continuous leaf

old: Assembly. `local_wires` (
new: Assembly. `local_wires` (the class marker),
tag: F

old: (mandatory,
new: `local_wires(::A)` is mandatory even when empty
tag: M
where: homes.md
note: R1, R1-19

old: the class marker),
new: `local_wires` (the class marker),
tag: F

old: `input_wires`, `output_wires`, `sample_times` and `transparent_container` (optional, default `nothing`).
new: `input_wires`, `output_wires` and `sample_times`, and the optional `transparent_container` (default `nothing`).
tag: R
ruling: coordinator 2026-10-20
note: §8.5 (frozen 3204–3206) gives the default `nothing` to `transparent_container` alone; the other three's defaults left unstated

old: Any component. `stop_reason` (optional, default `""`), the reason its stop requests report (§13.5).
new: Any component. `stop_reason` (optional, default `""`), the reason its stop requests report (§8.2, D-316).
tag: C
newcites: §8.2 D-316
note: coordinator 2026-10-20; §8.2 (frozen 2913), "`stop_reason(c)` returns the `String` a component's stop requests report, and it defaults to `""`" (D-316); stop requests linked to #g-stop-request (R12)

old: Shipped conditions. `condition(::C; kw)`, methods of the framework's `condition` generic that return the component's fragment (§14.2).
tag: F
note: fragment linked to #g-fragment (R12)

old: Bundle contents by function family (the maximal legal sets, §5.2;
new: Bundle contents by function family (the maximal legal sets, §5.2):
tag: F
note: function family linked to #g-function-family (R12)

old: signatures destructure less at will):
new: the destructuring narrows it further to actual reads
tag: M
where: homes.md
note: R1, R1-24

old: | function | tier | bundle fields | |---|---|---| | `y_state` | continuous | `x, m, t [, ws]` | | `y_direct` | continuous | `x, m, u, y_x, t [, ws]` | | `x_deriv` | continuous | `x, m, y, u, t [, ws]` | | `y_state` | discrete | `s, t, Δt [, ws]` | | `y_direct` | discrete | `s, u, y_s, t, Δt [, ws]` | | `s_update` | discrete | `s, y, u, t, Δt [, ws]` | | guard / handler | continuous | `x, m, y, u, t [, ws]` | | `x_projection` | continuous | positional `(comp, x)`, no bundle |
tag: F
note: R3, the table verbatim

old: Table footnotes, from the bundle law (§5.2).
new: under the bundle law (§5.2).
tag: X
note: R3, the footnote paragraph collapses to two sentences; bundle linked to #g-bundle

old: The sets above are maximal,
new: the maximal legal sets
tag: F
note: R1-34 repeats the table lead, which keeps it

old: and each field is present only if it exists for the component.
new: Each field is present only if it exists for the component
tag: F
note: R3

old: `u` is present iff the function family may see inputs and the component declares `u_types`.
new: | `u` | the function family (which bundle fields a given function may legally receive) may see inputs and the component declares `u_types` |
tag: M
where: homes.md
note: R3, R1-35

old: `y` is present iff the component declares `y_types`.
new: | `y` | the component produces any table cell at all (it declares `y_types`) |
tag: M
where: homes.md
note: R3, R1-36

old: `x`/`s`/`m` are present iff declared non-empty (D-297), and `ws` iff declared.
new: | `x` | the component declares a non-empty `x_init` (continuous tier) (D-297) | | `s` | the component declares a non-empty `s_init` (discrete tier) (D-297) | | `m` | the component declares a non-empty `m_init` (D-297) | | `ws` | the component declares `ws_init` |
tag: M
where: homes.md
note: R3, R1-37

old: `y_x`/`y_s` are present iff the stage-1 return is non-empty (§5.2, D-285).
new: | `y_x` / `y_s` | stage-1 ports exist, under the tier's own spelling |
tag: M
where: homes.md
note: R3, R1-38; §5.2 adds "A stage that exists produces at least one port (D-285)"

old: `Δt` is present on the discrete tier only.
new: | `Δt` | the component is on the discrete tier |
tag: M
where: homes.md
note: R3, R1-39

old: Returns follow three rules.
new: Returns follow three rules, among them
tag: F
note: R3

old: A stage returns a NamedTuple of port values (§4.3, §5.2).
new: An output stage returns its port NamedTuple, `y`, and nothing else (D-194).
tag: M
where: homes.md
note: R3, R1-41

old: `x_deriv` returns the layout image of `X` (§7.1).
new: `Ẋ` has exactly `X`'s shape at the activation scalar
tag: M
where: homes.md
note: R3, R1-42; the §7.1 citation stays on the returns sentence

old: A handler returns `(; x, m)`
new: the handler's `(; x, m)` under the return law (§5.2, §7.1, D-090)
tag: R
ruling: R3
newcites: §5.2 §7.1 D-090
note: R9, the return law cites D-090, whose Position states it; the bold goes (R3)

old: with each key present iff that store exists and the handler updates it
new: A key is present iff the corresponding store exists on the component and the handler updates it.
tag: M
where: homes.md
note: R3, R1-43

old: (the return law, §5.2).
new: under the return law (§5.2, §7.1, D-090)
tag: F

old: There is no padding.
new: An absent key is not an error and not a no-op to diagnose. It is the handler saying it does not touch that store.
tag: M
where: homes.md
note: R3, R1-44

old: `x` comes back complete, and `m` may come back partial.
new: `x` must be complete against the state field set, while `m` may be partial (D-053, D-287).
tag: M
where: homes.md
note: R3, R1-45

old: Build.
new: #### Build
tag: R
ruling: R4

old: - `build(world) → Build`.
new: - `build(world; activations = ()) → Build`.
tag: R
ruling: R1
note: src/build.jl:572 gives `activations::Tuple = ()`; `world` kept as §9.2 spells it, src says `root` (rulings.md)

old: Standalone.
tag: F

old: It yields the inspectable derived-contract artifact, `Structure`
new: It yields the inspectable derived-contract artifact, `Structure`, `Outputs`, `Events`, the activations and `warnings` (§9.2).
tag: F
note: derived-contract, Structure, Outputs, Events and activations linked (R12); their glosses move, next three blocks

old: (the structure step's product, the components, wires, faces and tiers),
new: `Structure` (the structure step's product, the components, wires and tiers)
tag: M
where: homes.md
note: R7, R1-49 drifted ("faces"); dropped since the thin shape no longer needs the gloss

old: `Outputs` (the nominal evaluation's product, the port classes and the execution order),
new: `Outputs` (the nominal evaluation's product, the port classes and the execution order)
tag: M
where: homes.md
note: R1; the name stays in the build entry

old: `Events` (the nominal evaluation's other product, the event names and policies), the activations and `warnings`
new: `Events` — the nominal evaluation's other product, built last, after the nominal stage probes: per component the event names, their detection policies and the bundle names.
tag: M
where: homes.md
note: R1, the gloss only; the name, the activations and `warnings` stay in the build entry

old: ; the wire list per assembly and the root inputs are `Structure`'s,
new: Its parts hold the wire list, per assembly and as declared, the root inputs and the execution order as plain printable data. The first two sit on `Structure`
tag: M
where: homes.md
note: R1, R1-50

old: the face table and the routes are functions over them,
new: The face table is two-sided, and `Structure` answers it as a function over the declared wires
tag: M
where: homes.md
note: R1, R1-50; the routes are §13.7's, "`show(::Structure)` derives each face's routing chain from the declared wires"

old: and the execution order is `Outputs`'s (§9.2).
new: The last sits on `Outputs`
tag: M
where: homes.md
note: R1, R1-50; the §9.2 citation stays on the build entry

old: `build(world; activations = (Float64, ProbeDual))` additionally pins activation invariants for CI
new: `activations = (Float64, ProbeDual)` additionally pins activation invariants for CI
tag: F
note: the keyword's value now hangs off the build signature above

old: (`ProbeDual` is the public canonical concrete probe scalar, §9.4),
new: - `ProbeDual`. The public canonical concrete probe scalar (§9.4).
tag: F
note: its own entry, linked to #g-probedual

old: and pre-materializes activations
new: and pre-materializes activations for a parallel sweep (§11.1, §9.4).
tag: F

old: so a parallel sweep shares a fully immutable `Build` (§11.1, §9.4).
new: The shared `Build` is then a fully immutable artifact, with no synchronization on any path.
tag: M
where: homes.md
note: R1, R1-54; both citations stay on the kept clause

old: - `resolve(assembly, path) → AbstractComponent`. Resolves an immediate child, a container element's key segment included.
new: - `resolve(assembly, path) → AbstractComponent`. Resolves an immediate child, a container element's key segment included (§13.3).
tag: F
newcites: §13.3

old: Wiring resolution applies the one-level rule (§6.1).
new: The first is the one-level rule (§6.1, D-207).
tag: M
where: homes.md
note: R1, R1-57

old: The service walk follows the structure's children (§13.3).
new: The service walk follows the structure's children and refuses no traversal past a generically held child (D-414).
tag: M
where: homes.md
note: R1, R1-58

old: - `input_faces(c)` / `output_faces(c) → Vector{String}`. Declaration-ordered face names (§13.3).
tag: F
note: face linked to #g-face

old: - `input_passthrough(assembly, path; prefix, sep, except, only, select)` / `output_passthrough(assembly, path; prefix, sep, except, only, select)`.
new: - `input_passthrough(assembly, child_path; sep = ".", prefix = replace(child_path, "/" => sep), except = (), only = (), select = nothing)` and `output_passthrough` with the same arguments.
tag: R
ruling: R1
note: spelled as src/assembly.jl:461 and :485 spell both, with every default; §8.8 names `child_path` too

old: The declaration-site helpers for computed interface connections.
new: The declaration-site helpers for computed interface connections (§8.8).
tag: F
newcites: §8.8

old: `path` names an immediate child.
new: Both helpers take `child_path` naming an immediate child, container key segments included (D-207).
tag: M
where: homes.md
note: R1, R1-63

old: `except`, `only` and `select` are exclusive, one per call;
new: The selectors are exclusive (D-251). A call takes `except`, `only` or `select`, one of the three and no more.
tag: M
where: homes.md
note: R1, R1-64

old: `select` is a predicate over face names.
new: `select` is a predicate over the child's face names, and the helper keeps the names it accepts.
tag: M
where: homes.md
note: R1, R1-64

old: More than one given is `UnknownFaceSelection` with reason `:multiple_selectors`,
new: More than one selector given is `UnknownFaceSelection` with reason `:multiple_selectors`,
tag: R
ruling: coordinator 2026-10-20
note: the kind name stays on B (D-226); "selector" as §8.8 spells it, since the clause naming the three selectors moved

old: and a selector that keeps nothing warns `EmptyFaceSelection`
new: and a selector that keeps nothing warns `EmptyFaceSelection` (§8.8).
tag: R
ruling: coordinator 2026-10-20
newcites: §8.8
note: the kind name stays on B (D-226)

old: on the `Build` (§8.8).
new: A call that gives a selector and keeps nothing raises `EmptyFaceSelection`, a warning on the `Build`'s list (§9.2, D-251).
tag: M
where: homes.md
note: one clause, no explanation the home gives; the §8.8 citation stays

old: Deployment.
new: #### Deployment and the model
tag: R
ruling: R4

old: - `Deployment(build; algorithm = RK4, h, N_base = 1, Δt_base = nothing, localization_tol = 1e-6, localization_budget = 8, firing_budget = 4) → Deployment`.
new: - `Deployment(build; h, N_base, Δt_base = nothing, algorithm = RK4, firing_budget = 4, localization_tol = 1e-6, localization_budget = 8) → Deployment`.
tag: R
ruling: R8
note: h and N_base without a default, the keyword order of src/deployment.jl:334

old: The artifact the grid parameters fix, scalar-free,
new: The deployment (the scalar-free artifact the grid parameters fix),
tag: F
note: merged with the old stop-policy paragraph's glossed first use, linked to #g-deployment

old: The deployment (the scalar-free artifact the grid parameters fix)
tag: F
note: moved up into the Deployment entry's gloss

old: carrying the `Schedule` (the typed per-component `(D, Φ, Δt)` tick table), the grid diagnostics and its `warnings` (§9.2).
tag: F

old: | keyword | default | meaning | owning section | |---|---|---|---|
tag: F
note: R2, the three keyword tables' header

old: | `algorithm` | `RK4` | the stepper,
new: | `algorithm` | `RK4` | the stepper (`RK4` or `Heun`), bound against the state buffer at `Model` construction (D-227) | §10.2 |
tag: R
ruling: R10
note: R10 names the shipped algorithms, §10.2 (frozen 5613, D-017); "bound against the state buffer" is §10.2's own verb, which cites B for it (frozen 5626); Model linked to #g-model

old: selected by type here
new: The `algorithm` keyword selects the backend by type on the `Deployment`
tag: M
where: homes.md
note: R2, the meaning cell kept to twelve words

old: and materialized against the state buffer at `Model` construction (D-227) | §10.2 |
new: bound against the state buffer at `Model` construction (D-227) | §10.2 |
tag: F

old: | `h` | — | required.
new: | `h` | — | required, refused as `DeploymentInvalid` when absent | §10.2 |
tag: R
ruling: R8
note: src/deployment.jl:182 raises DeploymentInvalid(parameter = :h, reason = :missing)

old: A domain rate is not a framework default | §10.2 |
new: A domain rate is not a framework default.
tag: M
where: homes.md
note: R2; §10.2's own sentence

old: | `N_base` | `1` | steps per base tick.
new: | `N_base` | — | steps per base tick, `1` absent `Δt_base` and derived otherwise | §9.2 |
tag: R
ruling: R8

old: Absent the `Δt_base` keyword, the `N_base·h` product is the base tick period (the default path).
new: the `N_base·h` product when only `N_base` is given, with the default `N_base = 1`
tag: M
where: homes.md
note: R2; the default 1 stays in the meaning cell

old: Given it, `N_base` is instead derived and validated an integer ≥ 1 | §9.2 |
new: from which `N_base` is derived as `Δt_base/h` and validated an integer ≥ 1
tag: M
where: homes.md
note: R2; "derived otherwise" stays in the meaning cell

old: | `Δt_base` | `nothing` | the base tick period as a `Rational`, `Period` or `Hz` value, or `:derive`
new: | `Δt_base` | `nothing` | the base tick period (`Rational`, `Period` or `Hz`), or `:derive` | §9.2 |
tag: R
ruling: R2

old: to request GCD derivation (all-anchored models only); one of three binding sources | §9.2 |
new: derivation, permitted only when every discrete component is anchored, that is, with anchor 0 unpopulated.
tag: M
where: homes.md
note: R2; "one of three binding sources" is §9.2's "`Δt_base` has exactly one of three sources"

old: | `localization_tol` | `1e-6` | the root-finder's relative bracket-width convergence test (`localization_tol · h`) | §10.4 |
tag: F

old: | `localization_budget` | `8` | the per-frame localization allowance | §10.4 |
tag: F

old: | `firing_budget` | `4` | the per-event, per-boundary firing allowance
new: | `firing_budget` | `4` | the per-event, per-boundary firing allowance, an integer ≥ 1;
tag: F
note: firing_budget linked to #g-firing-budget

old: of the event iteration,
new: It caps how many times each declared event may fire at one boundary.
tag: M
where: homes.md
note: R2, the meaning cell kept to twelve words

old: an integer ≥ 1 | §10.6 |
new: an integer ≥ 1; exhaustion warns `FiringBudget` | §10.6 |
tag: F

old: `Δt_base` binds from exactly one of three sources (§9.2).
new: `Δt_base` has exactly one of three sources, cross-validated (D-283)
tag: M
where: homes.md
note: R1, R1-77

old: The first is the `Δt_base` keyword, a `Rational`, `Period` or `Hz` value; `N_base` is then derived and validated an integer ≥ 1.
new: the explicit keyword, a `Rational`, `Period` or `Hz` value, from which `N_base` is derived as `Δt_base/h` and validated an integer ≥ 1
tag: M
where: homes.md
note: R1, R1-78

old: The second is the `N_base·h` product when the keyword is absent (the default path).
new: the `N_base·h` product when only `N_base` is given, with the default `N_base = 1`
tag: M
where: homes.md
note: R1, R1-79; "what silence means" is §9.2's next paragraph

old: The third, requested with `Δt_base = :derive` in a fully anchored model, is derivation from the constraint pool at the coarsest admissible value, printed with its drivers (§9.2).
new: | the derived `Δt_base` | `gcd(pool)` itself, the coarsest admissible value |
tag: M
where: homes.md
note: R1, R1-80; the request is §9.2's "Derivation is requested explicitly", the drivers its "It always prints the derived value with its drivers"

old: binds no stop policy.
new: The stop policy, with its `t_end` and ignored requesters, is the advance's argument
tag: M
where: homes.md
note: R1, R1-81

old: `t_end` and `ignore_stop_requests` are keywords of each advance (§12.6).
new: `t_end` and `ignore_stop_requests` are keywords of `run!`, `replay!` and `step!`.
tag: M
where: homes.md
note: R1, R1-82

old: A run ends at the first grid boundary reaching or exceeding `t_end`, whole frames only (§12.4).
new: The run ends at the first grid boundary whose time reaches or exceeds `t_end` (D-133). The run takes whole frames only
tag: M
where: homes.md
note: R1, R1-83

old: An unbounded run stays bounded in memory, since `log_max` keeps such a session from growing without limit (§11.2).
new: The log takes a retention bound beside its switch and its stride (D-137). The bound is `log_max`, the maximum number of retained snapshot references.
tag: M
where: homes.md
note: R7, R1-84 drifted (log_max bounds the log, not the session); dropped since the thin shape no longer needs it

old: An event that exhausts `firing_budget` at a boundary loses its further edges there,
new: When an event has fired `firing_budget` times at a boundary, its further edges there are lost for the rest of that boundary.
tag: M
where: homes.md
note: R1, R1-85

old: under a `FiringBudget` warning (§10.6).
new: exhaustion warns `FiringBudget` | §10.6 |
tag: R
ruling: coordinator 2026-10-20
note: the kind name stays on B (D-226), in the firing_budget row, whose owning section is §10.6

old: `localization_tol`, `localization_budget` and `firing_budget` are all three trajectory-determining like their siblings.
new: All three are recorded (D-133, D-181), because they determine the trajectory.
tag: M
where: homes.md
note: R1, R1-86

old: So they are validated with them (`DeploymentInvalid`)
new: The constructor validates them with the third such keyword, the `firing_budget` of §10.6, and failures are collected into `DeploymentInvalid`
tag: M
where: homes.md
note: R1, R1-87

old: and carried on the `Deployment` the trace header records, where replay compares the two deployments as values (§11.5, §12.7).
new: They ride the `Deployment` in the trace header (the trace's fixed preamble, §11.5). They also join the set that replay compares up front
tag: M
where: homes.md
note: R1, R1-88; §9.2 has "Two `Deployment`s compare as values, which is what replay's header check reads (§12.7)"

old: - `Model(deployment, T = Float64; chunk_size = 16) → Model{T}`. Materializes a deployment at a scalar type, allocating the buffers (§9.2, D-317).
tag: F

old: | `chunk_size` | `16` | the executor's unroll width, a performance knob that never moves the trajectory | §9.7, §12.6 |
tag: F

old: - `Model`'s own doors,
new: - `Model`'s own entry points,
tag: R
ruling: R9

old: for a model stepped on its own or used as a service's scratch (§9.2, D-317, D-318, D-319).
tag: F
note: scratch linked to #g-scratch

old: Each writing door is refused on a model a simulation has claimed, as `ArgumentInvalid` with reason `:claimed`.
new: Each is refused on a model a simulation has claimed, as `ArgumentInvalid` with reason `:claimed`.
tag: R
ruling: R9

old: A writing door.
new: The entry points below that write are `init!`, `frame!`, `restore!`, `overlay!` and `trim!`.
tag: R
ruling: R9
note: the five "A writing door." sentences (init!, frame!, restore!, overlay!, trim!) gathered into one sentence that names the five

old: - `init!(model, condition; t0 = 0.0, hooks = NoHooks())`.
new: - `init!(model, condition = set(); t0 = 0.0, hooks = NoHooks())`
tag: R
ruling: R8
note: src/model.jl:170 gives `condition = set()`

old: The model's door into `:consistent`.
new: The model's entry point into `:consistent` (D-317).
tag: R
ruling: R9
newcites: D-317
note: R5 cites the ruling entry; D-317, the status "written only by the model's own doors"

old: It checks root-input totality before any write
new: Each compares the resolved plan's root-input coverage against the `Build`'s `input_faces` before writing anything.
tag: M
where: homes.md
note: R1, R2-08; §14.6 names `init!` first among the sites; the §14.6 citation goes with it

old: and runs boundary zero at `t0`,
new: It runs boundary zero at `t0`,
tag: F
note: boundary zero linked to #g-boundary-zero

old: which settles through the hooks (§14.5, §14.6).
new: which settles through the hooks (§14.5, D-317).
tag: C
newcites: §14.5 D-317
note: R5, R2-10; D-317, "init! on the model takes the hooks too, so boundary zero publishes through settled!"

old: - `frame!(model, k, hooks = NoHooks()) → Bool`.
tag: F

old: Advances the model through frame `k` and settles its frame-top boundary (§10.4).
new: Advances the model through frame `k` and settles its frame-top boundary (§13.4).
tag: C
newcites: §13.4
note: §10.4 never names frame!; §13.4, "The Model's frame! wraps each whole frame, every boundary it settles included"

old: It returns `true` when a hook abandoned the frame's remainder (§13.5).
new: It returns `true` when a hook abandoned the frame's remainder (§13.5, D-317).
tag: C
newcites: §13.5 D-317
note: D-317, "A true from settled! abandons the frame's remainder and is frame!'s return"

old: `FrameHooks` is the hooks' contract.
new: `FrameHooks` is the hooks' type.
tag: R
ruling: brief_common, reserved words (contract)
note: R5, R2-15, cited with the next sentences to D-317

old: `frame_top!(hooks)` runs before the frame touches any state, and `settled!(hooks) → Bool` runs at every settled boundary.
tag: F
newcites: D-317
note: R5, R2-16 and R2-17; D-317 cited at the next sentence's end

old: `NoHooks()` is the no-op, and its `settled!` returns `false`.
new: `NoHooks()` is the no-op, and its `settled!` returns `false` (D-317).
tag: C
newcites: D-317
note: R5, R2-18; D-317, "NoHooks does nothing and returns false"

old: - `port(model, path, name)`, `state(model, path)` and `modes(model, path)`.
new: - `port(model, path, name)`, `state(model, path)` and `modes(model, path)`,
tag: F

old: The reads of a port's value, a component's state from whichever home owns it, and its modes (§7.3).
new: The reads of a port's value, a component's state from whichever home owns it, and its modes (§7.3, D-317).
tag: C
newcites: §7.3 D-317
note: R5, R2-21; D-317, "The model's doors are … warnings, port, state and modes"

old: - `warnings(model) → Vector`. The build's list and the deployment's, concatenated (§9.2).
new: - `warnings(model) → Vector`. The build's list and the deployment's, concatenated (§9.2, D-317).
tag: C
newcites: §9.2 D-317
note: R5, R2-23; D-317 lists warnings among the model's doors

old: - `checkpoint(model) → ModelState`. The model's state alone,
new: - `checkpoint(model) → ModelState`. The model's state alone (§12.6).
tag: F
newcites: §12.6

old: legal at `:consistent` with the clock on a grid top.
new: It is legal at `:consistent` with the clock on a grid top.
tag: M
where: homes.md
note: R1, R2-25

old: Any other status is `ServiceLifecycle`,
new: At a status other than `:consistent` it is `ServiceLifecycle` (§14, D-319).
tag: R
ruling: coordinator 2026-10-20
newcites: §14 D-319
note: the kind name stays on B (D-226); §14, "`checkpoint`, `overlay!` and the default `linearize` are legal at `:consistent`", and Appendix D's service lifecycle entry, "A violation is `ServiceLifecycle`"

old: and a clock off the grid is `CheckpointMidFrame` (§12.6).
new: A clock off the grid is `CheckpointMidFrame` (D-319).
tag: C
newcites: D-319
note: R5, R2-27; D-319, "and with the clock off the grid as CheckpointMidFrame"; the §12.6 citation stays on the gloss

old: - `restore!(model, model_state; hooks = NoHooks())`.
tag: F

old: Checks the state's fingerprint and deployment (`CheckpointMismatch`)
new: A fingerprint or deployment mismatch is `CheckpointMismatch` (§12.6).
tag: R
ruling: coordinator 2026-10-20
newcites: §12.6
note: the kind name stays on B (D-226); §12.6, "`restore!(model, model_state)` checks the state's fingerprint and deployment against the model, and a mismatch is `CheckpointMismatch`"

old: and its `t` against its grid (`CheckpointMidFrame`) before any write (§12.6).
new: It also checks that the state's `t` is a grid time `t₀ + k·h` of the state's own origin and step, and a state off its grid is `CheckpointMidFrame`.
tag: M
where: homes.md
note: R1, R2-29; §12.6 goes on, "Every mismatch of either kind is collected into one throw before any write"

old: Copies the state back, settles through the hooks and writes `:consistent` last.
new: Copies the state back, settles through the hooks and writes `:consistent` last (§12.6).
tag: F
newcites: §12.6

old: It takes no status gate (D-319).
new: `init!`, `restore!`, `trim!` and `linearize` with an explicit `about` are legal at any status (D-425).
tag: M
where: homes.md
note: R1, R2-31; D-319 also states it, "It has no status gate"

old: - `overlay!(model, condition; hooks = NoHooks())`.
new: - `overlay!(model, condition = set(); hooks = NoHooks())`.
tag: R
ruling: R8
note: src/model.jl:223 gives `condition = set()`

old: Writes the condition onto the model at rest and settles the overlaid state with no discrete output stage and no update,
new: Writes the condition onto the model at rest and settles the overlaid state with no discrete output stage and no update (§12.6).
tag: F

old: the clock and the priors kept (§12.6).
new: Every other store, the clock, the sampling lattice and the guard priors (each event's stored predicate sample from the previous boundary) are kept.
tag: M
where: homes.md
note: R1, R2-34; the §12.6 citation stays on the kept clause

old: Legal at `:consistent` with the clock on a frame top.
new: `overlay!(model, condition; hooks)` is the model's form, legal at `:consistent` with the clock on a frame top.
tag: M
where: homes.md
note: R1, R2-35

old: - `trim!(model, problem; baseline, t0 = 0.0, backend) → TrimReport`.
new: - `trim!(model, problem; baseline, t0 = 0.0, backend = LevenbergMarquardt()) → TrimReport`.
tag: R
ruling: R8
note: src/trim.jl:447 and §14.8 both give `backend = LevenbergMarquardt()`

old: The trim service on a `Model{Float64}`, committing through the model's `init!` (§14.8).
tag: F

old: - `linearize(model, taps; about, t0, width = 8) → Linearization`.
new: - `linearize(model, taps; about = nothing, t0 = nothing, width = 8) → Linearization`.
tag: R
ruling: R8
note: src/linearize.jl:128; D-319 spells the same

old: The query on a `Model{Float64}`, its default operating point `checkpoint(model)` (§14.10).
tag: F

old: `trim!` and `linearize` on a `Model` at another scalar are `ArgumentInvalid` with reason `:non_nominal`.
new: A `Model` at another scalar is refused as `ArgumentInvalid` with reason `:non_nominal` (D-319).
tag: M
where: homes.md
note: R1, R2-42; §14.8 for trim!; Appendix C's ArgumentInvalid entry carries linearize, which §14.10 never states

old: The stepping primitives `evaluate!`, `integrate!`, `boundary!`, `offtick_boundary!` and `boundary_zero!` are framework internals the spec names only as mechanisms, outside this API and outside the claim's gate.
new: The stepping primitives `evaluate!`, `integrate!`, `boundary!`, `offtick_boundary!` and `boundary_zero!` are framework internals, outside this API and outside the claim's gate (D-318).
tag: R
ruling: R5
newcites: D-318
note: "the spec names only as mechanisms" goes; D-318, "The stepping primitives evaluate!, integrate! and the boundary routines stay ungated internals that frame! and init! compose"

old: `apply!` is an internal outside this API too, and the claim's gate refuses it on a claimed model (D-318).
new: `apply!` is an internal outside this API too, and the claim's gate refuses it on a claimed model (D-318, D-319).
tag: C
newcites: D-318 D-319
note: R5, R2-44; the API placement stands only in D-319's Rationale (rulings.md)

old: - `Simulation(model; join_timeout = 5.0) → Simulation`.
new: - `Simulation(model::Model{Float64}; join_timeout = 5.0) → Simulation`.
tag: R
ruling: R5
note: the typed signature src/sim.jl:190 and D-317 spell, which carries the MethodError sentence

old: Runs a `Model{Float64}` beside the data plane, the control plane and the run, and offers the stopped-sim services.
tag: F
note: control plane and run linked (R12)

old: A `Model` at another scalar is a `MethodError`,
new: the constraint sits as a type on the one constructor that owns a loop
tag: R
ruling: R5
where: homes.md
note: the sentence goes; the typed signature above and §9.2 carry it

old: and one already claimed by a simulation or not at `:built` is `ArgumentInvalid`, reasons `:claimed` and `:not_built` (§9.2, D-318).
new: A `Model` already claimed by a simulation or not at `:built` is `ArgumentInvalid`, reasons `:claimed` and `:not_built` (§9.2, D-318).
tag: F
note: R5, R2-51; D-318 names both reasons

old: | `join_timeout` | `5.0` | the shutdown tail's join cap, in seconds of wall clock | §12.4 |
tag: F

old: `join_timeout`, the shutdown tail's join cap, lives on `Control` rather than the deployment (§12.1).
new: `join_timeout` is `Control`'s (§12.1).
tag: M
where: homes.md
note: R1, R2-53

old: It moves no trajectory, so replay neither records nor compares it (§12.4).
new: The cap is not trajectory-determining, because the trajectory has ended at the final snapshot before any join begins. So replay (the ordinary loop with the drain reading recorded batches) neither records nor compares the cap
tag: M
where: homes.md
note: R1, R2-54

old: The four recording keywords are `init!`'s, `restore!`'s and `replay!`'s, the doors that build a run (below, D-261).
new: The four recording keywords are `init!`'s, `overlay!`'s, `restore!`'s and `replay!`'s, the doors that build a run (below, D-261).
tag: R
ruling: R7
note: R2-55; §12.6, "there are four, init!, overlay!, restore! and replay!"

old: - `Simulation(deployment; kw...)`, `Simulation(build; kw...)` and `Simulation(world; kw...)`. The three convenience forms.
new: - `Simulation(deployment; kw...)`, `Simulation(build; kw...)` and `Simulation(world; kw...)`. The three convenience forms (§9.2).
tag: F
newcites: §9.2

old: The first materializes a `Model{Float64}` from the deployment and runs it, the second composes the `Deployment` constructor with that, and the third calls `build` first.
new: Simulation(deployment; kw...) # materializes a Float64 model and runs it Simulation(build; kw...) # composes the steps through a Float64 model Simulation(world; kw...) # calls build first
tag: M
where: homes.md
note: R1, R2-57

old: They take the `Model` and `Simulation` keywords above, the last two the deployment keywords as well (§9.2).
new: They take the `Model` and `Simulation` keywords above, the last two the deployment keywords as well (D-317).
tag: C
newcites: D-317
note: R5, R2-58; §9.2 does not state the pass-through; D-317 composes the three forms "through a Float64 model", and src/sim.jl:145 lists the keywords

old: - `attach!(sim, dev::AbstractDevice, binding::AbstractBinding; should_abort = false)`.
new: - `attach!(sim, dev::AbstractDevice, new_binding::AbstractBinding; should_abort = false) → DeviceHandle`.
tag: R
ruling: R8
note: §11.6 spells `new_binding`; src/sim.jl's docstring returns the attachment's handle, a DeviceHandle

old: The roots are mandatory, and the signature is the gate.
new: That is one mandatory word, and it costs nothing, because the periphery has no competing hierarchy to inherit from. What it buys is `attach!`'s dispatch gate (D-177).
tag: M
where: homes.md
note: R1, R2-60; the table rows keep "the root type is mandatory"

old: | argument | default | meaning | owning section | |---|---|---|---|
tag: F

old: | `dev::AbstractDevice` | — | the device instance; the root type is mandatory | §11.6 |
tag: F

old: | `binding::AbstractBinding` | — | the binding value; the root type is mandatory | §11.6 |
new: | `new_binding::AbstractBinding` | — | the binding value; the root type is mandatory | §11.6 |
tag: R
ruling: R8

old: | `should_abort` | `false` | the per-attachment failure policy. Set, the device's departure also requests a sim stop.
new: | `should_abort` | `false` | the per-attachment failure policy. Set, a departure also requests a sim stop | §11.6, §12.4 |
tag: R
ruling: R2
note: the meaning cell kept to twelve words; should_abort linked to #g-should_abort

old: Clear, the run continues with the device absent and its claims held to run end | §11.6, §12.4 |
new: With `should_abort` clear, a device's departure is reported and the run continues without it.
tag: M
where: homes.md
note: R2; claims to run end, §11.6's "Claims and the roster entry persist to run end"

old: A departure is the loop body returning, a crash, or a failed `init!`.
tag: M
where: homes.md
note: R1, R2-64; §11.6's own sentence

old: Sides are declared by the binding's Bool traits, and each declared side carries its own methods:
tag: F
note: R4, the bold goes

old: | trait / method | default | meaning | owning section | |---|---|---|---| | `is_input(b)` | `false` on `AbstractBinding` | declares the input side | §11.6 | | `is_output(b)` | `false` on `AbstractBinding` | declares the output side | §11.6 | | `is_greedy(b)` | `false` on `AbstractBinding` | `true` switches the claim's source | §11.3, §11.6 | | `claims(b)` / `map_input(datum, b)` | — | the input side. The enumerated face set is the claim
tag: F
note: claim linked to #g-claim

old: , what the device may write rather than what it will
new: A device's claim is the set of faces (the names ports wear on their component's boundary) it may write.
tag: M
where: homes.md
note: R2, the claims row's meaning cell kept to twelve words

old: | §11.3, §11.4 | | `reads(b)` / `map_output(nt, b)` | — | the output side | §14.4, §11.2, §11.6 |
tag: F

old: The conformance check runs at attach, pairing each trait against its method.
new: The attach runs a bidirectional conformance check over the pair (trait, method):
tag: M
where: homes.md
note: R1, R2-71

old: A declared side whose `claims`/`reads` was never written reaches the error fallback.
new: A declared side whose method was never written therefore fails loudly at the attach point rather than degrading into silence.
tag: M
where: homes.md
note: R1, R2-72

old: A method defined under a false trait is detected by `which` against the fallback.
new: Detecting it is one `which` against the fallback method.
tag: M
where: homes.md
note: R1, R2-73

old: Both are `BindingContractMismatch` (§11.6).
new: A declared side without its method, or a method under a false trait, is `BindingContractMismatch` (§11.6).
tag: R
ruling: coordinator 2026-10-20
note: the kind name stays on B (D-226); "both" named by the two cases, whose detail (the error fallback, `which`) stays M; §11.6, "Every violation in that list reports `BindingContractMismatch`"

old: A claim is registered with exclusivity enforced, and the staged shape and normalization shim are compiled (§11.4).
new: Attach validation, claim registration and the staging-shape compilation (§11.4) all run at the attach point.
tag: M
where: homes.md
note: R1, R2-75

old: The `reads` selectors are validated and compiled to one gather (§14.4, §11.2).
new: `is_output` ⇒ `reads(b)` is called and the gather compiled.
tag: M
where: homes.md
note: R1, R2-76

old: Under `is_greedy(b) = true` the framework computes the unclaimed complement at attach instead of calling `claims`.
new: `is_input && is_greedy` ⇒ the claim is computed (§11.3), and a `claims` method defined for this binding is an error.
tag: M
where: homes.md
note: R1, R2-77

old: Everything downstream is identical.
new: past the attach point nothing tells a greedy claim from a returned one (§11.3)
tag: M
where: homes.md
note: R1, R2-78

old: An empty remainder is legal and reported (`EmptyGreedyClaim`),
new: An empty greedy remainder is legal and reported as `EmptyGreedyClaim` (§11.6).
tag: R
ruling: coordinator 2026-10-20
newcites: §11.6
note: the kind name stays on B (D-226); "greedy" names the remainder, which the moved sentence before it set up; §11.6, "The attach succeeds and records `EmptyGreedyClaim`"

old: and `is_greedy` without `is_input` is an error (§11.3, §11.6).
new: `is_greedy` without `is_input` ⇒ error.
tag: M
where: homes.md
note: R1, R2-80

old: `TableBinding` is the shipped data-driven binding
new: - `TableBinding`. The shipped data-driven binding (§11.6).
tag: F
note: its own entry; the §11.6 citation repeats

old: and the standard GUI binding is the greedy one (§11.6).
new: The standard GUI binding is a greedy one.
tag: M
where: homes.md
note: R1, R2-82

old: `attach!` is a stopped-sim operation.
new: A stopped-sim operation that adds a device and its binding to the roster and returns the device's handle (§11.3, §11.6).
tag: F
newcites: §11.3 §11.6
note: the entry's gloss; device, binding and roster linked; the return is src/sim.jl's docstring, "Returns the attachment's handle"

old: It is legal in `built`, `initialized` and `stopped`.
new: `attach!`/`detach!` are legal in the `built`, `initialized` and `stopped` states (§12.6) and an error while `running`.
tag: M
where: homes.md
note: R1, R2-84

old: It is an error while `running` and on an `errored` simulation (`ServiceLifecycle`;
new: It is `ServiceLifecycle` while `running` and on an `errored` simulation.
tag: R
ruling: coordinator 2026-10-20
newcites: §11.3
note: the kind name stays on B (D-226); §11.3 cited at the end of the next sentence

old: the roster freeze, §11.3, and the terminal state, §13.6).
new: That error is `ServiceLifecycle` (Appendix C, D-108), the same kind that gates the §14 services. The list is exhaustive. An `errored` simulation refuses both with the same kind.
tag: M
where: homes.md
note: the two reasons stay in §11.3, which cites §13.6 for the terminal state

old: Admission checks identity and claims (§11.3).
new: Admission is a two-part check at the attach point, in order (D-375):
tag: M
where: homes.md
note: R1, R2-86

old: A second roster entry for one instance is `AlreadyAttached`,
tag: R
ruling: coordinator 2026-10-20
note: the kind name stays on B (D-226)

old: and rebinding is `detach!` + `attach!`.
new: An already-rostered instance is rejected rather than silently absorbed, because rebinding has an explicit spelling, `detach!` then `attach!`, both legal at any stopped-sim point.
tag: M
where: homes.md
note: R1, R2-87

old: An overlapping claim is `ClaimConflict`.
new: and an overlapping claim is `ClaimConflict` (§11.3).
tag: R
ruling: coordinator 2026-10-20
newcites: §11.3
note: the kind name stays on B (D-226)

old: `attach!` registers only. The task appears at the next `run!`.
new: `attach!` while stopped only registers, and the task appears at the next `run!`.
tag: M
where: homes.md
note: R1, R2-89

old: - `detach!(sim, device)`. Removes the roster entry and releases the device's claims.
new: - `detach!(sim, device)`. Removes the roster entry and releases the device's claims (§11.3).
tag: F
newcites: §11.3

old: Stopped-sim only, like `attach!`.
tag: R
ruling: coordinator 2026-10-20
note: kept, so detach! carries attach!'s `ServiceLifecycle` clause by reference

old: A loop body's voluntary exit or crash mid-run does not detach.
new: Device death does not detach (D-106, D-374). A mid-run crash, voluntary exit or unplug (§11.6, §12.4) ends the device's task.
tag: M
where: homes.md
note: R1, R2-93

old: The task dies, and the claims persist to run end (§11.3, §11.6, §12.4).
new: the roster entry, claims included, persists to the end of the run
tag: M
where: homes.md
note: R1, R2-94; the §11.3 citation repeats on the kept gloss

old: - The device contract.
new: - Device authoring.
tag: R
ruling: brief_common, reserved words (contract)

old: `MyDevice <: AbstractDevice` plus `init!(dev)` / `loop(dev, handle)` / `shutdown!(dev)` and the optional `unblock!(dev)`.
new: `MyDevice <: AbstractDevice` (an illustrative name), with `loop(dev, handle)` mandatory and `init!(dev)`, `shutdown!(dev)` and `unblock!(dev)` optional hooks (§11.6, D-366).
tag: R
ruling: R7
newcites: §11.6 D-366
note: R2-95 drifted; §11.6, "Of the four functions, only loop is mandatory (D-366). init!, shutdown! and unblock! are optional hooks"

old: Around those functions the framework runs a per-run `init!` on the calling task.
new: init!(dev) # per-run resource acquisition — calling task, before spawn (§12.4)
tag: M
where: homes.md
note: R1, R2-96; §11.6's code block, then "The framework owns everything around the four functions (D-102)"

old: That call is bracketed, so a throw there is `shutdown!` plus `DeviceCrash` by name,
new: A throw in the per-run `init!(dev)` is `shutdown!` plus `DeviceCrash` (§11.6).
tag: R
ruling: coordinator 2026-10-20
newcites: §11.6
note: the kind name stays on B (D-226); "by name" and the bracket stay at §11.6's code block, "a throw # here is shutdown! + DeviceCrash by name"

old: and the device is dead from the run's first frame top (§12.4).
new: No task is spawned for a failed device, so it is dead from the run's first frame top (D-138, D-396).
tag: M
where: homes.md
note: R1, R2-98

old: The author-owned task body runs inside the framework's try/catch/finally wrapper
new: The wrapper is the shutdown protocol (§12.4) made structural.
tag: M
where: homes.md
note: R1, R2-99; the wrapper's try/catch/finally is §11.6's next code block

old: and voluntary exit is returning (§11.6, §12.4).
new: A window ✕ or peer EOT is the loop body returning, which is §12.4(6)'s case.
tag: M
where: homes.md
note: R1, R2-100

old: - The device handle. One type, with capabilities rather than a taxonomy:
new: - The device handle, `DeviceHandle`. One type, with capabilities rather than a taxonomy:
tag: R
ruling: coordinator 2026-10-20
note: the type attach! returns (src/sim.jl:1949 docstring, src/devices.jl)

old: `running`, `latest`, `wait_next_snapshot` (§12.3), `stage!`, `binding`, `gather`, `report!` (§11.6),
new: `latest(handle)`, `wait_next_snapshot(handle)` (§12.3), `running(handle)`, `stage!(handle, writes::Pair...)`, `binding(handle)`, `gather(handle, snapshot)`, `report!(handle, occurrence)` (§11.6),
tag: R
ruling: R1, coordinator 2026-10-20
note: `running` moved off §12.3's citation to §11.6's (frozen 8024); each spelled as src/devices.jl spells it (signatures.tsv rows 94 to 100)

old: and `pending` (§11.7).
new: `pending(handle, slot)`;
tag: R
ruling: R1, coordinator 2026-10-20
newcites: §11.7
note: moved into the panel-kit entry, §11.7 (frozen 8393–8398), whose citation leads the entry; spelled as src/devices.jl spells it

old: - The panel kit (§11.7). `port_views(handle)`, the baked table of port views; `peek(view, handle, snapshot)`;
new: - The panel kit (§11.7). `port_views(handle)`, the baked table of port views; `pending(handle, slot)`; `peek(view, handle, snapshot)`;
tag: F
note: peek linked to #g-peek

old: `incumbent_status(view, snapshot)`, with `orphaned` and `stale` on the record it returns.
new: `incumbent_status(view, snapshot)`, with `orphaned(record)` and `stale(record; now = time())` reading the record it returns.
tag: R
ruling: R8
note: functions on the record, src/devices.jl:363 and src/dataplane.jl:293

added: #### The simulation and its devices

added: - The root type. `AbstractComponent`, the one root of primitives and assemblies alike, with no `AbstractAssembly` beside it (§8.5, D-039).

added: - Sample-time entries. `Relative(K, Φ = 0)` in scope ticks and `Absolute(q, τ = 0)` in exact rational seconds, with `q` a quantity value, `Period(T)` or `Hz(frequency)` (§10.5, D-185).

added: with the `Simulation` forms `port(sim, path, name)`, `state(sim, path)` and `modes(sim, path)`.

added: - `Model(build, T = Float64; kw...)` and `Model(world, T = Float64; kw...)`. The two composed forms. The first composes the `Deployment` constructor with the materialization, and the second calls `build` first.

added: (`set`, under Condition algebra)

added: - `port(snapshot, path, name)`. A port's value off a published snapshot, addressed exactly as the live table.

added: and `stop!(handle)`, which requests a stop (§11.6, D-268).

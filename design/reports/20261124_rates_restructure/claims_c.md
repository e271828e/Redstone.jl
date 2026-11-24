# Claims C: the passages that merge or move

Claim inventory of the nine passages of `design/spec.md`. The §10.5 split is not touched; nothing was edited. Line numbers are `spec.md` lines. A `*` marks a §10.5 citation. In `marks`, `B` is bold, `G:` a glossary link, `code` display code, `tbl` a table. Passage 2 covers 370–380 only; the adaptive-method paragraph at 382 is outside it.

## P1. §2.1 Time and boundaries (270–362)
| id | line | kind | claim | cites | marks |
|---|---|---|---|---|---|
| C-001 | 272 | ptr | A hybrid system flows between instants and jumps at them | | |
| C-002 | 272 | ptr | The section fixes which instants exist | | |
| C-003 | 273 | ptr | Roadmap: two fixed lattices, discrete instants are boundaries, every run has an origin | | |
| C-004 | 276 | law | Time advances in frames, the run's fixed periods and unit of scheduling | | G:frame |
| C-005 | 277 | law | Run starts at origin `t₀`; frame tops are `tₖ = t₀ + k·Δt_frame`, k = 0, 1, 2… | | |
| C-006 | 278 | law | `Δt_frame` is the frame period | | |
| C-007 | 279 | law | The start of a frame is its frame top | | |
| C-008 | 281 | law | Frame tops and base ticks are two lattices in no required ratio | D-445 D-449 | B |
| C-009 | 284 | law | Frame tops, `Δt_frame` apart, are where the run meets the outside | | |
| C-010 | 285 | law | Base ticks, `Δt_base` apart, form the lattice on which every discrete schedule falls | 10.5* | |
| C-011 | 288 | law/mech | Each instant is computed from its own index on its own lattice, never accumulated | 10.4 D-445 | |
| C-012 | 289 | law | `t₀` is an exact time; the clock at each instant is the nearest floating-point number | D-456 D-457 D-458 | |
| C-013 | 291 | law | A time typed on a lattice reads as its boundary's clock | | |
| C-014 | 292 | law | Coincidence of two instants is decided on the deployment's exact periods, never on computed times | | |
| C-015 | 294 | law | The lattices are fixed for the whole run | | |
| C-016 | 294 | law | An event located inside a step never moves a later instant | D-290 | |
| C-017 | 297 | law | Frame tops and due instants are the mandatory instants | | G:due G:mandatory-instant |
| C-018 | 298 | law | A due instant is a base tick at which some discrete component is scheduled to run | | G:due |
| C-019 | 299 | law | No integration step crosses a mandatory instant | 2.2 D-449 | |
| C-020 | 300 | law | A base tick at which no component is due is no mandatory instant | | |
| C-021 | 303 | law | A boundary is an instant where discrete changes may happen and the run publishes its values | | G:boundary |
| C-022 | 305 | law | Boundaries fall at four kinds of instant | D-081 D-445 | |
| C-023 | 307 | law | Boundary kind 1: every frame top after `t₀` | | |
| C-024 | 308 | law | Boundary kind 2: every end of an integration step inside a frame | | |
| C-025 | 308 | mech | A step ends at the next mandatory instant, or earlier where the method divides the span | 2.2 D-449 | |
| C-026 | 311 | law | Boundary kind 3: every localized event time `t*`, an event crossing located by root-finding inside a step | 2.3 | G:localized |
| C-027 | 313 | law | Boundary kind 4: the origin `t₀`, once; this boundary is boundary zero, with no integration before it | 5.3 | G:boundary-zero |
| C-028 | 315 | law | Frame 1's top follows boundary zero at the same instant | | |
| C-029 | 318 | law | A base tick at which no component is due is no boundary | D-445 | |
| C-030 | 319 | law | Every due instant is a boundary | | |
| C-031 | 319 | law | A due instant inside a frame ends the step that reaches it | | |
| C-032 | 322 | law | Every frame top is a boundary, but not every boundary is a frame top | | |
| C-033 | 323 | law | A step end inside a frame and a localized event time are never frame tops | | |
| C-034 | 326 | law | A step end before the next mandatory instant lies on neither lattice | | |
| C-035 | 327 | law/mech | Fixed-step: its time is the previous mandatory instant plus count times step, never a sum of steps | D-449 | |
| C-036 | 328 | law/mech | Adaptive: its time is the step's start plus the step's length | D-455 D-460 | |
| C-037 | 332 | ex | Diagram of frames, boundary zero, step ends `s`, due instant `d`, event `t*`, frame tops | | code |
| C-038 | 342 | law | Distinct boundaries other than a `t*` take strictly increasing clock values | | |
| C-039 | 343 | mech | A run whose clock cannot keep two boundaries apart is refused | 10.5* D-450 | |
| C-040 | 344 | law | A `t*` lies on no lattice; the refusal does not cover it | | |
| C-041 | 347 | law | Everything discrete happens at boundaries | | |
| C-042 | 347 | law | Discrete components tick only at boundaries | D-019 | G:tick |
| C-043 | 349 | law | Modes change only through event handlers | D-345 | |
| C-044 | 350 | law | Handlers run only at boundaries | D-345 | |
| C-045 | 351 | law | Root inputs change only at frame tops | 2.2 | G:root-input |
| C-046 | 352 | law | Between two boundaries only continuous state and time move | | |
| C-047 | 353 | law | Signals computed from them, such as continuous outputs, move with them | | |
| C-048 | 356 | law | Time is no component's state | | |
| C-049 | 356 | law | No store holds time | | G:store |
| C-050 | 357 | law | A condition never sets time | | G:condition |
| C-051 | 358 | law | `t₀` is fixed at initialization; nothing after boundary zero changes it | | |
| C-052 | 360 | law | `t₀` anchors both lattices and every discrete tick schedule | 14.5 D-067 D-273 | |
| C-053 | 361 | law | A restored run keeps the restored state's clock, origin included | D-273 | |

## P2. §2.2 Integration and inputs, mandatory-instants paragraph (370–380)
| id | line | kind | claim | cites | marks |
|---|---|---|---|---|---|
| C-054 | 370 | law | A one-step method advances the continuous state across each step | | |
| C-055 | 371 | decl | The method is chosen at deployment, fixed-step or adaptive | 10.2 D-017 D-442 D-461 | |
| C-056 | 372 | law | A fixed-step method takes the span between consecutive mandatory instants in the fewest equal steps no longer than `h_max` | D-449 | B G:mandatory-instant |
| C-057 | 375 | law | Mandatory instants are the frame tops and the due instants | | G:due |
| C-058 | 376 | law | A due instant is one at which some discrete component is scheduled to run | | |
| C-059 | 376 | law | A span of length `l` takes `N = ⌈l / h_max⌉` steps of `l / N` | | |
| C-060 | 377 | law | One step when the deployment sets no bound | | |
| C-061 | 378 | law | `h_max` need divide neither period | | |
| C-062 | 378 | law | The steps of a span are equal unless a localized event splits one | | |
| C-063 | 379 | law | No step is longer than `h_max`, each to the clock's round-off | | |

## P3. §3.2 Periodic discrete component (742–800)
| id | line | kind | claim | cites | marks |
|---|---|---|---|---|---|
| C-064 | 744 | ptr | Lists the facets of a periodic discrete component | | |
| C-065 | 746 | decl | Discrete state `s` is one leaf or a NamedTuple of leaves, each isbits or a `Symbol` | 7.3 D-231 D-438 | |
| C-066 | 748 | law | Update is `s⁺ = g(s, u, t)` at a declared rate | | |
| C-067 | 749 | law | Two output stages; feedthrough applies at update instants | | G:feedthrough |
| C-068 | 750 | law | A proportional path is direct feedthrough; a state-only output is not | | |
| C-069 | 753 | law | A discrete component has no events and no projection | | G:projection |
| C-070 | 754 | law | Its state changes only at its ticks | D-001 D-112 | G:tick |
| C-071 | 755 | law | A tick is an instant at which it runs its stages and update | D-001 D-112 | G:tick |
| C-072 | 758 | law | Ticks fall on a fixed lattice | | |
| C-073 | 758 | law | Every discrete period is an integer multiple of the base tick period | D-019 | G:dt_base |
| C-074 | 759 | law | The base tick period is the step of the lattice all discrete rates share | D-019 | G:dt_base |
| C-075 | 760 | law | The base tick period stands in no required ratio to the integration step | | |
| C-076 | 761 | law/mech | A step ends wherever a component is due, splitting there when the instant falls inside it | | |
| C-077 | 762 | law | So every tick falls on a boundary: boundary zero or a later step end | 2.1 10.5* D-444 | G:boundary-zero |
| C-078 | 765 | law | A component ticks at its phase plus whole multiples of its period | | G:phase |
| C-079 | 766 | law | Phase is the offset from the origin, in base ticks | | G:phase |
| C-080 | 767 | law | A component ticks at no other boundary | | G:boundary |
| C-081 | 768 | law | No component ticks at a localized event time | D-147 D-185 D-291 | G:localized |
| C-082 | 770 | ptr | The enclosing assembly declares the rate | 3.3 | |
| C-083 | 773 | law | A tick's update is the outgoing transition | | |
| C-084 | 773 | law | It consumes the samples of the boundary it runs at | 5.3 14.5 D-067 | |
| C-085 | 774 | law | It produces the state the component's next tick reads | 5.3 14.5 D-067 | |
| C-086 | 777 | law | Each tier carries its own state letter | D-195 | B G:tier |
| C-087 | 777 | law | `x` is the argument of the flow map under `f`; `s` of the jump map under `g`; different objects | | G:flow |
| C-088 | 779 | mech | `x` has a derivative and lives in the flat buffer | | G:buffer |
| C-089 | 780 | mech | `s` has none and is latched in a store between ticks | | G:store |
| C-090 | 782 | law | A primitive is strictly one tier | D-056 | |
| C-091 | 782 | law | No component ever reads another's state | | G:component |
| C-092 | 783 | law | A discrete component's `s` influences continuous dynamics only through signals | D-056 | |
| C-093 | 785 | law | Those outputs are held zero-order between ticks | D-019 | |
| C-094 | 787 | law | A stateless discrete primitive (empty `s`) computes outputs only at its ticks and at boundary zero, and holds them between | 5.3 D-205 | |
| C-095 | 790 | law | A stateless continuous primitive recomputes outputs at every sweep | | G:sweep |
| C-096 | 791 | law | The tier of a stateless primitive therefore changes its values | 8.2 D-019 D-263 | |
| C-097 | 794 | law | `m` is continuous-only | D-231 D-249 D-362 | B |
| C-098 | 795 | law | A discrete component has no mode store; FSM enums, flags and counters are ordinary `s` fields | | |
| C-099 | 796 | why | `m` exists on the continuous side because modes must change between flow evaluations, as handlers do | | |
| C-100 | 798 | why | On the discrete side `g` already runs at the only instants where anything may change | | |
| C-101 | 799 | why | A second store would duplicate the discrete tier's state semantics under another name | | |

## P4. §3.3 Assembly (802–822)
| id | line | kind | claim | cites | marks |
|---|---|---|---|---|---|
| C-102 | 804 | law | An assembly is a component built from children, local wires and boundary faces | | G:assembly G:local-wire G:face |
| C-103 | 806 | law | It has no dynamics of its own | | |
| C-104 | 806 | why | Hybridness emerges at the assembly level | | |
| C-105 | 807 | ex | An aircraft is continuous vehicle parts plus discrete avionics parts | | |
| C-106 | 808 | ptr | The two-tier split was upheld against the integrate-and-dump challenge | 3.4 D-056 | |
| C-107 | 809 | mech | Assemblies are flattened away for ordering | D-019 | |
| C-108 | 810 | law | They are retained as navigation and introspection hierarchy (GUI, logging, paths) | | |
| C-109 | 811 | law | They are retained as declaration-level rate scopes | 10.5* D-019 | G:rate-scope |
| C-110 | 815 | decl | An assembly declares the rate of each discrete child, in one of two forms | | |
| C-111 | 816 | decl/law | Relative form ticks the child once every `Dₛ` ticks of the enclosing scope, from a chosen phase | | |
| C-112 | 817 | decl/law | Absolute form gives a period and an offset in seconds and detaches the child from the scope's ticks | 8.7 D-185 D-186 | |
| C-113 | 819 | law | Relative entries compose down the tree, periods multiplying and phases adding | | |
| C-114 | 820 | law | Each discrete component ends with one period and one phase on the base grid | 10.5* D-291 | |

## P5. §5.2 `Δt` sentences
| id | line | kind | claim | cites | marks |
|---|---|---|---|---|---|
| C-115 | 1179 | law | The clock view is `t`, and on the discrete tier `Δt`, the component's own tick period | | |
| C-116 | 1180 | law | `Δt` is the same in both output stages and in the update | 10.5* D-019 D-291 | |
| C-117 | 1181 | law | The component's phase never changes `Δt` | 10.5* D-019 D-291 | |
| C-118 | 1207 | decl | Bundle table: `Δt` is present iff the component is on the discrete tier | D-074 D-341 | tbl |
| C-119 | 1232 | decl | Discrete-tier `y_state` and `y_direct` name sets are `s, t, Δt [, ws]` and `s, u, y_s, t, Δt [, ws]` | D-074 D-341 D-220 | |
| C-120 | 1144 | decl | Signature comments list `Δt` among the arguments of `y_state`, `y_direct` and `s_update` | | code |

## P6. §5.3 execution order, boundary zero, due stages and updates
| id | line | kind | claim | cites | marks |
|---|---|---|---|---|---|
| C-121 | 1393 | law | Execution runs all stage-1 functions in any order, then stage 2 topologically, then all `x_deriv` | D-288 9.7 | |
| C-122 | 1402 | law | Inside a step no discrete stage runs, for integration or event root-finding | 10.5* D-147 | |
| C-123 | 1404 | law | Discrete cells therefore hold across the step | | G:cell |
| C-124 | 1411 | law | Boundary sequence: integrate, project, boundary sweep (including discrete components due here), evaluate all guards once, fire events | | G:boundary-sequence |
| C-125 | 1425 | law | Order is integrate → project → [sweep → guards → handlers] to quiescence → due updates → publish | D-020 | code |
| C-126 | 1428 | law | Output stages of components due at this boundary run inside every round's sweep, on their unchanged `s` | D-020 | G:due |
| C-127 | 1430 | law | At quiescence their outputs reflect the settled instant | 10.6 D-020 | |
| C-128 | 1431 | law | Only then does every due update run, in any order | 10.5* D-020 | |
| C-129 | 1432 | law | Each due update reads the settled table and writes only its own `s` | 10.5* D-020 | |
| C-130 | 1433 | law | The boundary then publishes its snapshot | 2.4 | G:snapshot |
| C-131 | 1436 | law | State a tick writes stays invisible until the owner's next tick | | G:tick |
| C-132 | 1437 | law | No guard sees it; a tick never triggers an event | 10.6 D-292 | |
| C-133 | 1438 | law | Events and ticks need no joint fixed point | 10.6 D-292 | |
| C-134 | 1439 | law | A model with no continuous state runs the same sequence at every step end, with empty integration | 10.2 D-156 | |
| C-135 | 1449 | law | The signal table is written only by sweeps | 10.6 D-154 | |
| C-136 | 1451 | law | The round that detects quiescence leaves the table consistent for due updates and publication | 10.6 D-154 | |
| C-137 | 1479 | law | Initialization runs one ordinary boundary at `t₀`, with empty integration | | |
| C-138 | 1480 | law | That boundary is boundary zero | 14.5 D-067 | G:boundary-zero |
| C-139 | 1481 | law | Every discrete output stage publishes from the initial state, due or not | | |
| C-140 | 1482 | law | Only components whose phase is zero run their update at boundary zero | D-205 D-291 | G:phase |
| C-141 | 1484 | law | Every prior starts not holding, so an event already true at `t₀` fires there | D-292 | |
| C-142 | 1486 | law | Restoring a checkpoint runs no boundary zero and keeps saved priors, so nothing refires | 12.6 D-274 | G:checkpoint |

## P7. §6 chapter intro (1628–1633)
| id | line | kind | claim | cites | marks |
|---|---|---|---|---|---|
| C-143 | 1628 | law | Components become a system through wiring | | G:component |
| C-144 | 1629 | law | Connections route signals across the hierarchy of assemblies | | G:assembly |
| C-145 | 1630 | law | Assemblies only hold and wire children, with no dynamics | | |
| C-146 | 1631 | law | Ordinary junction components sit where several signals must combine | | |
| C-147 | 1632 | ptr | §6.1 gives the connection and hierarchy rules | 6.1 | |
| C-148 | 1633 | ptr | §6.2 gives the aggregation idiom they force | 6.2 | |

## P8. §8.7 Rate scopes (4039–4085)
| id | line | kind | claim | cites | marks |
|---|---|---|---|---|---|
| C-149 | 4041 | decl | An assembly schedules its children through one declaration, `sample_times`, its rate scope | | G:assembly G:component G:rate-scope |
| C-150 | 4042 | ptr | The section gives spelling and keys, then what the declaration never holds and why it belongs to the type | | |
| C-151 | 4045 | decl | `sample_times` maps each child name to a `Relative` or `Absolute` entry | | |
| C-152 | 4048 | ex | `sample_times(::A) = (nav = Relative(5), gnss = Absolute(1//10))` | | code |
| C-153 | 4052 | ptr | These are the two forms §10.5 defines | 10.5* D-185 | |
| C-154 | 4052 | law | Relative entries compose affinely down the tree; absolute entries anchor | | |
| C-155 | 4053 | mech | The build compiles them to one anchor and one `(Dₐ, Φₐ)` pair per discrete component | 9.1 9.2 D-283 | |
| C-156 | 4055 | mech | The deployment binds that to one `(D₀, Φ₀)` pair in base ticks | 9.1 9.2 D-283 | |
| C-157 | 4056 | ptr | §10.5 holds the wrappers' definitions and validation | 10.5* | |
| C-158 | 4057 | decl | The declaration is optional, and so is any given key | D-042 | |
| C-159 | 4058 | decl | An unlisted discrete child defaults to `Relative(1)` | 10.5* | |
| C-160 | 4059 | decl | Only multiplied, phased or anchored children need appear | | |
| C-161 | 4061 | decl | Keys are immediate child names only | D-042 | B |
| C-162 | 4061 | why | A deep key would edit another type's design from outside | | |
| C-163 | 4062 | why | The composition rule guarantees an author never needs a deep key | | |
| C-164 | 4065 | decl | Container elements are immediate children, so `"aircraft/red"` is a legal key | 8.5 D-085 | |
| C-165 | 4066 | decl | `sample_times` needs no rule change for containers | D-085 | |
| C-166 | 4066 | decl | The bare field name is sugar applying one uniform declaration across all elements | D-085 | |
| C-167 | 4067 | decl | The sugar keys on the field, not a path segment, so a name-transparent container keeps it unchanged | | |
| C-168 | 4069 | ex | `(children = Relative(2),)` is the uniform spelling for a `Group` | D-300 | |
| C-169 | 4072 | decl | A `sample_times` key on a continuous child is a build error | D-042 | |
| C-170 | 4073 | why | It is the declaration-time side of a run-time fact | | |
| C-171 | 4074 | law | A continuous bundle carries no `Δt` | 10.5* | G:bundle |
| C-172 | 4077 | decl | `Δt_frame`, `Δt_base` and `h_max` appear in no declaration | | |
| C-173 | 4078 | decl | They are deployment decisions fixed at deployment | D-254 | |
| C-174 | 4078 | ptr | §9.2 gives the three sources for `Δt_base` | 9.2 | |
| C-175 | 4081 | decl | The declaration belongs to the assembly type, not the child instance | D-042 D-299 | |
| C-176 | 4082 | why | A sample time is a design ratio or a modeled instrument's intrinsic rate, never per-instance | 10.5* | |
| C-177 | 4084 | decl | An instance wrapper like FlightCore's `Subsampled` is rejected | D-042 | |

## P9. §9.2 timing notation (4801–4840)
| id | line | kind | claim | cites | marks |
|---|---|---|---|---|---|
| C-178 | 4801 | law | A discrete component's timing is one period and one phase, counted in ticks of a reference lattice | | |
| C-179 | 4802 | law | Each reference is the lattice of a node | | |
| C-180 | 4803 | law | The scope's reference is the lattice of the subject's parent | | |
| C-181 | 4803 | law | The anchor's is the lattice of the nearest node at or above the subject that an `Absolute` entry declares | | |
| C-182 | 4805 | law | The base grid is the root's lattice, since the root sits at `(1, 0)` in base ticks | | |
| C-183 | 4806 | decl | A period and phase in ticks are written `D` and `Φ`, subscripted by lattice, argued by node | D-478 | B |
| C-184 | 4808 | ex | `D₀(i)` is the period of `i` in base ticks; `Φₐ(s)` is the phase of scope `s` in anchor `a` ticks | | |
| C-185 | 4810 | decl | A table leaves the argument out, since its row names the node | | |
| C-186 | 4813 | decl | Table: scope `(Dₛ, Φₛ)` in scope ticks as declared; anchor `(Dₐ, Φₐ)`; base grid, anchor `A₀`, `(D₀, Φ₀)` in base ticks; none, `(Δt, τ)` in seconds | | tbl |
| C-187 | 4820 | decl | The seconds pair has no reference and takes no subscript | | |
| C-188 | 4820 | decl | It names its node in an argument, as `Δt(i)` and `τ(i)` | | |
| C-189 | 4821 | law | `τ(i)` is the phase in seconds, the time from `t₀` to the first tick of `i` | | |
| C-190 | 4822 | decl | The spec and the framework's printed output always write the subscript | D-478 | B |
| C-191 | 4823 | decl | A bare `D` or `Φ` is only a field name, where its struct fixes the lattice | | |
| C-192 | 4824 | law | In every lattice, `D ≥ 1` and `0 ≤ Φ < D` | D-478 | B |
| C-193 | 4827 | law | One law composes the counts | D-478 | B |
| C-194 | 4827 | law | For `i` under `j` under `k`: `Dₖ(i) = Dⱼ(i)·Dₖ(j)` and `Φₖ(i) = Φₖ(j) + Φⱼ(i)·Dₖ(j)` | | |
| C-195 | 4829 | law | In seconds: `Δt(i) = Dⱼ(i)·Δt(j)` and `τ(i) = τ(j) + Φⱼ(i)·Δt(j)` | | |
| C-196 | 4831 | ptr | The fold's `Relative` row is the law with `j` the scope and `k` the anchor | 9.1 | |
| C-197 | 4832 | ptr | The admissibility table's last row is the law with `j` the anchor and `k` the base grid | | |
| C-198 | 4833 | law | With `j` the base grid, `Δt(i) = D₀(i)·Δt_base` and `τ(i) = Φ₀(i)·Δt_base` | | |
| C-199 | 4836 | law | An anchor `a` has base-grid and seconds pairs, `(D₀(a), Φ₀(a))` and `(Δt(a), τ(a))` | | |
| C-200 | 4837 | law | The base grid is anchor `A₀`: `Δt(A₀) = Δt_base`, `τ(A₀) = 0`, `D₀(A₀) = 1`, `Φ₀(A₀) = 0` | | |
| C-201 | 4838 | mech | Under an anchor other than `A₀` the build already knows a component's seconds pair | | |
| C-202 | 4839 | mech | Under `A₀` it is a multiple of `Δt_base` until the deployment binds | | |

## Ambiguous or overlapping claims
- C-039: the §2.1 refusal of a clock that cannot separate boundaries. It is a law (boundaries are strictly increasing) with enforcement attached. Part I's "laws, not enforcement" rule may split it.
- C-035 and C-036: the step-end time formulas read as definitions of the clock value, so law. They also read as arithmetic recipes, so mech.
- C-011: "computed from its own index, never accumulated" is a law about the values the clock takes, and also an implementation instruction.
- C-020 and C-029 repeat each other, and C-019 and C-056 overlap, across §2.1 and §2.2. C-017 and C-057 state the same mandatory-instant fact. C-077 repeats C-030 and C-031, and C-094 repeats C-139 and C-140. The §5.3 boundary-zero rule (C-139, C-140) is stated nowhere else in these passages as a general rule.
- C-018 and C-058 give the due-instant definition twice, once in glossary-linked prose in each section.
- C-076 ("a step ends wherever a component is due") is the same fact as C-025 and C-031.
- C-109: "retained as declaration-level rate scopes" is a pointer to §8.7 and §10.5, though it also states that the rate scope exists in the model.
- C-153 and C-154: the two forms are said to be defined in §10.5, yet §3.3 (C-111, C-112) already defines both. The §8.7 sentence "defined in §10.5" will be stale after the move.
- C-155 and C-156: "compiles" and "binds" are mechanics (mech). They are also the statement that each component ends with one period and phase (C-114), a law. Treat as the same claim.
- C-171 and C-116: a continuous bundle carries no `Δt`. This is a law about the bundle (§5.2 bundle law), but it is cited as the run-time half of a declaration error. Compare C-118.
- C-140: "only components whose phase is zero run their update at boundary zero". This is the only place the zero-phase rule appears. §3.2 (C-078) implies it through "phase plus whole multiples", so phase ≥ 0 and `Φ < D` hold.
- C-178 to C-182: "reference lattice" is used before it is defined. The §10.5 split should check whether these definitions belong in the new §6.3.
- C-176: "design ratio or instrument's intrinsic rate, never per-instance" is a rationale for a declaration rule (why) that also asserts a semantic fact about sample times (law).
- C-122: it is a law (nothing discrete runs inside a step). It cites §10.5 and root-finding as mechanism. Check whether it duplicates C-046.
- C-016 and C-081: a localized event neither moves later instants nor ticks components. Both are in §2.1 and §3.2, so check for a duplicate in the new §6.3.
- C-197: "admissibility table's last row" is a forward pointer into §9.2 text after line 4840, outside the passage.
- C-120: cited from the signature block at 1144, a code comment inside display code. Not strictly a sentence of §5.2 prose.

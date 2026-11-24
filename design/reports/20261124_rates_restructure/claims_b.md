# Claims B: spec.md §10.5, lines 7020–7288

Claim inventory of spec.md §10.5, lines 7020–7288 (read by `sed -n`; nothing edited). I read the three named sections of `spec_rules.md` first. "Part I check" was not done beyond what the three rule sections state; I did not open §2–§7 or §8.7.

| id | line | kind | claim | cites | marks |
|---|---|---|---|---|---|
| B-001 | 7022 | mech | Several components may be due at one boundary, and settled machinery already orders them. | | |
| B-002 | 7023 | law | All due components run output stages in topological order within the sweep. | | |
| B-003 | 7024 | law | All due `s_update` calls run after quiescence, in any order. | | |
| B-004 | 7025 | law | Each `s_update` reads the table and writes only its own `s` store. | | |
| B-005 | 7025 | why | An FCS cascade's intra-tick ordering is a sweep property, not an update-order property. | | |
| B-006 | 7031 | law | An assembly is virtual for execution; its children are scheduled individually and it never runs as a unit. | D-019 | B, G:assembly |
| B-007 | 7033 | decl | For declaration, a rate scope is an assembly's `sample_times` declaration against the enclosing scope. | | G:rate-scope |
| B-008 | 7034 | law | There are no atomic assemblies and no opt-in variant. | D-019 | |
| B-009 | 7037 | why | No coarsening is needed, because the signal table makes interleaving semantically invisible. | | |
| B-010 | 7038 | law | Consumers read cells whose freshness is guaranteed by topological order, not by contiguity. | | |
| B-011 | 7043 | decl | A discrete component or sub-assembly is scheduled by a `sample_times` entry in its enclosing assembly. | §8.7 | |
| B-012 | 7044 | decl | The entry declares one (period, phase) pair in one of two unit systems; the wrapper type names the unit system. | D-185 | B |
| B-013 | 7046 | ptr | The two forms declare one concept, a sample time, in different units. | | |
| B-014 | 7051 | decl | `Relative(D, Φ = 0)` is in scope ticks: every `Dₛ`-th tick of the enclosing scope, from its `Φₛ`-th. | | tbl |
| B-015 | 7051 | decl | `Relative` constraints: `Dₛ ≥ 1`, `0 ≤ Φₛ < Dₛ`. | | tbl |
| B-016 | 7052 | decl | `Absolute(Δt, τ = 0)` is in seconds: ticks at `t₀ + τ`, then every `Δt`, `t₀` the clock's origin. | | tbl |
| B-017 | 7052 | decl | `Absolute` constraints: `Δt > 0`, `0 ≤ τ < Δt`. | | tbl |
| B-018 | 7054 | law | `Dₛ = 1` admits no stagger. | D-185, D-291 | |
| B-019 | 7054 | decl | Two same-rate siblings are staggered one level down. | | |
| B-020 | 7055 | ex | Declare the scope at twice their rate, then give the siblings `Relative(2, 0)` and `Relative(2, 1)`. | | |
| B-021 | 7058 | decl | `Absolute` takes period and offset as exact seconds, each an integer or a `Rational`. | D-469 | B |
| B-022 | 7059 | ex | A 50 Hz loop is `Absolute(1//50)`; `Absolute(50)` is a period of 50 s. | | |
| B-023 | 7060 | why | `Absolute` names the unit, so numbers stand bare, as in the deployment's time keywords. | §9.2 | |
| B-024 | 7062 | mech | Every period and offset is an exact `Rational{Int}`. | | |
| B-025 | 7062 | why | Exactness is needed because grid derivation is GCD arithmetic, ill-defined over floats. | | |
| B-026 | 7063 | decl | A float argument throws the teaching error naming the exact spelling, `Absolute(1//50)` for 50 Hz. | | |
| B-027 | 7064 | decl | Any other real that is neither an integer nor a `Rational` throws the same error. | | |
| B-028 | 7065 | decl | An integer or `Rational` of any integer type is taken at its value. | | |
| B-029 | 7066 | decl | A value `Rational{Int}` cannot hold finitely is refused at the constructor as `ArgumentInvalid` `:range`, infinite period or offset included. | D-459 | B |
| B-030 | 7069 | why | Like a float, such a value fails normalization to an exact value. | | |
| B-031 | 7071 | decl | `Relative(D, Φ)` takes its child's `Dₛ` and `Φₛ`. | D-478 | B |
| B-032 | 7072 | decl | They count scope ticks, and each is an integer of any type. | | |
| B-033 | 7072 | decl | `Relative` refuses a count `Int` cannot hold as `ArgumentInvalid` `:range`, and a float or rational as `:not_a_count`. | D-459 | B |
| B-034 | 7074 | why | A fraction there usually asks for a child faster than its scope, or for a period in seconds. | | |
| B-035 | 7076 | decl | The message names `Absolute` for both cases. | | |
| B-036 | 7078 | decl | The wrappers are the whole vocabulary. | D-185 | |
| B-037 | 7078 | decl | A bare integer or a bare rational is a declaration error. | | |
| B-038 | 7079 | decl | An unlisted discrete child defaults to `Relative(1)`. | | |
| B-039 | 7080 | why | So the common case costs nothing. | | |
| B-040 | 7080 | decl | A multiplied or anchored child (declared `Absolute`) always appears explicitly. | | |
| B-041 | 7083 | mech | Validation belongs to the structure step (the build's declaration-reading step), which collects it with path attribution. | §9.1, §13.1, D-185 | |
| B-042 | 7085 | decl | Validation covers `Dₛ ≥ 1`, `0 ≤ Φₛ < Dₛ`, `Δt > 0`, `0 ≤ τ < Δt`, keys naming discrete or scope children, and composition past `Int`. | | |
| B-043 | 7087 | decl | Apart from the normalization above, the constructors are plain data carriers with no checks. | | |
| B-044 | 7092 | law | Multipliers compose multiplicatively and phases affinely down the tree. | D-019, D-185, D-291 | |
| B-045 | 7093 | law | A child `i` declared `Relative(D, Φ)` under scope `s` has `Dₛ(i) = D` and `Φₛ(i) = Φ`. | | |
| B-046 | 7095 | law | Against reference `k` (anchor or base grid), `Dₖ(i) = Dₛ(i)·Dₖ(s)` and `Φₖ(i) = Φₖ(s) + Φₛ(i)·Dₖ(s)`. | §9.2 | |
| B-047 | 7097 | mech | The build composes in anchor ticks. | §9.1 | |
| B-048 | 7097 | mech | The deployment composes in base ticks once `Δt_base` binds. | §9.2 | |
| B-049 | 7100 | mech | The structure step composes in checked `Int` and refuses a composed divisor or phase past `Int` as `RatesViolation` `:range` on the entry that composed it. | D-459 | B |
| B-050 | 7102 | mech | A rate its own check refuses composes nothing, so one fault is one refusal. | | |
| B-051 | 7103 | mech | The anchor's divisor `D₀(a)` joins the product only when a base tick binds. | | |
| B-052 | 7104 | mech | The build's trial composes it once at the coarsest base tick the anchors admit, refusing an `Int` overflow there as `RatesViolation` `:range`. | §9.1, D-465 | |
| B-053 | 7106 | mech | At a finer caller-chosen base tick, the deployment's check refuses the overflow on `Δt_base`. | §9.2 | |
| B-054 | 7109 | law | Composition preserves the canonical residue `0 ≤ Φ < D` in every lattice. | | |
| B-055 | 7110 | law | Proof is induction down the tree; the reference starts at `(1, 0)` in its own ticks (root scope in base ticks, anchor in anchor ticks). | | |
| B-056 | 7112 | law | Step: `Φₖ(s) ≤ Dₖ(s) − 1` and `Φₛ(i) ≤ Dₛ(i) − 1` give `Φₖ(i) ≤ Dₖ(i) − 1`. | | code |
| B-057 | 7115 | law | The same step carries an anchor's subtree into base ticks, since an anchor's pair is canonical, `0 ≤ τ(a) < Δt(a)`. | | |
| B-058 | 7116 | mech | All scoping compiles away at build to one triple `(a, Dₐ, Φₐ)` per discrete component. | §9.1, D-283 | |
| B-059 | 7118 | mech | The deployment binds each triple to one `(D₀, Φ₀)` pair. | §9.2 | |
| B-060 | 7119 | mech | The boundary sweep gates on that pair with the `(n − Φ₀) % D₀ == 0` test. | | |
| B-061 | 7121 | mech | The lattice stays static; the interior sweep holds no discrete entries to gate. | | |
| B-062 | 7124 | why | Relative is the default form because ratios are intrinsic to a layered control design and travel with the assembly type. | | |
| B-063 | 7126 | ex | The inner loop runs at `Relative(1)` and the outer loops at `Relative(5)`, whatever the deployment. | | |
| B-064 | 7127 | decl | Convention: a scope's base rate is its fastest relative member, which gets `Dₛ = 1`. | | |
| B-065 | 7127 | why | The convention keeps `Dₛ ≥ 1` livable. | | |
| B-066 | 7130 | ptr | Two structural properties keep a relative entry on the scope grid and confine grid cost to the other form. | | |
| B-067 | 7131 | law | A relative phase never refines the base grid, because it selects among scope ticks that already exist. | D-185, D-291 | B |
| B-068 | 7133 | law | A relative phase cannot place a tick between scope ticks. | | |
| B-069 | 7133 | decl | Off-grid stagger means declaring the offset in seconds, or declaring the scope base finer than its fastest member so unused slots exist. | | |
| B-070 | 7139 | decl | An `Absolute` entry may appear in any scope's `sample_times`, not only the root's. | D-186 | B |
| B-071 | 7140 | decl | The `(Δt(a), τ(a))` pair it establishes is an anchor, and the child hangs from it. | | G:anchor |
| B-072 | 7141 | law | The child is severed from the enclosing scope's grid; no relation to the scope's ticks remains. | | |
| B-073 | 7145 | ptr | Three corollaries follow. | D-186 | |
| B-074 | 7147 | law | `Dₛ ≥ 1` means a child cannot tick faster than the scope it is relative to. | | |
| B-075 | 7148 | law | An anchored child may tick faster than its scope. | | |
| B-076 | 7149 | decl | The fastest-member convention counts relative members only. | | |
| B-077 | 7150 | law | Phase relationships between an anchored child and its relative siblings are deployment-emergent. | | |
| B-078 | 7151 | law | Whether their ticks ever coincide depends on how grid derivation works out. | | |
| B-079 | 7152 | mech | The deployment's `Schedule` is the per-component `(D₀, Φ₀, Δt)` table the `Deployment` carries. | | G:schedule |
| B-080 | 7153 | ptr | The `Schedule` exists to answer whether anchored and relative ticks coincide. | §9.2 | |
| B-081 | 7156 | law | Relative children of an anchored subtree compose against the anchor exactly as against the root grid. | D-186, D-283 | |
| B-082 | 7157 | law | A nested anchor severs again (the fold). | §9.1 | |
| B-083 | 7160 | law | Absolute periods and nonzero offsets jointly constrain the base grid. | D-186, D-283 | B |
| B-084 | 7161 | mech | They join the deployment-time constraint pool. | §9.2 | |
| B-085 | 7162 | ex | An offset of `Δt/2` can cost a 2× finer grid, and `Δt/1000` a 1000× one. | | |
| B-086 | 7162 | why | This is the subtle part and has a real cost. | | |
| B-087 | 7164 | why | The cost is relational, incurred against everything else declared; hence attribution is the engine's job. | §9.2 | |
| B-088 | 7169 | decl | Absolute-first declaration as the default form is rejected. | D-019, D-186 | |
| B-089 | 7170 | ptr | What mid-tree anchors legitimize is narrower; the doctrinal line falls here. | | |
| B-090 | 7171 | decl | An absolute declaration inside a library type is legitimate when the rate is a fact about the modeled system, not a simulation preference. | D-186, D-291 | B |
| B-091 | 7175 | ex | A GPS receiver at 1 Hz, a data bus's transmission schedule and an ADC pipeline's fixed conversion offset are intrinsic to the assembly. | | |
| B-092 | 7177 | why | Forcing them to the root breaks encapsulation, since the root would need instrument internals to re-declare them. | | |
| B-093 | 7181 | decl | "Run the controller at 400 Hz in this study" remains a deployment choice. | | |
| B-094 | 7182 | decl | The existing idiom answers it: the assembly exposes its multiplier as a constructor parameter. | | |
| B-095 | 7183 | decl | Absolute pinning from outside a subtree's contract stays rejected as action at a distance. | | G:contract |
| B-096 | 7187 | decl | The framework cannot police the distinction; it is authoring doctrine, recorded here. | | |
| B-097 | 7190 | decl | Anchoring leaves the never-cache-`Δt` argument fully intact. | D-186, D-291 | B |
| B-098 | 7191 | why | Pinning happens in the enclosing assembly's `sample_times`, where the multiplier lives, so the component type stays rate-agnostic. | | |
| B-099 | 7193 | law | The component still consumes the `Δt` of its bundle. | | G:bundle |
| B-100 | 7194 | ptr | The bundle is the NamedTuple of zero-copy views a component function receives. | | G:bundle |
| B-101 | 7199 | ptr | The example follows one declaration to its compiled pairs and one hyperperiod (the span after which the tick pattern repeats). | | |
| B-102 | 7200 | ex | Three discrete components sit under two scopes, at a deployment binding `Δt_base = 2 ms`. | §9.2 | |
| B-103 | 7202 | ex | The root scope holds `fcs`, an FCS scope, and `gnss`, a GNSS component. | | |
| B-104 | 7205 | ex | Code block: `sample_times(::Vehicle)` and `sample_times(::FCS)` with compiled pairs `fcs` (1,0), `gnss` (10,0), `inner` (1,0), `outer` (5,2). | | code |
| B-105 | 7215 | mech | Those pairs are what the boundary gate reads at run time. | | |
| B-106 | 7215 | mech | One hyperperiod is `H = lcm D₀(i) = 10` base ticks. | | |
| B-107 | 7216 | law | The gate being pure modulo arithmetic, one hyperperiod is the complete truth, not a sample. | §9.2 | |
| B-108 | 7219 | ex | Tick chart over base ticks 0–9: `inner` every tick, `outer` at 2 and 7, `gnss` at 0. | | code |
| B-109 | 7226 | ex | `outer` is due where `(n − 2) % 5 == 0`, `gnss` where `n % 10 == 0`. | | |
| B-110 | 7227 | ex | If `outer` reads a `gnss` cell, the ZOH makes the read two base ticks old at `n = 2` and seven at `n = 7`. | | |
| B-111 | 7232 | law | Coincidence and stagger are modeling choices with observable consequences. | | |
| B-112 | 7233 | law | Coincident ticks give a consumer fresh same-instant reads via topological order. | | |
| B-113 | 7234 | why | That is the idealized synchronous-sampling picture. | | |
| B-114 | 7234 | law | A phase stagger makes the same reads pipelined and deterministically aged. | | |
| B-115 | 7235 | why | That expresses an acquisition pipeline's latency structurally, with no delay components. | | |
| B-116 | 7237 | ex | The two-tick and seven-tick reads above are the deterministic aging of a stagger. | | |
| B-117 | 7240 | mech | A stagger is a load-shaping tool under real-time pacing. | | G:pacing |
| B-118 | 7240 | ptr | Pacing means waits inserted between completed frames, never altering the boundary sequence. | | G:pacing |
| B-119 | 7242 | mech | Staggered stacks never share a boundary, so the worst-case cost of one boundary is a `max`, not a sum. | | |
| B-120 | 7243 | mech | A frame's cost is a `max` too when the stagger is at least a frame. | §10.7 | |
| B-121 | 7246 | ptr | Both patterns are worked in `reports/20260812_sample_time_proposal/report.md`, the proposal the design was adopted from. | | |
| B-122 | 7248 | ptr | The report also shows how silently an offset edit rewires a coincidence structure. | | |
| B-123 | 7249 | ptr | The `Schedule` and its hyperperiod chart are how a user audits which pattern a model has. | §9.2 | |
| B-124 | 7254 | law | `Δt` has a single source of truth, the deployment's `Schedule`. | D-187, D-254 | |
| B-125 | 7255 | decl | Each discrete component's effective period arrives read-only as the `Δt` field of every discrete-tier bundle. | §5.2, D-019 | B |
| B-126 | 7257 | decl | The field arrives in `y_state`, `y_direct` and `s_update` alike. | | |
| B-127 | 7258 | decl | It is absent from continuous bundles; touching it there is a missing-field error. | | |
| B-128 | 7261 | decl | The field must be readable in the stages, not just `s_update`. | | |
| B-129 | 7262 | why | Discretized laws consuming `Δt` run in `y_direct`, which computes each law once and publishes it; `s_update` is a copy. | §5.3, D-015 | |
| B-130 | 7263 | ex | PID backward-difference coefficients and a lead-lag Tustin transform are examples of such laws. | | |
| B-131 | 7267 | decl | The value must arrive through the call; the bundle field is where it arrives. | | |
| B-132 | 7268 | decl | A `comp.Δt` virtual property is impossible here. | D-019 | |
| B-133 | 7271 | decl | An author must never store `Δt`, or any `Δt`-derived coefficient, as a component parameter. | D-019 | |
| B-134 | 7272 | why | Recomputing per tick is a few arithmetic ops; a cached copy is a second thing for gain-scheduling machinery to chase. | | |
| B-135 | 7274 | decl | A discretized law is written to be stable at every period a deployment may assign. | D-019, D-291 | |
| B-136 | 7276 | why | The component cannot know its period at construction, and no check compares the law against it. | | |
| B-137 | 7280 | why | Relative declaration structurally enforces the no-store rule for the period, since the absolute rate does not exist until composition. | | |
| B-138 | 7284 | law | The bundle's `Δt` is still `Δt(i) = D₀(i)·Δt_base`. | D-185, D-291 | B |
| B-139 | 7286 | law | An offset shifts firing instants, never the period. | | |
| B-140 | 7287 | why | So discretized laws are unaffected by staggering. | | |

Notes on marks. Bold spans hold only the headline clause. B-014 to B-017 carry the table's `tbl` mark only; I did not add B for the table. The Part I-style law at B-054 to B-057 is stated as a proof sketch, so a coordinator may treat B-055 and B-056 as one `ex`/proof unit.

**Ambiguous claims**
- B-001: "settled machinery" has no citation. It points at the sweep, but no § or D- number backs it.
- B-005: "therefore" makes this a consequence of B-002 to B-004. It could be `why` or `law`.
- B-007: "rate scope" is defined as a declaration, not a runtime object. This is `decl` by wording, but the glossary term is Part I vocabulary.
- B-009/B-010: "no coarsening" implies a rejected alternative (atomic assemblies, covered by B-008). Its D-019 entry should carry the argument.
- B-024 vs B-021: `Rational{Int}` is storage spelling; "exact numbers" is the law. Split by kind: spelling is `decl`/`mech`, exactness is Part I-able.
- B-048/B-047 and B-052: "build composes in anchor ticks" and "build's trial composes at the coarsest base tick" are mechanics. The refusal reasons are `RatesViolation` diagnostics.
- B-064/B-065: the fastest-member convention has no D- cite here. B-076 cites it only through D-186. An unmarked sentence settles nothing (spec_rules), so confirm an entry backs it.
- B-066: "Two structural properties" announces only one bold ruling (B-067) plus B-068. The count is satisfied only if B-068 is the second.
- B-069: Is "or declaring the scope base finer" authoring advice or a law about what grids permit?
- B-077/B-078: "deployment-emergent" is a law about unspecified phase, but the sentence is a corollary of a bold ruling.
- B-089 and B-096: "the doctrinal line falls here" and "authoring doctrine, recorded here" are self-referential pointers. They are `decl` doctrine but have no rule content on their own.
- B-099: "still consumes the `Δt` of its bundle" restates B-125 in forward-looking form. It is `ptr` or `law`.
- B-124: "single source of truth" is a law in Part I terms, but `Schedule` is an API name, so Part I may need a concept label.
- B-132: "impossible here" is a reason (why the field is in the bundle). It is stated as a rule, with a D-019 cite.
- B-135: this is `decl` (authoring) but also a law about the model class that is well formed. The sentence is not bold.
- B-137: "Relative declaration structurally enforces…" could be `law` (period unknowable by construction).
- B-139 and B-140: the second half ("so unaffected") is a consequence, not a separate ruling.

**Duplicates of other sections**
I did not open §2–§7 or §8.7, so I verified no line there. From the section's own cross-references, these likely sit elsewhere. Check them:
- B-011 (the `sample_times` entry in the enclosing assembly) cites §8.7, which probably states it.
- B-046 cites "the law of §9.2", so the composition law lives there too.
- B-058 to B-060 and B-105 to B-107 (triples, `(D₀, Φ₀)`, gate test, hyperperiod) cite §9.1 and §9.2 as their home.
- B-084 and B-087 (constraint pool, attribution) cite §9.2.
- B-125, B-129 cite §5.2 and §5.3.
- B-002 to B-004 may duplicate sweep and quiescence statements in §5 and §10; the "above" in B-060 ("the `(n − Φ₀) % D₀ == 0` test above") points to an earlier §10.5 statement outside lines 7020–7288 that I did not read.

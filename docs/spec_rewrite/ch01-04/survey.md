# Survey of spec chapters 1 to 4 before their readability rewrite — 2026-10-13

Base commit: `d3af35a` (frozen; the owner may edit the working tree). Scope:
`docs/design/spec.md` lines 139–671 at `d3af35a`, "## 1. Introduction" to the
closing `---` of "## 4. Ports and signals", 4,285 words (`wc -w`). The Part I
roadmap above line 139 is out of scope. The convention is
`docs/design/tools/spec_style.md`; the method is `docs/spec_rewrite/recipe.md`
step 1; the models are chapter 5's survey (`git show
ffd659f:docs/spec_rewrite/ch05/survey.md`) and chapter 7's.

Line numbers are `spec.md` lines at `d3af35a` unless marked `log`
(`decisions.md` at `d3af35a`) or given with a file name. Copies of both files
are in `scratch_survey/` (`spec.md`, `decisions.md`). Entries consulted are in
`scratch_survey/entries/`, printed with log line numbers by
`scratch_survey/entry.sh`. Every bold span in the spec, with the D-citations of
its sentence, is in `scratch_survey/bold_spans_all.tsv` (`bolds.py`); every
glossary link in the run is in `scratch_survey/glossary_links.tsv`. Code was run
with `scratch_survey/run_ports.jl` and `run_handle.jl`.

The run cites 13 entries (D-001, D-004, D-008, D-016, D-036, D-056, D-179,
D-195, D-237, D-243, D-276, D-302, D-316). Entries that rule its content
without being cited in it include D-002, D-003, D-019, D-033, D-034, D-045,
D-080, D-082, D-090, D-112, D-121, D-139, D-141, D-172, D-180, D-194, D-220,
D-231, D-249, D-252, D-296, D-308. Four of these are cited nowhere in the spec
at all (grep of `D-nnn]` over `spec.md`): D-002, D-003, D-121 and D-172. D-139
is cited only in §14.

Classification codes used in part A (chapter 5's):

- **C** cited, and ruled by the cited entry's Position (at the spot or in the
  same paragraph, marked "adjacent").
- **U** ruled by an entry's Position that the section does not cite at that
  spot.
- **S** cited to a superseded entry.
- **R** ruled only in an entry's Rationale, Rejected list or annotation.
- **N** no entry found (checked by grep of the log at `d3af35a`). Where the
  sentence reads as a description of an inherited shape rather than a ruling,
  the row says so.
- **B** borderline; both readings are given.
- **O** chapter 1 only: overview of a ruling another chapter states and
  rules. It stays plain and points there. The entry is given for the
  rewriter's pointer, not for a citation at the spot.

"Marking" is how the spec marks the rule now: **Rule.**/**Why.**/**Example.**
label, a bold label of another wording ("**Rule of meaning.**", "**Write-side
rule.**", "**Vocabulary.**", "**Visibility.**", "**Granularity guideline.**",
"**Verdict.**", chapter 1's five lead-ins), bold sentence, bold lead-in (a bold
phrase opening a paragraph or bullet, used as a heading), bold words, or plain.
The run carries 3 **Rule.** labels (509, 557, 589), 2 **Why.** labels (349,
374), 2 **Example.** labels (574, 646), 11 other labels, and 76 bold spans in
all of about 210 words. Only two bold spans carry a D-citation in their
sentence: 269 (D-179) and 277 (D-001).

Section sizes (words, `wc -w` over the line ranges): §1 139–212 (597); §2
heading and lead 213–229 (118); §2.1 230–274 (354); §2.2 275–295 (159); §3
lead 296–300 (22); §3.1 301–327 (204); §3.2 328–353 (219); §3.3 354–363 (74);
§3.4 364–436 (612); §4 heading 437–438 (5, no lead); §4.1 439–473 (274); §4.2
474–491 (163); §4.3 492–601 (911); §4.4 602–671 (573).

Rows that are context, reasons, examples, pointers or code stay in the tables
for the rewriters but are left out of the tally. Chapter 1's O rows are
counted apart.

## A. Per section

### §1 Introduction (139–212, 597 words)

Purpose: what the framework is, what it can do, the five design criteria, its
origin in Flight.jl, and what this document is. Every capability and criterion
points at the chapter that rules it. Chapter 1 rules nothing of its own: no
sentence in it carries a D-citation, and the two statements that read as
rulings of this chapter (the scope paragraph and the entry-number rule) are
process, which `decisions_style.md` rule 9 keeps out of the log.

Subheadings: none. Bold lead-ins acting as headings: **Purpose.** (141),
**Capabilities.** (148), **Design criteria.** (166), **Origins.** (185),
**Scope of this document.** (194), and the five criterion names (170, 172,
174, 176, 179). None is a ruling; under `spec_style.md` ("Bold marks nothing
else: not lead-ins … or labels") all ten go. Part G q2.

| # | line | quote | marking | entry | class |
|---|---|---|---|---|---|
| 1 | 141–144 | "Redstone is a framework for modeling and simulating hierarchical hybrid causal systems (models that mix continuous dynamics, periodic discrete dynamics and events, exchanging values through directed ports)." | lead-in | D-001 Position log 359 ("Hybrid causal formalism"); D-002 Position log 376 ("Causal port-based paradigm"); home §2 213–215 | O |
| 2 | 144–146 | "Its home domain is aircraft guidance, navigation and control … The formalism itself is domain-neutral." | plain | none | context |
| 3 | 148–150 | "A model is written as a tree of components in plain Julia. The build checks the tree. A simulation runs a `Model` (the tree compiled at one scalar type, ready to step) ([§9])." | plain | D-032 Position log 1026 (plain Julia); D-317 (a `Simulation` runs a `Model{Float64}`, bold §9 4146) | O |
| 4 | 152–154 | continuous dynamics, "integrated on a fixed step, with events either located by root-finding or checked at step boundaries ([§2], [§10])" | plain | D-001 Position ("two-tier events"); D-179 | O |
| 5 | 155–156 | "Multi-rate periodic discrete dynamics at declared sample times, held zero-order between ticks ([§3.2], [§10.5])" | plain | D-019 Position log 715–716 (ZOH by construction) | O |
| 6 | 157–158 | "A build that derives the execution order from declared feedthrough and rejects algebraic loops by naming the cycle ([§5], [§9])" | plain | D-006, D-005, D-012 (homes §5.2, §5.5, §5.6) | O |
| 7 | 159–161 | "A runtime periphery (…) that writes by staging and reads by snapshot ([§11], [§12])" | plain | D-022, D-023, D-024 (homes §11) | O |
| 8 | 162 | "An input trace that replays any run bit-identically ([§11.5])" | plain | D-029, D-101 | O |
| 9 | 163–164 | "Stopped-sim services for initialization, trim and linearization, with exact automatic-differentiation Jacobians ([§14])" | plain | D-069, D-072 | O |
| 10 | 166–168 | "The design answers to five criteria. Wherever it admits a capability it does not build, that capability is weighed against them as a guarded addition." | lead-in | none. The glossary's *guarded addition* (13892–13895) cites §1 for it; no entry records the five criteria or the weighing rule (grep of "design criteri", "five criteria", "guarded addition" over the log: only D-180's and D-309's titles, log 6564, 12981) | N. Reads as the spec's own charter, not an inherited shape |
| 11 | 170–171 | "**Zero-allocation stepping and type stability.** The inner loop allocates nothing, and the test suite asserts it ([§7.5], [§9.7])." | bold lead-in | D-014, D-305 Position bullet 1 log 12890–12891 ("scoped to the stepping loop"); §7.5 2078 bolds the exactly-zero budget | O; overstates §7.5 (part E, F5) |
| 12 | 172–173 | "**Real-time interactive operation.** A simulation runs paced against the wall clock, with devices and a GUI attached ([§10.7], [§11])." | bold lead-in | D-021; D-310 Position log 13003–13004 (the built-in GUI is parked for a browser cockpit; "a GUI attached" still holds) | O |
| 13 | 174–175 | "**Live introspection.** Every published signal can be inspected by path, during a run and after it ([§11.2])." | bold lead-in | D-023, D-038 | O |
| 14 | 176–178 | "**Compositional flexibility.** Components compose hierarchically, and a component substitutes for another behind the same declared contract ([§6], [§8])." | bold lead-in | D-034, D-078, D-296 | O |
| 15 | 179–181 | "**Rigor and error locality.** Structure is declared and checked at build time, so a mistake fails where it was made, with a diagnostic naming it ([§8.4], [§13])." | bold lead-in | D-032 Position (schema authority); D-058 | O |
| 16 | 181–183 | "Components are plain Julia with no macro DSL, so debugging, tooling and comprehension work on the language's own terms ([§8.1])." | plain | D-032 Position log 1026–1030 and Rejected log 1050–1051; §8.1 2177 bolds "There is no macro DSL" | O. §8.1 2178 calls this "The debugging, tooling and comprehension criterion ([§1])": the words must survive (part D) |
| 17 | 185–192 | Origins: `FlightCore`, `FlightPhysics`, `FlightApps`; "Every capability they demonstrated had to survive, and none of their interfaces had to." … "Redstone itself does not depend on Flight.jl." | lead-in | none (history; `decisions_style.md` puts FlightCore contrasts in Rationale). The last sentence holds: `Project.toml` at `d3af35a` lists only ForwardDiff, LinearAlgebra, Random, StaticArrays | context |
| 18 | 194–204 | "This document is the normative statement of the design. It states what the framework *is*, in the present tense." Part roadmap; appendices; `pending.md`; "The explainers in `companions/` are not normative, and this document wins wherever they disagree." | lead-in | none for the document's status (process, `decisions_style.md` rule 9). D-123 Position log 3812–3815 rules the glossary's precedence (the owning section wins), which §1 does not state | N (process). Not a ruling candidate |
| 19 | 206–209 | "Decision rationale lives in `decisions.md` … one entry per settled decision. Entry numbers are stable and never reused, so a citation here always names the same entry there." | plain | `decisions_style.md` "ID" field rule, no D-entry | N (process) |

Statements in chapter 1 that are rulings elsewhere and must stay plain: every
row but 2, 17, 18 and 19. None is a bold candidate: each ruling is stated, and
bold, in the chapter row 1–16 points at, or belongs there (rows 1, 4 to §2;
row 11 to §7.5; row 16 to §8.1). Rows 10, 18 and 19 are this chapter's own
content and stay plain because no entry records them (row 10) or because they
are process (18, 19).

Two pieces of the overview say more than the ruling chapter: row 11 (part E,
F5) and row 12's "a GUI" (holds, see the row). Row 3's gloss of `Model`, "the
tree compiled at one scalar type, ready to step", matches the glossary's "a
deployment materialized at one scalar type" (13377) in substance; the
deployment step is §9.2's.

Reader-cold names in §1: `FlightCore`, `FlightPhysics`, `FlightApps` are
introduced in place (185–187). "the periphery" is glossed. "guarded addition"
(168) is linked but not glossed; its gloss first appears in §4.3 (562–564).
"sample times", "feedthrough", "execution order", "snapshot", "trace" and
"`Model`" are used before any definition, which is normal for an overview: each
points at its chapter. The rewrite should not gloss them all; one roadmap
pointer per bullet suffices.

Display-block candidates: none.

Appendix C kinds cited to §1: none.

### §2 Formalism, heading and lead (213–229, 118 words)

Purpose: names the class of systems simulated and lists its five parts. There
is no roadmap sentence for §2.1 and §2.2.

| # | line | quote | marking | entry | class |
|---|---|---|---|---|---|
| 20 | 215 | "The framework simulates **hybrid causal systems**. Such a system has five parts." | bold words (a linked term) | D-001 Position log 359 ("Hybrid causal formalism"), first ruling of the semicolon chain; D-002 Position log 376 ("Causal port-based paradigm"), cited nowhere in the spec | U. D-001 is cited only in §2.2 |
| 21 | 217 | "**Continuous dynamics.** $\dot{x} = f(x, m, u, t)$ with algebraic outputs." | bold lead-in | D-001 Position; the form against §5.3 956–958 (part E, F3) | U |
| 22 | 218–219 | "**Multi-rate periodic discrete dynamics.** $s^{+} = g(s, u, t)$ at declared rates, with outputs held zero-order between ticks." | bold lead-in | D-019 Position log 715–716 ("discrete stages gated to own tick instants (ZOH by construction)"); the letter D-195 Position bullet 1 log 7139–7141 | U |
| 23 | 220–221 | "**Zero-crossing events.** Guard functions with handlers, under two detection policies, stated below." | bold lead-in | D-001 Position ("two-tier events") | U |
| 24 | 222–226 | "**Post-step manifold projection.** An optional per-component hook `x ← x_projection(x)`, applied after each accepted step. It covers quaternion renormalization, DCM orthonormalization … the cheap end of the projection-methods family" | bold lead-in | D-001 Position ("projection"); positions D-016 Position log 626–627, standing per its annotation log 633–636; "both … schedule positions" D-111 Position log 3421–3422 | U. "applied after each accepted step" omits the handler position (F2) |
| 25 | 227–228 | "**External inputs.** The runtime injects them asynchronously, from pilot controls or the network, under the staging rules of [§11]." | bold lead-in | D-022 Position log 809–810, D-031 Position log 1002 | U |

Bold home: the lead is where D-001's first ruling ("Hybrid causal formalism")
is stated; it has no bold anywhere today with a citation. One bold at 215,
citing D-001 (and D-002 beside it). The five lead-ins are labels and go plain;
they may stay a bulleted list with italic or plain item names.

The formalism is stated with three symbols, `f`, `g` and the hook, but not with
the output map `h`, which §5.3 (876–891) and D-220 (log 8181–8182) keep as the
third formula symbol. "with algebraic outputs" is the only mention of outputs
(part E, F3).

Display-block candidates: the five-part list could become two display lines of
math (flow and jump), as §5.3 does; optional.

Appendix C kinds cited to §2: none.

### §2.1 Events: two detection policies (230–274, 354 words)

Purpose: one declaration, two detection policies; pace-independence; time
events against state events; the predicate and edge semantics; the return
type as the policy.

Subheadings: none. Labels: none. Bold lead-ins 235, 241, 247; bold words 259,
261; one bold sentence 269.

| # | line | quote | marking | entry | class |
|---|---|---|---|---|---|
| 26 | 232–233 | "Both policies share one declaration, a guard function plus a handler. Only detection differs." | plain | D-179 Position log 6538–6540 (`Event(guard, handler)` loses the `localize` keyword) | U |
| 27 | 235–237 | "**Boundary-detected (cheap).** The framework checks each guard for a not-holding → holding edge against its prior ([§10.6]) at step boundaries only." | bold lead-in | D-001 Position ("two-tier events"); D-179 Position (`Bool` ⇒ boundary-detected); D-082 Position log 2510–2511 (edges against a per-event baseline) | U |
| 28 | 237–240 | "There is no root-finding and no step rejection. The handler fires at the end of the step in which the edge was observed. The cost is one guard evaluation per event per step. This policy is fully compatible with fixed-step real-time execution." | plain | none for the cost. §10.6 6093–6099: each round evaluates all guards, and rounds continue to quiescence | description; the cost holds for a boundary of one round only (F4) |
| 29 | 241–243 | "**Localized (precise).** The framework finds the crossing instant by root-finding. This policy serves events where timing precision genuinely matters. [§10.4] gives the mechanics." | bold lead-in | D-018 Position log 687–688; D-179 Position | U |
| 30 | 245 | "Detection policy never depends on real-time pacing ([§10.7])." | plain | D-080 Position log 2459–2461; D-001 Position sentence 2 log 360. §10.7 6382–6383 bolds it | U |
| 31 | 247–249 | "**Time events and state events.** The discrete tier's ticks, declared by `sample_times`, are time events. Their instants are known in advance and scheduled ([§10.5])." | bold lead-in | D-220 Rationale log 8248–8251 | R |
| 32 | 249–251 | "Everything declared through `StateEvent(guard, handler)` is a state event. Its instant is unknown and must be detected, by boundary check or by localization." | plain | D-220 Rationale log 8251–8252 | R |
| 33 | 251 | "That is why the declaration is named `state_events` ([§8.2])." | plain | D-220 Position bullet 4 log 8188 | U (the name; its reason is row 31's R) |
| 34 | 252–253 | "The criterion is detection versus scheduling, not which fields a guard reads. A guard over an input is still a state event." | plain | D-220 Rationale log 8252–8253 | R |
| 35 | 255–257 | "This arrangement gives step-boundary logic *well-defined semantics*. The crossing defines the transition. Detection resolution is an execution-policy detail." | plain | the last clause: D-179 Position log 6541 (de-localization "semantics-preserving by construction"); the rest none | B: U by D-179 for the last sentence; N for "well-defined semantics". "This arrangement" points back across the time/state paragraph to the two policies (part F) |
| 36 | 259–262 | "A guard defines a **predicate**. It does so in one of two forms, either a `Bool`-valued form or the sign of a continuous function under the normative convention **positive = predicate holds**. Writing the guard's sign value `σ`, holding means `σ ≥ 0`." | bold words ×2 | D-082 Position log 2509–2510, first ruling ("a guard defines a condition (`Bool` predicate, or continuous with positive = holding, `σ ≥ 0`)"); D-001 Position sentence 2 log 360–361; the word D-122 Position log 3769 (condition → predicate) | U. Bold home: no other section bolds it |
| 37 | 264–265 | "An event fires when its predicate transitions from not-holding to holding. This is edge semantics, and it is uniform across both forms." | plain | D-082 Position log 2510–2514, second ruling ("events fire on not-holding → holding edges against a per-event baseline held in loop state") | U. Bold candidate: §10.6 states the prior plain (6176–6178) and bolds only D-181's three conditions (6102) |
| 38 | 265–266 | "[§10.6] states the prior bookkeeping." | plain | — | pointer |
| 39 | 266–267 | "The opposite crossing direction is declared as a second event with the negated guard. Stall entry and exit are one such pair." | plain | D-082 Rationale log 2519–2520 ("opposite direction = second event with negated guard"); D-180 Rejected log 2583–2584 relies on it | R. D-180's own ruling, a per-event `direction` as an unbuilt guarded addition (log 6568–6569, Spec §2.1 only), is stated nowhere in the spec (part E) |
| 40 | 269–271 | "Which form an author declares is not a free choice. **The guard's return type is the declared policy.** A `Bool` return declares boundary-detected, and the sign form declares localized ([D-179])." | bold sentence, cited | D-179 Position log 6538–6539 | C. §10.4 5415 bolds the same ruling ("The guard's return type declares its detection policy", D-179), which chapter 10's rewrite placed there: plain here |
| 41 | 271–273 | "[§10.4] states the rule, the exactness result that motivates the `Bool` form, and the gate idiom for localizing mixed predicates." | plain | — | pointer |

Bold, one per ruling, for §2.1: D-082's two rulings (rows 36 and 37), since
no section bolds either. Row 40 goes plain with its citation (home §10.4). Row
30 goes plain (home §10.7). Rows 31–34 (R, D-220's Rationale) could take one
bold on row 31's headline with an R citation; the time/state criterion has no
other statement in the spec except the glossary (13266–13298). Part G q6.

Descriptions that read like rules: row 28's cost, row 35's first sentence.

Display-block candidates: none. A two-row table (policy, declared by, detection,
cost) would replace the two bullets but adds nothing the bullets lack.

Appendix C kinds cited to §2.1: none. The run never names `GuardForm`, whose
condition (a guard returning neither form) §2.1 does not state; nothing to add.

### §2.2 Exclusions (deliberate) (275–295, 159 words)

Purpose: three things the formalism excludes, each with what covers the need.

| # | line | quote | marking | entry | class |
|---|---|---|---|---|---|
| 42 | 277–278 | "**No DAEs / algebraic constraints.** The actual need is state manifolds, and projection covers it ([D-001])." | bold lead-in, cited | D-001 Position log 359–360 ("no DAE/SDE/per-step hook"); Rejected log 368 ("projection suffices") | C |
| 43 | 279–282 | "**No SDEs / stochastic integrators.** Noise processes such as Dryden/von Kármán turbulence and sensor noise are modeled as ordinary RNG-driven discrete processes, that is, shaping filters. That modeling is faithful to how they are specified, and it is cheap." | bold lead-in | D-001 Position; Rejected log 369 ("shaping filters suffice") | U (D-001 is cited in the bullets either side, not in this one) |
| 44 | 282–285 | "One consequence is elevated to a framework guarantee, **deterministic replay**. RNG state lives in component discrete state (`s`), never in ambient globals, so the same seed gives a bit-identical trajectory." | bold words | RNG values in `s`: D-231 Position log 8692–8693 ("A PRNG object is workspace; the values that determine its next draw are the state"), bold in §7.3 1975, which cites §2.2 back for replay (1979). The guarantee itself: no Position (grep of "determinis", "reproduc" over Position fields: none states it) | B: U by D-231; N for "elevated to a framework guarantee". "RNG state" must not be read as the generator (part F) |
| 45 | 286–287 | "**No unconditional per-step hook**, so no `f_step!` equivalent." | bold lead-in | D-001 Position, cited adjacent at 292; Rejected log 370 ("step-size-dependent semantics") | C (adjacent) |
| 46 | 287–290 | "Every current use decomposes into one of two mechanisms. Projection covers quaternion renormalization. Boundary-detected events … cover engine phase transitions and the stall hysteresis latch." | plain | evidence: D-141 Rationale log 4761–4764 (`PistonEngine`'s `f_step!` "does mode transitions only") | context. "Every current use" means Flight.jl's, unsaid |
| 47 | 290–292 | "For one class the mapping tightens semantics. Level-triggered cross-component resets become edge-triggered events. The gear friction regulator under `!wow` is one such reset ([§5.3], [D-001])." | plain, cited | D-141 Position log 4726–4738 (a commanded continuous reset is an event on the touchdown edge, `strut.wow → frc.reset`); the cited D-001 is silent on resets | B: cited to an entry whose Position is silent; U by D-141. "under `!wow`" (F1) |

Bold home: D-001's three exclusions are one Position clause, "no
DAE/SDE/per-step hook", one ruling by the semicolon test: one bold, on the
first bullet's headline or on a context sentence naming all three. The three
bold lead-ins become plain item names. Row 44's "deterministic replay" bold has
no entry; §7.3 holds D-231's bold. Part G q6.

The section never says why `f_step!` is excluded. D-001's Rejected list
(log 370) gives "step-size-dependent semantics", and two outside rows rely on
§2.2 for it (part D: spec 6121, log 772). One clause citing D-001 would make
those rows right (part G q9).

`f_step!` is FlightCore's per-step hook (`Flight.jl/lib/FlightCore/src/modeling.jl`
214, `function f_step!(mdl::Model, args...)`); the spec never says so.

Display-block candidates: none.

Appendix C kinds cited to §2.2: none.

### §3 Component taxonomy, lead (296–300, 22 words)

| # | line | quote | marking | entry | class |
|---|---|---|---|---|---|
| 48 | 298–299 | "There are three classes. Two of them are leaves with crisp, closed semantics, and one is pure composition." | plain | D-003 Position log 389–390, first ruling of the semicolon chain ("Taxonomy: hybrid continuous primitive + periodic discrete + assemblies"); D-003 is cited nowhere in the spec | U. Bold home of D-003's first ruling. "classes" here is neither glossary sense of *class* (part F) |

The lead has no roadmap sentence naming §3.1–§3.4, and none saying that §3.4
is the justification of the split. Chapters 5 to 10 open with one.

### §3.1 Continuous component (the hybrid primitive) (301–327, 204 words)

Purpose: the continuous leaf's facets; any facet may be empty, so the same
primitive is an FSM; the two factorings of mode logic; the rule of meaning.

| # | line | quote | marking | entry | class |
|---|---|---|---|---|---|
| 49 | 303 | "A continuous component is a classical hybrid automaton. It has these facets." | plain | D-003 Position ("hybrid continuous primitive") | U |
| 50 | 305 | "**Continuous state** `x`, an isbits struct of real scalars ([§7])." | bold lead-in | D-094 Position log 2852–2853 (leaves are "plain real scalars and `SArray`s at the common eltype"); D-247 Position log 9373–9374 (every store declaration returns a `NamedTuple`); D-304 Position bullet 1 log 12852 (flat) | U; misstates §7.1 (F7, README carried item) |
| 51 | 306–307 | "**Mode variables** `m`. These are piecewise-constant values (enums, integers, flags) that parametrize the flow and change *only* through event handlers." | bold lead-in | contents D-308 Position bullet 1 log 12966; a handler writes `m`: D-090 Position log 2750–2752; "only": none | B: U by D-308 and D-090; N for "only" |
| 52 | 308 | "**Flow** $\dot{x} = f(x, m, u, t)$." | bold lead-in | as row 21 | U (F3) |
| 53 | 309 | "**Two output stages** ([§5.2])." | bold lead-in | D-006, bold §5.2 696 | U; home §5.2 |
| 54 | 310–312 | "**Events**, each a guard plus a handler. A handler may update `m` and may reset the component's own `x`. Both guard and handler read the fresh boundary signal table ([§5.3])." | bold lead-in | D-090 Position (handler returns `(; x, m)`); the fresh table D-016 Position log 625 (a clause its annotation log 633–636 neither removes nor keeps) and D-154 Position log 5457–5459 (the epoch rule, bold §10.6 6219) | U |
| 55 | 313 | "An optional **projection**." | bold words | D-001 Position ("projection") | U |
| 56 | 315–317 | "Any facet may be empty. In particular, a component with *no* continuous state, only modes, events and mode-valued outputs, is an FSM. A single primitive therefore supports both factorings of mode logic." | plain | "empty": D-263 Position bullet 5 log 10442–10443 ("a stateless leaf declares it empty"); the factorings D-003 Position, second ruling log 390 ("both mode factorings") | U. "therefore" demotes D-003's second ruling to a consequence |
| 57 | 319–320 | "**Internal modes** suit tightly coupled cases, such as stall hysteresis inside the aero component. They preserve cohesion and enable reset maps." | bold lead-in | D-003 Rejected log 395–396 ("*Strict purity/no modes:* loses reset maps") | R |
| 58 | 321–322 | "An **external FSM component** feeding modes through a port gives maximal purity, independent testability and swappable supervision logic." | bold words | D-003 Position, second ruling | U |
| 59 | 324–326 | "**Rule of meaning.** A supervisor *commanding* a mode change is an ordinary **input**. A component *detecting* its own transition is an **event**. The two mechanisms carry two meanings and do not overlap." | label, bold words | "commanding is an input": D-089 (title "Route supervisor gains and resets through ordinary ports"; Position log 2724–2728 states the gains only), D-342 Position bullet 6 log 14084–14087 (a commanded reset is a same-tick input, discrete tier). "do not overlap": none (grep of "Rule of meaning", "commanding", "mode change" over the log: no hit). The rule dates from the first design checkpoint (`b4d8f5f`, 2026-07-12) | B: U by D-342 for the discrete tier; N for the rest. Tension with D-141 (F6) |

Bold homes: D-003's second ruling (both factorings) is bold nowhere; its
place is row 56 or row 58, with "therefore" removed from row 56 if the bold
goes there. Row 59 keeps no bold unless q7 rules it.

Display-block candidates: none.

Appendix C kinds cited to §3.1: none.

### §3.2 Periodic discrete component (328–353, 219 words)

Purpose: the discrete leaf's facets; why the tiers have different state
letters; `m` is continuous-only, and why.

| # | line | quote | marking | entry | class |
|---|---|---|---|---|---|
| 60 | 332 | "**Discrete state** `s`, any isbits value ([§7])." | bold lead-in | D-231 Position log 8689–8691 ("Every field of a store value … is isbits or a `Symbol`"); D-247 Position log 9373–9374 (a `NamedTuple`) | U; misstates §7.3 (F7, README carried item) |
| 61 | 333 | "**Update** $s^{+} = g(s, u, t)$ at a declared rate." | bold lead-in | D-195 Position bullet 1 log 7139–7141; D-019 Position | U |
| 62 | 334–335 | "**Two output stages**, with feedthrough applying at update instants. A proportional path is direct feedthrough. A state-only output is not." | bold lead-in | D-220 Position bullet 2 log 8185–8186 (one pair of names for both tiers); D-019 Position (stages gated to tick instants) | U |
| 63 | 337–341 | "Each tier carries its own state letter. `x` is the argument of the flow map under `f`, and `s` is the argument of the jump map under `g`. The two are different objects. … So they are spelled differently ([D-195])." | plain, cited | D-195 Position log 7135 ("The discrete state un-fuses from `x` into its own letter `s`"); the reasons D-195 Rationale log 7152–7157 | C. The ruling comes last behind "So"; rule first (part F). D-195 is bold nowhere in the spec |
| 64 | 341–342 | "Nothing is lost by the split, because a leaf is strictly one tier ([D-056]) and no component ever reads another's state." | plain, cited | one tier: D-263 Position bullet 5 log 10442 ("exactly one of `init_x` and `init_s`"); the cited D-056 Position (time bases, cross-tier through cells) supports it, as D-195 Rationale log 7165–7166 reads it; no reading of another's state: D-056 Rejected log 1707–1709, D-035 Position | B: C by D-056 in substance; the closest Position is D-263 bullet 5 |
| 65 | 342–344 | "A discrete component's `s` influences continuous dynamics only **through signals**. Those outputs are held zero-order between ticks." | bold words | D-056 Position log 1683–1684 ("cross-tier coupling always routes through table cells"); D-019 Position (ZOH) | U |
| 66 | 346–347 | "**`m` is continuous-only.** A discrete component has no mode store. Its FSM enums, flags and counters are ordinary `s` fields." | bold sentence | "no mode store": D-231 annotation log 8724–8725 ("`m` is continuous-only, since a discrete component has no mode store ([§3.2], [§8.2])"); `m_init` tier-bound: D-249 Position bullet 1 log 9494–9496 (`DeclarationOnWrongTier` keeps … `init_m`) | B: R by D-231's annotation; U by D-249. §5.2 811 states it plain; §8.2 2932 bolds the agreement rule (D-112, D-249) |
| 67 | 349–352 | "**Why.** `m` exists on the continuous side because modes must change *between* flow evaluations … A second store would duplicate the discrete tier's own state semantics under another name." | label | none | reason (constructive) |

Bold homes: D-195 (row 63, bold nowhere; chapter 8's rewrite cited it four
times plain and bolded none) and the no-mode-store rule (row 66, R, keep the
bold and flag the log). Part G q6.

Display-block candidates: none.

Appendix C kinds cited to §3.2: none. Row 66 states part of
`DeclarationOnWrongTier`'s condition (an `m_init` on a discrete leaf;
Appendix C 12507–12511) without naming it. Naming it is optional; the kind's
row does not cite §3.2.

### §3.3 Assembly (354–363, 74 words)

| # | line | quote | marking | entry | class |
|---|---|---|---|---|---|
| 68 | 356–357 | "An assembly is pure composition. It holds submodels, local wires and boundary faces." | plain | D-003 Position (first ruling); D-170, D-314 (local wires); D-172 (faces) | U |
| 69 | 357 | "**It has no dynamics of its own.**" | bold sentence | D-141 Rejected log 4797–4799 ("events are leaf-owned and an assembly has no dynamics of its own, [§3.3]"); D-019 Position log 716 ("assemblies virtual for execution"). §8.5 3105 "Assemblies have no state of their own" plain | B: R by D-141; U by D-019 in part |
| 70 | 357–359 | "Hybridness emerges at the assembly level. An aircraft is continuous vehicle parts plus discrete avionics parts." | plain | D-003 Position | context |
| 71 | 359–360 | "The two-leaf split was upheld against the integrate-and-dump challenge ([§3.4], [D-056])." | plain, cited | D-056 Position | C (pointer; home §3.4) |
| 72 | 360 | "Assemblies are flattened away for ordering." | plain | D-019 Position log 716; §10.5 5870 bolds "An assembly is virtual for execution" | U |
| 73 | 360–362 | "They are retained as the navigation and introspection hierarchy (GUI, logging, paths) and as declaration-level rate scopes ([§10.5])." | plain | D-019 Position log 716–718 ("rate scopes for declaration"); D-040 (paths) | U |

Bold: row 69 is the only bold, and no Position states it. Options: keep it
with D-141's R citation, or make it plain as part of D-003's taxonomy
(row 48's ruling). Part G q6.

"submodels" (356) is a reader-cold word for the assembly's child components;
`spec_style.md` reserves lowercase "model" for a `Model` or the modeled system
(part F).

Appendix C kinds cited to §3.3: none.

### §3.4 Why two leaf classes, not one hybrid primitive (364–436, 612 words)

Purpose: the case against an all-in-one primitive; the integrate-and-dump
challenge, its algebraic answer, the verdict, and the recorded escape hatch.

Subheadings: one `####`, "The hardest case: integrate-and-dump" (393).
Labels: **Why.** 374; **Verdict.** 420; bold lead-in **Algebra removes the
reset.** 415.

| # | line | quote | marking | entry | class |
|---|---|---|---|---|---|
| 74 | 366–372 | "Why two leaf classes at all? One all-in-one primitive could carry continuous state, modes *and* discrete state … Class is already read off declaration shape ([§8.5]), so the question is whether the two declaration sets should be exclusive. They are ([D-056])." | plain, cited | D-056 Position log 1682–1684 and Rejected *All-in-one component kind* log 1701; exclusivity: D-263 Position bullet 5 log 10442 and the agreement rule D-112, D-249 (bold §8.2 2932); class D-039 | B: C for the verdict; U by D-263 for "exclusive" |
| 75 | 374 | "**Why.** The split is between *time bases*, not state classes." | label | D-056 Position log 1683 ("the kinds are time bases, sweep-driven vs. tick-driven") | U. A ruling under a **Why.** label |
| 76 | 374–377 | "The continuous primitive is already hybrid, with `m`, guards and handlers ([§3.1]). What separates the classes is sweep-driven versus tick-driven execution." | plain | D-056 Position, same ruling as row 75 | U |
| 77 | 377–382 | "the settled rules force a merged component's two halves to communicate exactly as two siblings do. There is one home per datum ([§5.2]), `x_deriv` sees only the continuous state and `s_update` only the discrete one, and `s⁺` is decoded only at the owner's next tick, because `s_update` runs last." | plain | D-056 Rejected log 1701–1703 ("the halves still communicate through cells — one home per datum, sole-reader `z`, no cross-tier state views"); one home per datum D-035 (bold §5.2 761); `s_update` last D-020 Position log 759–760 (bold §10.6 6324) | R |
| 78 | 382–384 | "That deferred decode is what makes ticks→events structurally impossible and what terminates the boundary iteration ([§10.6])." | plain | D-020 Rejected log 776–777 ("*Event/tick fixed-point iteration:* structurally unnecessary — `z⁺` is invisible until the next tick decode") | R |
| 79 | 384–385 | "Cross-tier influence inside the merged class still routes through published table cells." | plain | D-056 Position log 1684 | U |
| 80 | 385–388 | "The all-in-one component is therefore an assembly of two primitives in a trench coat. It buys no expressiveness and incurs costs of its own, which [D-056] enumerates." | plain, cited | D-056 Rejected log 1701–1704 | R (cited) |
| 81 | 388–391 | "One of those costs is not bookkeeping. The sampling seam, the ZOH and the `z⁻¹` delay, is the most bug-prone boundary in a flight-control stack. A monolith swallows it. The split keeps it a visible wire." | plain | D-056 Rejected log 1705–1706 ("hides the sampling seam") | R |
| 82 | 395–401 | the strapdown IMU's direct formulation, "publishes the sample, and **zeroes them**" | bold words | — | example |
| 83 | 401–407 | the interval forms; "These are exactly the forms the differencing idiom of [§8.6] recovers from the cumulative stores, term by term." | plain | D-056 Position bullet 2 log 1688–1690 | example, pointer |
| 84 | 407–408 | "The reset is periodic, not condition-triggered, so events are the wrong tier." | plain | D-056 Rejected log 1710–1711 ("*Periodic reset via time-guard events:* hand-rolls the tick scheduler") | R. "tier" misused (part F) |
| 85 | 408–411 | "And the reset is a discrete-tier write into continuous state, exactly the operation this design forbids. `s_update` writes only its own `s`, and handlers are the sole resetters of continuous state, guard-driven." | plain | D-056 Rejected log 1707–1709 ("*`z` view in `f` / discrete writes into `x`*"); D-141 Position log 4726 ("A continuous component's state reset is an event") | B: R by D-056; U by D-141 |
| 86 | 412–413 | "Integrate-and-dump falls squarely into the crack between the classes." | plain | — | context |
| 87 | 415–418 | "**Algebra removes the reset.** Every interval-relative integral becomes a cumulative one, and a discrete sampler differences consecutive samples against its latch. [§8.6] spells that idiom, its exactness condition and the resulting assembly in full." | bold lead-in | D-056 Position bullet 1 log 1686–1687; §8.6 3432–3433 bolds "Every interval-relative integral becomes a *cumulative* one" (D-056) | U. Home §8.6 (README carried item): plain here |
| 88 | 420–427 | "**Verdict.** … with *less* code than the direct formulation. It keeps the same thirteen integral scalars … three structural gains … Under a `Dual` activation the discrete tier is held ([§8.2])" | label | — | evidence. The count holds: §8.6's `x_init(::IMUIntegrals)` (3510–3511) declares Θ, q, Υ, V, 3 + 4 + 3 + 3 = 13 scalars |
| 89 | 427–429 | "The framework's rules pushed the model into the only form its own linearization semantics could coherently handle." | plain | D-056 Rejected log 1708 ("breaks held-`z` linearization exactness") | context |
| 90 | 428–433 | "One escape hatch is recorded, unbuilt. If interval-relative dynamics ever neither factor algebraically nor tolerate the latch-back wire, the guarded addition is a **tick-triggered handler** on continuous components (periodic events). No known case needs it ([D-056])." | bold words, cited | D-056 Position bullet 4 log 1693 ("Tick-triggered continuous handlers are the recorded, unbuilt escape hatch"); the conditions bullets 2–3 log 1688–1692 | C. Bold home: no other section bolds it |

Bold homes for D-056, by its Position (one sentence and five bullets): the
sentence (taxonomy upheld; time bases; cross-tier through cells) takes one
bold in §3.4, at row 75's or row 76's headline; bullet 1 (the idiom) is bold
in §8.6, so row 87 goes plain; bullets 2, 3 and 5 are §8.6's (3474, 3480, 3593,
3603); bullet 4 takes its bold at row 90. Two bolds in §3.4, both citing
D-056. §3.3's row 71 points here.

Descriptions that read like rules: rows 77 and 78, whose rulings live in
Rejected lists.

Antecedent hazards: 377 "And the settled rules force"; 382 "That deferred
decode"; 386 "therefore"; 388 "One of those costs"; 412 "Integrate-and-dump
falls"; 425 "And linearization got sane"; 428 "One escape hatch".

Display-block candidates: the interval forms (401–406) are inline math run
into prose; a display block of the four integrals would read better and
changes no claim.

Appendix C kinds cited to §3.4: none. Row 74's "the two declaration sets
should be exclusive. They are" is `DeclarationOnWrongTier`'s condition for a
leaf declaring both update laws (Appendix C 12507–12511), unnamed. Naming it
is optional.

### §4 Ports and signals, heading (437–438, no lead)

The chapter opens straight into §4.1. Its only roadmap is the Part I roadmap
(128–129: "[§4] gives the port, the addressable unit through which components
exchange immutable values"). A one-sentence roadmap naming §4.1–§4.4 would be a
declared addition, as chapter 5's opening was (part G q3).

### §4.1 Immutable value semantics (439–473, 274 words)

Purpose: ports exchange immutable values through a typed signal table; the
binding vocabulary (cell, store, staging cell, root input); the precise signal
requirement; its four consequences.

| # | line | quote | marking | entry | class |
|---|---|---|---|---|---|
| 91 | 441–442 | "Ports exchange **immutable values**, typically isbits structs (floats, `SVector`s, enums, nested immutables)." | bold words | D-004 Position log 403 ("Immutable value signals in a typed signal table"), cited only at 472 for freshness | U. D-004 is bold nowhere: bold home |
| 92 | 442–443 | "The framework owns a **signal table**, with one concretely typed **cell** per output port in the flattened model." | bold words (terms) | D-004 Position, same ruling as row 91; D-162 (per-eltype stores) | U |
| 93 | 443–447 | "A producer's output stage function (…) returns a named tuple of fresh values. The framework writes each of those values into its cell, and consumers read cells." | plain | D-036 Position, first ruling log 1169 | U |
| 94 | 449 | "**Vocabulary.** These names are binding throughout this document." | label | D-121 Position log 3728–3731; D-121 Rejected log 3757–3759 relies on "[§4.1]'s 'throughout this document' rule" | U |
| 95 | 451 | "A bare *cell* is the table entry, and only that." | plain | D-121 Position ("Bare *cell* denotes a signal-table entry only"). D-121 is cited nowhere in the spec | U. Bold home |
| 96 | 452–454 | "A *store* is the framework-owned home of one of a component's state letters, `x`, `s` or `m` ([§7.1], [§7.3], [D-302]). An `x` store is a range of the buffer. Stores are not cells." | plain, cited | D-302 Position log 12750–12754 | C. §7.3 1871 bolds "Discrete state, a discrete leaf's `s`, and the modes `m` live in typed stores" citing D-013 and D-302 |
| 97 | 455–457 | "A *staging cell* is a distinct compound term. It is the per-device inbound register of [§11.4]. Unlike a table cell it is mutated frame by frame, and it sits outside the table's publish-once discipline." | plain | D-121 Position log 3729–3731 | U |
| 98 | 458–459 | "A *root input* is a source cell fed by the periphery rather than by a producer ([§11.3])." | plain | D-206 Position log 7566–7568 (the term); D-208 Position log 7653–7654 | U |
| 99 | 461–462 | "Stated precisely, the signal requirement is **immutability plus frozen references**." | bold words | stated by D-243 Rationale log 9210 ("[§4.1] requires of a port value immutability plus frozen references"); presupposed by D-231 Position log 8691–8692 ("The frozen-reference latitude of [§4.1] stays with signals"); D-237 Position (opaque leaf, references included). No Position states the requirement | R. §7.3 1892 bolds D-231's sentence |
| 100 | 462–464 | "Signals may reference bulk data ([§4.4]) provided that data is read-only for the duration of the run. `isbits` is the common case, not the rule." | plain | D-008 Position; D-237 Position | U |
| 101 | 466–468 | "There is no aliasing, ever. Nothing can be mutated under a consumer's feet." | plain | D-004 Rejected log 410 ("*Shared mutable buffers:* aliasing/staleness, concurrent-read hazards") | R |
| 102 | 469 | "Concurrent reads from the GUI and logging threads are safe by construction." | plain | D-004 Rejected log 410; such readers read the published snapshot, D-023, D-293 Position log 12467–12469 | R |
| 103 | 470 | "Isbits payloads allocate nothing, because named tuples of isbits are isbits." | plain | — | consequence |
| 104 | 471–472 | "Each cell has a definite freshness, tied to its producer's position in the execution order ([D-004])." | plain, cited | D-004 Rejected log 412–414 ("per-cell freshness is tied to the producer's schedule position") | R (cited) |

Bold homes: D-004 once (rows 91–92), D-121 once (row 95). D-302 stays plain
(§7.3 holds a bold citing it; part G q6 asks whether that bold is D-302's or
D-013's). Row 99 is a ruling with no Position; keep plain, or bold it with
D-243's R citation (q6).

Display-block candidates: the vocabulary list stays a list.

Appendix C kinds cited to §4.1: none.

### §4.2 Consumers see ports, not stages (474–491, 163 words)

| # | line | quote | marking | entry | class |
|---|---|---|---|---|---|
| 105 | 476 | "The port is the addressable unit." | plain | D-036 Rejected log 1183 ("the port stops being the atomic unit"), D-276 Rejected log 11655 | R |
| 106 | 476–477 | "A component's outputs appear to consumers, the GUI and logs as one flat namespace of ports (`dyn.vel`, `dyn.f_c_c`)." | plain | D-040 Position log 1282 (slash-string paths, "one canonical form shared by declarations, diagnostics, devices and logs") | U; the example spells the dotted path form D-040 rejects (F8) |
| 107 | 477–480 | "A reader reaches a leaf inside a port value through the port's leaf address (the field name with dotted and bracketed steps below it, [§14.4])." | plain | D-276 Position log 11558–11560 | U (cited at 537, §4.3) |
| 108 | 480–481 | "Which output stage computes which port is an ordering annotation, invisible outside the component." | plain | D-033 Position log 1066 ("stage membership derived …, no stage tags") and Rejected log 1100 ("stage membership is internal, [§4.2]"). §8.2 2884 bolds "No port carries a stage tag, and stage membership …" (D-033) | U. Home §8.2 |
| 109 | 481–483 | "Moving an output between stages is non-breaking *for consumers*. No wire, log or panel sees it. The build does see it, because the feedthrough graph and stage membership change ([§9.1])." | plain | — | consequence |
| 110 | 485–486 | "**Visibility.** Which ports exist at all is a declaration-layer decision. The output contract *is* the public interface." | label | D-034 Position log 1106 ("declared = public"); §8.3 2967 bolds "Visibility is decided by *where the value goes*" (D-034) | U. Home §8.3 |
| 111 | 486–488 | "There are no private intermediates. A value a later function needs is a declared port like any other, and a stage result outside the contract is a build error ([§5.2], [§8.3])." | plain | D-194 Position log 7058–7060; the build error D-034 Position log 1109 ("undeclared stage-return fields = build error"). Kind `UndeclaredReturnField` (Appendix C 12580, cited to §8.3) | U; kind unnamed |
| 112 | 488–490 | "A presentational *unlisted* flag, skipped in logs and GUI but still connectable, is closed ([D-016])." | plain, cited | D-034 Rejected log 1126–1127 ("*`unlisted` presentational flag:* hidden but connectable"); the cited D-016 holds it only in a *Superseded position* item (log 639–643) | R (cited to the less direct entry). §8.3 3024–3025 points here for it |

No bold belongs in §4.2: every ruling it states is bold in §8.2 or §8.3, or
lives in a Rejected list. The section stays as the reader-facing statement,
because §8.3 3025 and §11.2, §14.4 rows point at it (part D).

`run_ports.jl` confirms two of these claims against the package:
a returned field outside `y_types` is `UndeclaredReturnField`, and a port
produced by both stages is `ProducedByTwoStages` (part C, "Code blocks").

Appendix C kinds cited to §4.2: none. `UndeclaredReturnField`'s condition is
stated at 488 unnamed.

### §4.3 Table mechanics and port granularity (492–601, 911 words)

Purpose: ports against faces; the port as the periphery's atom; scatter and
gather; what a port may hold; granularity on the read side and on the write
side.

Subheadings (`####`): "Ports and faces" (500), "Scatter and gather" (513),
"What a port may hold" (530), "Granularity, read side" (555), "Granularity,
write side" (585). Labels: **Rule.** 509, 557, 589; **Granularity
guideline.** 566; **Example.** 574; **Write-side rule.** 587. One `julia`
block (577–583). The opening (494–498) names four questions, which match the
five subheadings once the two granularity subheadings are read as one answer.

| # | line | quote | marking | entry | class |
|---|---|---|---|---|---|
| 113 | 494–498 | "[§4.2] fixed the port as the addressable unit. Four questions remain. …" | plain | — | context (roadmap) |
| 114 | 502–505 | "A component's **ports** are its signal endpoints, one cell and one producer each. Its **faces** are the names those ports wear on the component's boundary. For a leaf the two coincide. For an assembly every face aliases an interior port through its boundary declarations ([§8.6]) and never creates an endpoint." | bold words (terms) | D-172 Position log 6220–6228. D-172 is cited nowhere in the spec | U. Bold home |
| 115 | 505–507 | "The distinction is kind-blind. Wiring and the periphery address a child's faces without knowing whether it is primitive or composite." | plain | D-172 Position ("kind-blind", "without knowing whether it is primitive or composite") | U, same ruling as row 114. "kind" is the word D-122 retired for this sense (F9) |
| 116 | 509–511 | "**Rule.** The port is the atomic unit of the entire periphery. It is one cell, one root input, one staged write, one device claim ([§11.3]), one trace address and one GUI liveness verdict ([§11.7])." | label | D-045 Rejected log 1436–1438 ("the port is the periphery's atomic unit on the write side too, [§4.3]"); D-036 Rejected log 1183 (wiring); D-172 Position calls it "[§4.3]'s periphery atom" | R. Bold candidate with an R citation |
| 117 | 515–519 | "**Scatter/gather is the whole protocol.** A stage function (…) returns a named tuple. The framework scatters each field into that port's concretely typed cell. Every reader gathers views from cells. The readers are the next stage, `x_deriv`/`s_update`, guards, wired consumers and snapshot capture." | bold sentence | D-036 Position first ruling log 1169; D-035 Position (views) | U |
| 118 | 521–526 | "**The aggregate `y` is a merge semantically and virtual physically.** Semantically, a component's `y` is the merge of its stage products, `merge(y_x, y_xu)` … and `merge(y_s, y_su)` … It carries declared ports only. Physically no such object exists. `y` is reconstructed per call from cells … and is never stored as an object." | bold sentence | D-036 Position second ruling log 1170 ("aggregate `y` = virtual merge, gathered per call, never stored") | U. Bold home (D-036 is bold nowhere). `y_xu`, `y_su` are §5.2's signature-block names (703–709), not bundle fields |
| 119 | 528 | "Name collisions across a component's stages are a build error." | plain | D-252 Position sentence 1 log 9665–9666; §8.3 2992 bolds "A declared port must be produced by exactly one stage" (D-252). Kind `ProducedByTwoStages`, whose Appendix C row (12570) cites §4.3 | U; kind unnamed |
| 120 | 532 | "**Stage returns are named tuples of port values, period.**" | bold sentence | D-036 Position first ruling log 1169 | U. Bold home. §5.2 833 bolds D-194's "An output stage returns its port NamedTuple, `y`, and nothing else", a different entry's ruling (no `w` channel) |
| 121 | 532–534 | "A custom struct is a first-class port *value*. It is one field of the returned tuple, one declared port, one cell (`pose = KinPose{T}`). Nested fields get no cells of their own." | plain | D-036 Position third ruling log 1170–1171 ("custom structs are port values — one port, one cell, atomic in wiring"); nested D-036 Rejected log 1185–1186 | U (R for the last sentence) |
| 122 | 535–537 | "A reader reaches one through the port's leaf address (…), `"pose.q_eb"` ([§14.4], [D-276]), and a wired consumer takes the bundle whole." | plain, cited | D-276 Position log 11558–11560; "takes the bundle whole" D-036 third ruling ("atomic in wiring") | C |
| 123 | 537–538 | "Bare-struct returns are rejected ([D-036])." | plain, cited | D-036 Rejected log 1179–1182 | R (cited) |
| 124 | 540–541 | "A port value's leaves are what the leaf walk reaches through `Real`s, static arrays and isbits structs." | plain | D-237 Position log 8950–8951 | C (adjacent, cited at 553) |
| 125 | 541 | "An enum is one leaf, pinned ([§8.2])." | plain | D-316 Position bullet 1 log 13404–13405 ("An enum is one leaf of its own eltype, pinned at every activation", citing [§4.3]) | U |
| 126 | 542–545 | "`StopFlag` is the one enum with a framework meaning. An output port of that type is a stop request (…), and a `StopFlag` nested in a port of another type or declared as a root input is refused (`IllegalPortType`, [§13.5], [D-316])." | plain, cited | D-316 Position bullets 1–2 log 13406–13412; §13.5 9810 and 9821 bold both | C. Home §13.5 |
| 127 | 545–548 | "The walk stops at an immutable type that is not isbits and treats it as one opaque leaf (a leaf the table stores whole, references included). That leaf is the field handle ([§4.4])." | plain | D-237 Position log 8951–8953 | C (adjacent). "That leaf is the field handle" (F10) |
| 128 | 548–551 | "A `Symbol` is an opaque leaf too. … so a `Symbol` mode publishes like any other ([D-243])." | plain, cited | D-243 Position log 9202–9204 | C. D-243 is bold nowhere: bold home |
| 129 | 551–553 | "A mutable type anywhere in a port value is refused, and so is an opaque leaf surfacing as a root input, which has no synthesis (`IllegalPortType`, [D-237])." | plain, cited | D-237 Position log 8954–8956; D-243 Position log 9205–9206 | C. §9.5 4790 bolds D-237's identity clause only, so this clause's bold is here |
| 130 | 557 | "**Rule.** Wiring is port-granular. There are no sub-field connections." | label | D-276 Position last bullet log 11611 ("Wiring stays port-granular ([§4.3])"); D-036 Rejected log 1183 (*Sub-field wiring*) | U. Bold home (D-276 is bold nowhere; its leaf-address ruling belongs to §14.4) |
| 131 | 557–561 | "A consumer that wants less than a bundle takes the bundle and destructures it, in its own stage or through an unbundling component (…), or asks the producer for a loose port ([D-276])." | plain, cited | D-276 Position last bullet log 11611–11613; the loose port D-276 Rejected log 11649–11651 ("kept as an optimization for a known hot field") | C |
| 132 | 561–564 | "A field-projection connector is a guarded addition (…). Its shape is obvious, and it is not built." | plain | D-036 Rejected log 1183–1184 ("field-projection connector kept as guarded addition") | R |
| 133 | 566–567 | "**Granularity guideline.** Authors should bundle what *shares a stage* *and is consumed together*." | label | D-036 Position fourth ruling log 1171–1172 ("granularity guideline: bundle what shares a stage and is consumed together") | U. Bold candidate: a Position ruling worded as a guideline |
| 134 | 567–568 | "The first criterion is trivially enforced, because each port has exactly one producing function." | plain | D-252 Position sentence 1 | consequence |
| 135 | 568–570 | "Bundling across dependency footprints is the classic mistake. A kinematics bundle mixing pose, which is stage 1, with velocity-derived quantities, which are stage 2, must split." | plain | D-036, D-252 | example |
| 136 | 570–572 | "Fan-out is free, so publishing both a bundle and a hot loose field (`pose` *and* `q_eb`) is legitimate. It costs one extra isbits cell." | plain | "Fan-out is free": none (`pending.md` 97 lists chapter 6's "local fan-out is free" as an owner item with no live entry). The loose field: D-276 Rejected log 11649–11651 | N for the first clause (owner's open item: stays uncited, no entry proposed); R for the loose field |
| 137 | 574–583 | "**Example.** The sketch below shows the bundle, the loose hot field and a face aliasing an interior port, in declaration form." and the block | label, code | — | code (part C) |
| 138 | 587 | "**Write-side rule.** **Bundle what is written together.**" | label, bold sentence | D-045 Rejected log 1436–1440 | R |
| 139 | 589–590 | "**Rule.** Data written by different external writers, or at different cadences, must not share a port." | label | D-045 Rejected log 1436–1438 ("kills per-field claiming, liveness and trace tag"); D-207 Rejected log 7642–7643 and D-299 Position log 12664–12666 lean on it ("collides with [§4.3]'s write-side granularity") | R. Rows 138 and 139 are one ruling: one bold |
| 140 | 592–595 | "Pilot commands are the case in point. They are scalar faces under a namespace prefix. The convenient bundle is assembled *downstream* … by an ordinary component. That is legal by the read-side guideline …" | plain | D-045 Rejected log 1438–1440 ("the namespace prefix plus `input_passthrough`") | example |
| 141 | 597–599 | "The guideline and the rule compose into one principle. A port's granularity is set by the finest-grained party owning either end, producers on the read side and external writers on the write side." | plain | none | N (a synthesis of rows 133 and 139) |
| 142 | 599–600 | "Field-addressed staging (a lens into struct slots) stays a recorded guarded addition, unbuilt." | plain | none (grep of "lens", "field-addressed" over the log: only D-066's unrelated `Getter{P}` lenses, log 1964). The glossary's *guarded addition* (13894) cites §4.3 for it | N. "recorded" with no record in the log |

Bold, one per ruling, for §4.3: D-172 (row 114), D-036's four rulings (rows
117 or 120 for the first, 118, 121, 133), D-237's walk and refusal (rows 124
or 127, and 129), D-243 (row 128), D-276's last bullet (row 130), and the R
rulings at rows 116 and 138–139 (D-045's Rejected list). D-316 (row 126) and
D-252 (row 119) stay plain. Part G q6.

The section mixes three registers: the table's protocol (513–528), the port
value's leaf walk (530–553, written after D-237, D-243 and D-316 landed), and
granularity advice (555–600). It is the longest section of the run.

Display-block candidates: the periphery atom (509–511) as a list: one cell,
one root input, one staged write, one device claim, one trace address, one GUI
liveness verdict.

Appendix C kinds cited to §4.3 (Appendix C 12548, 12570):

| kind | condition stated in §4.3? | named? |
|---|---|---|
| `IllegalPortType` | yes, 545 (`StopFlag` placements) and 551–553 (mutable, opaque leaf at a root input) | yes, twice |
| `ProducedByTwoStages` | yes, 528 ("Name collisions across a component's stages are a build error") | no |

### §4.4 Function-valued signals: environment access (602–671, 573 words)

Purpose: environment models are query-shaped, so ports carry immutable query
objects (field handles); parametric against bulk-data handles; no mutable
caches; the value-level constructor; pre-sampling; abstract input entries.

Subheadings: none. Labels: **The value-level constructor.** 626 (bold
lead-in with a link); **Example.** 646. One `julia` block (649–655).

| # | line | quote | marking | entry | class |
|---|---|---|---|---|---|
| 143 | 604–607 | "Atmosphere and terrain are **query-shaped**. Consumers evaluate them at arguments of their own choosing … Ordinary ports therefore carry them as **immutable query objects**, called field handles." | bold words | D-008 Position log 477 ("Function-valued environment signals + handle pattern"), cited at 660 only for resource injection | U. D-008 is bold nowhere: bold home |
| 144 | 609–613 | the environment component emits a field value; consumers receive it through ordinary input ports and call query functions on it | plain | D-008 Position | U (mechanism) |
| 145 | 614–619 | "**Parametric models are isbits** (…). **Bulk-data models use the handle pattern.** The handle is an immutable struct combining isbits parameters with references to bulk data (…) loaded at build time and frozen. Handles are rebuilt per evaluation without allocation … They are never `Ref`s, whose mutable cell allocates." | bold lead-ins ×2 | D-008 Position ("handle pattern"); D-237 Rationale log 8960–8963 restates the boundary | U, same ruling as row 143 |
| 146 | 620–623 | "**No mutable caches inside field objects**, such as memoizing interpolators or lazy loaders. Concurrent consumers and the GUI thread would race on them. Caches belong in the consumer's state, or the interpolant is restructured to be pure." | bold lead-in | the refusal: D-237 Position log 8954 ("A mutable type anywhere in a port value is refused"). "Caches belong in the consumer's state": none, and three later Positions leave it no home (F11) | B: U by D-237 for the refusal; the remedy conflicts with D-231, D-183 and D-342 |
| 147 | 624 | "Loggers treat field-handle signals specially. They skip or summarize them." | plain | none (grep of "summar", "skip or" over the log: none). §7.5 2103 calls it "The summarize-or-skip rule ([§4.4])" | N |
| 148 | 626–629 | "**The value-level constructor.** Every field-emitting component must expose the map (component, input values) → handle as a plain, pure, public function. For the `SimpleAtmosphere` successor that function is `atmospheric_field(atm; T_sl, p_sl, wind)`." | bold lead-in | D-139 Position log 4575–4578. D-139 is cited only in §14 (11014, 11337) | U |
| 149 | 629–631 | "The field-emitting component's swept output stage must be a **one-line call to that function**, never the other way round. The other way round puts the query math in the output stage, where only a sweep can reach it." | bold words | D-139 Position log 4577–4579 | U. One ruling with row 148: one bold, D-139's home |
| 150 | 633–636 | "The reason is script-side. The condition math ([§14.1]) must be able to construct, outside any sweep, bit-for-bit the same handle the sweep would produce from the same root input values. One implementation serves two call sites, so there is no drift." | plain | D-139 Position (its "because" clause) and Rationale log 4590–4595 | reason |
| 151 | 636–637 | "The drift avoided here is the silent-drift class that [§5.3] exists to kill." | plain | D-139 Position log 4582–4583 (same words). §5.3 945–948 now names the drift class (D-015, D-342 bullet 3) but holds more than that | pointer; "exists to kill" overstates §5.3 (chapter 5's survey part D listed this row) |
| 152 | 637–639 | "This is a *shipped component's obligation*, not something a consumer can retrofit. The real component composes sub-models, and anyone else reconstructing the map has re-created the drift class." | plain | D-139 Position log 4579–4583 | U |
| 153 | 641–644 | "For bulk-data components the obligation is only that the query math be reachable as a plain function. … That cost is acceptable, because condition authoring is design-time code." | plain | D-139 Rationale log 4587–4589 | R |
| 154 | 646–655 | "**Example.** The sketch below shows the map as a plain function, and the stage that does nothing but call it." and the block | label, code | — | code (part C) |
| 155 | 657–659 | "Pre-sampling is an **idiom built on top**, used where natural, not a separate mechanism. In it, a component consumes the field and a pose and emits plain data, as `Airflow` emits `AirData` for the whole vehicle." | bold words | D-008 Rejected log 485 ("*Pre-sampling as mechanism:* dependency inversion at struts") | R |
| 156 | 659–660 | "Resource injection (declare-and-resolve service registries) is closed for the first cut ([D-008])." | plain, cited | D-008 Rejected log 484 ("*Resource injection:* second composition mechanism, invisible"); D-139 log 4657–4659 calls it "rejected" | R (cited). "for the first cut" hedges a rejection no entry limits in time |
| 157 | 662–663 | "The field-handle mechanism replaces threading `atmosphere`/`terrain` as arguments through every update signature." | plain | D-008 Position; `flight_case_studies.md` 33 states the same contrast | context (a FlightCore contrast) |
| 158 | 663–664 | "It dovetails with the terrain ray-query direction of the landing-gear redesign." | plain | none | context; reader-cold, and a plan rather than a design fact (part F) |
| 159 | 664–666 | "Substitutability behind a stable face is declared with an abstract input entry, `terrain = AbstractTerrainField`, which is structural substitutability ([§8.2])." | plain | D-296 Position bullet 1 log 12551–12553 ("Abstract entries state structural substitutability, as [§4.4]'s field handles use them"), bold §8.2 2560 | U. Home §8.2 |
| 160 | 666–668 | "The consumer wires to any concrete field type below the bound. That preserves today's `AbstractTerrain` polymorphism at the declaration layer." | plain | D-078 Position log 2390–2392 (`producer_face <: entry`) | U. "today's `AbstractTerrain`" is FlightPhysics' (`lib/FlightPhysics/src/terrain.jl` 26) (part F) |

Bold homes: D-008 (row 143) and D-139 (rows 148–149), one each. Both are
bold nowhere in the spec today. Row 146's refusal is D-237's, bold at row 129
in §4.3: plain here with a pointer.

Display-block candidates: the existing block.

Appendix C kinds cited to §4.4: none. Row 146 restates `IllegalPortType`'s
mutable-type condition without naming it; a pointer to §4.3 covers it.

### Tally

Each counted row is classed by its first code. Left out: the 25 rows that are
context, reasons, examples, evidence, consequences, pointers or code (2, 17,
28, 38, 41, 46, 67, 70, 82, 83, 86, 88, 89, 103, 109, 113, 134, 135, 137, 140,
150, 151, 154, 157, 158). Chapter 1's 14 O rows are counted apart.

| section | rules | C | U | S | R | N | B |
|---|---|---|---|---|---|---|---|
| §1 | 3 (+14 O) | 0 | 0 | 0 | 0 | 3 | 0 |
| §2 lead | 6 | 0 | 6 | 0 | 0 | 0 | 0 |
| §2.1 | 13 | 1 | 7 | 0 | 4 | 0 | 1 |
| §2.2 | 5 | 2 | 1 | 0 | 0 | 0 | 2 |
| §3 lead | 1 | 0 | 1 | 0 | 0 | 0 | 0 |
| §3.1 | 11 | 0 | 8 | 0 | 1 | 0 | 2 |
| §3.2 | 7 | 1 | 4 | 0 | 0 | 0 | 2 |
| §3.3 | 5 | 1 | 3 | 0 | 0 | 0 | 1 |
| §3.4 | 12 | 1 | 4 | 0 | 5 | 0 | 2 |
| §4.1 | 13 | 1 | 8 | 0 | 4 | 0 | 0 |
| §4.2 | 7 | 0 | 5 | 0 | 2 | 0 | 0 |
| §4.3 | 25 | 7 | 10 | 0 | 5 | 3 | 0 |
| §4.4 | 13 | 0 | 8 | 0 | 3 | 1 | 1 |
| total | 121 (+14 O) | 14 | 65 | 0 | 24 | 7 | 11 |

No superseded entry is cited: all 13 cited entries have status `ratified`
(`scratch_survey/titles.txt`). D-016, cited at 490, is superseded in part (its
annotation, log 633–636); the run cites it only for the `unlisted` rejection,
which its annotation does not touch, though D-034 states that rejection more
directly (row 112).

Against chapter 5 (103 rules, C 14, R 26, N 7): about one rule in nine is cited
where it stands (14 of 121), and one in five lives only in a Rationale,
Rejected list or annotation (24). The U rows (65, more than half) cluster in
entries the run never cites: D-003 (the taxonomy), D-121 and D-172 (the
vocabulary of cells and faces), D-139 (the value-level constructor), D-082 (the
predicate and edges), and D-036, D-237 and D-008, which the run cites only for
side clauses. The R rows cluster in D-056's Rejected list (§3.4), D-004's
Rejected list (§4.1), D-045's Rejected list (the write-side rule and the
periphery atom) and D-220's Rationale (time and state events). Seven rules have
no entry: the five design criteria and the guarded-addition rule (row 10), the
document's status and the entry-number rule (rows 18, 19, process), fan-out is
free (row 136, the owner's open item), the composed granularity principle (row
141), field-addressed staging as a "recorded" guarded addition (row 142), and
the loggers' skip-or-summarize rule (row 147).

### Bold, one per ruling

Today: 3 **Rule.**, 2 **Why.**, 2 **Example.** labels, 11 other labels, and
76 bold spans in all (about 210 words); only 2 carry a D-citation. The table
proposes where each ruling the run states takes its one bold, after checking
every bold span in the spec (`scratch_survey/bold_spans_all.tsv`) for the same
entry. Semicolons separate rulings in old entries (chapter 5's lesson 34).

| section | entry | ruling | where |
|---|---|---|---|
| §2 lead | D-001 first ruling ("Hybrid causal formalism") | the framework simulates hybrid causal systems | row 20, 215; D-002 cited beside it |
| §2 lead | D-001 third ruling ("projection") | the formalism includes post-step projection | row 24, 222. §5.3 1019 bolds D-016's ruling on its positions, a different ruling |
| §2.1 | D-001 second ruling ("two-tier events") | one declaration, two detection policies | row 26, 232 |
| §2.1 | D-082 first ruling | a guard defines a predicate, positive = holding | row 36, 259–262 (today two bold spans; one headline clause) |
| §2.1 | D-082 second ruling | events fire on not-holding → holding edges against the prior | row 37, 264 |
| §2.1 | D-220 Rationale (R) | ticks are time events; a declared `StateEvent` is a state event; the criterion is detection against scheduling | row 31, 247, optional (q6); the log owes a Position |
| §2.2 | D-001 fourth ruling ("no DAE/SDE/per-step hook") | the three exclusions | one bold, on row 42's headline or a context sentence naming all three |
| §3 lead | D-003 first ruling | three classes: two leaves and the assembly | row 48, 298 |
| §3.1 | D-003 second ruling | one primitive supports both factorings of mode logic | row 56 (with "therefore" removed) or row 58 |
| §3.2 | D-195 Position | the discrete state has its own letter `s` | row 63, 337 (rule first, before the reasons) |
| §3.2 | D-231 annotation (R), D-249 bullet 1 | `m` is continuous-only; a discrete component has no mode store | row 66, 346; the log owes a Position |
| §3.4 | D-056 Position sentence | the two kinds are time bases; cross-tier coupling routes through cells | row 75 or 76 |
| §3.4 | D-056 Position bullet 4 | tick-triggered continuous handlers are the recorded, unbuilt escape hatch | row 90, 431 |
| §4.1 | D-004 Position | immutable value signals in a typed signal table | row 91, 441 |
| §4.1 | D-121 Position | bare *cell* means a table entry only (and the staging cell is a distinct compound) | row 95, 451 |
| §4.3 | D-172 Position | ports are endpoints, faces are their boundary names, class-blind | row 114, 502 |
| §4.3 | D-036 first ruling | stage returns are NamedTuples of port values | row 120, 532 |
| §4.3 | D-036 second ruling | aggregate `y` is a virtual merge, gathered per call, never stored | row 118, 521 |
| §4.3 | D-036 third ruling | a custom struct is one port, one cell, atomic in wiring | row 121, 532 |
| §4.3 | D-036 fourth ruling | granularity guideline | row 133, 566 |
| §4.3 | D-237 Position sentence 1 | the walk stops at a non-isbits immutable type: one opaque leaf | row 127, 545 (or 124) |
| §4.3 | D-237 Position sentence 3 | a mutable type anywhere is refused, and so is an opaque leaf at a root input | row 129, 551. §9.5 4790 bolds sentence 2 |
| §4.3 | D-243 Position | a `Symbol` is an opaque port leaf | row 128, 548 |
| §4.3 | D-276 Position last bullet | wiring stays port-granular | row 130, 557 |
| §4.3 | D-045 Rejected (R) | the port is the periphery's atomic unit | row 116, 509, optional (q6) |
| §4.3 | D-045 Rejected (R) | write-side rule: data from different writers or cadences never share a port | rows 138–139, one bold; the log owes a Position |
| §4.4 | D-008 Position | environment signals are function-valued, carried as immutable handles | row 143, 604–607 |
| §4.4 | D-139 Position | the value-level constructor; the stage is a one-line call to it | row 148 or 149 |

Not bold, each for the reason given: D-179 (§10.4 5415, row 40), D-080 (§10.7
6383, row 30), D-019 (§10.5 5870, rows 72–73), D-302 (§7.3 1871, row 96), D-231
for the PRNG (§7.3 1975, row 44), D-033 (§8.2 2884, row 108), D-034 (§8.3 2967,
rows 110–112), D-194 (§5.2 833, row 111), D-252 (§8.3 2992, row 119), D-316
(§13.5 9810, 9821, row 126), D-296 (§8.2 2560, row 159), D-056 bullet 1 (§8.6
3432, row 87, the README's carried item), D-006 (§5.2 696, row 53), D-035
(§5.2 761, row 77), D-154 (§10.6 6219, row 54). Chapter 1 takes none. About 25
bolds against 18 labels and 76 spans today, plus up to four optional R bolds
(rows 31, 69, 99, 116).

## B. Overlaps

### Inside the run

1. **The formalism's equations.** §2 217–218 and §3.1 308, §3.2 333 state the
   same `f` and `g`. Each section needs its own; both stay. A correction to one
   (F3) applies to all three.
2. **Projection.** §2 222–226 (the hook, its positions, its uses), §2.2
   277–278 and 287 (covers manifolds and quaternion renormalization), §3.1 313
   (an optional facet). Distinct facts; F2 applies at 223 only.
3. **Boundary-detected events glossed twice.** §2.1 235–240 and §2.2 288–290
   ("checked for edges at step boundaries only, no root-finding"). Per-section
   glosses; both stay.
4. **No component reads another's state.** §3.2 342 and §3.4 377–381 (the
   merged component's halves). The §3.4 statement is the argument's premise;
   §3.2 states the rule. Both stay; §3.4 can point back.
5. **Cross-tier coupling through signals.** §3.2 342–344 ("only through
   signals") and §3.4 384–385 ("routes through published table cells"). One
   ruling (D-056's sentence): bold once, in §3.4 (part A); §3.2 plain.
6. **The integrate-and-dump verdict.** §3.3 359–360 announces it, §3.4 states
   it. §3.3 is a pointer and stays one.
7. **Ports as the unit.** §4.2 476 ("The port is the addressable unit"), §4.3
   494 ("[§4.2] fixed the port as the addressable unit") and §4.3 509–511 (the
   periphery atom). One R ruling; the bold, if any, at 509 (q6).
8. **The leaf address glossed twice, verbatim.** §4.2 478–480 and §4.3
   535–537 carry the same gloss ("the field name with dotted and bracketed steps
   below it"). Per-section glosses, so both may stay, but §4.3's sentence
   restates §4.2's; the rewriter may keep §4.3's example (`"pose.q_eb"`) and
   point back.
9. **Stage function glossed three times.** §4.1 444–445, §4.3 515–516, §4.4
   611 each gloss `y_state`/`y_direct`. Per-section; fine. The §4.1 gloss says
   "the two output stages every component provides", which an assembly does
   not (§5.2 696 says the same; no change here).
10. **Bulk data by reference.** §4.1 461–464 (frozen references) and §4.4
    614–619 (the handle pattern). §4.1 states the requirement, §4.4 the
    mechanism. Both stay.
11. **Mutable things refused in ports.** §4.3 551 (refused, `IllegalPortType`)
    and §4.4 620–623 (no mutable caches inside field objects). One ruling
    (D-237 sentence 3), bold in §4.3; §4.4 plain with a pointer.
12. **The guarded-addition gloss.** §1 168 (linked, unglossed), §3.4 431
    (linked), §4.3 562–564 (glossed). First gloss lands in §4.3; §1's first use
    should carry it (part F).

### Other chapters

| content | chapters 1–4 | elsewhere | home |
|---|---|---|---|
| detection policy by the guard's return type | §2.1 269–271, bold | §10.4 5415, bold (D-179) | §10.4. §2.1 plain, citing D-179 and pointing there |
| detection independent of pacing | §2.1 245 | §10.7 6382–6383, bold (D-080) | §10.7 |
| the predicate, positive = holding | §2.1 259–262, bold | §10.6 6109–6110 ("The predicate is the one [§2.1] defines"), §10.4 5433–5435, glossary 13237 | §2.1 (D-082 bold here) |
| edge semantics and the prior | §2.1 264–266 | §10.6 6102–6108 (D-181's three conditions, bold), 6176–6178 (prior update, plain, D-082) | §2.1 for the edge (D-082); §10.6 for the prior's bookkeeping and the firing condition |
| time events and state events | §2.1 247–253 | glossary 13266–13298; D-220's Rationale | §2.1 |
| RNG values in `s`, deterministic replay | §2.2 282–285, bold "deterministic replay" | §7.3 1974–1979, bold (D-231), citing §2.2 back for replay | §7.3 for the PRNG idiom; §2.2 for the exclusion and the guarantee |
| no per-step hook | §2.2 286–292 | §10.6 6116–6121 (cites §2.2 for the reason it does not give) | §2.2 |
| the continuous reset is an event (the gear regulator) | §2.2 290–292 | §5.3 1089–1099, bold (D-141); Appendix A 11815 | §5.3. §2.2 points there |
| continuous state's shape | §3.1 305 | §7.1 1688–1691, bold (D-094) | §7.1 |
| discrete state's shape | §3.2 332 | §7.3 1880, bold (D-231) | §7.3 |
| `m` continuous-only | §3.2 346, bold | §5.2 810–811 (plain), §8.2 2932 (bold agreement rule, D-112, D-249), glossary 12926 | §3.2 for "no mode store" (R); §8.2 for the agreement check |
| one letter per tier | §3.2 337–341 (D-195) | §8.2 2925–2927, 2943 (D-195 cited, plain) | §3.2 (D-195 bold nowhere) |
| assembly has no dynamics, virtual for execution | §3.3 357, 360 | §10.5 5870, bold (D-019); §8.5 3105 ("no state of their own", plain) | §10.5 for execution; §3.3 plain |
| class read off declaration shape | §3.4 370 | §8.5 3080–3090 (D-039, bold) | §8.5 |
| integrate-and-difference idiom | §3.4 415–418, bold lead-in | §8.6 3428–3436, bold (D-056 bullet 1) | §8.6 (README's carried item) |
| one home per datum | §3.4 379 | §5.2 761, bold (D-035) | §5.2 |
| store, cell, staging cell vocabulary | §4.1 449–459 | §7.3 1871–1877 (D-302 bold, D-013), glossary | §4.1 for the vocabulary (D-121 bold here) |
| frozen-reference latitude | §4.1 461–464 | §7.3 1892, bold (D-231) | §4.1 states the signal requirement; §7.3 says stores do not get it |
| stage membership invisible outside | §4.2 480–483 | §8.2 2884, bold (D-033) | §8.2 |
| visibility, no private intermediates, `unlisted` | §4.2 485–490 | §8.3 2967–3025 (D-034 bold), §5.2 833 (D-194 bold); §8.3 3025 points to §4.2 for `unlisted` | §8.3; §4.2 keeps the `unlisted` sentence |
| ports and faces | §4.3 500–507 | §8.6 3263–3265 (face glossed), glossary 13002 | §4.3 (D-172 bold here) |
| one producer per port | §4.3 528 | §8.3 2992, bold (D-252) | §8.3; §4.3 names the kind |
| leaf address | §4.2 477–480, §4.3 535–537 | §14.4 (not rewritten) | §14.4 |
| enum one leaf, `StopFlag` | §4.3 541–545 | §13.5 9810, 9821 (bold, D-316) | §13.5 |
| opaque leaf | §4.3 545–553 | §9.5 4790 (bold, D-237 identity clause), §6.1 1442–1448, §7.3 1887 | §4.3 for the walk and the refusal |
| wiring port-granular | §4.3 557–564 | glossary 13032 | §4.3 |
| granularity guideline | §4.3 566–572 | §5.4 1156 ("the mitigating idiom is the granularity guideline ([§4.3])") | §4.3 |
| write-side rule | §4.3 587–600 | §8.8 3890, §9 4488 lean on it | §4.3 |
| field handles, value-level constructor | §4.4 | Appendix A 11789–11794, glossary 13072, §14.1 | §4.4 (D-008, D-139 bold here) |
| abstract input entry for terrain | §4.4 664–668 | §8.2 2560–2563, bold (D-296) | §8.2 |
| fused evaluation drift class | §4.4 636 | §5.3 945–948 (D-015, D-342) | §5.3 |

No passage in chapters 1 to 4 should be trimmed to a pointer at a rewritten
chapter. Each overlap above is either a home here, or a short statement whose
outside citations rely on it (part D: §4.2's `unlisted` sentence, §3.1's
"externalized FSM", §2.2's replay). The two places where the earlier statement
duplicates a later bold verbatim (§2.1 269 against §10.4 5415; §3.4 415
against §8.6 3432) lose their bold and keep their sentence.

## C. Proposed structure

No section is renumbered or retitled at the `###` level. Every `####` slug in
the run was checked for outside links (`git grep` at `d3af35a` over `docs/`
for `#the-hardest-case`, `#ports-and-faces`, `#scatter-and-gather`,
`#what-a-port-may-hold`, `#granularity-read-side`, `#granularity-write-side`):
none, so retitling a subheading is free.

### Moves

| move | content | from | to | needs a ruling |
|---|---|---|---|---|
| M1 | chapter 1's five bold lead-ins become `####` subheadings or plain topic sentences; the five criterion names lose their bold | §1 141–194 | in place | yes, q2 |
| M2 | a roadmap sentence for §2 (naming §2.1 and §2.2), for §3 (naming §3.1–§3.4 and that §3.4 justifies the split) and an opening for chapter 4 (naming §4.1–§4.4) | new, declared additions drawn from the Part I roadmap 124–129 and the section titles | the heads of §2, §3 and §4 | yes, q3 |
| M3 | the predicate and edge semantics (259–267), with the return-type paragraph (269–273), move up before the two policies (235–243), so "holding", "edge" and "prior" are defined before the boundary-detected bullet uses them (236) | §2.1 259–273 | after 232–233 | yes, q4 |
| M4 | §3.2's letter paragraph puts its ruling first: "Each tier carries its own state letter" and the D-195 citation open it, the reasons follow, "So they are spelled differently" goes | §3.2 337–341 | in place | no (style rule "Rule first, reason after") |
| M5 | §3.4's "**Algebra removes the reset.**" becomes a plain topic sentence pointing at §8.6 | §3.4 415–418 | in place | no (README carried item, bold rule) |
| M6 | §4.4's mutable-cache bullet points at §4.3's refusal instead of restating it | §4.4 620–623 | in place | only with q8 (F11) |

All moves stay inside their section and inside one rewrite unit.

### Order within each section

Define-before-use was checked for each order below against the terms each block
uses.

- **§1.** Purpose, capabilities, design criteria, origins, scope (unchanged).
  The capabilities use "feedthrough", "execution order", "snapshot", "trace"
  and `Model` before they are defined; as an overview each points at its
  chapter, which suffices. "guarded addition" (168) takes its gloss here, not
  first in §4.3.
- **§2.** Lead with roadmap (M2); five parts. §2.1: one declaration (232–233);
  the predicate, edges and opposite direction (M3, 259–267); the return type
  decides the policy (269–273, plain, pointing at §10.4); the two policies
  (235–243); pace-independence (245); "the crossing defines the transition"
  (255–257); time and state events (247–253). Placing the time/state paragraph
  last removes row 35's antecedent hazard ("This arrangement" then follows the
  policies it names). §2.2 unchanged.
- **§3.** Lead with roadmap (M2). §3.1, §3.2 (M4), §3.3, §3.4 in today's order:
  the taxonomy, then its justification. §3.4 uses "time bases", "sweep",
  "tick", "one home per datum" and "the boundary iteration", each linked or
  cited where used.
- **§4.** Opening (M2). §4.1, §4.2, §4.3, §4.4 unchanged. Inside §4.3 the
  subheadings stay; the opening's "Four questions" counts the two granularity
  subheadings as one answer, which it already says ("The last question has two
  answers"). §4.3 uses "root input", "staged write", "device claim" and "trace
  address" (510) in the periphery atom: "root input" is defined in §4.1 (458);
  the other three take a pointer to §11.3 as they have.

### Rewrite units

Units are cut by content and never cross a chapter boundary.

| unit | lines (original) | content | moves | words |
|---|---|---|---|---|
| A | 139–212 | §1 | M1 | 597 |
| B | 213–295 | §2, §2.1, §2.2 | M2 (§2's roadmap), M3 | 631 |
| C | 296–363 | §3 lead, §3.1, §3.2, §3.3 | M2 (§3's roadmap), M4 | 519 |
| D | 364–436 | §3.4 | M5 | 612 |
| E | 437–529 | §4 opening, §4.1, §4.2, §4.3 through "Scatter and gather" | M2 (§4's opening) | 748 |
| F | 530–601 | §4.3 "What a port may hold" through "Granularity, write side" | — | 605 |
| G | 602–671 | §4.4 | M6 if q8 | 573 |

Seven units of 520 to 750 words for 4,285 words (chapter 5 used six for
4,717). §4.3 spans E and F, so the brief must assign each glossary term's
first-use link in §4.3 to one unit (lesson 36): E links *port*, *face*, *cell*,
*root input*, *device*, *claim*, *trace*, *stage function*, *tier*, *guard* and
*snapshot*; F links *leaf address*, *stop request*, *field handle* and
*guarded addition*, and must not relink E's terms. The alternative is C and D
as one unit of 1,131 words (q10).

### Code blocks

Two fenced blocks, both `julia`. One display-math run (401–406, inline math in
prose) and the formulas at 217, 218, 308, 333.

- **The granularity sketch (577–583)** is a fragment: it declares
  `y_types(::Kinematics)` and `output_wires(::Vehicle)` with no struct, state,
  stage or `local_wires`, and `KinPose` and `RQuat` are Flight.jl-flavored
  names (part F). `scratch_survey/run_ports.jl` adds the minimum it implies
  (stand-in isbits `KinPose{T}` and `RQuat{T}`, a continuous `Kinematics` leaf
  with `x_init`, `x_deriv` and a `y_state` returning both ports, a `Vehicle`
  assembly holding it with empty `local_wires`) and carries both declarations
  verbatim. It builds (`Build`), runs `init!`, and the snapshot holds two cells,
  `kin.pose` (`KinPose{Float64}`) and `kin.q_eb` (`RQuat{Float64}`), each
  aliased by a root face; this matches "two cells" and "each face aliases an
  interior port, creating no endpoint". The same script checks §4.2–§4.3's
  build-error claims: a bare-struct return is refused (as
  `ConformanceFailure`, the always-on check; the spec names no kind for it); a
  port returned by both stages is `ProducedByTwoStages`; a returned field
  outside `y_types` is `UndeclaredReturnField`; a mutable port type and a
  `StopFlag` nested in a struct port are both `IllegalPortType`; a `Symbol`
  mode published as a port builds. All match the text. Carry the block
  verbatim. One shape note: FlightPhysics' `RQuat` is not parametric
  (`struct RQuat <: Abstract3DRotation`, `_u::UnitQuat`,
  `Flight.jl/lib/FlightPhysics/src/attitude.jl` 66–68), so `RQuat{Float64}` is
  the spec's form, not FlightPhysics' (lesson 30).
- **The value-level constructor sketch (649–655)** cannot run as written: its
  bodies are `ISAField(…)` and `(; … = atmospheric_field(atm; T_sl = …, …))`,
  and `args` stands for the bundle, as in §5.2's signature block.
  `scratch_survey/run_handle.jl` fills it in (an isbits `ISAField`, a
  bulk-data `TerrainField` holding a `Vector`, an `Atmosphere` whose `y_direct`
  is the one-line call, a `Strut` consumer with `terrain = AbstractTerrainField`
  as an abstract input entry, wired in a `World`). It builds and runs: the
  strut reads pressure through `airdata(u.atm, …)` and terrain through the
  handle; `atmospheric_field(...)` called outside any sweep returns a value
  `===` the swept cell's (the "bit-for-bit the same handle" of 634); the bulk
  handle's `Vector` is the same object as the build-time array (a frozen
  reference, not a copy); and the abstract entry accepts the concrete
  `TerrainField` producer. All match §4.4's claims. Carry the block verbatim.
- **Inline code names presented as API**, checked against `src/` at the
  working tree (unchanged since `d3af35a` for `src/`): `StateEvent`,
  `state_events`, `sample_times`, `x_projection`, `x_deriv`, `s_update`,
  `y_state`, `y_direct`, `y_types`, `output_wires`, `StopFlag`,
  `STOP_REQUESTED`, `IllegalPortType` and `Model` all exist. No framework name
  in the run is stale. The domain names (`atmospheric_field`, `ISAField`,
  `TerrainField`, `AbstractTerrainField`, `airdata`, `ray_intersect`,
  `KinPose`, `Airflow`) exist neither in `src/` nor in Flight.jl;
  `SimpleAtmosphere`, `AirData`, `AbstractTerrain` and `RQuat` are
  FlightPhysics' (`lib/FlightPhysics/src/atmosphere.jl` 198, 260;
  `terrain.jl` 26; `attitude.jl` 66); `f_step!` is FlightCore's
  (`lib/FlightCore/src/modeling.jl` 214). Part F lists how each needs
  introducing.
- `merge(y_x, y_xu)` and `merge(y_s, y_su)` (522–523) use §5.2's
  signature-block names (703–709); `y_xu` and `y_su` are not bundle fields.

### Glossary links

`scratch_survey/glossary_links.tsv` lists every link: 106 links to 50
anchors. Six are second links to one anchor in one section:

- §2.1: `g-edge-semantics` (236 on "holding", 265).
- §3.4: `g-component` (368, 378), `g-guard` (375, 411), `g-tier` (384, 408),
  `g-seam` (389, 423).
- §4.3: `g-tier` (516, 523).

First uses with an anchor and no link (or a link later in the section):
*assembly* in §3.3 (356; linked at 358), *component* in §3.1 (301, linked 315)
and §3.2 (328, linked 342) and §4.1 (445, none), *continuous component* in
§3.1 (its own title term, unlinked), *store* in §4.1 (452, where the vocabulary
defines it), §3.4 (407) and §4.3 (547), *view* in §4.3 (518), *cell* in §4.4
(619), *boundary* in §2.2 (288), §3.3 (357) and §4.3 (495), *contract*,
*tick*, *feedthrough*, *snapshot*, *trace*, *device* and *execution order* in
§1 (where an overview may leave them to their chapters), *face* in §4.3 (500,
the subheading; first prose use 503 is linked).

Links whose use departs from the glossary entry (lesson 35):

- `g-seam` at 389 and 423, "the sampling seam". The glossary's *seam* (13913)
  is "a narrow, named interface kept deliberately thin so what sits behind it
  can be replaced or measured" (the stepper, backend, measurement and
  phase-body seams). The sampling seam between tiers is none of those. Unlink.
- `g-tier` at 408, "events are the wrong tier". Events are not a tier; the
  glossary reserves bare "tier" for the continuous/discrete side (part F).
- `g-projection` at 222: the glossary gives both positions (13112–13114);
  §2 gives one (F2).

Anchors that must *not* be linked where the run uses the word in another
sense: *bundle* in §4.3 (537, 558–570, 587, 593–594: a struct-valued port,
not the NamedTuple of views); *condition* at 408 ("condition-triggered") and
417 ("exactness condition"), which are not §14's condition; *class* in §3 298,
§2.2 290 and §4.4 636, 639 (ordinary English; the spec_style trap names §3.4's
"class split" and "two leaf classes" already); *entry* in §1 189, 208 (log
entries).

## D. Inbound citations

The full list is `inbound.tsv` (beside this file), in chapter 5's format: 250
rows, one per "§1" … "§4.4" occurrence (or a `spec.md#…` anchor of chapters 1
to 4) outside the run (139–671) and outside the Contents block (5–117), in
`spec.md` and in every file the check rosters name (`decisions.md`,
`extensions.md`, `implementation.md`, `pending.md`, the fifteen companions),
all read at `d3af35a`. The pattern is `§[1-4](\.[0-9]+)?` not followed by a
digit, so §10–§14 and §1x.y never match; `§` occurs in no version number.
Link-definition blocks are excluded. For `decisions.md` rows the `entry` and
`field` columns are filled. The script is `scratch_survey/inbound.py`; its
raw output, `scratch_survey/inbound_raw.tsv`, has 254 rows. Four companion
self-references were dropped after reading each companion's headings:
`event_visibility_walkthrough.md` 90 and 129 link its own sections 3 and 4
(`#3-the-round-and-who-writes-what`, `#4-why-cross-component-order-dissolves`),
and `inbound_periphery_walkthrough.md` 62 and 64 write "(§3)" in a code comment
for its own section 3, "Batches and staging cells". The last two spell the
companion's own section with `§`, which `spec_style.md` reserves for the spec.

By file: `decisions.md` 128 (Spec 65, Rationale 23, Rejected 22, Position 17,
annotation 1), `spec.md` 89 (6 of them the Part I roadmap, 120–138),
`extensions.md` 7, `trim_environment_walkthrough.md` 6, `implementation.md` 5,
`flight_case_studies.md` 5, `limited_integrator_variants.md` 3,
`localization_validation_walkthrough.md` 2, `event_visibility_walkthrough.md`,
`handle_walk_walkthrough.md`, `library_inventory.md`, `migration_outline.md`
and `pid_anti_windup.md` 1 each, `pending.md` 0. By target: §1 5, §2 4, §2.1
34, §2.2 10, §3 6, §3.1 15, §3.2 17, §3.3 12, §3.4 18, §4 3, §4.1 24, §4.2 10,
§4.3 43, §4.4 49.

### Citations relying on moved or trimmed content

No move takes content across a section boundary, so no row's section changes.
M3 reorders §2.1 internally; the rows citing §2.1 for the predicate, edges,
two forms and time/state events (spec 4881, 5435, 5498, 6110, 13178, 13237,
13270, 13298; `limited_integrator_variants.md` 4, 31, 249) keep their target.
M1, M2, M4 and M5 change no content. Terms a rewrite must keep, because rows
quote or name them:

| file:line | term relied on | where in the run |
|---|---|---|
| spec 2178 (§8.1) | "The debugging, tooling and comprehension criterion ([§1])" | §1 181–183; the criterion's own name is "Rigor and error locality" (179), so the words "debugging, tooling and comprehension" must survive in the criterion |
| spec 6123 (§10.6), log 772 (D-020 Rejected) | "Externalized FSM components are blessed ([§3.1])" | §3.1 321–322, "external FSM component" |
| spec 1979, 6379 (§7.3, §10.7); `extensions.md` 55 | "deterministic replay ([§2.2])" | §2.2 283 |
| spec 3025 (§8.3) | "the `unlisted` flag ([§4.2])" | §4.2 488–490 |
| spec 3890 (§8.8), 4488 (§9), log 7642 (D-207), 12665 (D-299) | "the write-side rule / write-side granularity of [§4.3]" | §4.3 587–590 |
| spec 2097, 2103 (§7.5) | "The summarize-or-skip rule ([§4.4])" | §4.4 624 |
| spec 1156 (§5.4), log 4692 (D-140), 7079 (D-194) | "the granularity guideline ([§4.3])" | §4.3 566 |
| spec 12848 (glossary *class*) and `spec_style.md`'s trap | "class split", "two leaf classes" in §3.4 | §3.4 364, 366 (title and first sentence) |
| `flight_case_studies.md` 16, spec 977, 3377, 3430 | "the strapdown IMU of [§3.4]" | §3.4 393–413 |
| glossary 13894 | "field-addressed staging, [§4.3]" as a guarded addition | §4.3 599–600 |

### Citations that already rely on content chapters 1 to 4 do not hold

The inbound check will flag these whatever the rewrite does; they belong to
track 2 or to a ruling at checkpoint 1.

| file:line | claim | what chapters 1–4 say |
|---|---|---|
| spec 1091 (§5.3) | "only handlers write `x` ([§3.1])" | §3.1 310–311 says a handler "may reset the component's own `x`", not "only"; §3.4 410–411 says it ("handlers are the sole resetters of continuous state"). Retarget to §3.4, or §3.1 gains "only" from §3.4 (q9) |
| log 4747 (D-141 Rationale), 4793 (D-141 Rejected) | "[§3.1]'s immutable stage views" | §3.1 says nothing of immutable stage views; D-141's Rationale of its day |
| spec 13103 (glossary *flow / RHS*) | "There is no incremental `x_deriv`-only re-evaluation ([§3.1], [§5.3])" | §3.1 does not state it; §5.3 does. This is the owner's open item "evaluating the RHS means running the sweep" (`pending.md` 105); leave it, and leave §3.1 uncited for it |
| spec 13885 (glossary *decision entry*) | "a superseded one is marked `superseded → D-nnn` in its Status line rather than rewritten ([§1])" | §1 206–209 says entry numbers are stable and never reused; the supersession rule is `decisions_style.md`'s, never §1's |
| spec 6121 (§10.6), log 772 (D-020 Rejected) | "the same class of footgun [§2.2] cited when killing `f_step!`" (step-size-dependent semantics) | §2.2 286–292 gives no reason for excluding `f_step!`; D-001 Rejected log 370 does. One clause in §2.2 citing D-001 makes both right (q9) |
| spec 2935 (§8.2) | "projection's one manifold is the continuous state's ([§2.2])" | §2.2 says projection covers state manifolds (277–278) and quaternion renormalization (287–288); "the continuous state's" is §2's lead (222–224) and §3.1 313. Holds loosely |
| spec 2934 (§8.2) | "the event system is continuous-side only ([§5.2], [§3.2], [§14.1])" | §3.2 implies it (the discrete facets list no events; "`m` is continuous-only"), never states it |
| spec 6725 (§11.2), log 4437 (D-137) | "Snapshots are immutable object graphs with internal sharing ([§4.1])" | §4.1 says "no aliasing, ever" and nothing of sharing. Sharing immutable data is not aliasing in §4.1's sense; VAGUE, not wrong |
| spec 11785 (Appendix A) | "**One home per datum** ([§5.2], [§4.3])" | §4.3 does not state one home per datum (§3.4 379 mentions it, citing §5.2) |
| spec 13052 (glossary *signal table*) | "within a step it is transiently integrator scratch ([§4.1], [§10.3])" | §4.1 does not say it; §10.3 5376–5379 does |
| spec 10664 (§14.4), log 11603 (D-276 annotation) | "a discrete `s` field is any isbits value ([§3.2])" | holds today and relies on the wording F7 corrects; after the correction it reads against "isbits or a `Symbol`" (README's chapter 14 item) |
| log 4579 (D-139 Position), spec 636 (§4.4 itself) | "the silent-drift class [§5.3] exists to kill" | outbound, listed for completeness: §5.3 states the drift (945–948) but was not written to kill it |
| log 3827 (D-123 Rationale) | the audit "closed D-122's application stragglers (component-sense 'kind' residue in [§3], …)" | §4.3 506 still says "kind-blind" (F9) |

### Log entries whose Spec field would change

None from the moves: no content crosses a section boundary. Stale Spec fields
found in passing, all track 2:

- D-001 Spec (log 363): §2.2 only. D-001's Position also rules §2's lead
  (formalism, projection) and §2.1 (two-tier events, positive = holding, edge
  semantics, pace-independence).
- D-002 and D-003 have no Spec field. D-002 rules §1 and §2's lead; D-003
  rules §3 and §3.1 (the mode factorings).
- D-082 Spec (log 2516): §10.4, §10.6, §14.5; lacks §2.1, which defines the
  predicate and the edge.
- D-080 Spec (log 2463): lacks §2.1 (245).
- D-180 Spec (log 6571): §2.1 only, which never states D-180's guarded
  addition (part E).
- D-141 Spec (log 4740): lists §2.1, which holds nothing of D-141 (its Position
  says §2.1 is "unchanged"), and lacks §2.2, which states the gear reset (290–292).
- D-020 Spec (log 762): lists §2.2 and §3.1, which hold none of D-020's
  mechanism (the iteration); they hold only the footgun D-020's Rejected list
  names.
- D-053 Spec (log 1610): lists §2.1, which holds the two guard forms but not
  the conformance check.
- D-045 Spec (log 1414): §11.7 only; its Rejected item is the run's write-side
  rule (§4.3).
- D-121 Spec (log 3733): lists §2.1 (the restated sign-change spots), fine;
  D-172 Spec (log 6230) fine.
- D-123 Spec (log 3820) lists §3 and §3.4, and D-242 Spec (log 9167) lists
  §3.4: both for word sweeps, not for a mechanism there.
- D-231 Spec (log 8695): lacks §2.2 (RNG values in `s`).
- D-247 Spec (log 9380): lacks §3.1 and §3.2 if F7's correction lands.
- D-308 Spec (log 12969): lacks §3.1 (the modes' contents).
- D-019 Spec (log 721): lacks §3.3 (virtual for execution, rate scopes).

## E. Log repairs and factual problems

Log repairs go to the second track, after landing (recipe step 8). The rewrite
only adds citations; it states no repair. Factual problems stay as written and
go to the units' `rulings.md`, unless part G pre-rules them.

### Entries to cite at the rule

From part A's U and B rows: D-001 (rows 20–25, 27, 43; cited today only in
§2.2), D-002 (20; cited nowhere), D-003 (48, 49, 56, 58, 68; cited nowhere),
D-082 (27, 36, 37), D-080 (30), D-179 (26, 27, 29, and 35's last sentence),
D-018 (29), D-220 (33), D-019 (22, 61, 62, 65, 72, 73), D-195 (22, 61), D-094,
D-247 and D-304 (50, in the corrected sentence), D-308 (51), D-090 (51, 54),
D-154 (54), D-263 (56, 64, 74), D-231 (44, 60, 66), D-249 (66), D-056 (65,
75, 76, 79, 87), D-141 (47, 85), D-022 and D-031 (25), D-004 (91–92), D-121
(94, 95, 97; cited nowhere), D-206 and D-208 (98), D-036 (93, 117, 118, 120,
121), D-035 (117), D-040 (106), D-276 (107, 130), D-033 (108), D-034 (110,
111, 112), D-194 (111), D-172 (114, 115; cited nowhere), D-252 (119), D-237
(124, 127), D-316 (125), D-008 (143–145), D-139 (148, 149, 152; cited only in
§14), D-296 (159), D-078 (160).

### Superseded and half-superseded citations

- None. The run cites no superseded entry.
- D-016 (cited at 490 for the `unlisted` rejection) is superseded in part
  (annotation log 633–636). The rejection sits in its Rejected list as a
  *Superseded position* item (log 639–643); D-034's Rejected list states it
  directly (log 1126–1127). Cite D-034, or both (q6).
- Row 54 relies on D-016's clause "guards and handlers read the fresh boundary
  table" (log 625), which D-016's annotation neither removes nor lists as
  standing. D-154's epoch rule (log 5457–5459) is the live statement; cite it.

### Rulings that need an entry stating them in a Position

1. Ticks are time events and a declared `StateEvent` is a state event; the
   criterion is detection against scheduling (rows 31, 32, 34). D-220 Rationale
   log 8248–8253.
2. The opposite crossing direction is a second event with the negated guard
   (row 39). D-082 Rationale log 2519–2520.
3. Internal modes keep reset maps (row 57). D-003 Rejected log 395–396.
4. A discrete component has no mode store (row 66). D-231 annotation log
   8724–8725; D-249 bullet 1 implies it for `m_init` only.
5. A merged component's halves would communicate as siblings; the deferred
   decode makes ticks→events impossible; the merge hides the sampling seam;
   a periodic reset is not an event (rows 77, 78, 80, 81, 84). D-056 Rejected
   log 1701–1711; D-020 Rejected log 776–777.
6. An assembly has no dynamics of its own (row 69). D-141 Rejected log
   4797–4799.
7. The signal requirement is immutability plus frozen references (row 99).
   D-243 Rationale log 9210; D-231's Position presupposes it.
8. No aliasing, concurrent reads safe, per-cell freshness tied to the producer
   (rows 101, 102, 104). D-004 Rejected log 410–414.
9. The port is the addressable unit and the periphery's atomic unit (rows 105,
   116). D-036 Rejected log 1183; D-045 Rejected log 1436–1438.
10. The `unlisted` flag is closed (row 112). D-034 Rejected log 1126–1127.
11. Bare-struct returns are rejected; nested fields get no cells; a
    field-projection connector is an unbuilt guarded addition (rows 121, 123,
    132). D-036 Rejected log 1179–1186.
12. A loose hot field beside its bundle is kept as an optimization (rows 131,
    136). D-276 Rejected log 11649–11651.
13. The write-side rule (rows 138–140). D-045 Rejected log 1436–1440; D-207
    Rejected log 7642–7643 and D-299 Position log 12664–12666 lean on it.
14. A bulk-data component owes only reachability of the query math (row 153).
    D-139 Rationale log 4587–4589.
15. Pre-sampling is an idiom, not a mechanism; resource injection is closed
    (rows 155, 156). D-008 Rejected log 484–485.

### Rulings with no entry at all

Each was searched in the log at `d3af35a` (the search is given in part A's
row): the five design criteria and the rule that an unbuilt capability is
weighed against them as a guarded addition (row 10); deterministic replay as a
framework guarantee (row 44); modes change *only* through handlers (row 51);
the rule of meaning's "do not overlap" (row 59); the composed granularity
principle (row 141); field-addressed staging as a "recorded" guarded addition
(row 142: no entry records it; `docs/design/briefs/brief_increment_57_leaf_address.md`
40 and 148 attribute the lens to D-036, whose Rejected item records only the
read-side field-projection connector); the loggers' skip-or-summarize rule
(row 147, which §7.5 2103 calls a rule); "well-defined semantics" (row 35).
Rows 18 and 19 are process and earn no entry (`decisions_style.md` rule 9).

D-180's guarded addition runs the other way: the log records a per-event
`direction` keyword as an unbuilt guarded addition (log 6568–6569, Spec §2.1
only), and the spec states it nowhere (grep of `direction`, `:upward`,
`:downward` over `spec.md` and `extensions.md`; the row entered the log in
`f6ba628`, 2026-08-11, with no spec change). One sentence in §2.1 after row 39
would state it from its entry (q5).

### The owner's open items (`pending.md` 82–114)

Listed so the rewrite leaves them as they are; no entry is proposed.

- **"Fan-out is free"**, §4.3 570, with "publishing both a bundle and a hot
  loose field … is legitimate". Chapter 6 left "local fan-out is free" with no
  live entry (`pending.md` 97). The run's sentence stays plain and uncited. Its
  second half (the loose field) has D-276's Rejected item behind it; that
  citation may sit on the "legitimate" clause only, if at all.
- **Stage-2 conservatism, the RHS sweep, the unit delay's caveat, stage
  discovery by method existence** (`pending.md` 102–110): chapters 1 to 4 state
  none of them (grep of "conservativ", "presumed", "unit delay", `UnitDelay`,
  "re-evaluation", "method existence", "RHS" over 139–671: no hit). The
  glossary's *flow / RHS* (13103) cites §3.1 for the RHS sweep; §3.1 does not
  state it, and the rewrite should not add it there.

### Stale entry text and Spec fields

- Spec fields: part D's list (D-001, D-002, D-003, D-019, D-020, D-045, D-053,
  D-080, D-082, D-123, D-141, D-180, D-231, D-242, D-247, D-308).
- D-141 Rationale (log 4747) and Rejected (log 4793) cite "[§3.1]'s immutable
  stage views", which §3.1 never stated (part D).
- D-123 Rationale (log 3827) records the "kind" stragglers as closed; §4.3 506
  keeps one (F9).

### Factual problems in chapters 1 to 4

Each was grepped over 139–671 for every instance of its phrase (lesson 19);
the instances are listed. Each correction was checked against the entries
ratified after its source (lesson 18).

- **F1. The gear regulator's reset is not "under `!wow`".** 290–292: "Level-triggered
  cross-component resets become edge-triggered events. The gear friction
  regulator under `!wow` is one such reset ([§5.3], [D-001])." D-141 Position
  (log 4730–4738): the reset is an event whose guard reads `wow`, "The gear wires
  `strut.wow → frc.reset` (the touchdown edge)"; D-141 Rejected (log 4788–4792):
  "*The liftoff edge (`!wow`):* behaviorally closest to today's level reset".
  §5.3 1093–1097: "re-initialized at touchdown by weight-on-wheels … so the
  reset fires on the touchdown edge". `!wow` names FlightCore's level-reset
  condition, so the sentence is true of the old reset, but read as the new
  event it names the rejected edge. Correction: "The gear friction regulator,
  which FlightCore resets while `!wow` holds, becomes an event on the touchdown
  edge ([§5.3], [D-001], [D-141])." Instances: 292 only (`!wow` occurs nowhere else in
  the run). No entry after D-141 rules the gear reset.
- **F2. Projection runs after a handler's reset too.** 222–223: "An optional
  per-component hook `x ← x_projection(x)`, applied after each accepted step."
  §5.3 1019–1021 (D-016): "That is after integration, and after any handler
  `x`-reset. Those are the only positions"; glossary 13112–13114 the same; §7.5
  2080 ("`x_projection` at both of its positions"); D-111 Position log
  3421–3422 ("both … schedule positions"). Correction: "applied after each
  accepted step and after any handler reset of `x` ([§5.3])". Instances: 223
  only ("accepted step" occurs once in the run).
- **F3. The formalism's `f` against §5.3's.** 217 and 308: "$\dot{x} = f(x, m,
  u, t)$"; 218 and 333: "$s^{+} = g(s, u, t)$". §5.3 956–958: "This design's
  `f` receives the orthodox arguments *plus* the published table, $\dot{x} =
  f(x, m, y, u, t)$. The composite map $x \mapsto \dot{x}$ is mathematically
  identical". §2's form is that composite, so it is not wrong; but §2 never
  says so and never names the output map `h` that D-220's Position (log
  8181–8182) keeps as a formula symbol. A wording question, not a correction:
  part G q4.
- **F4. The boundary-detected cost.** 239: "The cost is one guard evaluation
  per event per step." §10.6 6093–6099: each iteration round "evaluates all
  guards … against it", and rounds continue to quiescence; §7.5 2079–2080:
  guards are "evaluated every boundary whether they fire or not". The count
  holds at a boundary of one round, the common case. Correction, if ruled:
  "one guard evaluation per event per iteration round ([§10.6])". Instances:
  239 only.
- **F5. The zero-allocation criterion overstates §7.5.** 170–171: "The inner
  loop allocates nothing, and the test suite asserts it ([§7.5], [§9.7])."
  §7.5 2069–2073: the invariant is "scoped to the stepping loop", and
  publication's one snapshot allocation per boundary "sits … outside what the
  invariant claims is zero"; 2078–2083: the exactly-zero, CI-enforced budget is
  the continuous hot path's; 2084–2090: ticks and handlers are zero by idiom,
  with a documented tolerance. D-305 Position log 12890–12896 (the latest
  entry) agrees. Correction: "The stepping loop's hot path allocates nothing,
  and CI asserts it ([§7.5], [§9.7])." Instances: 170–171 (the run's other
  "allocate" sentences, 470 and 618–619, are about isbits values and `Ref`s and
  hold).
- **F6. The rule of meaning against D-141.** 324–326: "A supervisor
  *commanding* a mode change is an ordinary **input**. A component *detecting*
  its own transition is an **event**. The two mechanisms carry two meanings and
  do not overlap." On the continuous tier `m` and `x` change only through
  handlers (306–307, 310–311), and D-141's Position (log 4729–4732) spells a
  commanded continuous reset as "an event whose guard reads that input; the
  discrete tier's input answer does not transfer"; §5.3 1090–1093 states it
  bold. A commanded mode change of a continuous component therefore takes both
  mechanisms, an input carrying the command and an event applying it. The rule
  has no entry (row 59). Read as "the command travels as an input, the
  transition happens in an event", it holds; read as "a commanded change is
  not an event", D-141 contradicts it. Part G q7.
- **F7. The leaves' state shapes (README's carried chapter 3 item).** 305:
  "**Continuous state** `x`, an isbits struct of real scalars ([§7])." §7.1
  1688–1691: the declaration "is a NamedTuple ([D-247]). Its leaves are drawn
  from a deliberately closed vocabulary, plain real scalars and `SArray`s … of
  a common eltype"; D-094 Position log 2852–2853; D-304 bullet 1 log 12852
  (flat). 332: "**Discrete state** `s`, any isbits value ([§7])." §7.3 1880:
  "Every field of an `s` or `m` store value is isbits or a `Symbol`" (D-231
  Position log 8689–8691); D-247 log 9373–9374 (a `NamedTuple`); D-304 bullet 3
  log 12859–12861 (a struct nesting a `Symbol` does not qualify). Corrections:
  305 "a flat NamedTuple of real scalars and `SArray`s ([§7.1])"; 332 "a
  NamedTuple whose fields are each isbits or a `Symbol` ([§7.3])". Instances:
  305 and 332 only ("isbits struct" and "any isbits value" occur nowhere else
  in the run). D-304 is the latest entry on both and agrees.
- **F8. `dyn.vel` is the rejected dotted path.** 476–477: "one flat namespace
  of ports (`dyn.vel`, `dyn.f_c_c`)". D-040 Position log 1282 (slash-string
  paths, "one canonical form shared by declarations, diagnostics, devices and
  logs") and Rejected log 1293–1294 ("*Dotted paths:* false Julia-property
  affordance — the last segment is a port, not a field"); D-276 Rationale
  (log 11642–11646): the leaf address "begins after the port", so `dyn.vel`
  now reads as leaf `vel` of a port `dyn`. Correction: (`"dyn/vel"`,
  `"dyn/f_c_c"`). Instances: 477 only (the run's other dotted string,
  `"pose.q_eb"` at 536, is a leaf address and correct).
- **F9. "kind-blind" uses the retired word.** 506: "The distinction is
  kind-blind." D-122 Position log 3769–3770 renames "component **kind →
  class**", and its Rationale (log 3787–3788) gives bare *kind* to the
  diagnostic kind; the glossary's *class* (12842–12846) is "a component's
  primitive-vs-assembly status … Not to be confused with … a diagnostic
  *kind*"; the sentence's own gloss, "without knowing whether it is primitive
  or composite", is that sense. D-172 (log 6220) says "kind-blind" in the
  vocabulary of its day (`decisions_style.md` rule 2), and D-123 (log 3827)
  believed the stragglers closed. Correction: "class-blind". Instances: 506
  only (the run's other "kind", 200, is the diagnostic kind).
- **F10. "That leaf is the field handle."** 547–548. D-237 Position (log
  8950–8953): every immutable non-isbits type is one opaque leaf; 548–549
  continues "A `Symbol` is an opaque leaf too". The field handle is one such
  leaf, not the only one. Correction: "A field handle ([§4.4]) is such a
  leaf." Instances: 548 only.
- **F11. "Caches belong in the consumer's state."** 622. A memoizing
  interpolator or lazy loader is mutable or holds references, and every field
  of a store value must be isbits or a `Symbol` (D-231 Position log 8689–8691,
  §7.3 1880); a workspace "must carry no information between calls" (§7.3
  1914–1915, D-183); output stages are pure, "No mutable cache carries values
  between the derivative and the outputs" (D-342 bullet 2, log 14076–14077);
  and a continuous consumer's stages cannot write its state at all (only
  handlers do, 306–311). The remedy names a home three later rulings close,
  leaving only "the interpolant is restructured to be pure". A fix changes
  what the design admits: a serious finding (part G q8). Instances: 622 only.

Outside the run, met while checking citations:

- **F12.** Spec 13885 (glossary *decision entry*) cites §1 for the supersession
  rule, which is `decisions_style.md`'s (part D).
- **F13.** Spec 1091 (§5.3) cites §3.1 for "only handlers write `x`", which
  §3.4 410–411 states and §3.1 does not (part D).
- **F14.** `inbound_periphery_walkthrough.md` 62, 64 write "(§3)" for the
  companion's own section, against `spec_style.md`'s reservation of `§`.
- **F15.** Spec 6121 (§10.6) and log 772 (D-020) cite §2.2 for `f_step!`'s
  step-size dependence, which §2.2 does not give (part D, q9).

## F. Difficulty per section

| unit | difficulty | reason |
|---|---|---|
| A (§1) | medium | the coldest reader in the spec; no ruling of its own, so the job is register and pointers; ten bold labels to remove (q2); F5; every bullet must keep its pointer; the words "debugging, tooling and comprehension" must survive (§8.1 2178 quotes them) |
| B (§2) | medium to high | M3 reorders §2.1; five U rows of D-001 and two of D-082 to bold and cite where today only §2.2 cites anything; D-179's bold moves to §10.4; F1, F2, F4, and F3's wording question; the R rows of D-220; reader-cold `f_step!`, DCM, Dryden/von Kármán, `!wow` |
| C (§3 lead to §3.3) | medium | D-003 cited nowhere and bold nowhere; F7's two corrections; the rule of meaning (F6, q7); M4; three uses of "class" against the glossary; "submodels" |
| D (§3.4) | high | 612 dense words; nearly every ruling lives in D-056's Rejected list (five R rows); two bolds for D-056 and one bold removed (README item); the IMU notation (`ϑ_c`, `υ_c_sc`, `q_c_cc`, the interval integrals) is reader-cold; two misused glossary links (`g-seam`, `g-tier`); "events are the wrong tier" |
| E (§4 opening to "Scatter and gather") | medium | the binding vocabulary (D-121, cited nowhere) must stay exact; F8 and F9; D-172 cited nowhere; the periphery atom's six "one"s; §4.3 spans E and F (link assignment, part C) |
| F ("What a port may hold" to the write side) | high | 605 words written across four entries (D-036, D-237, D-243, D-316) with three C rows and many U; F10; "fan-out is free" (owner's item, uncited); the write-side rule is R; "bundle" in the port sense throughout (no `#g-bundle` link); the code block carried verbatim |
| G (§4.4) | medium to high | D-008 and D-139 bold nowhere; F11 (escalation candidate); five Flight.jl or invented domain names; "the landing-gear redesign" and "today's `AbstractTerrain`" are plans and history in normative text; the code block carried verbatim |

Warnings for the rewriter:

- **Terms of art stay verbatim**: hybrid causal system, boundary-detected,
  localized, predicate, holding, edge semantics, prior, time event, state
  event, guarded addition, hybrid primitive, both factorings of mode logic,
  internal modes, external FSM component, rule of meaning, time bases,
  sweep-driven, tick-driven, one home per datum, integrate-and-dump, latch-back
  wire, escape hatch, tick-triggered handler, immutable values, signal table,
  cell, store, staging cell, root input, immutability plus frozen references,
  addressable unit, port, face, atomic unit of the periphery, scatter/gather,
  aggregate `y`, opaque leaf, leaf walk, stop request, port-granular,
  unbundling component, loose port, granularity guideline, write-side rule,
  query-shaped, field handle, handle pattern, value-level constructor,
  shipped component's obligation, pre-sampling, structural substitutability,
  abstract input entry. "debugging, tooling and comprehension" (§1) and
  "Externalized FSM" (§3.1's "external FSM component") are quoted by other
  sections (part D).
- **Counts are rulings**: five parts of a hybrid causal system, two detection
  policies, two guard forms, one guard evaluation per event per step (F4),
  three exclusions, two mechanisms for every `f_step!` use, three classes, two
  leaves, five design criteria, thirteen integral scalars, three structural
  gains, four consequences of the signal requirement, one cell and one
  producer per port, the six "one"s of the periphery atom. Each carries its
  entry (part A).
- **Both halves of every two-condition ruling**: "shares a stage *and* is
  consumed together" (566); "different external writers, or at different
  cadences" (589); "immutability plus frozen references" (461); "a `StopFlag`
  nested in a port of another type or declared as a root input" (543–544); "a
  mutable type anywhere … and … an opaque leaf surfacing as a root input"
  (551–552).
- **The log's vocabulary is old.** D-001 says "Tier-2" and "guard
  conditions"; D-003 "hybrid continuous primitive"; D-016 `h_x`, `project`;
  D-020 `g`, `z⁺`; D-033 `init_*`, `output_types`, `local_types`, `events`,
  `localize`; D-034 `output_types()`, `local_types`; D-056 "two-kind", `z`;
  D-082 "condition", "baseline"; D-141 `init_x`, `z⁺`, `PIVector`; D-172
  "kind-blind"; D-179 `Event(guard, handler)`; D-206 "slot". Never import them
  when citing an entry.
- **Glossary-reserved words the run uses loosely** (lesson 26):
  - *class*, the primitive-versus-assembly status (glossary 12842–12848): §3
    298 "There are three classes" counts two leaf kinds and the assembly,
    neither glossary sense; §2.2 290 "For one class the mapping tightens";
    §4.4 636, 639 "the silent-drift class", "the drift class". §3.4's "class
    split" and "two leaf classes" are the recorded trap: never linked.
  - *tier*, "Bare 'tier' means only this" (glossary, the continuous or
    discrete side): §3.4 408 "events are the wrong tier" (and its link).
  - *kind*, owned by the diagnostic kind: §4.3 506 "kind-blind" (F9).
  - *seam* (glossary 13913): §3.4 389, 423 "the sampling seam" (unlink).
  - *entry*, "never used bare": §1 189, 208, 209 ("entries in the decision
    log", "one entry per settled decision", "Entry numbers") are decision-log
    entries, a compound the glossary's list omits but its *decision entry*
    anchor names (13880); fine as compounds. §2.1 267 "Stall entry" is
    English.
  - *condition*, §14's value: §3.4 408 "condition-triggered" and 417
    "exactness condition" are other senses; §4.4 633 and 643 ("condition math",
    "condition authoring") are §14's and correct.
  - *bundle*, the NamedTuple of views: §4.3 537–594 use the port sense (a
    struct-valued port). Never link `#g-bundle` there.
  - *register*, retired by D-242 except in its storage sense: §4.1 456
    "inbound register" is the storage sense; 525 "register-level field loads"
    is the CPU's. Both fine.
  - *model*: `spec_style.md` reserves lowercase "model" for a `Model` or the
    modeled system. §1 148 "A model is written as a tree of components" is
    about authoring, which the style gives to "the component tree"; §3.3 356
    "submodels" means child components; §4.4 614–615 "Parametric models",
    "Bulk-data models" mean environment models (say so); §4.4 638 "sub-models"
    means the environment component's internal physics.
  - bare `h`, bare `z`: not used. `z⁻¹` (389) is the shift operator, correct.
- **Reader-cold names** (introduce each; the gloss claims nothing beyond its
  source, lesson 14):
  - Flight.jl's own: `FlightCore`, `FlightPhysics`, `FlightApps` are introduced
    at 185–187. `f_step!` (286) is FlightCore's per-step hook
    (`lib/FlightCore/src/modeling.jl` 214), never introduced. `SimpleAtmosphere`
    (628) is FlightPhysics' atmosphere model (`atmosphere.jl` 260), and "the
    `SimpleAtmosphere` successor" is the Redstone port D-139 names. `AirData`
    (659) is a FlightPhysics struct (`atmosphere.jl` 198); `Airflow` is not a
    Flight.jl type (only GUI labels match), so the gloss must not call it
    Flight.jl's. `AbstractTerrain` (668) is FlightPhysics' (`terrain.jl` 26).
    `RQuat` (579) is FlightPhysics' rotation quaternion and is not parametric
    there (part C); §7.1 1693–1695 glosses it.
  - Invented for the examples, in neither `src/` nor Flight.jl: `KinPose`,
    `Kinematics`, `Vehicle` (the sketch's, not `test/fixtures.jl`'s),
    `ISAField`, `TerrainField`, `AbstractTerrainField`, `airdata`,
    `ray_intersect`, `atmospheric_field`. A gloss may say "an illustrative"
    name, no more.
  - Aerospace terms: DCM (224, direction cosine matrix), Dryden/von Kármán
    turbulence (280, the standard turbulence models), the stall hysteresis
    latch (290, 319), engine phase transitions (289), the gear friction
    regulator and `!wow` (292; weight-on-wheels, D-141 log 4730–4731), the
    strapdown IMU and its notation (395–405: `ϑ_c`, `υ_c`, `q_c_cc` the coning
    increment, `υ_c_sc` the sculling integral, `ω_ic_c`, `f_c_c`), ISA (614),
    the geoid undulation grid (617), a gear strut's contact point (605). Point
    the IMU at §8.6, which spells it in full, rather than gloss its physics.
  - Abbreviations: FSM (316; first spelled out nowhere in the run), ZOH (389;
    219 says "held zero-order"), RNG (280), AD (164 spells it out), DSL (181).
  - "the landing-gear redesign" (664): a Flight.jl plan no source in the spec
    or log describes; and "today's" (668) is history in normative text. Both
    are context the rewriter may keep only with a named source, or ask (q11).
- **Antecedent hazards.** Each opens on a word pointing back across a sentence
  or paragraph a move or split can disturb: 255 "This arrangement" (M3 fixes
  it); 290 "For one class"; 317 "therefore"; 326 "The two mechanisms"; 341
  "So they are spelled" and "Nothing is lost by the split" (M4); 377 "And the
  settled rules"; 382 "That deferred decode"; 386 "therefore"; 388 "One of
  those costs"; 425 "And linearization got sane"; 428 "One escape hatch"; 466
  "This requirement"; 548 "That leaf"; 594 "That is legal"; 597 "The
  guideline and the rule"; 631 "The other way round"; 636 "The drift avoided
  here"; 637 "This is a shipped component's obligation"; 663 "It dovetails";
  667 "That preserves".
- **Bold**: about 25 bolds against 18 labels and 76 spans today (part A,
  "Bold, one per ruling"). The 10 bold lead-ins of chapter 1 and the 13 of
  §2–§4 used as headings become topic sentences, plain list items or `####`
  labels. `check_bold.jl` fails any bold span with no D-citation in its
  sentence.
- **Glossary links reset per section**: six duplicates today and two misused
  anchors (part C).
- **Code and math**: part C, "Code blocks". Both fences carry verbatim.

## G. Decisions for checkpoint 1

Settled for every chapter and not asked again: log repair rides track 2, and
bold marks one headline clause per ruling (recipe step 1, checkpoint 1). Each
wording correction below was grepped over 139–671 for every instance of its
phrase (lesson 19); the instances are in part E.

**q1. The README's two chapter 3 items.** (i) §3.4's lead-in "**Algebra
removes the reset.**" (415) bolds D-056's first bullet, which §8.6 3432 bolds
(D-056). Recommendation: plain topic sentence pointing at §8.6 (M5); §3.4's
D-056 bolds go to its Position sentence (row 75 or 76) and bullet 4 (row 90).
(ii) §3.1's "an isbits struct of real scalars" (305) and §3.2's "any isbits
value" (332) against §7.1 and §7.3: recommendation, F7's two corrections, in
q5. Both items then leave the README's list.

**q2. Chapter 1's labels.** §1 carries ten bold labels (the five lead-ins and
the five criterion names) and no ruling. Options: (a) the five lead-ins become
`####` subheadings (Purpose, Capabilities, Design criteria, Origins, Scope of
this document) and the five criterion names stay as plain item names; (b) the
lead-ins become topic sentences with no subheadings; (c) keep. Recommendation:
(a). Chapter 1 is read by entry point ("Design criteria" is cited from §8.1
2178 and the glossary 13892), and `spec_style.md` allows subheadings as entry
points while forbidding bold labels. Chapter 1 takes no bold.

**q3. Openings for §2, §3 and chapter 4 (M2).** §2's lead names the five parts
but not §2.1 and §2.2; §3's lead has no roadmap and does not say §3.4 is the
justification; chapter 4 opens straight into §4.1. Options: (a) one roadmap
sentence each, declared additions drawn only from the Part I roadmap (124–129)
and the section titles; (b) none. Recommendation: (a), as chapters 5 to 10
open.

**q4. §2.1's order and §2's formula (M3, F3).** (i) M3 moves the predicate,
edge semantics and return-type paragraphs (259–273) ahead of the two policy
bullets, which use "holding", "edge" and "prior" (236) before 259–265 defines
them; the time/state paragraph moves last, curing "This arrangement" (255).
Recommendation: apply. (ii) §2 writes $\dot{x} = f(x, m, u, t)$ and never names
the output map, while §5.3 956–958 lets `f` read the published table and calls
the composite identical. Options: (a) one declared clause in §2's continuous
bullet pointing at §5.3's departure, sourced from 956–958 alone; (b) leave.
Recommendation: (a), with no new formula; §3.1 308 and §3.2 333 stay as they
are (each is the facet list's flow and update).

**q5. Clear factual corrections, ruled before writing (lesson 13).** Evidence
for each is in part E.

- F1, 292: "The gear friction regulator under `!wow` is one such reset ([§5.3],
  [D-001])" → "The gear friction regulator, which FlightCore resets while
  `!wow` holds, becomes an event on the touchdown edge ([§5.3], [D-001],
  [D-141])". D-141 Position log 4737–4738, Rejected log 4788–4792; §5.3
  1093–1097. D-001 stays cited for the exclusion itself. Recommendation:
  apply.
- F2, 223: "applied after each accepted step" → "applied after each accepted
  step and after any handler reset of `x` ([§5.3])". §5.3 1019–1021 (D-016);
  glossary 13112–13114. Recommendation: apply.
- F4, 239: "one guard evaluation per event per step" → "one guard evaluation
  per event per iteration round ([§10.6])". §10.6 6093–6099. Recommendation:
  apply; the old count is the one-round case and nothing cites it.
- F5, 170–171: "The inner loop allocates nothing, and the test suite asserts
  it" → "The stepping loop's hot path allocates nothing, and CI asserts it".
  §7.5 2069–2090; D-305 log 12890–12896. Recommendation: apply.
- F7, 305: "an isbits struct of real scalars ([§7])" → "a flat NamedTuple of
  real scalars and `SArray`s ([§7.1])"; 332: "any isbits value ([§7])" → "a
  NamedTuple whose fields are each isbits or a `Symbol` ([§7.3])". D-094,
  D-247, D-304 (305); D-231, D-247, D-304 (332). Cite D-094 and D-231
  respectively in the corrected bullets. Recommendation: apply. Spec 10664
  (§14.4) and log 11603 (D-276's annotation) then read against the new wording;
  chapter 14's rewrite takes 10664 (README).
- F8, 477: "(`dyn.vel`, `dyn.f_c_c`)" → "(`"dyn/vel"`, `"dyn/f_c_c"`)". D-040
  Position and Rejected log 1282, 1293–1294; D-276 Rationale log 11643.
  Recommendation: apply.
- F9, 506: "kind-blind" → "class-blind". D-122 Position log 3769–3770 and
  Rationale log 3787–3788; glossary *class* 12842–12846. Cite D-172 in the same
  sentence (its log wording stays, rule 2). Recommendation: apply.
- F10, 547–548: "That leaf is the field handle ([§4.4])" → "A field handle
  ([§4.4]) is such a leaf". D-237 Position log 8950–8953; 548–549's "A `Symbol`
  is an opaque leaf too". Recommendation: apply.
- The two misused glossary links: unlink `g-seam` at 389 and 423 (the sampling
  seam is not the glossary's seam, 13913), and reword 408 "events are the wrong
  tier" to "events are the wrong mechanism", unlinked (glossary *tier*: "Bare
  'tier' means only this"). Recommendation: apply both; they are glossary
  corrections, not meaning changes, since D-056's Rejected item (log
  1710–1711) is about the mechanism ("hand-rolls the tick scheduler").
- D-180's guarded addition, stated nowhere in the spec: add one sentence after
  row 39, "A per-event `direction` keyword is a recorded guarded addition,
  unbuilt ([D-180])", restating D-180's Position (log 6568–6569) only.
  Recommendation: apply, as a declared addition; it makes D-180's Spec field
  true.

**q6. The bold table.** Part A's "Bold, one per ruling" proposes about 25
bolds. Open placements and the R candidates:

- D-001: four bolds (rows 20, 24, 26 and one in §2.2), one per semicolon
  ruling of its first sentence. Its second sentence's two rulings take no bold
  under D-001: pace-independence is §10.7's (D-080), and the predicate and edge
  rulings are D-082's (rows 36, 37), which D-001 cites. Recommendation: as
  proposed, citing D-001 beside D-082 at rows 36–37.
- D-003's second ruling at row 56 (removing "therefore") or row 58.
  Recommendation: row 56, since it states the ruling for the whole primitive.
- D-056's sentence at row 75 (under today's **Why.** label) or row 76.
  Recommendation: row 75, with the label gone.
- D-036's first ruling at row 117 or row 120. Recommendation: row 120, whose
  words are the Position's; row 117 states the scatter mechanism.
- R bolds, kept with their R citation and flagged for track 2 (`spec_style.md`
  allows it): row 31 (time and state events, D-220 Rationale), row 66 (no mode
  store, D-231 annotation, with D-249 cited), row 99 (immutability plus frozen
  references, D-243 Rationale with D-231 cited), rows 138–139 (the write-side
  rule, D-045 Rejected; one bold). Recommendation: bold all four. Row 116 (the
  periphery atom) and row 69 (no dynamics of its own) go plain: 116's claim is
  the reason inside D-045's Rejected item, not its ruling, and 69 is part of
  D-003's taxonomy (row 48) and §10.5's bold (D-019).
- Row 112 cites D-016, whose `unlisted` rejection is a *Superseded position*
  item; D-034's Rejected list states it directly. Recommendation: cite D-034
  beside D-016 (the rewrite adds citations, never removes them).
- D-302 at row 96 stays plain: §7.3 1871 holds a bold citing D-013 and D-302.

**q7. The rule of meaning (row 59, F6).** No entry records it, and D-141's
Position spells a commanded continuous reset as an event whose guard reads the
input, so on the continuous tier a commanded change takes both mechanisms.
Options: (a) keep the three sentences as written, remove the label, and add one
declared clause from D-141's Position: "On the continuous tier the commanded
change still lands through an event whose guard reads that input ([§5.3],
[D-141])"; escalate whether "do not overlap" is a ruling the owner wants
recorded; (b) keep as written and escalate only; (c) drop "and do not overlap".
Recommendation: (a). The clause restates a recorded Position, keeps the
sentence the spec has, and stops a cold reader from concluding that a
commanded continuous change bypasses events; whether the principle earns an
entry is the owner's call, since none records it.

**q8. Mutable caches in the consumer's state (F11).** "Caches belong in the
consumer's state" (622) names a home D-231 (isbits or `Symbol` store fields),
D-183 (no information between workspace calls) and D-342 bullet 2 (no mutable
cache across stages) close. A fix changes what the design admits, so it is a
serious finding: the text stays as written, and the finding goes to
`escalations.md`. Recommendation to the owner: strike the clause, leaving "the
interpolant is restructured to be pure", unless a discrete consumer's isbits
cache in `s` is meant, in which case say so.

**q9. Two clauses that make outside citations right.** (i) §2.2 never says why
`f_step!` is excluded; spec 6121 (§10.6) and log 772 (D-020) cite §2.2 for the
step-size dependence. Option: one clause in §2.2's third bullet, "because its
semantics depend on the step size ([D-001])", from D-001 Rejected log 370.
Recommendation: apply. (ii) Spec 1091 (§5.3) cites §3.1 for "only handlers
write `x`", which §3.4 410–411 states and §3.1 does not. Options: (a) retarget
1091 to §3.4 at landing (step 7, outside edits first); (b) add "only" to §3.1
310–311. Recommendation: (a): §3.1's facet list is about what a handler may do,
and "only" there would need `x_projection` and integration excepted.

**q10. The units.** Seven units as in part C: A 597, B 631, C 519, D 612, E
748, F 605, G 573. The alternative is C and D as one unit of 1,131 words.
Recommendation: seven. §3.4 is the run's densest R section and needs its own
verifier.

**q11. History and plans in §4.4.** "It dovetails with the terrain ray-query
direction of the landing-gear redesign" (663–664) has no source in the spec,
the log or the companions (`git grep` for "ray-query", "landing-gear redesign"
at `d3af35a`: only this line); "today's `AbstractTerrain` polymorphism"
(667–668) is FlightPhysics' (`terrain.jl` 26). Options: (a) introducing
clauses that claim only the owner: "Flight.jl's landing-gear redesign",
"Flight.jl's `AbstractTerrain` polymorphism"; (b) move both sentences to
`flight_case_studies.md`; (c) keep as written. Recommendation: (a); chapter 6's
lesson prefers an introducing clause to a companion move for context that gives
a rule its scale.

**q12. Appendix C kinds to name where the condition is stated.**
`ProducedByTwoStages` at 528 (its row cites §4.3; today unnamed) and
`UndeclaredReturnField` at 488 (its row cites §8.3; the condition is also
stated here). Each name is a declared addition that changes no ruling.
`IllegalPortType` is already named (545, 553). Recommendation: name
`ProducedByTwoStages`; name `UndeclaredReturnField` too, since §4.2 states its
condition in full. Leave `DeclarationOnWrongTier` unnamed in §3.2 and §3.4: its
row cites neither, and §8.2 states it in full.

**q13. Held as written, for the record.** "Fan-out is free" (570) stays plain
and uncited (owner's open item, `pending.md` 97); no entry is proposed. "closed
for the first cut" (660) stays: D-008's Rejected item sets no time limit, but
the hedge is not clearly wrong, so it goes to `rulings.md` if a rewriter
questions it.

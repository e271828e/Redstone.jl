# Survey of spec chapter 5 before its readability rewrite — 2026-10-12

Scope: `docs/design/spec.md` lines 672–1220, "## 5. Evaluation order and
feedthrough", at commit `b08afca` (frozen base; peers edit the working tree),
4,717 words. The convention is `docs/design/tools/spec_style.md`; the method is
`docs/spec_rewrite/recipe.md` step 1; the models are chapter 10's survey
(`git show 0f9ce8a:docs/spec_rewrite/ch10/survey.md`) and chapter 7's
(`git show 733be21:docs/spec_rewrite/ch07/survey.md`).

Line numbers are `spec.md` lines at `b08afca` unless marked `log`
(`decisions.md` at `b08afca`) or given with a file name. Entry claims rest on the
entry's Position as read, with its log line where the point sits outside the
Position's first sentence. Every entry a row is classified under was read in
full or at its Position and the cited lines. The chapter cites 15 entries
(D-005, D-012, D-015, D-034, D-035, D-055, D-067, D-074, D-075, D-090, D-141,
D-195, D-220, D-245, D-252); 39 entries name a §5 section in their Spec field
(among them D-016, D-086, D-089, D-112, D-140, D-147, D-154, D-194, D-248,
D-258, D-285, D-287); 11 more rule or bear on the chapter's content without
either (D-004, D-006, D-020, D-048, D-111, D-164, D-191, D-263, D-288, D-297,
D-312). Copies are in
`scratch_survey/entries/`, printed by `scratch_survey/entry.sh`. `src/` was
read, and run, where a claim about code was in doubt
(`scratch_survey/run_pi.jl`, `scratch_survey/run_bundle.jl`).

Classification codes used in part A:

- **C** cited, and ruled by the cited entry's Position (at the spot or in the
  same paragraph, marked "adjacent").
- **U** ruled by an entry's Position that the section does not cite at that
  spot.
- **S** cited to a superseded entry.
- **R** ruled only in an entry's Rationale, Rejected list or annotation.
- **N** no entry found. Where the sentence reads as a description of an
  inherited shape rather than a ruling, the row says so.
- **B** borderline; both readings are given.

"Marking" is how the spec marks the rule now: **Rule.**/**Why.** label, bold
sentence, bold lead-in (a bold phrase opening a paragraph or bullet, used as a
heading), bold words, or plain. The chapter carries 10 **Rule.** labels (714,
729, 785, 797, 856, 885, 911, 953, 983, 1159) and 4 **Why.** labels (719, 903,
994, 1029), and about 45 other bold spans of about 185 words
(`scratch_survey/bold_spans.txt`).

Section sizes (words, `wc -w` over the line ranges): heading 672–673 (6, no
intro); 5.1 674–682 (71); 5.2 683–830 (1,278); 5.3 831–1042 (1,771); 5.4
1043–1112 (594); 5.5 1113–1132 (167); 5.6 1133–1220 (830, the closing `---`
included).

Rows that are context, reasons, examples, pointers or code stay in the tables
for the rewriters but are left out of the tally (part A, "Tally").

## A. Per section

### Chapter heading (672–673, no intro)

The chapter opens straight into `### 5.1`. Chapters 7 to 10 each open with a
context paragraph and a roadmap. The only roadmap for chapter 5 is the Part I
roadmap at 130–132: "[§5] is the central chapter. It fixes two output stages
per component, what each stage may see, and how those signatures alone yield a
static execution order." It names neither the loop sections (§5.4–§5.6) nor
the step boundary (§5.3). Part G q1.

Sources a new opening may draw on, so that it claims nothing new: spec
130–132; spec 158 ("A build that derives the execution order from declared
feedthrough and rejects algebraic loops by naming the cycle"); the six section
titles; §5.3's own opening at 833–836.

### §5.1 The ordering problem (674–682, 71 words)

Purpose: states the problem (consistent signals at every instant) and the
answer (a static order from a topological sort, run as a flat list).

Subheadings: none. Labels: none.

| # | line | quote | marking | entry | class |
|---|---|---|---|---|---|
| 1 | 676–677 | "At every evaluation instant, all signals must be computed consistently. Every consumer reads values already produced at that instant." | plain | D-004 Rejected log 406–408 (per-cell freshness tied to the producer's schedule position) | context |
| 2 | 677–680 | "The build constructs the directed graph of wiring edges and intra-component feedthrough relations. If the graph is acyclic, a topological sort yields a **static execution order**, computed once at build time." | bold words | D-048 Position bullet B log 1488–1489 ("feedthrough graph → topo/cycle"); the term D-258 Position log 9985–9990 | U |
| 3 | 680–681 | "The hot loop runs a flat list of `(component, stage)` entries, with no runtime graph logic." | plain | D-086 Position log 2597–2600 ("§5.1 … reachable only under full specialization") | U |

The section never says what happens when the graph is cyclic; §5.5 does. A
forward pointer is a declared addition (part C). Bold homes: D-048 is bold in
§9.1 (3787) and D-086 in §9.7 (4792), so §5.1 takes no bold.

Display-block candidates: none.

Appendix C kinds cited to §5.1: none.

### §5.2 Two-stage outputs: signatures, bundles and the hand-off laws (683–830, 1,278 words)

Purpose: fixes the two output stages and the four laws of the authoring
surface: the hand-off (two arguments), the bundle law (which names arrive), the
stage return law and the handler return law; then says where each view comes
from and states one home per datum.

Subheadings (`####`): "The hand-off: one component, one bundle" (712), "The
bundle law: which names a component receives" (727), "The stage return law"
(783), "The handler return law" (795), "What the views are" (813). Labels:
**Rule.** 714, 729, 785, 797; **Why.** 719. One table (732–742), one `julia`
block (689–706).

| # | line | quote | marking | entry | class |
|---|---|---|---|---|---|
| 4 | 685 | "Every component provides exactly **two output stages**." | bold words | D-006 Position log 430–431 ("Strict two-stage structural feedthrough") | U. D-006 is cited nowhere in the chapter |
| 5 | 685–687 | "Feedthrough is declared **structurally, by function signature**. There are no dependency annotations anywhere in the design." | bold words | D-006 Position (structural); the no-annotations clause D-006 Rejected log 440–441 ("Per-output declarations + tracer verification: under-declaration = silent wrongness") | B: U for "structurally"; R for "no annotations" |
| 6 | 689–706 | the signature block: the six stage and update signatures with each function's maximal legal bundle set, then guard, handler and `x_projection` | code | sets: D-074 Rationale log 2222–2225, D-220 Rationale log 8179–8183; `x_projection` positional D-074 Position | code (part C, "Code blocks") |
| 7 | 708–710 | "The laws that govern that surface follow. They fix how a function receives its arguments, which names it receives, what an output stage returns, and what a handler returns." | plain | — | context (the section's roadmap sentence) |
| 8 | 714–717 | "**Rule.** Every function receives exactly two arguments, the component and one NamedTuple bundle of zero-copy views. From that bundle the author **destructures by name** only what the body reads" | **Rule.** label, bold words | D-074 Position log 2216–2218 | U. D-074 is cited at 724, two paragraphs on |
| 9 | 719–721 | "**Why.** The executor … issues one fixed call shape, `fn(comp, args)`. Language semantics ignore unread fields. Argument order cannot be confused, because there is no order." | **Why.** label | D-074 Rejected log 2246–2247 (swappable `t`/`Δt`) | reason |
| 10 | 723–724 | "Positional, `kwarg_decl`-reflected and slurping-keyword spellings are all closed ([D-074])." | plain, cited | D-074 Rejected log 2232–2237 | R (cited) |
| 11 | 724–725 | "`x_projection` alone stays positional. It takes one store in and returns the same store out, so there is nothing to select." | plain | D-074 Position ("`project(comp, x)` alone stays positional"), cited adjacent; the reason is not recorded | C (adjacent) |
| 12 | 729–730 | "**Rule.** Under the bundle law, a name appears in a component's bundle **iff the corresponding store or fact exists for that component**." | **Rule.** label, bold words | D-074 Rationale log 2222 ("a field exists iff the store or tier fact exists"); D-090 Position says only "under the bundle law" | R |
| 13 | 732–742 | the presence table: `x`/`s`/`m` iff the component "declares" `x_init`/`s_init`/`m_init`; `ws` iff `ws_init`; `u` iff the family may see inputs and `u_types` is declared; `y` iff `y_types`; `y_x`/`y_s` iff stage-1 ports exist; `t` always; `Δt` on the discrete tier | table | D-074 Rationale log 2222–2224; `y_x`/`y_s` D-285 Position bullet 3 log 11985–11986; the state letters D-297 Position bullet 6 log 12545 ("A store puts its letter in the bundle only when it is non-empty") | B: R by D-074 for the table; U by D-297 for the `x`/`s`/`m` rows, which misstate it (part E, F2) |
| 14 | 744–746 | "**The stage-1 hand-down carries the stage-1 *return*.** `y_x`, or `y_s` on the discrete tier, comes from the stage-1 probe's return ([D-252])." | bold sentence, cited | D-252's Position says nothing of the hand-down; it supersedes D-169, whose Position did (log 6058). D-285 Position bullet 3 log 11985–11986 states it; D-194 bullet 2 log 7021–7023 ("stage-1 products through `y_x`") | B: cited to an entry whose Position is silent; U by D-285 |
| 15 | 746–747 | "A component with no stage-1 ports has no `y_x`/`y_s` in its stage-2 bundle at all." | plain | D-074 Rationale (absent, never filled) | R |
| 16 | 749 | "Undeclared stores are *absent*, never `nothing`-filled." | plain | D-074 Rationale log 2222–2223; Rejected log 2242–2243 | R |
| 17 | 749–754 | "Destructuring a field that does not exist for the component fails at the probe, inside the §13.2 framing diagnostic. The diagnostic carries did-you-mean … against the legal field set." with the `Foo` example | plain | D-248 Position bullet 4 log 9401–9405 (`BundleFieldError` at the probe) | B: U by D-248; the "framing diagnostic" is stale (part E, F1) |
| 18 | 754 | "One law covers tier facts, stage legality and declarations alike." | plain | D-074 Rationale log 2222–2225 | R |
| 19 | 756–763 | the mechanism: `FieldError` with type and field as data (Julia ≥ 1.12), caught *matched against the bundle's own NamedTuple type*, classified as an undeclared store, a wrong-tier fact or a name illegal for the family; no message scraping; bare NamedTuple ([D-074]); getproperty wrapper the recorded fallback | plain, cited | D-074 Rationale log 2225–2229 for all but the three classes; the classes have no entry (Appendix C 12435–12439 lists them) | B: R by D-074 Rationale; N for the three classes |
| 20 | 765–767 | "The wrong-tier class covers the state letters too ([D-195]). `x` and `m` are continuous-only, and `s` and `Δt` are discrete-only" | plain, cited | D-195 Position bullet 2 log 7100–7101 (the two tiers' name families disjoint) by inference; bullet 3 log 7102–7104 rules the declaration-side class (`DeclarationOnWrongTier`), not the bundle-side one | B |
| 21 | 769 | "The per-function name sets are **closed**, one set per function per tier." | bold word | closed: D-074 Rationale log 2224–2225; per tier: D-220 Rationale log 8179–8183 ("`output_state` and `output_direct` take one legal set per tier again"). D-195 Position bullet 2 log 7100–7101 says per-function sets, retired in part by D-220 without an annotation on D-195 | R |
| 22 | 769–773 | "The update laws carry their tier in the name … The two output stages are shared machinery over both tiers ([D-220]), so `y_state` and `y_direct` have one set per tier." | plain, cited | D-220 Position bullet 2 log 8138–8139 | C |
| 23 | 773–775 | the four output-stage sets spelled out | plain | as row 21; Appendix B 11782–11795 repeats them | part of row 21 |
| 24 | 775–776 | "Adding a name to any of them is a decision-log entry, not a convenience." | plain | D-074 Rationale log 2224–2225 ("growth = a decision-log event") | R |
| 25 | 776–781 | the comments state the maximal set; the bundle narrows it to declared reality; destructuring narrows to reads; "That three-level funnel … is worth teaching once" | plain | D-075 Rationale log 2267 ("three-level narrowing taught"); Appendix A 11618 (*The stage funnel*) | R |
| 26 | 785 | "**Rule.** An output stage returns its port NamedTuple, `y`, and nothing else." | **Rule.** label | D-194 Position log 7015–7017, bullet 1 log 7019–7020 | U |
| 27 | 787–788 | "`y` scatters into the component's declared cells as always, and every value a later function needs is one of those cells ([§8.3])." | plain | D-194 Position bullet 2 log 7021–7023 | U |
| 28 | 788–789 | "Stages are discovered by method existence, and stage membership is a partition of the declared ports." | plain | only D-165 Position log 5740–5741, superseded → D-194; D-194 does not restate it; D-252's two classes (log 9618–9619) imply the partition | B: the one Position stating it is superseded; U by D-252 for the partition |
| 29 | 791 | "An empty `y = (;)` is a `DeadStage` build error at the probe ([§9.3])." | plain | D-285 Position bullet 2 log 11983–11984; D-194 bullet 5 log 7032–7033. §9.3 4296–4297 bolds it | U |
| 30 | 791–793 | "A stage returning nothing at all computes nothing any consumer can read. That is the inert-component check ([§8.1]), applied to a single stage." | plain | §8.1 2166–2169 (D-164) | reason |
| 31 | 797–799 | "**Rule.** A handler returns a NamedTuple carrying the stores it writes. A key is present **iff** the corresponding store exists on the component **and** the handler updates it." | **Rule.** label, bold words | D-090 Position log 2716–2718, cited at 804 in the next paragraph | U |
| 32 | 801–804 | the pure-FSM, `x`-only and both-stores examples | plain | D-090 Position | example |
| 33 | 804–805 | "Padding forms such as `((;), m⁺)` and `(x⁺, (;))` do not exist ([D-090], on the argument-side ground of [D-074])." | plain, cited | D-090 Rejected log 2728–2730 | R (cited) |
| 34 | 807–811 | per key: `x` complete against the state field set; `m` under the names-subset predicate; an unknown key gets did-you-mean against `{x, m}`; "the same `FieldError`-shaped machinery … now running in both directions ([§9.5])" | plain | D-287 Position bullets 1–2 log 12087–12090; `m` names-subset and "both directions" D-090 Rationale log 2722–2725 | B: U by D-287; R by D-090 |
| 35 | 815 | "The views themselves are unchanged in meaning." | plain | none. A residue of commit `7b63c99` (2026-07-28), where it meant unchanged from the positional design the bundle replaced | context; part G q3 |
| 36 | 817–823 | the five view sources: own state (buffer, mode stores, discrete store), own published signals (own cells, the declared ports, §8.2), inputs (foreign cells through the name binding), the clock (`t`, `Δt`, §10.5), scratch (`ws`, §7.3) | bullets | D-035 Position log 1129–1132, cited at 829 | U |
| 37 | 825–827 | "The signal table holds only *produced* signals, never transported ones. Each datum has exactly one home. … No store mirrors another." | plain | D-035 Position log 1132–1133, cited adjacent | C (adjacent) |
| 38 | 827–829 | "Every bundle field earns its place as a view genuinely readable, and no minimization of the set survives without introducing a copy ([D-035])." | plain, cited | first clause D-035 Position ("the stores it genuinely reads"); second D-035 Rejected log 1151–1154 | B: C; R for the minimization clause |

Descriptions that read like rules: row 28 (no current Position) and the
mechanism details of row 19 (the Julia version, the fallback).

The section mixes the authoring rule (rows 12–16) with the probe's machinery
(rows 17–20) inside one subsection of 541 words. The machinery is §13.2's and
§9.3's subject too (§13.2 9252–9262 states the `FieldError` recognition with
D-248). It stays here as the reason the law is enforceable; part C keeps it,
after the rule.

Display-block candidates: none needed beyond the existing block. Optional: the
three-level funnel as a one-line display (`stage name at its tier ⊇ bundle ⊇
reads`).

Appendix C kinds cited to §5.2 (spec 12348, 12425, 12435, 12440):

| kind | condition stated in §5.2? | named? |
|---|---|---|
| `DeclarationOnWrongTier` | no. §5.2's wrong-tier class (765–767) is `BundleFieldError`'s classification. The kind's condition is stated in §5.3 868–870 | no (cite belongs to §5.3; part D) |
| `DeadStage` | yes, 791 | yes |
| `BundleFieldError` | yes, 749–763 | no; 751 and 759 call it "the §13.2 framing diagnostic", which is `UserCodeFraming` (F1) |
| `HandlerReturnKey` | yes, 809–810 ("An unknown key gets did-you-mean against `{x, m}`") | no |

### §5.3 Structural feedthrough: stage roles, execution order and step boundaries (831–1042, 1,771 words)

Purpose: reads the two-stage surface. What a stage name asserts and what each
stage may see; the execution order; where projection, guards and handlers sit in
a step boundary; two supervisory idioms; why derivatives may read outputs.

Subheadings (`####`): "Stage roles: the names" (838), "Stage roles: what each
stage may see" (872), "The execution order" (909), "Step boundaries" (924),
"Supervisory inputs: scheduled gains and commanded resets" (965), "Why
derivatives may read outputs" (1016). Labels: **Rule.** 856, 885, 911, 953,
983; **Why.** 903, 994, 1029. One table (849–854), one blockquote (946), one
`julia` block (988–992), display math at 1019–1021.

The opening (833–836) names the parts as "the names", "what it may see", the
order, and the step boundary. It omits the last two subsections, the
supervisory idioms and the justification.

| # | line | quote | marking | entry | class |
|---|---|---|---|---|---|
| 39 | 833–836 | "[§5.2] fixes the two-stage surface … What remains is the reading. … The rest of the section orders the stages, then puts that order inside a step boundary." | plain | — | context |
| 40 | 840–847 | "**Mathematical symbols and API names are two vocabularies, deliberately.** … `f` is the continuous flow and `g` the discrete update … `h` is … the output map … The API spells the same objects as words, so that a name bound in an author's own module is unambiguous evidence of a forgotten import ([D-220])." | bold lead-in, cited | D-220 Position head log 8133–8135 ("the spec's formulas keep `f`, `g` and `h` as mathematical symbols"); the lineage D-075 Position log 2253–2257; the import reason D-220 Rationale log 8159–8170 | C |
| 41 | 847–854 | "The correspondence is one to one." and the four-row table | plain, table | D-220 bullets log 8137–8139, as renamed by D-267 log 10723–10727 and D-279 log 11722–11724 | U |
| 42 | 856–859 | "**Rule.** A stage's **name** states the **dependence class**, not the argument list. … So "no `direct` in the name" *is* the no-feedthrough property, visible at every definition site." | **Rule.** label, bold words | D-220 Position bullet 2 log 8138–8139 ("'direct' naming direct feedthrough"); D-075 Rationale log 2261–2263 ("suffix = the *dependence class*") | U |
| 43 | 861–863 | "The names are deliberately non-exhaustive. Modes fold under the state. … Ambient facts (`t`, `Δt`) and scratch (`ws`) ride unnamed." ([D-075]) | plain, cited | D-075 Rationale log 2263; Rejected log 2273–2275 (`h_xm`/`h_xmu`) | R (cited) |
| 44 | 865–867 | "The update law carries the tier in its name … The two output stages do not. One pair of names serves both tiers … ([D-220])." | plain, cited | D-220 Position bullet 2 | C |
| 45 | 867–868 | "A stateful leaf's declarations must agree on one tier throughout ([§8.2])." | plain | D-112 Position log 3408–3411; D-263 bullet 5 log 10395–10397. §8.2 2774 bolds D-112 | U |
| 46 | 868–870 | "A leaf mixing the update laws, or declaring a store of one tier and the update law of the other, is a build error, not a reading." | plain | D-195 Position bullet 3 log 7102–7104; D-220 Rationale log 8183–8187; the kind is `DeclarationOnWrongTier` (Appendix C 12348–12354, §8.2 2781–2787) | U; kind unnamed |
| 47 | 874–878 | "**`y_state` is the no-feedthrough stage**, defined entirely by what it cannot see. Its bundle … carries no `u`, so "no feedthrough" cannot be violated by construction. … They break would-be loops." | bold lead-in | D-035 Position log 1134 ("`h_x`/`h_z` = the no-feedthrough stage"); D-006 Position | U |
| 48 | 880–883 | "Stage 1 exists when the component has state-derived ports … Otherwise it is simply absent. A stage that would produce none is the `DeadStage` error. An empty stage is unwritable on purpose." | plain | stage-1 existence: none; `DeadStage` D-285 bullet 2 | B: N; U by D-285 |
| 49 | 885–886 | "**Rule.** A declared output is produced by stage 1 or by stage 2, and by nothing else ([D-252])." | **Rule.** label, cited | D-252 Position sentence 1 log 9618–9619. §8.3 2834–2835 bolds it | C |
| 50 | 886–887 | "A component exposes a state or mode field by returning it from `y_state`. The line is one method, `y_state(c, b) = (; q = b.x.q)`." | plain | D-252 Position sentence 2 log 9619–9620, adjacent | C (adjacent) |
| 51 | 887–889 | "A declared output that no stage produces is `DeclaredNotProduced` ([§8.3]), at every tier and every level of the tree." | plain | D-252 Position sentence 3 log 9620–9621, adjacent | C (adjacent) |
| 52 | 891 | "**`y_direct` receives all wired inputs plus the stage-1 hand-down.**" | bold sentence | D-006 Position ("all-inputs `h_xu`"); hand-down D-285 bullet 3 | U |
| 53 | 891–895 | "The hand-down is the component's own stage-1 ports. A shared intermediate is therefore computed once and read … Stage 1 declares it as a port, and stage 2 finds it in `y_x` … Stage 2 receives the state views too." | plain | D-194 Position bullet 2 log 7021–7023; D-035 Position | U |
| 54 | 896 | "Conservatively, every stage-2 output is presumed dependent on every wired input." | plain | none. D-006 Rejected log 440–443 rejects the finer alternatives; glossary *feedthrough* 12855 repeats it citing §5.3 | N |
| 55 | 898–901 | "**`x_deriv` and `s_update` run after the sweep**, when the full signal table is complete and fresh, the component's own stage-2 ports included. The fused idiom stands. Compute each law once, in a stage. Publish it." | bold lead-in | D-015 Position log 595–598 (cited at 904, next paragraph); `s_update` after the sweep D-020 Position log 752–753 | U |
| 56 | 903–904 | "**Why.** The interfaces *reward* single-source-of-truth rather than making duplication unwritable. Nothing ever needs computing twice ([D-015], [D-035])." | **Why.** label, cited | D-015 Position ("the *rewarded* idiom, not an impossibility claim") | C. A ruling under a **Why.** label |
| 57 | 906–907 | "All output stages must be pure, with no side effects. State types make mutation impossible anyway ([§7])." | plain | D-015 Rejected log 605–606 ("hidden state, purity violation") | R |
| 58 | 911–913 | "**Rule.** Execution runs all stage-1 functions in any order, then stage 2 in topological order, then all `x_deriv` calls against the now-consistent signal table." | **Rule.** label | D-288 Position bullet 1 log 12124–12126 ("the order-free stage-1, `x_deriv` and `s_update` blocks, the topologically ordered stage-2 block"), first recorded in D-086 Rationale log 2604–2605. §9.7 4826–4836 bolds it | U |
| 59 | 915–917 | "The systemic consequence is that *evaluating the RHS means running the sweep*. There is no incremental `x_deriv`-only re-evaluation." | plain | none. D-194 Rationale log 7045–7046 cites §5.3 for it | N |
| 60 | 917–918 | "Nothing is lost by that, because implicit solvers, linearization and trim already work this way. They seed `x` and run the composite." | plain | — | reason |
| 61 | 918–919 | "[§10.3] and [§10.4] restate that consequence as a property of the execution model." | plain | — | pointer |
| 62 | 919–922 | "RHS evaluations and guard trial evaluations alike run the *interior* sweep, the continuous-only variant of [§10.5]. Discrete entries are absent from it by construction, so discrete cells hold across the step." | plain | D-147 Position log 5082–5088. §10.5 5642 and §10.4 5321 bold it | U |
| 63 | 926–931 | "**Guards and handlers read the same fresh world.** At a step boundary the order is *integrate → project → boundary sweep → guards*. So by guard and handler time `y` is a fresh decode of exactly the state being transformed … A reset map is `(; x = (; x..., ω = 0.0))`" | bold lead-in | D-016 Position log 619 ("guards and handlers read the fresh boundary table"), the half its annotation (log 627–629) keeps; D-154 Position sentence 2 | U |
| 64 | 933–937 | "**`x_projection` runs between a state write and its decode.** That is after integration, and after any handler `x`-reset. … `x_projection` is not *unique* in receiving raw state … It is unique in that position of the execution order." | bold sentence | D-016 Position log 620–621 ("`project` is the sole raw-state function (schedule-structural)"), kept by the annotation; the two positions D-111 Position log 3387–3388 | U |
| 65 | 939–944 | "**The boundary sequence.** At each boundary the framework integrates, projects, runs the boundary sweep, evaluates **all guards once** against that sweep, and fires the eligible events. Each firing is `handler → x_projection`. The sweep → guards → handlers phase then iterates to quiescence" | bold lead-in, bold words | D-020 Position log 749–753. §10.6 5934–5941 states and bolds it | U |
| 66 | 946 | "> integrate → project → **[ sweep → guards → handlers ]** iterated to quiescence" | blockquote, bold | as row 65. §10.6 6189–6190 gives the final form (firing budget, `s_update`, logging) | part of row 65 |
| 67 | 948–949 | "The signal table is written **only by sweeps**, so a transition reaches the table at the next round's re-sweep ([§10.6])." | bold words | D-154 Position sentence 1 log 5408–5409. §10.6 bolds that sentence's other clause (5938) and states this one plain (6055) | U |
| 68 | 949–951 | "The round that detects quiescence leaves the table post-transition-consistent for whatever else the boundary does, such as discrete ticks and logging." | plain | D-020 Position (ticks after quiescence). §10.6 6165 bolds it | U |
| 69 | 953–955 | "**Rule.** Hence the epoch rule ([§10.6]). A handler executes against exactly the world its guard fired on. Own `y`, foreign `u` and own `x`/`m` alike come from the firing round's sweep, so `y = h(x)` holds at every handler entry." | **Rule.** label | D-154 Position sentence 2 log 5414–5416. §10.6 6062–6063 bolds it | U; "Hence" demotes it to a consequence |
| 70 | 957–963 | "[§10.6] settles the iteration itself … Within a round each component fires at most one event, and declaration order picks among that component's simultaneously eligible events. Same-component sequential composition happens *across* rounds. Each later event is re-decided against the post-transition sweep" | plain | D-154 Position log 5408–5419; D-191 (blocked, not lost; §10.6 6072) | U |
| 71 | 967–970 | the supervisor: "Both are ordinary signal flow here, because the stores-and-views rules admit neither parameter mutation nor hand-ordered resets." | plain | D-089 Rejected log 2704–2707 | context |
| 72 | 972–974 | "**Scheduled gains are inputs.** A scheduler component owns the lookup tables as inert parameters, reads the scheduling variables as inputs, and publishes one gain bundle per compensator. Compensators consume gains as `u`." | bold lead-in | D-089 Position log 2690–2694. D-089 is cited nowhere in the chapter | U |
| 73 | 975–979 | gain trajectories observable in log, trace and replay; the feedthrough graph carries the dependency; linearization holds unseeded gain inputs constant ([§14.10]) | plain | D-089 Position (the parenthetical) | U |
| 74 | 979–981 | "One-shot design-time gains … are construction-time parameters or stopped-sim service outputs. They are not a runtime write path." | plain | D-089 Rationale log 2698–2699 | R |
| 75 | 983–986 | "**Rule.** A commanded reset of a discrete component is a same-tick input, consumed in the output stage. The supervisor publishes `engage` and the latch value from its own feedthrough stage. The compensator … honors them **this tick**" | **Rule.** label, bold words | D-089 Rationale log 2699–2701 | R |
| 76 | 988–992 | the `PI` block | code | — | code (run; part C) |
| 77 | 994–1002 | "**Why.** Honoring the reset only in `s_update` is legal, and it means something else. … The update stage cannot rescue its own boundary, because republishing from `s⁺` is rejected ([D-067]). The output stage is therefore the *only* same-tick path." | **Why.** label, cited | legal-but-late D-089 Rationale log 2700–2701 and Rejected log 2708–2710; republish rejection D-067 Rejected log 1990–1992 | R (cited) |
| 78 | 1003–1004 | "[Appendix A] carries this as the same-tick reset entry, and the bumpless-engage answer ([§11.7]) presupposes exactly this spelling." | plain | — | pointer; §11.7 holds no such answer (F3) |
| 79 | 1006–1009 | "**A continuous component's reset is an event.** The continuous tier admits no input spelling at all, because only handlers write `x` ([§3.1]). A commanded reset of continuous state … is therefore an edge-triggered event owned by the reset component." | bold lead-in | D-141 Position log 4690–4696, cited adjacent at 1012 | C (adjacent); "therefore" demotes the rule |
| 80 | 1010–1012 | "A landing gear's friction regulator, re-initialized at touchdown by weight-on-wheels, is the canonical case ([D-141])." | plain, cited | D-141 Position log 4701–4702 | example |
| 81 | 1012–1013 | "A flag-gated reset face on a library PI block is sugar over exactly that event." | plain | D-141 Position log 4696–4700 (the reimplemented `PIVector`), adjacent | C (adjacent) |
| 82 | 1018–1023 | "**Departure from the orthodox formalism, stated openly.** The textbook form is $\dot{x} = f(x, u)$, $y = g(x, u)$. This design's `f` receives … $\dot{x} = f(x, m, y, u, t)$. The composite map … is mathematically identical, so linearization, trim and AD are untouched." | bold lead-in | D-015 Position (cited at 1033) | U; the textbook form uses `g` for the output map (F4) |
| 83 | 1025–1027 | the teaching line | plain, italics | — | context |
| 84 | 1029–1034 | "**Why.** Derivative/output overlap is the *norm* … That overlap is what makes the orthodox split expensive here ([D-015]). FlightCore's fused `f_ode!` already embodied the same economics." | **Why.** label, cited | D-015 Rejected log 610–611 | R (cited) |
| 85 | 1036–1038 | "**Shared expensive computations** are thereby solved uniformly. Compute once in stage 2, publish, and let `x_deriv`/`s_update` consume the ports. External consumers read the same ports, as an accelerometer model reads `f_c_c`." | bold lead-in | D-015 Position | U |
| 86 | 1039–1041 | "The **computer/integrator split** remains fully expressible without framework support. [§7.4] carries the full statement" | bold words | D-015 Rejected log 610–611 (the split rejected as the *standard* idiom). §7.4 1888–1889 states it, citing D-015 | R |
| 87 | 1041 | "Purity rules forbid the classic resolution by mutable caching, by design." | plain | D-015 Rejected log 605–606 | R |

Descriptions that read like rules: rows 54 and 59 (no entry; both glossary
entries repeat them), row 48's "Stage 1 exists when".

The step-boundary block (rows 63–70, 375 words) restates §10.6, which chapter
10's rewrite bolded (D-020 at 5934 and 6165, D-154 at 5938 and 6062, D-191 at
6072). §5.3 keeps the boundary sequence because five spec citations name §5.3
for it (part D); the epoch rule and the per-round rules can drop to plain
statements with a pointer (part B, part C M3).

Display-block candidates: the step-boundary order (926–927, "integrate →
project → boundary sweep → guards") already sits in the blockquote at 946; one
display is enough.

Appendix C kinds cited to §5.3: `DeclaredNotProduced` (12419, the remedy),
named at 888. Two kinds whose conditions §5.3 states are cited elsewhere:
`DeclarationOnWrongTier` (condition 868–870, unnamed, cited to §5.2) and
`DeadStage` (named at 882, cited to §5.2 and §9.3).

### §5.4 Artificial loops and the escape hatch (1043–1112, 594 words)

Purpose: defines the artificial loop, then the remedy ladder: the two-stage
split, contract re-factoring, splitting the component; the diagnostic's two
exits; why the split is rare; stage-2 conservatism.

Subheadings: none. Labels: none. Two bold-lead bullets (1057, 1084), one
untyped fence (1068–1076).

| # | line | quote | marking | entry | class |
|---|---|---|---|---|---|
| 88 | 1045–1047 | "A component that bundles a no-feedthrough output with a feedthrough output in one atomic evaluation unit can be **port-level acyclic yet admit no evaluation order**. Simulink calls this an "artificial algebraic loop"." | bold words | D-006 Rejected log 443 ("Component-atomic conservative: false loops everywhere"); D-019 Rejected log 727–729 | R |
| 89 | 1047–1050 | rigid-body dynamics the canonical instance; "The two-stage split resolves it, and it is the rung that absorbs most of the class." | plain | D-140 Position log 4629–4630 (three-rung ladder); Rationale (i) log 4634–4635 | U. D-140 is cited nowhere in the chapter |
| 90 | 1052–1055 | "What survives the split is the case where a single component's stage-2 outputs cross-couple through a neighbor. … port-level acyclic and stage-level cyclic. The tracer ([§5.6]) labels it **artificial**. Two remedies apply, in this order." | bold word | D-140 Position | U |
| 91 | 1057–1061 | "**Re-factor the contract.** Before moving any code, re-examine the cycle's wires. An input the neighbor consumes *only in a fallback branch* is the archetypal false dependency. … Move the branch to its natural owner and the wire disappears." | bold lead-in | D-140 Rationale (ii) log 4636–4641 | R |
| 92 | 1063–1083 | the strut/steering instance, the before/after diagram, and "The factoring survives substitution, which is the test that it records structure rather than dodging the diagnostic." (`migration_outline.md`) | plain, fence | D-140 Rationale log 4641–4652 | R (the substitution test is the rule; the rest is example) |
| 93 | 1084–1092 | "**Split the component.** This is the residual remedy … Visibility ([§8.3]) is binary, so every intermediate shared across the new boundary becomes `y_types` … The mitigating idiom is the granularity guideline ([§4.3]) … **one struct-valued bundle port** … The bundle type is then contract." | bold lead-in, bold words | D-140 Rationale (iii) log 4652–4660; the mitigation D-194 Position bullet 6 log 7034–7037 | B: R by D-140; U by D-194 for the mitigation |
| 94 | 1092–1094 | "No visibility level is added for the orphaned intermediates. [D-034] and [D-055] (`unlisted`, `Private(T)`) stay closed." | plain, cited | D-194 Position bullet 6 log 7034–7035 ("no `Private` level is added"); D-140 Rejected log 4671–4675. The cited D-034 and D-055 are the entries kept closed, not the ruling that keeps them so | B: cited, ruling elsewhere; U by D-194 |
| 95 | 1096–1098 | "The build diagnostic offers both exits explicitly. It reads "cycle through `systems/aero` is artificial at port level — split the component, or narrow the neighbor's contract"." | plain | D-140 Rationale log 4660–4661 | R; the quote is not `src`'s text (part E, F9) |
| 96 | 1098–1100 | "The dead hop … is carried as a separate payload field rather than dotted onto the path ([§8.6], [§13.2])." | plain | D-245 Position bullet 2 log 9230 (dead hops listed); "rather than dotted" none | B: U by D-245; N for the form |
| 97 | 1102–1105 | "The split is rare, and the ladder is what earns that word rather than asserting it." | plain | D-140 Rationale log 4662–4664 | R |
| 98 | 1107–1111 | "One consequence of stage-2 conservatism is worth recording. An input consumed only by `x_deriv`, never by `y_direct`, still creates a feedthrough edge if the component has stage-2 outputs. … The remedy, if ever needed, is the same ladder." | plain | none | N. `pid_anti_windup.md` 91, 294 and 324 rely on it as a constraint |

The section's title says "the escape hatch", a word the text never uses; D-140
Position calls it "§5.4's escape hatch". The two remedies are bullets, and the
two-stage split, the first rung, sits in prose before them (1049–1050), so the
"three-rung" structure D-140 names is not visible. The section uses "the
tracer" (1054) and "real"/"artificial" before §5.6 defines them, and "algebraic
loop" before §5.5 defines it (part C).

Display-block candidates: the diagram stays a fence. The diagnostic quote
(1097–1098) could be a display line.

Appendix C kinds cited to §5.4: none. The diagnostic it quotes is
`AlgebraicCycle` (cited to §5.5 and §5.6), unnamed here.

### §5.5 Algebraic loop policy: reject at build time (1113–1132, 167 words)

Purpose: a genuine cycle is a build error; the three ways to break it; the
unit delay's caveat; implicit balances inside a component stay legal.

Subheadings: none. Labels: none.

| # | line | quote | marking | entry | class |
|---|---|---|---|---|---|
| 99 | 1115–1116 | "A genuine cycle in the instantaneous dependency graph, an algebraic loop, is a **build error**." | bold words | D-005 Position log 414, cited at 1127 | U (D-005 cited two paragraphs on) |
| 100 | 1116–1118 | "The diagnostic names every wire of the loop as a terminal pair in the canonical slash form of [§8.6], as in `aero/F → dyn/F, dyn/a → aero/a`." | plain | D-012 Position log 529–530 ("one SCC = one named loop"); Appendix C 12406–12410 | U; kind `AlgebraicCycle` unnamed |
| 101 | 1120–1122 | "The user breaks the cycle explicitly, by one of three routes. They can insert dynamics (the α-filter idiom), insert an explicit unit delay (`UnitDelay`, [§13.7]), or restructure." | plain | D-005 Position ("explicit breaks"); the three routes none | B: U for "explicitly"; N for the routes |
| 102 | 1122–1126 | "The unit delay carries a caveat. It changes the model's tier structure. The broken signal becomes discrete, sampled at `Δt_base` … That is a modeling decision, not a transparent wire." | plain | none (D-312 log 13074–13075 rules only `UnitDelay`'s spelling; §13.7 10036–10042 states the same caveat) | N; "sampled at `Δt_base`" holds at the root scope only (F6) |
| 103 | 1126–1127 | "Implicit delays and per-step numerical loop solving are both closed ([D-005])." | plain, cited | D-005 Rejected log 421–424 | R (cited) |
| 104 | 1129–1131 | "Implicit *algebraic balances* inside a component, such as a turbomachinery operating point, remain the component author's business. They are local, owned and bounded." | plain | none | N |

Appendix C kinds cited to §5.5: `AlgebraicCycle` (12406). The condition is
stated (1115–1118); the kind is not named.

### §5.6 Diagnostics: feedthrough tracing (1133–1220, 830 words)

Purpose: tracing is diagnostic only; how a cycle is detected, named and
classified; the verdict; the two tracer variants; the caveats; the two tracer
modes; what tracing never touches; the blind spot.

Subheadings: none. Bold lead-ins act as headings: "Detection and naming."
(1141), "Classification needs no execution order." (1150), "Caveats, carried in
the diagnostic rather than assumed away." (1177), the two mode bullets (1195,
1200), "Boundaries." (1206). Label: **Rule.** 1159.

| # | line | quote | marking | entry | class |
|---|---|---|---|---|---|
| 105 | 1135–1136 | "Tracing is **diagnostic only, never relied on for correctness**. Ordering correctness comes exclusively from the structural two-stage split." | bold words | D-012 Position log 528–529 ("diagnostic-only"); Rejected log 545 ("Tracing as scheduling input: soundness") | U (D-012 first cited at 1148) |
| 106 | 1136–1139 | "The build triggers it when it finds a cycle, to classify that cycle. A genuine cycle gets "insert a state", and an artificial one gets the remedy ladder ([§5.4])." | plain | D-012 Position (classified); D-140 Position (ladder) | B: U; the quoted "insert a state" is not `src`'s text (F9) |
| 107 | 1141–1148 | "**Detection and naming.** A cycle surfaces as a topological-sort stall in the nominal evaluation … decomposed into **strongly connected components**. Each nontrivial SCC names one cyclic cluster exactly … Neither the raw stall residue nor a single back edge names the cluster correctly ([D-012])." | bold lead-in, bold words, cited | D-012 Position log 529–530; the last sentence Rejected log 546–550 | C (adjacent) |
| 108 | 1150–1157 | "**Classification needs no execution order.** … each SCC member is evaluated *once, in isolation*, at the probe point. That evaluation reads state views from `init_*`, out-of-cycle cells from the acyclic prefix's probe values, and in-cycle cells synthesized through `probe_value` ([§9.3]) under tracer tags." | bold lead-in | D-012 Position log 530–532 | U; `init_*` is the pre-D-267 spelling (F5) |
| 109 | 1159–1168 | "**Rule.** The traced maps decide the verdict as one graph question over the cluster. Every wire holds. A hop inside a member … holds iff that member's map routes the face to the port. The loop is **real** iff a cycle survives … **artificial** ([§5.4]) iff none does … The diagnostic lists every dead hop under either verdict … ([D-245]). For a simple cycle this reduces to the expected reading" | **Rule.** label, bold words, cited | D-245 Position bullets 1–2 log 9225–9230 | C |
| 110 | 1170–1175 | "No activation machinery is touched. … This is the *local* variant ([D-012]) … The "tracer activation" ([§9.4]) names the other variant ([D-012]), the global set-tracer run as an ordinary activation. The two must not be conflated." | plain, cited | local variant D-012 Position; the "tracer activation" naming none (§9.4 4446–4452 states it, citing D-012) | B: C for the local variant; N for the naming |
| 111 | 1177–1179 | "**Caveats, carried in the diagnostic rather than assumed away.** The trace speaks for the branch taken at the probe state (the diagnostic-only doctrine, [D-012])." | bold lead-in, cited | D-140 Rejected log 4681–4683 ("the classifier's trace speaks only for the branch taken at the probe point ([D-012]'s diagnostic-only doctrine)") | R |
| 112 | 1179–1182 | "Discrete members trace *structurally*, because the discrete tier's plain, wholesale-pinning declarations admit no tracer scalar. Structural tracing is sound as a may-depend answer but never sharp, so the remedy hint is offered only for continuous members." | plain, cited | D-012 Position log 533–534 ("conservative on discrete members"); hint for continuous members only D-140 Rationale log 4661 | B: C; R for the hint clause |
| 113 | 1182–1184 | "A continuous face or port declared with no walking leaf admits no tracer scalar either, so the hops through it trace structurally too." | plain | D-245 Rationale log 9246–9249 | R |
| 114 | 1184–1186 | "The diagnostic records, per member, whether its map came from the global tracer, from sampled states or from structure … ([D-245])." | plain, cited | D-245 Position bullet 3 log 9231 | C |
| 115 | 1186–1189 | "The hint itself is to split this component, *or* to narrow the neighbor's contract when the dead hop's input is consumed only in a fallback branch (the ladder, [§5.4])." | plain | D-140 Rationale log 4660–4661 | R |
| 116 | 1189–1191 | "If a member's evaluation itself throws, the diagnostic ships with its members and wires alone, unclassified. Classification is a bonus on the cycle error, never its precondition." | plain | D-012 Position log 535 ("classification optional on the error") | U |
| 117 | 1193 | "There are two modes, and they degrade gracefully." | plain | — | context |
| 118 | 1195–1199 | "**Global (value-blind) set-tracer.** … **may-depend semantics**, a sound over-approximation. … It is exact, in one evaluation. It requires the traced stage-2 code to be free of branches and lookups on *input-tainted* values." | bold lead-in, bold words | D-012 Position ("global + sampled-local"); the properties none | B: U for the mode; N for its properties |
| 119 | 1200–1204 | "**Local (primal-carrying) set-tracer at sampled states.** This is the fallback whenever the global tracer hits an undecidable branch … sampled across randomized states. Its only misses are untaken branches ([D-012])." | bold lead-in, cited | D-012 Position; the properties none | B: C for the mode; N for its properties |
| 120 | 1206–1214 | "**Boundaries.** Only *inputs* are seeded … Stage-1 functions are never traced … Derivatives, guards, handlers and projections are outside tracing's jurisdiction entirely. A known tracer blind spot is documented. Value-severing operations pass dependence through a bare `Int` index … Linear and cubic interpolation are immune" | bold lead-in | none (D-012 Rejected log 544 is a different blind spot, `Dual`-based tracing's derivative-zero one) | N |
| 121 | 1216–1217 | "Both modes ride the same `T <: Real` genericity as `Dual`. Dual-cleanliness in CI effectively guarantees traceability." | plain | none | N |

The section uses "global tracer" and "sampled states" (1185) and "tracer tags"
(1155) before the two modes are defined (1193–1204). "Boundaries." (1206)
means the limits of tracing, not a step boundary, a collision with the
chapter's own term (§5.3) and the glossary's `#g-boundary`. The local variant
(1172) and the sampled mode (1200) are two different "local"s: the order-free
per-member trace at the probe point, and the primal-carrying tracer. `src`
agrees with the text: the per-member trace runs the global tracer first and
falls back to eight sampled evaluations (`src/tracer.jl` 208–228).

§9.4 4446–4452 (rewritten) states the two variants plain, citing D-012; §5.6
1170–1175 restates them. Both stay; §5.6 owns the classifier.

Display-block candidates: none.

Appendix C kinds cited to §5.6: `AlgebraicCycle` (12406). The section describes
its payload (members, wires, verdict, dead hops, tracing mode) and never names
it.

### Tally

| section | rules | C | U | S | R | N | B |
|---|---|---|---|---|---|---|---|
| §5.1 | 2 | 0 | 2 | 0 | 0 | 0 | 0 |
| §5.2 | 28 | 3 | 7 | 0 | 9 | 0 | 9 |
| §5.3 | 40 | 8 | 21 | 0 | 8 | 2 | 1 |
| §5.4 | 11 | 0 | 2 | 0 | 5 | 1 | 3 |
| §5.5 | 6 | 0 | 2 | 0 | 1 | 2 | 1 |
| §5.6 | 16 | 3 | 3 | 0 | 3 | 2 | 5 |
| total | 103 | 14 | 37 | 0 | 26 | 7 | 19 |

The count leaves out the 18 rows that are context, reasons, examples, pointers,
code or parts of another row (1, 6, 7, 9, 23, 30, 32, 35, 39, 60, 61, 66, 71,
76, 78, 80, 83, 117), and classes each row by its first code.

No superseded entry is cited. Every cited entry has status `ratified` (checked
in `scratch_survey/entries/`). Two cited entries are superseded in part:
D-012 on its verdict clause (by D-245, said in its own Position, log 535–537),
and D-016's per-event re-decode and auto-publication (annotation log 627–629);
the chapter cites D-012 only for its standing clauses and does not cite D-016.
Row 28 rests on a clause only superseded D-165 states.

Against chapter 7 (79 rules, one in four outside a Position) and chapter 10
(154 rules, C 35, U 58, R 35): chapter 5 is cited where it stands for fewer than
one rule in seven (14 of 103), and about one in four lives only in a
Rationale or Rejected list (26). The R rows cluster in four entries: D-074's
Rationale holds the bundle law nearly whole (rows 12, 15, 16, 18, 19, 21, 24;
D-297 bullet 6 alone restates a piece of it, the state letters); D-140's Rationale
holds the ladder (rows 91–97, 111, 115); D-089's Rationale holds the commanded
reset (rows 74–77); D-015's Rejected list holds the case for fused evaluation
(rows 57, 84, 86, 87). Five entries rule the chapter and are cited nowhere in
it: D-006 (the two-stage split itself), D-089 (§5.3's supervisory idioms, which
its Position names), D-140 (§5.4's ladder, which its Position names), D-154 and
D-194.

### Bold, one per ruling

Today: 10 **Rule.** labels, 4 **Why.** labels and about 45 bold spans (lead-ins,
terms, phrases). The table proposes where each ruling the chapter states takes
its one bold, after checking the rewritten chapters (7–10) for the same entry.

| section | entry | ruling | where |
|---|---|---|---|
| §5.2 | D-006 Position (one sentence, one ruling) | two output stages, feedthrough structural | row 4's headline, 685 |
| §5.2 | D-074 Position, first clause | the named-bundle hand-off | row 8's headline, 714 |
| §5.2 | D-074 Position, after the semicolon | `x_projection` alone stays positional | row 11, 724 |
| §5.2 | D-074 Rationale (R) | the bundle law | row 12's headline, 729; the log owes a Position (part E) |
| §5.2 | D-074 Rationale (R) | the name sets are closed, growth is a log entry | row 21's headline, 769, or none if the rewriter treats it as part of the bundle law's ruling |
| §5.2 | D-285 Position bullet 3 | the hand-down carries the stage-1 return | row 14, 744, cited to D-285 instead of D-252 (q6). §9.3 4277–4279 states it plain |
| §5.2 | D-194 Position sentence 2 | an output stage returns its port NamedTuple alone | row 26, 785 |
| §5.2 | D-090 Position | the handler return law | row 31, 797. Appendix B 11807 bolds it old-style |
| §5.2 | D-035 Position, second ruling | the table holds produced signals only, one home per datum | row 37, 825. §7.1 1576 states it plain, pointing here |
| §5.3 | D-220 Position head | formulas keep `f`, `g`, `h` as symbols; the API spells words | row 40, 840 |
| §5.3 | D-220 Position bullet 2 | one pair of output-stage names for both tiers, "direct" naming direct feedthrough | row 42 (856) or row 44 (865–867), one of the two. §8.2 2771–2772 states it plain |
| §5.3 | D-035 Position, last ruling | `y_state` is the no-feedthrough stage | row 47, 874 |
| §5.3 | D-252 Position sentence 2 | a state or mode field is exposed by returning it from `y_state` | row 50, 886. Sentence 1 is bold in §8.3 2834, so row 49 goes plain |
| §5.3 | D-015 Position | fused evaluation: derivatives read the fresh table; one computation site is rewarded | row 55 (898) or row 56 (903), one of the two |
| §5.3 | D-016 Position, standing clause | `x_projection` is the one function between a state write and its decode | row 64, 933 |
| §5.3 | D-089 Position | scheduled gains are inputs | row 72, 972 |
| §5.3 | D-089 Rationale (R) | a commanded discrete reset is a same-tick input consumed in the output stage | row 75, 983; the log owes a Position |
| §5.3 | D-141 Position | a continuous component's reset is an event | row 79, 1006. Appendix A 11657 has it as an index lead-in |
| §5.4 | D-140 Position | the three-rung ladder | rows 89–90, at the sentence that names the rungs |
| §5.5 | D-005 Position | a genuine algebraic loop is a build error, broken explicitly | row 99, 1115–1116 |
| §5.6 | D-012 Position, first ruling | tracing is diagnostic only | row 105, 1135 |
| §5.6 | D-012 Position, second ruling | one SCC names one loop | row 107, 1143–1145 |
| §5.6 | D-012 Position, third ruling | classification is an order-free per-member trace at the probe point | row 108, 1150 |
| §5.6 | D-012 Position, the discrete clause | discrete members trace structurally | row 112, 1179 |
| §5.6 | D-012 Position, last clause | classification is optional on the error | row 116, 1190–1191 |
| §5.6 | D-245 Position bullets 1, 2, 3 | the graph verdict; every dead hop listed; the mode recorded | rows 109 (1159) and 114 (1184), three bolds |

Not bold, each for the reason given: D-048 (§9.1 3787), D-086 (§9.7 4792), D-288
(§9.7 4826, row 58), D-297 bullet 6 (cited in the corrected table rows, row 13;
a table cell holds no headline clause), D-112
(§8.2 2774), D-147 (§10.4 5321, §10.5 5642), D-020 (§10.6 5934, 6165), D-154
(§10.6 5938, 6062), D-191 (§10.6 6072), D-252 sentence 1 (§8.3 2834), D-285
bullet 2 (§9.3 4297), D-287 (§9.5 4701), D-248 (home §13.2), D-067 (home §10.6,
§14.5), D-075 (vocabulary, spelled out by D-220), D-195 (vocabulary, home
§8.2), D-034 and D-055 (home §8.3). About 27 bolds (28 with row 21) against 14 labels and about
45 spans today. Rulings stated only in a Rationale may keep a bold with their
R citation, per `spec_style.md`; rows 12, 21 and 75 are the candidates.

## B. Overlaps

### Inside the chapter

1. **`DeadStage`.** §5.2 791 (the rule, at the probe) and §5.3 882 ("A stage
   that would produce none is the `DeadStage` error"). Home §9.3 (4296–4297,
   bold); §5.2 keeps one sentence and a pointer, §5.3 drops to a pointer or
   joins it.
2. **The hand-down.** §5.2 744–747 (it carries the return), §5.3 891–895
   (`y_direct` receives it; a shared intermediate is computed once). Distinct
   facts, each pointing at the other. Both stay.
3. **The no-feedthrough stage.** §5.2 685–687 (feedthrough is declared by
   signature) and §5.3 856–859 and 874–878 (the name states the class; `y_state`
   cannot see `u`). One ruling (D-006) and one consequence (D-035's last
   clause). The bold goes once each (part A, "Bold").
4. **Shared intermediates computed once.** §5.3 892–895, §5.3 900–901 ("Compute
   each law once, in a stage. Publish it."), §5.3 1036–1038 ("Compute once in
   stage 2, publish, and let `x_deriv`/`s_update` consume the ports"). Three
   statements of D-015's rewarded idiom. Home: 898–904; 1036–1038 keeps its
   accelerometer example and points back.
5. **The step-boundary order.** 926–927 (integrate → project → boundary sweep →
   guards), 939–944 (the boundary sequence in prose), 946 (the blockquote).
   Three statements in 20 lines. One prose statement plus the blockquote
   suffices.
6. **The ladder.** §5.4 1049–1105 (the rungs), §5.6 1136–1139 ("an artificial
   one gets the remedy ladder") and 1186–1189 (the hint names both exits).
   §5.4 owns the ladder; §5.6 keeps the hint as the diagnostic's content.
7. **The quoted diagnostic.** §5.4 1096–1098 and §5.6 1186–1189 give the hint
   twice, in different words ("split the component" against "split this
   component"); §5.5 1116–1118 and §5.6 1146–1147 give the slash-form loop
   twice, with the same `aero/F → dyn/F` example. One quote each.
8. **One home per datum.** §5.2 825–827 states it whole. Inside the chapter only
   once.
9. **Two "local"s.** §5.6 1172 (the local variant, the order-free per-member
   trace) and 1200 (the local, primal-carrying set-tracer). Different things
   under one adjective; part F.

### Other chapters

| content | chapter 5 | elsewhere | home |
|---|---|---|---|
| D-252 sentence 1, one producer per port | §5.3 885–886 under **Rule.** | §8.3 2834–2835, bold | §8.3 (README's carried item). §5.3 states it plain with a pointer and bolds sentence 2 (row 50) |
| the epoch rule | §5.3 953–955 under **Rule.** | §10.6 6060–6066, bold (D-154), with "An epoch here is the world one round's sweep produces"; Appendix A 11681–11686 | §10.6. §5.3 keeps one plain sentence and the pointer. Chapter 10's survey F17 reported a wrong `#g-input-epoch` link at the old §5.3 947; at `b08afca` 953 carries no glossary link, so that item is closed |
| the iteration to quiescence, one event per component per round, re-decision across rounds | §5.3 939–963 | §10.6 5934–5941, 6055–6078 | §10.6. §10.6 5929 opens "[§5.3] leaves two questions open", so §5.3 must keep the sequence and its hand-off to §10.6 |
| the boundary macro-sequence blockquote | §5.3 946 | §10.6 6189–6190 (final form) | §5.3 for the sequence the periphery cites (5062, 5089, 5101, 5220); §10.6 for the final form |
| interior sweep for RHS and trial evaluations | §5.3 919–922 | §10.4 5321 (bold), §10.5 5642 (bold), glossary *sweep* 12958 | §10.5; §5.3 plain with the pointer it has |
| tier agreement | §5.3 867–870 | §8.2 2768–2787, bold at 2774 (D-112) | §8.2 |
| `DeadStage` | §5.2 791, §5.3 882 | §9.3 4294–4297, bold | §9.3 |
| handler-return key check | §5.2 807–811 | §9.5 4701–4710, bold (D-287) | §9.5 for the check; §5.2 for the law (D-090) |
| `FieldError` recognition | §5.2 756–763 | §13.2 9252–9262 (D-248) | §13.2 for the catch sites; §5.2 for the law and the classes |
| the maximal bundle sets | §5.2 689–706, 773–775 | Appendix B 11782–11810 (table and footnotes), glossary *function family* 12738–12745 | §5.2 |
| the handler return law | §5.2 797–799 | Appendix B 11806–11808, bold | §5.2 (an appendix bold to drop when the appendices are rewritten) |
| the continuous reset is an event | §5.3 1006–1014 | Appendix A 11656–11671; §2.2 290–292 | §5.3 for the rule; Appendix A carries the contract |
| same-tick discrete reset | §5.3 983–1002 and the `PI` block | Appendix A 11648–11655; `flight_case_studies.md` 155–181, the same block and nearly the same prose | §5.3; the companion is the case study |
| fused evaluation, prior art, computer/integrator split | §5.3 1016–1041 | §7.4 1849–1897 (rewritten; it cites §5.3 for the overlap norm) | §5.3 for the rule and the teaching; §7.4 for the lineage and the split |
| the two tracer variants | §5.6 1170–1175 | §9.4 4446–4452 (rewritten, plain) | §5.6 for the classifier, §9.4 for the activation |
| the unit delay's tier caveat | §5.5 1122–1126 | §13.7 10036–10042 ("must be stated wherever the remedy is recommended") | both; §13.7's sentence requires §5.5's |
| static order, flat list, no runtime graph logic | §5.1 677–681 | §9.7 4790–4797 (bold, D-086); glossary *execution order* 12934–12939 | §9.7 for the executor; §5.1 for the problem |
| artificial loop and the ladder | §5.4 | glossary *algebraic loop* 12926–12933 | §5.4 |

No chapter 6 passage (1221–1509) states a chapter 5 ruling: a scan of 1221–1509
for feedthrough, stage names, bundle, execution order and loops finds only the
`Junction`'s `y_direct` (1383) and an unrelated "bundle" (1461–1463). Nothing in
part C trims a passage to a pointer at chapter 6.

## C. Proposed structure

No section is renumbered and none is retitled at the `###` level. A swap of §5.4
and §5.5, which would define the genuine loop before the artificial one, would
retarget 46 citations (§5.4 31, §5.5 15; part D) plus D-140's Position ("§5.4's
escape hatch") and D-258's ("§5.1 is "The ordering problem""). A one-clause
forward gloss in §5.4 buys the same define-before-use. No file links a `####`
anchor of chapter 5 (checked with `git grep` at `b08afca` over `docs/` for each
subheading slug), so retitling subheadings is free.

### Moves

| move | content | from | to | needs a ruling |
|---|---|---|---|---|
| M0 | a chapter opening: context paragraph and a roadmap sentence naming §5.1–§5.6 | new (declared additions; sources in part A, "Chapter heading") | before §5.1 | yes, q1 |
| M1 | "What the views are" (142 words) | §5.2 813–829 | up, directly after the hand-off (after 725), so the five view sources are given before the bundle law's table names the fields; the roadmap sentence 708–710 gains "where each view comes from" | yes, q2 (and q3 for its first sentence, 815) |
| M2 | "Why derivatives may read outputs" (227 words) | §5.3 1016–1041 | up, directly after "Stage roles: what each stage may see" (after 907), so the justification follows the `x_deriv` rule it justifies (898–904), before the execution order | yes, q2 |
| M3 | the step-boundary restatement of §10.6 | §5.3 939–963 | stays, trimmed: the **Rule.** epoch rule (953–955) becomes one plain sentence citing D-154 and pointing at §10.6; 926–931 and 939–944 merge into one statement of the sequence (part B item 5); 957–963 stays as the hand-off to §10.6. The sequence itself stays (five spec citations, part D) | yes, q4 |
| M4 | the two tracer modes, "Boundaries." and the `Dual` paragraph (1193–1217, 224 words) | §5.6 | up, after "Detection and naming" (after 1148), so "tracer tags", "global tracer" and "sampled states" are defined before the classifier and the caveats use them | yes, q2 |
| M5 | the `DeadStage` sentence in §5.3 882 | §5.3 | trimmed to a pointer at §5.2 791 (or §9.3) | no |

All moves stay inside their section, and each lands inside one rewrite unit.
None trims a passage to a pointer at chapter 6.

### Order within each section

Define-before-use was checked for each order below against the terms each block
uses.

- **Opening (M0).** What chapter 5 owns: the two output stages, what each may
  see, the order they yield, and the build's answer to a cycle. One roadmap
  sentence naming §5.1–§5.6.
- **§5.1.** Unchanged, plus one declared clause pointing at §5.5 for the
  cyclic case. It is the chapter's problem statement and stays short.
- **§5.2.** Context (685–687, the two stages and structural feedthrough), the
  signature block, the roadmap sentence (708–710, extended by M1), "The
  hand-off", "What the views are" (M1), "The bundle law" (rule and table; the
  absence rule; the hand-down; the diagnostic; the mechanism; the wrong-tier
  class; the closed sets and the funnel), "The stage return law", "The handler
  return law". The signature block uses "maximal legal view set" before the
  views and the bundle law are defined; a display block may preview, and its
  comment points "below", so it stays first. Inside "The bundle law", put the
  absence rule (749) before the hand-down (744–747), since "no `y_x` at all"
  (746–747) is an instance of it.
- **§5.3.** The opening (833–836) must name all six parts once M2 lands: the
  names, what each stage may see, why derivatives may read outputs, the order,
  the step boundary, the supervisory idioms. Then: "Stage roles: the names";
  "Stage roles: what each stage may see"; M2; "The execution order"; "Step
  boundaries" (M3); "Supervisory inputs". M2's blocks use `f`, `g`, `h` (from
  the names), "the published table" and stage 2 (from what each stage may see);
  nothing from the execution order. The supervisory block uses "same-tick",
  "sweep", "boundary" and ZOH, all from the blocks before it (ZOH needs
  spelling out; part F).
- **§5.4.** Unchanged order. One clause after the first sentence says a genuine
  cycle is §5.5's algebraic loop, and "the tracer (§5.6)" takes a gloss. The
  two-stage split is the first rung in prose (1049–1050) and the other two are
  bullets; the rewriter may make the three rungs visible as three items, which
  is what D-140 names (no content change).
- **§5.5.** Unchanged.
- **§5.6.** The opening (1135–1139); "Detection and naming"; M4 (the two
  modes, then what tracing seeds and never touches, then `Dual`); "Classification
  needs no execution order"; the verdict (1159–1168); the local variant against
  the tracer activation (1170–1175); the caveats (1177–1191). "Boundaries."
  becomes a topic label that does not collide with the step boundary, such as
  "What tracing touches".

### Rewrite units

| unit | lines (original) | moves in | moves out | words |
|---|---|---|---|---|
| A | 672–726: heading, §5.1, §5.2 to the end of "The hand-off" | M0 (new), M1 (813–829) | — | 430 + 142 = 572, plus the opening |
| B | 727–812: the bundle law, the stage return law, the handler return law | — | M1 | 783 |
| C | 831–923: §5.3 opening, the names, what each stage may see, the execution order | M2 (1016–1041) | — | 746 + 227 = 973 |
| D | 924–1015: step boundaries, supervisory inputs | — | M2 | 798 |
| E | 1043–1132: §5.4, §5.5 | — | — | 761 |
| F | 1133–1220: §5.6 | M4 (in place) | — | 830 |

Total 4,717 words, six units of 570 to 975 words (chapter 7 used four units for
3,250 words). Each unit is cut by content: A is the surface and the hand-off, B
the laws over names and returns, C the reading of the stages, D what happens at
a step boundary, E the loops and their remedies, F the tracer. A is the
smallest; it carries the new opening and the reader-cold Julia names
(`kwarg_decl`, slurping keywords). The open alternative is A and B as one unit
of 1,355 words (q8).

Each move stays inside one unit. M1 and M2 each move a block from one unit's
original range into another's; the block belongs to its destination unit, and
the source unit's inventory maps it there.

### Code blocks

Three fences, not two: two `julia` blocks (689–706, 988–992) and one untyped
diagram (1068–1076). One table each in §5.2 (732–742) and §5.3 (849–854), one
blockquote (946), display math at 1019–1021.

- **The signature block (689–706)** is a sketch and cannot run: `comp` and
  `args` are placeholders, and `guard` and `handler` stand for whatever named
  functions a component registers through `state_events` as
  `StateEvent(guard, handler)` (`src/declare.jl` 210–221; `test/fixtures.jl`
  61), a declaration chapter 5 never names. Checked against the package
  instead: every maximal set in its comments equals `LEGAL_BUNDLE`
  (`src/declare.jl` 380–388), family by family and tier by tier, and
  `x_projection` is called positionally (`src/build.jl` 1159). The comment at
  698 sits one column right of its neighbors, a leftover of a rename; carry it
  verbatim.
- **The `PI` block (988–992)** runs. `scratch_survey/run_pi.jl` adds the
  struct, `s_init`, `u_types` and `y_types` the block implies, a supervisor
  that engages at one tick (`t = 0.1`, `h = 1//50`), and a second component that
  honors the reset only in `s_update`. Output, with `k_p = 2`, `k_i = 1`,
  `e = 1`, latch 5:

  ```
  PI      t = 0.08  u_cmd 2.08  s_i 0.1  | t = 0.10  u_cmd 5.0  s_i 3.0  | t = 0.12  u_cmd 5.0   s_i 3.02
  PILate  t = 0.08  u_cmd 2.08  s_i 0.1  | t = 0.10  u_cmd 2.1  s_i 3.0  | t = 0.12  u_cmd 5.0   s_i 3.02
  ```

  The block publishes the latch at the engagement tick and stores the matching
  `s⁺`, so the next tick's output is the latch again (bumpless). The late
  spelling publishes the stale 2.1 at the engagement tick and lands one tick
  later. Both match 994–998 exactly. Carry the block verbatim; it is also
  byte-identical to `flight_case_studies.md` 162–164.
- **The strut/steering diagram (1068–1076)** is not code. It is an untyped
  fence, so `checks/norm.py` leaves it as prose and the claim's span must cover
  each arrow and comment.
- **Tables and the blockquote** carry verbatim as one claim each.
- **A third check against the package**, for §5.2's diagnostic text:
  `scratch_survey/run_bundle.jl` builds the section's own example (`x_deriv`
  destructuring `m` with no `m_init`) and a stateless continuous leaf whose
  `y_direct` destructures `x`. The first raises
  `DiagnosticError{BundleFieldError}` ("`x_deriv` destructures `m`, but the
  root component declares no `m_init` — the bundle carries {x, y, t} (§5.2)"),
  not the framing diagnostic 751 names (F1). The second raises the same kind:
  a leaf declaring `x_init(::C) = (;)` gets no `x` (F2).

### Glossary links

`scratch_survey/glossary_links.tsv` lists every glossary link by section. The
chapter carries 65 links to 32 anchors; 11 are second or later links to one
anchor in one section:

- §5.2: `g-bundle` (715, 729), `g-port` (740, 746), `g-tier` (734, 769).
- §5.3: `g-boundary` (836, 1001), `g-feedthrough` (858, 862, 878, 977),
  `g-flow` (842 for "flow", 915 for "RHS"), `g-sweep` (927, 997), `g-tier`
  (865, 1007), `g-view` (895, 969).

First uses with an anchor and no link: *view* in §5.2 (715, "zero-copy views";
the glossary entry cites §5.2), *feedthrough tracer* in §5.4 (1054, "The
tracer") and §5.6 (the section never links `#g-feedthrough-tracer`, which cites
it), *algebraic loop* in §5.4 (1047), *continuous component* in §5.3 (1006),
*feedthrough* in §5.6 (its own title term), *face* in §5.4 (1098) and §5.6
(1160), *nominal* in §5.6 (1142). Two anchors that must *not* be linked where
the chapter uses the word in another sense: *bundle* in §5.4 1091–1092 and §5.3
974 (a struct-valued port, not the NamedTuple of views) and *trace* in §5.6
1166 and 1178 (the tracer's result, not the recorded input trace of
`#g-trace`).

## D. Inbound citations

The full list is `inbound.tsv` (beside this file), in chapter 10's format: 231
rows, one per "§5" or "§5.N" occurrence (or a `spec.md#5…` anchor) outside
chapter 5 (672–1220) and outside the Contents block (5–117), in `spec.md` and in
every file the check rosters name (`decisions.md`, `extensions.md`,
`implementation.md`, `pending.md`, `companions/*.md`), all read at `b08afca`.
For `decisions.md` rows the `entry` and `field` columns are filled.
Link-definition blocks are excluded. A range counts its two ends only. Five
companion self-references were dropped after a check: each links the
companion's own section 5 (`event_visibility_walkthrough.md` 175, twice;
`inbound_periphery_walkthrough.md` 97 and 153; `sample_time_proposal.md` 31).
`event_visibility_walkthrough.md` 175 spells its own section as "§5", which
`spec_style.md` reserves for the spec. The script is
`scratch_survey/inbound.py`.

By file: `spec.md` 92, `decisions.md` 82 (Spec 57, Rationale 10, Position 8,
Rejected 7), `implementation.md` 14, `pid_anti_windup.md` 11,
`flight_case_studies.md` 8, `event_visibility_walkthrough.md` 4,
`library_inventory.md` 4, `extensions.md` 3, `migration_outline.md` 3,
`linear_blocks.md` 3, `frame_walkthrough.md` 2, `frozen_discrete_walkthrough.md`
2, `sample_time_proposal.md` 2, `trim_environment_walkthrough.md` 1,
`pending.md` 0. By target: §5 5, §5.1 7, §5.2 67, §5.3 82, §5.4 31, §5.5 15,
§5.6 24. No inbound row comes from chapter 6 (1221–1509).

### Citations relying on moved or trimmed content

M1, M2 and M4 move blocks inside their own sections; no row's section changes.
M5 trims a `DeadStage` sentence no row cites to §5.3 (Appendix C 12425 cites
§5.2 and §9.3).

M3, the step-boundary trim. The rows that rely on §5.3 stating the boundary
sequence or the handler's world:

| file:line | fact relied on | after M3 |
|---|---|---|
| spec 312 (§3.1) | guard and handler read the fresh boundary table | holds if 926–931's statement survives the merge |
| spec 5062, 5070, 5089, 5101, 5220 (chapter 10) | the boundary sequence is fixed in §5.3 | holds: M3 keeps the sequence |
| spec 5929 (§10.6) | "[§5.3] leaves two questions open", how far the phase runs and how often each event fires | holds only if 957–959's hand-off to §10.6 stays |
| spec 2720 (§8.2) | §5.3 uses declaration order among a component's simultaneous events | holds if 959–961 stays |
| spec 11681 (Appendix A, *Handler-phase visibility*) | the epoch rule, one event per round, only sweeps write the table | holds if each survives as a plain sentence |
| spec 12966 (glossary *sweep*) | the event phase re-runs whole boundary sweeps | holds |
| `event_visibility_walkthrough.md` 4, 12 | "The spec's one-sentence answer ([§5.3]) is: *a handler executes against exactly the world its guard fired on*" | holds if the epoch-rule sentence survives verbatim; the label goes, the sentence stays |
| log 5422 (D-154 Spec), 2996 (D-100 Spec) | §5.3 holds the visibility rule | holds |

A visible three-rung ladder in §5.4 (part C, optional): `pid_anti_windup.md` 95
calls contract re-factoring "[§5.4]'s first rung" and 102 calls the split
"[§5.4]'s second remedy", counting today's two bullets; `migration_outline.md`
108 calls re-factoring "the middle rung", counting D-140's three. Numbering the
rungs makes 95 wrong and 108 right. `pid_anti_windup.md` 91 relies on
conservatism being "[§5.4]'s last paragraph"; part C keeps it last.

### Citations that already rely on content chapter 5 does not hold

The inbound check will flag these whatever the rewrite does; they belong to
track 2 or to a ruling at checkpoint 1.

| file:line | claim | what chapter 5 says |
|---|---|---|
| spec 2322, 2797–2799 (§8.2) | "the bundle law puts a state declaration's letter in the bundle only when it is non-empty ([§5.2])" | §5.2's table says "declares" (F2). Fixing F2 makes both rows right |
| spec 12348 (Appendix C, `DeclarationOnWrongTier`) | cites §5.2 | the condition is §5.3 868–870; §5.2 states none. Retarget to §5.3, or add it |
| spec 10042 (§13.7) | "The diagnostic ([§5.5]) therefore says so rather than offering the remedy as free" | §5.5 states the caveat (1122–1126) but not that the diagnostic carries it. `src` does (`_BREAK_CYCLE`, `src/diagnostics.jl` 929–931) |
| spec 636 (§4.4), log 4546 (D-139 Position), `trim_environment_walkthrough.md` 62 | "the silent-drift class that [§5.3] exists to kill" | §5.3 never names a drift class; the drift bug class is D-015's Rejected item (log 607–608). §5.3 903–904 is the nearest text |
| spec 1555 (§7.1), 1869 (§7.4) | "the argument rule of [§5.2]" | §5.2 calls it the hand-off; "argument rule" appears nowhere in it |
| spec 6500 (§11.2) | "Private intermediates are not in it, because they were never cells at all ([§5.2])" | §5.2 says every value a later function needs is a cell (787–788); it says nothing of private intermediates, which D-194 retired |
| spec 10517 (§14.4), 10829 (§14.7) | "only cells are addressable ([§5.2])" | §5.2 does not say it; §8.3 and §14.4 are the homes |
| spec 6526 (§11.2) | "at a cost of one cell per sweep ([§5.3])" | §5.3 886–887 gives the one-line method, not its cost |
| spec 12956 (glossary *projection*) | "the cheap end of geometric integration's projection methods ([§2], [§5.3])" | §5.3 gives the two positions; the "cheap end" is §2's |
| log 7157 (D-196 Rationale) | "The stage number is the tier-neutral fact ([§5.3])" | §5.3 does not state it |
| log 9353 (D-247 Rationale) | "auto-publication publishes a state field as the port of the same name ([§5.3])" | auto-publication is gone (D-252); a Rationale of its day |
| log 10772–10773 (D-267 Rationale) | "[§5.3]'s own nouns, the "state-only output" and "direct feedthrough"" | §5.3 contains neither phrase (grep over 831–1042) |
| `flight_case_studies.md` 132 | "the claim in [§5.3] that … the decoder matches the codebase's grain" | §5.3 makes the overlap claim (1029–1032), not the grain claim |
| `flight_case_studies.md` 180 | "the bumpless-engage answer ([§11.7])" | the same dangling pointer as §5.3 1004 (F3) |
| `sample_time_proposal.md` 390 | "[§5.3]'s discretized laws and the never-cache-`Δt` rule" | the never-cache rule is §10.5's (D-019); §5.3 has the laws only |

### Log entries whose Spec field would change

None. No move takes content across a section boundary. Stale Spec fields found
in passing, all track 2:

- D-006 Spec (log 433): §7.4 only. The two-stage split lives in §5.2 and §5.3,
  its "component split as the refinement" in §5.4.
- D-019 Spec (log 714): lists §5.4 on the strength of a Rejected item (atomic
  assemblies, log 727–729). §5.4 holds none of D-019's mechanism.
- D-020 Spec (log 755): lacks §5.3, which states the iteration (939–944).
- D-048 Spec (log 1492): lacks §5.1.
- D-111 Spec (log 3392): lacks §5.3, whose 933–935 holds the two positions its
  Position cites to §7.1 (part E).
- D-245 Spec (log 9233): lacks §5.4, which states the dead-hop payload
  (1098–1100).

## E. Log repairs and factual problems

Log repairs go to the second track, after landing (recipe step 8). The rewrite
only adds citations; it states no repair. Factual problems stay as written and
go to the units' `rulings.md`, unless part G pre-rules them.

### Entries to cite at the rule

From part A's U and B rows: D-006 (rows 4, 5, 47, 52; cited nowhere in the
chapter), D-074 (8), D-297 (13, in the corrected `x`/`s`/`m` rows), D-285 (14 in place of D-252, 29, 48, 52), D-248 (17), D-194
(26, 27, 53, 93, 94), D-090 (31, at its rule rather than the next paragraph),
D-287 (34), D-035 (36, 47, 53), D-220 (41, 42), D-112 and D-263 (45), D-195 (46),
D-015 (55, 82, 85), D-020 (55, 65, 68), D-288 (58, in place of the label), D-147 (62), D-016 (63, 64), D-111 (64),
D-154 (63, 67, 69, 70), D-191 (70), D-089 (72, 73; cited nowhere), D-140 (89,
90, 106; cited nowhere), D-245 (96, 100), D-005 (99, at its rule), D-012 (100,
105, 108, 116), D-048, D-086 and D-258 (§5.1 rows 2–3).

### Superseded and half-superseded citations

- None. The chapter cites no superseded entry.
- D-012 is cited five times (1148, 1172, 1174, 1179, 1204), each for a clause
  its Position keeps; its verdict clause, superseded by D-245 (log 535–537), is
  cited to D-245 at 1167. Correct as it stands.
- Row 28 (788–789) has no live Position: "stages are discovered by method
  existence" is stated only by D-165 (log 5740), superseded → D-194, whose
  Position does not restate it.

### Rulings that need an entry stating them in a Position

1. The bundle law: a name iff its store or fact exists; undeclared stores
   absent, never `nothing`-filled; `t` always, `Δt` discrete only, `ws` iff
   declared; closed per-function name sets whose growth is a log entry; the
   `FieldError` mechanism and the getproperty fallback (rows 12, 13, 15, 16, 18,
   19, 21, 24). D-074 Rationale log 2222–2229. D-090's Position leans on it
   ("under the bundle law") and §5.2 states it under a **Rule.** label, but no
   Position states it; D-297 bullet 6 (log 12545, chapter 8's track 2) restates
   only the state-letter piece.
2. One legal set per tier for the shared output stages (row 21). D-220
   Rationale log 8179–8183. D-195 Position bullet 2 (log 7100–7101) still says
   "per-function closed sets", with no annotation pointing at D-220.
3. The three-level funnel (row 25). D-075 Rationale log 2267.
4. The closed spellings, positional, `kwarg_decl` and slurp (row 10): D-074
   Rejected log 2232–2237. The padding forms (row 33): D-090 Rejected log
   2728–2730.
5. The handler return per key: `m` under the names-subset predicate, the check
   run in both directions (row 34). D-090 Rationale log 2722–2725.
6. Modes fold under the state; ambient facts and scratch ride unnamed (row 43).
   D-075 Rationale log 2263.
7. Output stages are pure (rows 57, 87). D-015 Rejected log 605–606.
8. (Settled since: the execution order's shape, row 58, is D-288 Position
   bullet 1, chapter 9's track 2. No repair.)
9. One-shot gains are construction-time parameters; a commanded discrete reset
   is a same-tick input consumed in the output stage; a reset honored only in
   `s_update` is legal and one tick late (rows 74, 75, 77). D-089 Rationale log
   2698–2701 and Rejected log 2708–2710. D-089's Position states the gains
   only, though its title is "Route supervisor gains and resets through
   ordinary ports".
10. Republishing from `s⁺` is rejected (row 77). D-067 Rejected log 1990–1992.
11. The orthodox split is expensive here; the computer/integrator split stays
    expressible without framework support (rows 84, 86). D-015 Rejected log
    607–611.
12. The ladder's content: the fallback-branch false dependency, the
    substitution test, the split's cost and its one-bundle-port mitigation, the
    two exits in the diagnostic, "rare" earned, the hint for continuous members
    only (rows 91, 92, 93, 95, 97, 112, 115). D-140 Rationale log 4634–4664.
    D-140's Position says only "a three-rung remedy ladder".
13. A component-atomic unit admits artificial loops (row 88). D-006 Rejected
    log 443; D-019 Rejected log 727–729.
14. Implicit delays and per-step loop solving are closed (row 103). D-005
    Rejected log 421–424.
15. The trace speaks for the branch taken at the probe state (row 111). D-140
    Rejected log 4681–4683.
16. Unwalked continuous faces and ports trace structurally (row 113). D-245
    Rationale log 9246–9249.
17. No dependency annotations (row 5). D-006 Rejected log 440–441.
18. No minimization of the bundle without a copy (row 38). D-035 Rejected log
    1151–1154.

### Rulings with no entry at all

Every stage-2 output is presumed dependent on every wired input (row 54), and
its consequence that an input read only by `x_deriv` still makes an edge (row
98); evaluating the RHS means running the sweep, with no incremental
re-evaluation (row 59); stage 1 exists when state-derived ports exist (row 48);
`BundleFieldError`'s three classes (row 19); the three ways to break a loop
(row 101); the unit delay's tier caveat (row 102, stated again by §13.7
10036–10042); algebraic balances inside a component stay legal (row 104); the
dead hop as a payload field rather than a dotted path (row 96); "tracer
activation" naming the global variant (row 110); the two modes' properties
(rows 118, 119); what tracing seeds and never touches, and the
value-severing blind spot (row 120); `Dual`-cleanliness implies traceability
(row 121). Rows 54, 59 and 98 are relied on by other files (the glossary at
12855 and 12945; `pid_anti_windup.md` 91, 294, 324), so they read as rulings
the log never recorded rather than descriptions.

### Stale entry text and Spec fields

- D-006 Spec (log 433): §7.4 only (part D).
- D-016 annotation (log 627–629): "`project` as the sole raw-state function
  stand[s]". §5.3 936–937 says `x_projection` is *not* unique in receiving raw
  state, only in its position. The Position's own "(schedule-structural)"
  (log 621) carries the spec's reading; the annotation drops it.
- D-019 Spec (log 714): §5.4 from a Rejected item (part D).
- D-089 Position (log 2690–2694): states the gains only; the reset half lives
  in the Rationale (item 9 above).
- D-111 Position (log 3387–3388): "written back to the buffer wholesale at both
  [§7.1] schedule positions". The two positions are §5.3's (933–935); §7.1 1561
  cites §5.3 for them, and D-131 Rationale (log 4037) records retargeting the
  spec's citation to §5.3 without touching D-111.
- D-195 Position bullet 2 (log 7100–7101): per-function sets, retired in part
  by D-220 (log 8179–8183); no annotation.
- D-020, D-048, D-245 Spec fields: part D.
- D-297 Spec (log 12552): §8.1–§8.6 only; bullet 6, the state letter in the
  bundle, is §5.2's table (and §8.2 2797–2799 cites §5.2 for it).
- D-196 Rationale (log 7157), D-247 Rationale (log 9353), D-267 Rationale (log
  10772–10773): claims about §5.3 that §5.3 does not hold (part D).

### Factual problems in chapter 5

Each was grepped over 672–1220 for every instance of its phrase (lesson 19);
the instances are listed.

- **F1. The bundle-law failure is not the framing diagnostic.** 750–751:
  "fails at the probe, inside the [§13.2] framing diagnostic"; 758–759: the
  probe "synthesizes the framing diagnostic from the legal set". D-248 Position
  bullet 4 (log 9401–9402): "A `FieldError` matched against the bundle is
  `BundleFieldError` at the probe and a `StepError` species at [§13.4]'s catch
  site." §13.2 9239: "A user-code exception is wrapped in a framing diagnostic,
  `UserCodeFraming`"; §13.2 9252: "One class of exception is recognized rather
  than merely framed. A `FieldError` …". `src/build.jl` 57–61 throws
  `BundleFieldError` before the `UserCodeFraming` line; `run_bundle.jl` gets
  `DiagnosticError{BundleFieldError}`. Correction: name `BundleFieldError` at
  both places (which also names Appendix C's kind, part A). Instances: 751, 759.
- **F2. The bundle law admits a letter only for a non-empty store.** 734–736:
  "`x` | the component declares `x_init`", likewise `s` and `m`. D-263 Position
  bullet 5 (log 10395–10397): "Every leaf declares exactly one of `init_x` and
  `init_s`, and a stateless leaf declares it empty". D-297 Position bullet 6
  (log 12545): "A store puts its letter in the bundle only when it is
  non-empty." §8.2 2797–2799: "the
  bundle law puts a state declaration's letter in the bundle only when it is
  non-empty ([§5.2])". `src/declare.jl` 340–343 tests `!isempty(…)`;
  `run_bundle.jl`'s stateless leaf gets `{u, t}`. §5.2's own 780–781 ("a
  stateless component legitimately writes `y_direct` while owning neither `x`
  nor `m`") agrees with the non-empty reading. Correction: "declares a
  non-empty `x_init`" (and `s_init`, `m_init`). Instances: 734, 735, 736. A
  lesser wording point in the same table: the `u` row carries the
  function-family condition and the `y` and `y_x`/`y_s` rows do not, though
  `src` gives `y` only to the update law, guards and handlers; 777–778 ("A given
  component's bundle narrows that set") covers it, so no correction is needed.
- **F3. §11.7 holds no bumpless-engage answer.** 1003–1004: "the
  bumpless-engage answer ([§11.7]) presupposes exactly this spelling". §11.7
  (7645) is "The GUI write path: port resolution, peek, staging contract", and
  no line of it contains "engage". The pointer began in `f9e2cac` as "§12.5's
  bumpless-engage answer — engage semantics live in the FCS", the C172X demo's
  *Mode engage* frame anatomy, which now lives in `flight_case_studies.md`
  349–350 ("**Bumpless-engage semantics live in the FCS already.**").
  `flight_case_studies.md` 180 repeats the dangling pointer. Correction: point
  at `flight_case_studies.md` (its C172X demo section), or drop the clause.
  Instances: 1004.
- **F4. The textbook form uses `g` for the output map.** 1019: "The textbook
  form is $\dot{x} = f(x, u)$, $y = g(x, u)$." The same section fixes `g` as
  the discrete update and `h` as the output map (841–845); D-075 Rejected log
  2272: "*`g` for outputs:* the complementary collision"; D-220 Position head
  (log 8134–8135) keeps `f`, `g`, `h` as the formulas' symbols. Correction:
  `y = h(x, u)`. Instances: 1019 only.
- **F5. `init_*` is the retired spelling.** 1153: "reads state views from
  `init_*`". D-267 bullet 1 (log 10723–10724): "`init_x` → `x_init`, `init_s` →
  `s_init`, `init_m` → `m_init`". Correction: "from the `x_init`, `s_init` and
  `m_init` declarations". Instances: 1153. Outside the chapter: 3797 (§9.1),
  4276 (§9.3, a rewritten chapter), 10223 (§14.1).
- **F6. A unit delay ticks at its scope's period, not always at `Δt_base`.**
  1124–1125: "The broken signal becomes discrete, sampled at `Δt_base`".
  §13.7 10017: "`UnitDelay{V}` is a **discrete** leaf at `K = 1`"; spec 3392:
  "`K = 1` (its `sample_times` entry is `Relative(1)`) in its own scope"; spec
  3479: "an unlisted discrete child defaults to `Relative(1)`"; D-019 Position
  (log 710–711): multipliers "composing down the tree". Under an assembly
  scoped at `Relative(5)` the delay ticks at `5·Δt_base`. §13.7 10038 and `src`'s
  message say "a `Δt_base`-scale ZOH", which holds. Correction: "sampled at its
  scope's rate, `Δt_base` at the root" or "on a `Δt_base`-scale period".
  Instances: 1125.
- **F7. "The views themselves are unchanged in meaning."** (815). Unchanged
  from what, the text never says. It entered in `7b63c99` (2026-07-28, "the
  named-bundle hand-off"), meaning unchanged from the positional signatures the
  bundle replaced: history in normative text. Part G q3.
- **F8. The hand-down's citation.** 744–745 cite D-252 for "`y_x` … comes from
  the stage-1 probe's return". D-252's Position (log 9618–9624) does not
  mention the hand-down; D-285 Position bullet 3 (log 11985–11986) states it.
  A citation fix under `spec_style.md` ("Cite the entry that rules"), part G q6.
- **F9. Two quoted diagnostics differ from `src`'s text.** 1097–1098: "cycle
  through `systems/aero` is artificial at port level — split the component, or
  narrow the neighbor's contract"; 1138: a genuine cycle gets "insert a state".
  `src/diagnostics.jl` 920–948 renders "algebraic loop among …: … —
  artificial at port level: …; split `m`, or narrow the neighbor's contract if
  `f` is consumed only in a fallback branch (§5.4)" and, for a real loop,
  "break it with a state, a stage-1 (`y_state`) port, or a `UnitDelay` …". The
  spec is the design; these quotes read as illustrative. `spec_style.md` keeps
  quoted diagnostics verbatim, so the rewrite carries them; whether `src` or
  the spec moves is an implementation question, not a correction here.
- **F10. "A library PI block" with a reset face.** 1012–1013. D-141 Position
  (log 4696–4700) gives the face to "the reimplemented `PIVector`". `src`'s
  library has no `PIVector`, and its `PID` declares no events
  (`src/blocks.jl`: `state_events` only on `Step`, `LimitedIntegrator`,
  `Relay`); `library_inventory.md` has no entry for it. The spec states the
  design; the library gap is the implementation's. No correction.
- **F11. `h` used bare for the output map.** 843: "`h` is the control/estimation
  convention that the output map is `y = h(x, u)`". The glossary (12771):
  "Bare `h` means the integration step size only". D-220 keeps `h` as a formula
  symbol. A reserved-word clash, not a wrong fact; the rewriter writes "`h` in
  `y = h(x, u)`" or similar. Instances of bare `h` in prose: 843.

Outside chapter 5, met while checking citations:

- **F12.** `flight_case_studies.md` 180: the same §11.7 pointer as F3.
- **F13.** Spec 3797, 4276, 10223: `init_*` (F5).
- **F14.** Spec 12348 (Appendix C): `DeclarationOnWrongTier` cites §5.2, whose
  text states no declaration-tier condition; §5.3 868–870 does.
- **F15.** Spec 10042 (§13.7) says §5.5's diagnostic states the unit delay's
  caveat; §5.5 does not say so (part D).

## F. Difficulty per section

| unit | difficulty | reason |
|---|---|---|
| A (opening, §5.1, §5.2 surface and hand-off, plus M1) | low to medium | 572 words plus about 70 of declared opening; the signature block carried verbatim; M1 changes the roadmap sentence; q3 decides 815; two reader-cold Julia names in one sentence (723) |
| B (the bundle law and the two return laws) | high | 783 words, 9 R rows, most in D-074's Rationale; F1 and F2 sit here, with three instances of each phrase; two Appendix C kinds to name; the table carried verbatim except F2; the `iff … and` precision of the `u` row and the handler law; three duplicated glossary links |
| C (§5.3 names, what each stage may see, M2, the order) | medium | the most bolds of any unit (D-220 twice, D-035, D-252 sentence 2, D-015) against two rulings bold elsewhere (D-252 sentence 1 in §8.3, D-112 in §8.2); F4 and F11; M2 moves 227 words up; `f_ode!`, `f_c_c`, AD unglossed; the **Why.** at 903 holds a ruling |
| D (step boundaries, supervisory inputs) | medium to high | M3 trims against chapter 10's rewritten §10.6 without losing the sentences five spec rows and `event_visibility_walkthrough.md` 12 rely on; F3; four R rows from D-089's Rationale; the `PI` block verbatim; the landing-gear example, ZOH and FSM unglossed |
| E (§5.4, §5.5) | medium | nearly every ruling lives in D-140's Rationale; Flight.jl's strut/steering names (`ψ_v`, castoring, `StrutGeometry`, `migration_outline.md`); two quoted diagnostics (F9); F6; whether to number three rungs (part D) |
| F (§5.6) | high | 830 dense words with no subheadings; M4 reorders; D-012's semicolon chain gives five bolds and D-245 three; two "local"s; "Boundaries." collides with the step boundary; F5; "cells" used where "there is no table"; "trace" in a sense the glossary reserves for the input trace |

Warnings for the rewriter:

- **Terms of art stay verbatim**: no-feedthrough stage, stage 1, stage 2,
  hand-down, bundle law, return law, function family, maximal legal set,
  closed, absent (never `nothing`-filled), wrong-tier fact, the three-level
  funnel, dependence class, the fused idiom, boundary sweep, interior sweep,
  quiescence, epoch rule, firing round, same-tick, one-tick-late,
  port-level acyclic, stage-level cyclic, real, artificial, dead hop,
  may-depend, input-tainted, value-blind, primal-carrying, structural tracing,
  probe point. "Blocked, not lost" and "re-decided" are §10.6's distinctions;
  a paraphrase that drops one half changes the rule.
- **Both halves of every "iff … and".** The `u` row ("the function family may
  see inputs **and** the component declares `u_types`") and the handler return
  law ("the store exists on the component **and** the handler updates it") are
  two-condition rulings. A split sentence must keep both.
- **The log's vocabulary is old.** D-074 says `project` and `workspace`; D-075
  `h_x`, `h_xu`, `h_z`, `h_zu`, `z`; D-015 `f`/`h`; D-016 `h_x`, `project`,
  re-decode; D-035 `h_xu`, `f`, `h_zu`, `g`; D-089 `g`, `z⁺`; D-012
  "Stratum-B"; D-140 `output_types`, `AbstractSteering`; D-141 `init_x`, `z⁺`;
  D-252 `output_state`; D-263 `init_x`, `init_s`. Never import them when citing
  an entry.
- **Glossary-reserved words the chapter uses loosely** (lesson 26):
  - *entry*, "never used bare" (glossary 12838): 681 "`(component, stage)`
    entries" and 920–921 "Discrete entries" are executor entries. 775
    ("decision-log entry"), 955 ("handler entry") and 1003 ("the same-tick
    reset entry", Appendix A's) are other compounds.
  - *class*, the primitive-versus-assembly status (glossary 12683–12689): 765
    "the wrong-tier class" (a `BundleFieldError` classification), 856
    "dependence class" (D-075's term) and 1050 "absorbs most of the class" (of
    artificial loops). None takes the link; "classification" or "category"
    avoids the clash where the rewriter touches the sentence.
  - *cell*, "Bare 'cell' means only this", a signal-table entry (glossary
    12826–12829): 1153–1154 speaks of "out-of-cycle cells" and "in-cycle cells
    synthesized" in an evaluation where "There is no activation …, no layouts
    and no table" (1170–1171). The values stand in for cells; the rewriter
    keeps the claim and may say "cell values".
  - *bundle*, the NamedTuple of views (glossary 12821): 974 "one gain bundle
    per compensator" and 1091–1092 "one struct-valued bundle port … The bundle
    type" use §4.3's port sense. Never link those.
  - *trace*, the recorded input trace (glossary 13534): 976 links it correctly;
    1166 ("the chords the trace found false") and 1178 ("The trace speaks for
    the branch") mean the tracer's result. No link there.
  - *boundary*: §5.6's lead-in "**Boundaries.**" (1206) means the limits of
    tracing; rename the label (part C).
  - *binding*, the device binding (glossary 13293): 821 "the wiring's name
    binding" is another sense; no link.
  - bare `h`: 843 (F11).
  - *tier*, "Bare 'tier' means only this": every use in the chapter is the
    continuous/discrete sense. Correct as it stands.
  - *schedule* (D-258: the tick timing): 965–973 "scheduled gains",
    "scheduler", "scheduling variables" are gain scheduling, ordinary English;
    the chapter otherwise says "execution order" correctly.
- **Reader-cold names** (introduce each from the start; the gloss claims
  nothing beyond its source, lesson 14):
  - `kwarg_decl` and "slurping-keyword" (723): Julia's `Base.kwarg_decl`
    reflection and a `_...` keyword slurp (D-074 Rejected log 2234–2237).
  - ZOH (997), FSM (801), AD (1022): spell out at first use (zero-order hold,
    finite-state machine, automatic differentiation).
  - `f_ode!` (1033): FlightCore's fused in-place derivative function (§7.4
    1885–1886 words it so). FlightCore itself needs nothing.
  - `f_c_c` (1038): a port of §3.4's strapdown IMU example (396–398, 477);
    point there rather than gloss its physics.
  - "A landing gear's friction regulator, re-initialized at touchdown by
    weight-on-wheels" (1010–1011): an aerospace example; one introducing
    clause from D-141 (log 4701–4702, "the gear wires `strut.wow → frc.reset`
    (the touchdown edge)").
  - "a library PI block" (1012): D-141 calls it the reimplemented `PIVector`;
    the spec's phrasing is fine, but the name `PIVector` must not be added
    without saying it is Flight.jl's block to be reimplemented (F10).
  - the strut/steering pair (1063–1083), `ψ_v` (glossed in place), castoring
    (glossed in place), `StrutGeometry` (1091, a "`StrutGeometry`-shaped
    value"): Flight.jl's landing-gear model; D-140 Rationale log 4641–4652 is
    the source, `migration_outline.md` 108 the companion.
  - the α-filter idiom (1121–1122): defined nowhere in the spec.
    `library_inventory.md` 127 maps it to `FirstOrderLag`, and
    `flight_case_studies.md` 53 calls the C172's version "a filter state". A
    gloss may say "a filter state inserted in the loop", no more.
  - "tracer tags" (1155): never defined; the global tracer's bullet (1195–1196,
    "carries a set of input indices") is the nearest definition, which M4 puts
    first.
  - `Dual` (1216): ForwardDiff's dual number, the AD scalar (§7.2 introduces
    it).
  - "Goebel–Sanfelice–Teel" (843): a citation of the hybrid-systems
    literature; it stays as written.
- **Antecedent hazards.** Each sentence below opens on a word that points back
  across a sentence or paragraph a move or split can disturb: 801 "That is the
  bundle law's *iff* shape"; 877–878 "That structural guarantee … They break
  would-be loops" (They = stage-1 ports); 918 "restate that consequence"; 934
  "Those are the only positions"; 953 "Hence the epoch rule"; 959 "Two of its
  rules" (its = §10.6); 968 "Both are ordinary signal flow" (scheduling and
  resets); 1036 "thereby"; 1049–1050 "it is the rung" (it = the two-stage
  split); 1053 "That case"; 1085 "Its cost"; 1092 "That is a real cost"; 1151
  "None is needed"; 1153 "That evaluation"; 1172 "This is the *local*
  variant"; 1174–1175 "The two must not be conflated"; 1193 "There are two
  modes" (of the tracer, which M4 must say once the block moves). M1's first
  sentence (815, "The views themselves") reads against the hand-off's "bundle
  of zero-copy views" only if M1 lands right after it.
- **Counts are rulings**: exactly two output stages, exactly two arguments,
  one set per function per tier, four sets, five view sources, two positions
  for `x_projection`, all guards once, one event per component per round, one
  diagnostic per cluster, each member once in isolation, three routes, two
  remedies (or three rungs), two modes. Each carries its entry (part A).
- **Bold**: about 27 bolds against 14 labels and about 45 spans today (part A,
  "Bold, one per ruling"). Lead-ins acting as headings (1141, 1150, 1177,
  1195, 1200, 1206 and §5.3's) become topic sentences or `####` labels. The
  bold check fails any bold span with no D-citation in its sentence.
- **Glossary links reset per section**: 11 duplicate links today (part C).
  M1 moves the first uses of *buffer*, *store* and *signal table* earlier in
  §5.2; M2 moves *flow* and the RHS into §5.3's earlier blocks.
- **Code and math**: part C, "Code blocks". The display math at 1019–1021 is
  carried as written except for F4's ruled edit.

## G. Decisions for checkpoint 1

Settled for every chapter and not asked again: log repair rides track 2, and
bold marks one headline clause per ruling (recipe step 1, checkpoint 1).

**q1. A chapter opening.** Chapter 5 opens straight into §5.1. Options: (a) a
short opening before §5.1, a context paragraph and one roadmap sentence naming
§5.1–§5.6, every word a declared addition drawn from spec 130–132 and 158, the
section titles and 833–836; §5.1 gains one clause pointing at §5.5 for a cyclic
graph; (b) grow §5.1 into the opening, since it is already the problem
statement; (c) none. Recommendation: (a). Chapters 7 to 10 open that way, and
§5.1 stays the citable home of "the ordering problem" that D-258's Position
names.

**q2. The three reorders, M1, M2 and M4.** M1 puts "What the views are" after
the hand-off, M2 puts "Why derivatives may read outputs" after the stage roles,
M4 puts the tracer's modes before the classifier. Each fixes a define-before-use
or a rule-before-reason order, each stays inside its section, and no inbound
row depends on the old position (part D). Options: (a) all three; (b) none,
with forward glosses instead. Recommendation: (a).

**q3. "The views themselves are unchanged in meaning." (815, F7).** History
from `7b63c99`: unchanged from the positional design. Options: (a) replace it
with a topic sentence the bullets support, such as "Each bundle field is a view
of one source:", a declared addition; (b) drop it; (c) keep it as written.
Recommendation: (a), ruled now, since M1 moves the sentence to the head of its
block.

**q4. The step-boundary block against §10.6 (M3).** §10.6 bolds D-020, D-154
and D-191 (part B). Options: (a) keep the sequence, the blockquote and the
hand-off to §10.6 (957–963); merge 926–931 with 939–944; state the epoch rule
as one plain sentence, verbatim from 954–955, citing D-154 and pointing at
§10.6, with no label and no "Hence"; bold none of D-020, D-154, D-191 here;
(b) cut 939–963 to a pointer; (c) keep everything, labels removed. Recommendation:
(a). (b) breaks spec 5929, 2720 and 11681 and `event_visibility_walkthrough.md`
12, which quote or rely on §5.3's sentences.

**q5. Clear factual corrections, ruled before writing (lesson 13).** Each was
grepped over the chapter for every instance (part E):

- F1, 751 and 759: "the [§13.2] framing diagnostic" → `BundleFieldError`, the
  kind D-248 bullet 4 names (log 9401–9402); `src` and `run_bundle.jl` agree.
  Recommendation: apply.
- F2, 734, 735, 736: "declares `x_init`" → "declares a non-empty `x_init`", and
  likewise `s_init`, `m_init`. D-263 bullet 5 (log 10395–10397), §8.2
  2797–2799, `src/declare.jl` 340–343, `run_bundle.jl`. Recommendation: apply.
  Checked against entries ratified after D-263 (lesson 18): no later entry
  states the "declares" reading, and D-297 bullet 6 (log 12545), the latest,
  states the non-empty one in its Position. Cite D-297 in the corrected rows.
- F3, 1004: "([§11.7])" → "(`flight_case_studies.md`)", where the
  bumpless-engage answer now lives (349–350). Recommendation: apply; the same
  pointer in `flight_case_studies.md` 180 goes to track 2.
- F4, 1019: "$y = g(x, u)$" → "$y = h(x, u)$". Recommendation: apply.
- F5, 1153: "`init_*`" → "the `x_init`, `s_init` and `m_init` declarations".
  Recommendation: apply; 3797, 4276 and 10223 go to track 2.
- F6, 1124–1125: "sampled at `Δt_base`" → "sampled on a `Δt_base`-scale
  period", §13.7 10038's wording, which holds under any rate scope.
  Recommendation: apply. The glossed link to `#g-dt_base` stays.

**q6. The hand-down's citation (F8).** 744–745 cite D-252, whose Position is
silent on the hand-down. Options: (a) cite D-285 (bullet 3), keeping the bold
there; (b) cite both; (c) leave it. Recommendation: (a), under `spec_style.md`
"Cite the entry that rules".

**q7. Appendix C kinds to name where the condition is stated.** `BundleFieldError`
at 751 (with F1), `HandlerReturnKey` at 809–810, `DeclarationOnWrongTier` at
868–870, `AlgebraicCycle` at 1115–1116 and once in §5.6. Each name is a
declared addition that changes no ruling, and each kind's Appendix C row
already cites the section (or, for `DeclarationOnWrongTier`, §5.2, which track 2
retargets to §5.3, F14). Recommendation: name all four.

**q8. The units.** Six units as in part C: A 572 (plus the opening), B 783, C
973, D 798, E 761, F 830. The alternative is A and B as one unit of 1,355 words.
Recommendation: six. B's two factual corrections and its R-heavy law are a
unit's worth of care on their own.

**q9. Two bold placements the table leaves open.** D-220 bullet 2 at 856 (the
dependence-class **Rule.**) or 866 (one pair of names for both tiers); D-015 at
898 (the rule) or 903 (the **Why.**). Recommendation: 856 and 898, the places
the rule is stated; 866 and 903 cite the entries plain. And the three R bolds
(rows 12, 21, 75): keep them with their R citations, as `spec_style.md`
allows, and list each for track 2. Recommendation: bold rows 12 and 75; treat
row 21 as part of the bundle law's ruling, cited plain.

**q10. The ladder's rungs in §5.4.** D-140 names three rungs; §5.4 shows the
first in prose and the other two as "Two remedies". Options: (a) make the three
rungs visible as three items, retargeting `pid_anti_windup.md` 95 and 102 in
track 2; (b) keep the prose-plus-two-bullets shape and add "the ladder's other
two rungs" so the count reads. Recommendation: (b). It matches D-140 without
breaking the companion's counting.

**q11. Adversarial rationale.** Candidates for `spec_style.md`'s "lives in
`decisions.md`": 723–724 (closed spellings), 804–805 (padding forms), 1092–1094
(no visibility level), 1126–1127 (implicit delays and numerical solving), 1148
(neither the stall residue nor a back edge). Each is one sentence that states
what is closed and cites its entry; none argues. Recommendation: keep all five.

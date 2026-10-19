<!-- Sliced from survey_1.md for unit B (§14.4, §14.5, §14.6) by checks/slice_survey.py. -->
# Survey of spec chapter 14, half 1, before its readability rewrite — 2026-10-20

Scope: `docs/design/spec.md` lines 11267–11873 at commit `c3d29fb`, 5,352
words: the chapter heading and roadmap (11267–11319, 482 words), §14.1
(11320–11375, 476), §14.2 (11376–11487, 985), §14.3 (11488–11558, 566),
§14.4 (11559–11717, 1,381), §14.5 (11718–11820, 1,018) and §14.6
(11821–11873, 444). Half 2 (§14.7–§14.10, 11874–12730, 7,064 words) is the
sibling survey's. The convention is `docs/design/tools/spec_style.md`; the
method is `docs/spec_rewrite/recipe.md` step 1; the model is chapter 13's
half-1 survey (`git show ae63ca9:docs/spec_rewrite/ch13/survey_1.md`).

Line numbers are lines of the frozen copies in `scratch_survey/h1/`
(`spec.md` and `decisions.md` at `c3d29fb`). Lines marked `log` are
`decisions.md` lines. Entry claims rest on the entry as read in full. `src/`
was read at the working tree where a name or a claim was in doubt. The script
that ran the half's code and claims is `scratch_survey/h1/run/blocks.jl`, its
output `run/output.txt`. `run/entry.sh` prints an entry, `run/bolds.py`,
`run/gloss.py` and `run/firstuse.py` count bolds, glossary links and first
uses, and `mine.tsv` holds the half's 356 inbound rows.

Classification codes used in part A, as in chapters 10 to 13:

- **C** cited, and ruled by the cited entry's Position (at the spot or in the
  same paragraph, marked "adjacent").
- **U** ruled by an entry's Position that the section does not cite at that
  spot.
- **S** cited to a superseded entry or clause.
- **R** ruled only in an entry's Rationale, Rejected list or annotation
  (whether or not the entry is cited).
- **N** no entry found. Where the sentence reads as a description of an
  inherited status quo rather than a ruling, the row says so.
- **B** borderline; both readings are given.

"Marking" is how the spec marks the rule now: **Rule.** or **Why.** label,
bold label (a bold phrase opening a paragraph and acting as a heading,
"**Doctrine.**"), bold lead-in (a bold sentence or clause opening a paragraph
or list item), bold sentence, bold term, or plain.

Bold now: 44 spans and 203 words in the half. Heading 3 spans (10 words);
§14.1 4 (13); §14.2 6 (19); §14.3 7 (23); §14.4 11 (49); §14.5 9 (64); §14.6
4 (25). Labels: **Rule.** ×5 (§14.2 1, §14.3 1, §14.4 3), **Why.** ×1
(§14.3), and three bold labels acting as headings (**Lifecycle
preconditions.**, **Doctrine.**, **Pre-sweep doctrine.**). Of the 44, five
are list labels (§14.4's two ways, §14.5's "Project runs.", "Events run.",
"Due `s_update` calls run."), ten mark a term or a name (**condition
value**, **environment queries**, **condition method**, **inert, lazy
tree**, **The locality law**, **error method**, **tree position**,
**Schema**, **Layout**, **`override(base, patch)`**), two open a converter
case (§14.3), and the rest are bold sentences or lead-ins. Only two bold
headline clauses carry their D-citation in their own sentence: 11310
(`errored`, a double of §12.6's bold) and 11736–11737 (D-205).

Ten entries that rule much of the half are cited nowhere in the spec: D-066
(the two ways to apply a plan, §14.4), D-098 (the source rule, §14.4), D-095
(the `get_` family, §14.4), D-124 (table sources, §14.4), D-125 (`get_face`
in service reads, §14.4), D-148 (the per-leaf converter, §14.3), D-405 (`set`
and the condition method, §14.2), D-110 (`trim!`'s `t0`, §14.5), D-126
(commit-fired events, §14.5) and D-155 (projection as the second mover,
§14.5). D-149 (totality wherever a virgin world is established) is bold in
§9.3 and cited in §11.3, never in §14. The half's sharpest factual problems
are §14.4's client policy, which lags D-414 and §13.3's rewritten client
table (F1), and §14.6's list of totality sites, which omits linearization's
`about` application (F2). No finding is serious.

## A. Per section

### §14 heading and roadmap (11267–11319, 482 words)

Purpose: name the stopped-sim services and the condition they share, map the
chapter, and fix the services' lifecycle preconditions.

Subheadings: none. The opening paragraph (11269–11281) is context and
roadmap; the rest is rules under a bold label. Bold: one term (**condition
value**, 11271), one label (11283), one bold sentence (11310).

| # | line | quote | marking | entry | class |
|---|---|---|---|---|---|
| 1 | 11269–11270 | "[§9.6] previewed the services as activation clients. They are initialization, trim and linearization." | plain | — | framing; names three services, then a fourth (row 4), while the table has five (F3) |
| 2 | 11270–11272 | "Everything they share reduces to one artifact, the **[condition] value**. A condition is the datum that says 'set this build to this state.'" | bold term | D-063 Position (by implication) | B: framing with a bold term, which `spec_style.md` reserves for rulings; or the definition the glossary repeats. `checkpoint` and `restore!` share nothing of the condition (F3) |
| 3 | 11273–11278 | "[§14.1]–[§14.4] settle its representation, composition and application. [§14.5]–[§14.6] cover the boundary-zero sequence and root-input totality (…). [§14.7]–[§14.9] cover the trim service in full. [§14.10] covers linearization." | plain | — | roadmap |
| 4 | 11278–11281 | "A fourth stopped-sim service, `checkpoint`, returns a checkpoint (…). A checkpoint is not a condition and has no algebra, and `restore!` puts it back ([D-273])." | plain | D-273 Position; D-274 Position (`restore!`) | C; double of §12.6 (9536–9546) and §14.1 row 33 (H1) |
| 5 | 11283 | "**Lifecycle preconditions.** Every service requires a non-running simulation." | bold label | D-108 Position | U (D-108 cited only at 11310) |
| 6 | 11284–11286 | "While a run exists the loop owns the stores between drains (…), and a service reading or writing them would race it." | plain | D-108 Position ("the D-106 doctrine — the loop owns the stores between drains") | U (reason) |
| 7 | 11286–11289 | "Pause is no exception, by the doctrine that freezes the roster. Pause is a control-plane state *inside* a run, so a prohibition that holds mid-run holds while paused ([§11.3], [§12.1])." | plain | D-108 Position ("pause included"); D-106 Position ("pause is inside a run") | U; restates §11.3 7344–7345 (O3) |
| 8 | 11291 | "Within the stopped-sim states, legality follows each service's inputs." | plain | D-108 Position | U |
| 9 | 11295 | table row `checkpoint`: "error / legal / legal / a frame-top rest; refused after a `t*` stop and after an abandoned frame" | table | D-274 bullet 2; D-108 Position (as `capture`); D-319 bullet 3 | U; states `CheckpointMidFrame`'s condition without naming it (F5); restates §12.6 9539–9546, which names it |
| 10 | 11296 | row `init!`: "legal / legal / legal / authored conditions" | table | D-108 Position | U |
| 11 | 11297 | row `restore!`: "legal / legal / legal / a checkpoint whose fingerprint and deployment match the simulation's and whose `t` sits on its grid ([§12.6])" | table | D-274 bullet 3 ("a door beside `init!`"); D-319 bullets 2–3 (the grid) | B: legality from `built` follows from "beside `init!`" and is stated in no Position; the code agrees (`src/sim.jl` 707–735) |
| 12 | 11298 | row `trim!`: "legal / legal / legal / authored conditions; the scratch world is `override(baseline, condition(guess))` ([§14.8]), never the sim's stores" | table | D-108 Position | U |
| 13 | 11299 | row `linearize`, default operating point: "error / legal / legal / inherits `checkpoint`'s precondition, its refusals included" | table | D-108 Position; D-319 bullet 5 | U |
| 14 | 11300 | row `linearize`, explicit `about`: "legal / legal / legal / inherits `init!`'s legality" | table | D-108 Position | U |
| 15 | 11302–11304 | "Each row's service also has a form on a [`Model`] (…), gated by the model's status rather than by the lifecycle ([D-319])." | plain | D-319 Position | C |
| 16 | 11304–11305 | "`checkpoint` and the default `linearize` are legal at `:consistent`." | plain | D-319 bullets 2, 5 | C, adjacent |
| 17 | 11305–11306 | "`init!`, `restore!`, `trim!` and `linearize` with an explicit `about` are legal at any status." | plain | D-319 bullet 2 (`restore!` "has no status gate"), bullet 5; `init!`: none | B: `init!`'s any-status legality is stated in no Position; the code agrees (`src/model.jl` 170–198); the run confirmed `restore!(model, state)` at `:built` |
| 18 | 11306–11308 | "A model a simulation has claimed refuses each form that writes, `init!`, `restore!` and `trim!` ([D-318])." | plain | D-318 bullet 3; D-319's annotation on D-318 (`trim!`, log 14266–14268) | C; the refusal's kind, `ArgumentInvalid` reason `:claimed`, is unnamed (F5) |
| 19 | 11310 | "**`errored` is terminal for every row** ([D-059], [D-108])." | bold sentence | D-108 Rationale (log 3564); D-059 bullet 4 | R; double of §12.6's bold (9429), carried B84 (part E) |
| 20 | 11311–11312 | "Post-mortem inspection of an errored sim's stores, log and [trace] stays available as a diagnostic read." | plain | D-232 Position ("The stopped-sim reads stay admitted there"); D-108 Rationale | U |
| 21 | 11312 | "It may not become a checkpoint." | plain | D-274 bullet 2; D-108 Rationale; D-319 Rationale | U |
| 22 | 11314–11315 | "A violation is `ServiceLifecycle` ([Appendix C]). Its payload is the operation, the current status and the legal statuses." | plain | D-108 Rationale | R |
| 23 | 11315–11317 | "It is the same kind `attach!`/`detach!` raise while `running` ([§11.3]), so there is one error form for 'this operation is illegal in the current lifecycle state.'" | plain | D-108 Rationale; D-232 Position | R |
| 24 | 11318 | "`MissingInit` is distinct, and names a missing prior step." | plain | D-108 Rejected | R; no service raises it, only the advances and `trace` (`src/sim.jl` 405, 2297) |

Descriptions that read like rules: rows 9–14 (the table is the services'
gates as built, `src/sim.jl` 591–795), row 24 (a contrast, not a service
rule).

Display-block candidates: none beyond the table.

Glossary terms in the heading (lesson 35):

| term | first use | linked there | use matches the entry |
|---|---|---|---|
| activation | 11269 ("activation clients") | no | yes |
| condition | 11271 | yes, inside a bold term, defined in the next sentence | yes |
| boundary zero | 11274 | **wrong anchor**: "[boundary](#g-boundary)-zero" links `#g-boundary`; `#g-boundary-zero` exists (F4) | yes |
| root-input totality | 11275 | yes, glossed | yes |
| root input | 11276 | no | yes |
| checkpoint | 11279 | yes, glossed | yes |
| `Model` | 11279 (in the checkpoint gloss) | no; linked at 11302 | yes |
| frame | 11280 ("a frame top") | no | yes |
| store | 11284 | yes, no gloss | yes |
| drain | 11285 | yes, glossed | yes |
| roster | 11287 | yes, no gloss | yes |
| control plane | 11288 | no | yes |
| service lifecycle | 11283 | never linked | yes; the block states it |
| deployment | 11297 | no (`#g-deployment`) | yes |
| override, baseline, scratch | 11298 | `override` yes; `baseline`, `scratch` no | yes |
| trace, log | 11311 | `trace` yes; `log` no | yes |
| kind | 11315 | no | yes ("the same kind") |

Appendix C kinds cited to the bare §14: `ServiceLifecycle` (13597) and
`CheckpointMidFrame` (13707). The block names `ServiceLifecycle` where it
states the violation (11314). It states `CheckpointMidFrame`'s condition in
the table (11295) and does not name it (F5). It also states the claim
refusal (row 18) without naming `ArgumentInvalid`, which Appendix C does not
cite to §14.

### §14.1 Conditions are path-addressed overlays on the declared defaults (11320–11375, 476 words)
(§14.1 is another unit's; see the full survey.)

### §14.2 Fragment composition: locality without schema (11376–11487, 985 words)
(§14.2 is another unit's; see the full survey.)

### §14.3 Resolution: flatten, validate, compile once (11488–11558, 566 words)
(§14.3 is another unit's; see the full survey.)

### §14.4 One plan, two ways to apply it (11559–11717, 1,381 words)

Purpose: the two ways a resolved condition is applied, then (under `#### The
read-selector family`, 11600) the closed selector family, the leaf address,
the source rule, the client policy, the gather twin and trim's cost ledger.

Subheadings: one `####` (11600), linked from nowhere (`rg` over `docs/`).
No context paragraph names the parts; the bold opening sentence (11561) is an
aphorism. Bold: one sentence (11561), two list labels (11568, 11585), three
**Rule.** (11593, 11607, 11642), one bold sentence (11602), three list
lead-ins (11667, 11683, 11690), one lead-in (11705). One table (11697–11703).

| # | line | quote | marking | entry | class |
|---|---|---|---|---|---|
| 115 | 11561 | "**The paradigm-change tax feared at execution does not materialize.**" | bold sentence | — | N; an aphorism-style topic sentence (`spec_style.md`), history |
| 116 | 11561–11566 | "All string work, validation and addressing are functions of the *shape* of the [condition] (…). Every hot path holds the shape fixed while varying values. Execution is therefore resolve-once/execute-many, with two ways to apply one plan." | plain | D-066 Position | U (D-066 cited nowhere in the spec) |
| 117 | 11568–11569 | "**Specialized `apply!`** serves the service that iterates, trim's per-evaluation write." | list label | D-066 Position | U |
| 118 | 11569–11571 | "It unrolls stores through the baked lenses and converters. Those are the same machine operations as today's in-place writes: zero-alloc, no strings, no dispatch." | plain | D-066 Position | U; the run measured `@ballocated` 0; mid-sentence colon |
| 119 | 11571–11574 | "The per-iteration shape check is the mechanism of [§9.5] transferred. The tree type is proven by dispatch, and it carries the full nesting, every field name and leaf type." | plain | D-066 Position ("§9.5-style shape check via tree type") | U |
| 120 | 11574 | "A `===` sweep over the prefix strings closes the remainder." | plain | D-066 Position ("literal `===` sweep") | U; *sweep* is reserved (F17) |
| 121 | 11575–11577 | "`===` on strings compares content, so a prefix computed at run time pairs with the compiled one exactly as a literal does, at the cost of one short comparison per `at` node." | plain | — | N; the code says the same (`src/conditions.jl` 627–635); the run paired a computed prefix |
| 122 | 11577–11579 | "Shape drift (a tree of another type, or a prefix that differs at a position) is `ConditionShapeDrift` ([Appendix C]), a structured error rather than silent corruption." | plain | D-066 Position (the check); the kind has no entry | N; the run raised both reasons, `:tree_type` and `:prefix` |
| 123 | 11580–11582 | "The cost is Julia codegen *once per condition shape*, and it grows with the shape's writes. On Julia 1.13 it measures 10 to 50 ms up to 32 writes, 0.09 s at 64 and 0.2 s at 128 (`docs/reports/20261002_tuple_walks/`)." | plain | D-066 Position and annotation (2026-10-02) | U |
| 124 | 11583–11584 | "That cost is noise against the model's own first-sweep warmup (seconds), and against the 10³–10⁴ optimizer evaluations the codegen amortizes over." | plain | — | N; the scale disagrees with §14.7's LM default of ~5–15 evaluations (F18) |
| 125 | 11585–11586 | "**The dynamic walk** serves the one-shot uses, `init!` and `linearize`'s operating condition." | list label | D-066 Position ("for one-shot init") | U; leaves out trim's setup write (F19) |
| 126 | 11586–11589 | "It executes the same validated entry list by runtime dispatch per write. That takes microseconds in total, with allocation permitted, since the stopped-sim path was never under the zero-alloc regime ([§9.8])." | plain | D-066 Position | U; bare *entry* (F29) |
| 127 | 11589–11591 | "It needs no per-shape codegen. Fifty structurally different scripted conditions cost fifty walks, not fifty compiles." | plain | D-066 Position; Rejected (a single always-specialized form) | U |
| 128 | 11593 | "**Rule.** Which of the two a service uses is internal, never user-facing API." | **Rule.** | D-130 Position (names it as "§14.4's `apply!` precedent") | B: D-130's Position assumes the rule as a precedent and rules it for resolution clients; no entry rules it for the two ways |
| 129 | 11595–11597 | "A compiled plan or reader carries the [activation] it was compiled at and applies only to a store set of that activation. That pairing is a framework invariant the services uphold, not a user-facing check." | plain | — | N; realized as `_activation_mismatch` (`src/conditions.jl` 549, 763; `src/readers.jl` 375); uses *reader* before the section defines it (M4) |
| 130 | 11597–11598 | "Neither plans nor readers are user values." | plain | — | N; `apply!(model, plan)` is a gated door outside the API (D-319 Rationale, log 14386–14388), consistent |
| 131 | 11602 | "**The read-[selector] family is closed.**" | bold sentence | D-095 Position ("completed"); D-406 Rationale ("The family is closed") | U |
| 132 | 11602–11605 | "Its members are `get_state(path, leaf)`, `get_deriv(path, leaf)`, `get_output(path, leaf)`, `get_input(leaf)` and `get_face(leaf)`. They form one address space for every reader of the model." | plain | D-276 Position; D-095 Position (old names `get_local`, `get_slot`) | U |
| 133 | 11607–11610 | "**Rule.** `leaf` is a [leaf address]: the field or face name, followed by `.name` and `[k]` or `[k,l]` steps in any order, … A bare `Symbol` is the short form of a plain name, …" | **Rule.** | D-276 Position, bullet 1 | C (D-276 at 11627); mid-sentence colon |
| 134 | 11611–11617 | "A face name is an arbitrary string and may contain a dot ([§8.6]), so on `get_input` and `get_face` the head is matched rather than parsed: it is the longest declared face name that is a prefix of the address … and where faces `a` and `a.b` both exist, `"a.b"` names the face `a.b`." | plain | D-276 annotations of 2026-09-30 and 2026-10-01 | R |
| 135 | 11618–11622 | "Each step is checked at resolution against the type resolved so far. A `.name` step needs an isbits struct with that field. An index step needs an `SArray`, … A step never enters an opaque leaf (…), which is read whole." | plain | D-276 bullet 2 | C, adjacent |
| 136 | 11622–11625 | "A continuous state field is flat ([§7.1]), so `get_deriv`, and `get_state` on the continuous tier, take at most an index step. A discrete `s` field is isbits or a `Symbol` ([§3.2]), and `get_state` on it takes the full address." | plain | D-276 bullet 4 and its annotation | C, adjacent; the run's `.name` step on a `Float64` field refused as `:no_such_field` (`src/readers.jl` 679–681) |
| 137 | 11625–11627 | "The address is checked once and baked, and the read runs as field loads and indexing unrolled at compile time ([D-276])." | plain | D-276 bullet 3 | C |
| 138 | 11629–11632 | "The names carry a deliberate `get_` prefix. A selector is a *deferred read*, … and it keeps five short common nouns out of the namespace user declarations share with domain code." | plain | D-095 Position | U (D-095 cited nowhere in the spec) |
| 139 | 11634–11636 | "There is no selector for a value a [component] computes without declaring it, and there cannot be one, because only [cells] are addressable ([§4.2], [§8.3])." | plain | D-125 Rationale; D-098 annotation | R; "only cells" leaves out the stores the store selectors read (F20) |
| 140 | 11636–11637 | "So a reader that wants one is asking the producing component to declare it an output ([§8.3])." | plain | D-125 Rationale ("demand-driven publication") | R |
| 141 | 11637–11640 | "`get_face` addresses an output [face] of the mount level, the level its read set is mounted at ([§14.9]). At the root that face is root-exported. Either way the read is an *integration* read ([§11.2])." | plain | D-277 bullet 3 | U |
| 142 | 11642–11643 | "**Rule.** A selector resolves against a source, before any client policy applies." | **Rule.** | D-098 Position | U (D-098 cited nowhere in the spec) |
| 143 | 11645–11649 | "The table selectors (…) resolve against a *table source*. A table source is a [boundary] [snapshot], or the scratch tables a service evaluation instantiates ([§14.8]). The store selectors (…) resolve only against live stores." | plain | D-098 Position; D-124 Rationale (table sources) | U |
| 144 | 11649–11650 | "The table/store axis separates table-borne values from store-borne ones, not snapshots from services." | plain | D-124 Rationale | R |
| 145 | 11652–11654 | "Only stopped-sim service evaluations, `checkpoint`, and post-run inspection of the live stores (the [replay]-to-inspect, [§11.2]) ever hold live stores." | plain | D-098 Position (which says `capture`) | U; the entry text is stale (part E) |
| 146 | 11654–11656 | "The snapshot deliberately carries no state stores ([§11.2]), and `ẋ` [buffers] are integrator scratch, not boundary-consistent objects outside a service evaluation." | plain | D-098 Rejected; D-038 | R |
| 147 | 11656–11658 | "A reader resolving for a table source that names a store selector is therefore refused at resolution, as a `ReadResolution` ([D-406])." | plain | D-406 bullet 1 | C; the run raised `ReadResolution` reason `:store_selector` |
| 148 | 11658–11659 | "The resolver takes the source it resolves for, so the rule is the resolver's and not a client's." | plain | D-406 bullet 1 | C, adjacent; §11.2 bolds D-406's Position sentence for bindings, not this bullet |
| 149 | 11660–11662 | "The honest remedy ([§11.2]) is to declare the field in `y_types`, return it from `y_state`, and read the resulting [port] ([§5.3])." | plain | D-098 Rationale and annotation | R |
| 150 | 11664–11665 | "Client policy rides on top. It is [D-083]'s service and inspection sides restated as a resolver property." | plain | D-083 Position | C; "a resolver property" contradicts D-414's Rejected list, which keeps the resolver client-free (F1) |
| 151 | 11667 | "**Service reads speak the [contract].**" | list lead-in | D-409 Position; D-414 bullet 4 (guidance) | B: a rule by its bold, authoring guidance by D-414 and by the next sentence (F1) |
| 152 | 11667–11673 | "Trim's `reads` and linearization's [taps] (…) name `get_state`/…/`get_face`. They do so within the scopes the locality law ([§6.1]) and [fragment] scoping ([§14.2]) describe, as authoring guidance ([D-414])." | plain | D-414 bullet 4 | C |
| 153 | 11673–11677 | "`get_face` is the set's [seam]-crossing member. It resolves through export chains exactly as [mounting] (…) resolves [root input] faces ([§14.9]), so the read side mirrors the write side." | plain | D-125 Position | U (D-125 cited nowhere in the spec); every path selector crosses seams since D-414 (F1) |
| 154 | 11677–11680 | "An equilibrium equation meant to outlive the build it was posed against therefore binds the curated face behind a generically-held child rather than a path into it." | plain | D-125 Position; D-414 bullet 4 | U |
| 155 | 11680–11682 | "A service evaluation needing an undeclared intermediate has one remedy, and it is the same for every client. The component exports it ([§14.7])." | plain | D-125 Rationale | R; double of rows 139–140 (H9) |
| 156 | 11683 | "**Inspection readers admit the whole family, within the source rule.**" | list lead-in | D-095 Rationale ("inspection readers the whole family (within D-098's later source axis)"); D-083 Position | R |
| 157 | 11684–11686 | "Output-[device] bindings, log extraction by `series` and snapshot inspection take deep paths, `get_face` names and leaf addresses alike ([D-406], [D-407], [D-414])." | plain | D-406 Position; D-407 Position; D-276 bullet 5 (binding reads) | C; snapshot inspection takes none of these (F21); §13.3 lists bindings and `series` as service clients (F1, q5) |
| 158 | 11686–11689 | "The store selectors reach only the inspection clients that actually hold stores (`checkpoint`, post-run inspection). A snapshot-bound reader is barred from them by source, not by client." | plain | D-098 Position | U; no inspection reader resolves selectors against live stores in the code (F22) |
| 159 | 11690 | "**`ignore_stop_requests` is not a family client.**" | list lead-in | D-095 Rationale and Rejected (`stop_on` outside the family) | R |
| 160 | 11691–11692 | "It names requesters from the `Build`'s requester roster, period ([§13.5], [D-060], [D-316])." | plain | D-316 bullet 6 | C; D-060's policy clause is superseded by D-316 (S beside it, part E); "requester roster" unlinked (carried) |
| 161 | 11692–11693 | "Termination is run policy over the requests the model declares, and no path selector reaches `ignore_stop_requests`." | plain | D-060 Rejected ("stopping is run policy"); D-316 Rationale | R |
| 162 | 11695–11703 | "The five selectors, their sources, and their clients:" and the table | table | D-098 Position; D-083 | U; its "named in the contract" column states as a rule what D-414 made guidance (F1) |
| 163 | 11705–11707 | "**Compiled readers are the gather twin** over this family and the layout tables. Trim's cost read (`ẋ` and output fields) and linearization's Jacobian gather are one primitive run in reverse." | lead-in | D-066 Position ("compiled readers as the gather twin") | U; "cost read" is stale (F23) |
| 164 | 11708 | "It is one machinery, in both directions, in the `Build`'s client kit." | plain | D-066 Position | U |
| 165 | 11710–11713 | "The per-iteration ledger for trim has four terms. They are the user fragment math (…, plus the tree's few boxes, [§14.2]), the leaf stores, the folded shape check, and the sweep. The sweep dominates, exactly as `f_ode!` does today." | plain | — | N (an estimate); "few boxes" against §14.2's "allocates nothing" (F9); `f_ode!` is FlightCore's (F12) |
| 166 | 11713–11716 | "`apply!` ends at established stores. Making the model *coherent* is the job of [boundary zero] (…), [§14.5]." | plain | D-067 Position | U |

Descriptions that read like rules: rows 121–122, 129–130 (code facts), row
165. Row 150 describes a client policy no code enforces (part H, P23).

Display-block candidates: row 133's leaf address could take a one-line
display of the three example spellings; the selector table stays.

Glossary terms in §14.4:

| term | first use | linked there | use matches the entry |
|---|---|---|---|
| condition | 11563 | yes, glossed | yes |
| store | 11569 | no | yes |
| lens | 11569 ("baked lenses") | no | yes |
| fragment tree | 11573 ("tree type") | no | yes |
| sweep | 11574 ("A `===` sweep") | no | **no**: `#g-sweep` is a pass through the execution order (F17); the true sweep first appears at 11712 |
| entry | 11586 ("validated entry list") | no | **no**: bare (F29) |
| activation | 11595 | yes, no gloss | yes |
| selector | 11602 | yes, no gloss | yes |
| leaf address | 11607 | yes, defined there | yes |
| face | 11607 ("field or face name"), linked 11638 | late link | yes |
| tier | 11623 | no | yes |
| component | 11634 | yes, no gloss | yes |
| cell | 11635 | yes, no gloss | the sentence's claim is narrower than the store selectors (F20) |
| mounting | 11638 ("mounted at"), linked 11675 | late link | yes |
| boundary, snapshot | 11646–11647 | yes, no gloss | yes |
| scratch | 11647 | no | yes |
| checkpoint | 11652 | no | yes |
| replay | 11653 | yes, no gloss | yes |
| buffer | 11655 | yes, no gloss | yes |
| port | 11662 | yes, no gloss | yes |
| contract | 11667 | yes, no gloss | yes |
| taps | 11668 | yes, glossed | yes |
| fragment | 11672 | yes, no gloss | yes |
| seam | 11674 | yes, no gloss | yes |
| root input | 11676 | yes, no gloss | yes |
| generic holding | 11679 ("generically-held") | no | yes |
| device | 11684 | yes, no gloss | yes |
| log | 11684 | no | yes |
| requester roster | 11691 | **no**; `#g-requester-roster` exists (carried) | yes |
| layout | 11705 | no (`#g-schema-vs-layout`) | yes |
| boundary zero | 11715 | yes, glossed | yes |

Appendix C kinds cited to §14.4: `ReadResolution` (13650, 13656),
`ConditionShapeDrift` (13678) and `ReadSetMisuse` (13735). The section names
`ReadResolution` where it states the source refusal (row 147) and
`ConditionShapeDrift` where it states the drift (row 122). It never names
`ReadSetMisuse` and states none of its conditions; the empty-prefix case is
§14.9's (12421–12422) and the non-selector and non-tap-list cases are stated
nowhere in the half (F5). Appendix C's owning section for `ReadSetMisuse` is
stale, which is Appendix C's to settle with half 2.

### §14.5 Boundary zero: an ordinary boundary with authored incoming transitions (11718–11820, 1,018 words)

Purpose: the boundary-zero sequence piece by piece, the `t₀` argument, and
what boundary zero means for trim's commit.

Subheadings: none; a bullet list carries the structure. One inline sequence
(11722–11723), one table inside a list item (11778–11781), one formula
(11785). Bold: three list labels (11730, 11749, 11769), two bold sentences
(11736–11737, 11771–11772) and four bold lead-ins (11792, 11804, 11807,
11813).

| # | line | quote | marking | entry | class |
|---|---|---|---|---|---|
| 167 | 11720–11721 | "`apply!` establishes the stores at `t₀`. The init service then completes the [§10.6] macro-sequence with an empty integrate." | plain | D-067 Position | U (D-067 cited at 11756) |
| 168 | 11721–11723 | "The sequence is project → [[sweep] → [guards] → handlers]\* → [due] `s_update` calls → first [snapshot]." | inline sequence | D-067 Position; D-205; D-292 | U; the code runs it so (`src/model.jl` 325–332, then `settled!` at 195) |
| 169 | 11723–11726 | "After the first snapshot `init!` takes the [trace header], the [checkpoint] (…) of the state the sequence leaves ([§11.5], [D-274])." | plain | D-274 bullet 4 | C |
| 170 | 11727–11728 | "The parity with an ordinary boundary is exact, not approximate. The pieces follow one by one." | plain | — | N (framing) |
| 171 | 11730–11735 | "**Project runs.** Authored `x` can sit off-manifold. … [Projection] after condition writes holds the same position it holds after any other `x` mutation. And it costs nothing when the state is already clean." | list label | D-067 Position (project first) | U |
| 172 | 11736–11737 | "**The sweep runs, and every discrete output stage publishes, due or not ([D-205]).**" | bold sentence | D-205 Position | C; §10.5 (6141–6142) and §5.3 (1368–1369) state it plain and point here |
| 173 | 11737–11738 | "`t₀` is a grid point of every phase-free divisor, so the `Φ = 0` components are due in full." | plain | D-067 annotation (2026-10-02); D-185, D-291 | U |
| 174 | 11738–11742 | "An offset [component] ([§10.5]) is *not* due, because its first [tick] is at `Φ·Δt_base`. Its output stages run at boundary zero all the same, publishing from the authored `s` and the `t₀` table in the ordinary sorted walk." | plain | D-205 Position | C, adjacent |
| 175 | 11742–11744 | "That evaluation is establishment, not a scheduled sample. The schedule owns every instant after `t₀`, and the first sample the component's `s_update` consumes remains its `Φ·Δt_base` tick's." | plain | D-205 Position and Rationale | C, adjacent |
| 176 | 11744–11746 | "What the rule buys is a `t₀` snapshot carrying the authored world fully evaluated. No published [cell] holds the [probe]'s synthesized values." | plain | D-205 Position | C, adjacent |
| 177 | 11747–11748 | "That is the [§14.6] barrier extended from the [root inputs] to the whole table." | plain | D-205 Rationale | R |
| 178 | 11749–11753 | "**Events run.** A condition can land a guard [predicate] in [holding] territory (…). An authored stall flag, or a strut authored into contact, does exactly that. The event then fires visibly at `t₀` rather than one step later." | list label | D-292 bullet 1 | U |
| 179 | 11753–11756 | "The [prior] rule grounds that timing ([§10.6]). [Boundary zero] establishes every guard prior (…) as not-holding." | plain | D-292 bullet 1; D-082 | U; §10.6 bolds it (6487–6488), so plain here is right |
| 180 | 11756–11758 | "Suppressing those firings was rejected ([D-067]), on the [stage-on-interaction] lesson of [§11.7] (widgets stage on edit or activation, never per render pass)." | plain | D-067 Rejected | R; the lesson rests on the parked GUI (F14) |
| 181 | 11759–11760 | "Insurance that masks invariant violations is anti-diagnostic ([D-026])." | plain | D-026 Rejected | R |
| 182 | 11760–11763 | "The trace header is taken after the sequence ([§11.5]). [Replay] restores it and runs no [boundary] zero, so whatever fired at `t₀` comes back as part of the restored state and never fires twice ([§12.7])." | plain | D-274 bullet 4 | U; "[boundary](#g-boundary) zero" links the wrong anchor (F4) |
| 183 | 11763–11765 | "The checkpoint records the post-firing state faithfully and suppresses nothing." | plain | D-274 Rationale | R |
| 184 | 11765–11768 | "A [stop request] already reading `STOP_REQUESTED` is a different category. Nothing *fires*. The request simply holds in the published `t₀` snapshot and the loop reacts ([§13.5])." | plain | D-413 bullet 1 | U (D-413 cited only in §13.5) |
| 185 | 11769–11771 | "**Due `s_update` calls run.** This follows from an interval-alignment fact that is easy to mis-picture. It is hereby a taught contract, sibling to the boundary-sampling line ([§8.6])." | list label | D-067 bullet 1 | U; Appendix A indexes it (12779) |
| 186 | 11771–11772 | "**A boundary's `s_update` is the *outgoing* transition.**" | bold sentence | D-067 bullet 1 | C, adjacent (D-067 at 11787, not in the sentence); §3.2 (680–682) states the law plain (O4, q4) |
| 187 | 11772–11774 | "At tick `t_k` it consumes the completed boundary's samples and produces `s_{k+1}`, the value the next tick reads. The transition that carried `s` *into* `t_k` ran at `t_{k-1}`." | plain | D-067 bullet 1 | C, adjacent |
| 188 | 11774–11776 | "Boundary zero is missing its incoming transitions on *both* tiers, and authorship replaces both." | plain | D-067 bullet 1 | C, adjacent |
| 189 | 11778–11781 | the tier table (`t₋₁`, `t₀`, `t₁`) | table | D-067 bullet 1 | C, adjacent (illustration) |
| 190 | 11783–11785 | "The outgoing work all runs, and `t₀`'s `s_update` has its only opportunity. `s(1)` must sit in the store before `t₁`'s gated stages read it." | plain | D-067 bullet 1 | C, adjacent |
| 191 | 11785–11787 | "An accumulator $s_{k+1} = s_k + \Delta t \, e_k$ authored with $s_0 = 0$ under nonzero $e(t_0)$ would otherwise first integrate $e(t_1)$, putting the whole sampled-data lattice one period late ([D-067])." | plain | D-067 Rejected | R |
| 192 | 11787–11789 | "The authored `s(0)` needs no protection, because it is published in the `t₀` snapshot regardless." | plain | D-067 Rejected | R |
| 193 | 11789–11791 | "The continuous-tier analogue of `s_update`-at-`t₀` is not the empty incoming integrate but that first *outgoing* one. Both authored values are the published initial conditions of their outgoing transitions." | plain | — | N (explanation) |
| 194 | 11792–11793 | "**`t₀` is an init-service argument** (default `0.0`), never a condition entry, because time is not a store of any component." | bold lead-in | D-067 bullet 2 and Rejected; D-110 Position (the default) | U (D-110 cited nowhere in the spec); bare *entry* (F29) |
| 195 | 11793–11795 | "The [harmonic grid] (…) anchors at whatever `t₀` boundary zero runs at." | plain | D-067 bullet 2 | U |
| 196 | 11795–11799 | "Both init-service entry points carry the argument, with the same default. They are `init!(model, condition; t0)`, which the simulation's `init!(sim, condition; t0)` forwards to, and `trim!`'s commit ([§14.8], [D-319])." | plain | D-110 Position; D-319 bullet 5 | C (D-319); the simulation's door resolves the condition itself and calls the model's plan method (F27) |
| 197 | 11799–11801 | "`trim!(model, problem; baseline, t0, backend)` commits through the model's `init!`, and `trim!(sim, problem; baseline, t0, backend)` through the simulation's." | plain | D-319 bullet 5 | C, adjacent; restates §14.8's signature (H11) |
| 198 | 11802 | "Conditions are time-free. Nothing after boundary zero sets the origin." | plain | D-273 bullet 3; D-067 bullet 2 | C, adjacent |
| 199 | 11802–11803 | "A restore inherits the clock and takes no `t0` ([D-273])." | plain | D-273 bullet 3 | C |
| 200 | 11804 | "**Trim is untouched by all of this.**" | bold lead-in | D-067 bullet 3 | U |
| 201 | 11804–11806 | "Optimizer iterations are raw write → sweep → read cycles on the activation, with no boundaries, no events and no `s_update`. Only the committed solution executes boundary zero." | plain | D-067 bullet 3 | U |
| 202 | 11807 | "**A guard firing at commit is a wanted failure signal.**" | bold lead-in | D-067 bullet 3 | U; the same bullet as row 200, so one bold between them |
| 203 | 11807–11810 | "Today's hand-written trim asserts (`!stall`, no weight-on-wheels, `ω > ω_idle`) become the model's own event logic, surfaced through the ordinary machinery instead of `@assert`." | plain | D-067 bullet 3 | U; "today's" means FlightApps' `c172s.jl` (F12) |
| 204 | 11810–11812 | "A handler that fires at commit moves the committed stores off the solved point. Saying nothing would be warn-but-assign relocated. The channel that says it is the trim report ([§14.8])." | plain | D-126 Position and Rationale | U (D-126 cited nowhere in the spec) |
| 205 | 11813–11814 | "**A commit-fired handler is not the only mover, and the second one is unconditional.**" | bold lead-in | D-155 Position | U (D-155 cited nowhere in the spec) |
| 206 | 11814–11819 | "Boundary zero's *first* act is `x_projection`, so the committed `x` is `x_projection(x*)`, not the solver's `x*`. … That move is legitimate, wanted, and usually invisible in the residuals. But the point the stores sit at is no longer the point the verdict was read at. Both movers take the same remedy, specified with the report in [§14.8]." | plain | D-155 Position and Rejected | U |

D-067 is cited three times (11756, 11787) and rules rows 167–171, 173,
185–195, 200–203. D-205 rules rows 172–177. D-274, D-292, D-413, D-110,
D-126 and D-155 rule the rest; the last three are cited nowhere in the spec.

Descriptions that read like rules: row 168 (the sequence as the code runs
it), row 193.

Display-block candidates: the inline sequence (11722–11723) is a display
already in §10.6 (6642–6644, a block quote); a block here would match.

Glossary terms in §14.5:

| term | first use | linked there | use matches the entry |
|---|---|---|---|
| store | 11720 | no | yes |
| sweep, guard, due | 11722–11723 | yes, no gloss | yes |
| snapshot | 11723 | yes, no gloss; **linked again at 11745** | yes; a duplicate link in one section |
| trace header | 11724 | yes, no gloss | yes |
| checkpoint | 11725 | yes, glossed | yes |
| frame | 11725 (in the gloss) | no | yes |
| condition | 11731 | yes, glossed | yes |
| projection | 11733 | yes, no gloss | yes |
| component | 11738 | yes, no gloss | yes |
| tick | 11739 | yes, no gloss | yes |
| boundary zero | 11718 (title), 11740 in prose | linked at 11754 | late link |
| cell, probe | 11746 | yes, no gloss | yes |
| root input | 11748 | yes, no gloss | yes |
| predicate, holding, prior | 11749–11753 | yes; prior glossed at 11755 | yes |
| stage-on-interaction | 11757 | yes, glossed | yes; the gloss describes the parked GUI's widgets (F14) |
| replay | 11761 | yes, no gloss | yes |
| boundary | 11762 ("[boundary](#g-boundary) zero") | wrong anchor (F4) | — |
| stop request | 11765 | yes, no gloss | yes |
| contract | 11770 ("a taught contract") | no | a distinct usage (Appendix A's), correctly unlinked |
| tier | 11775 ("*both* tiers"), linked 11778 | late link | yes |
| harmonic grid | 11794 | yes, glossed | yes |
| entry | 11793 ("never a condition entry") | no | yes, the listed compound |
| baseline | 11799 | no | yes |

Appendix C kinds cited to §14.5: none. The section raises nothing.
`TrimCommitEvents` and `TrimCommitResiduals` (both cited to §14.8) are the
report's warnings behind rows 204–206, named in §14.8.

### §14.6 Root-input totality: the missing-value error and the `override` combinator (11821–11873, 444 words)

Purpose: why root inputs need the condition, the totality check and its
sites, the probe-value barrier, and baselines layered by `override`.

Subheadings: none. A context paragraph (11823–11828) ends "Three
consequences follow", which names the parts by count. Bold: three bold
sentences opening the consequences (11830, 11847, 11858), one bold term
(11865).

| # | line | quote | marking | entry | class |
|---|---|---|---|---|---|
| 207 | 11823–11825 | "[Root inputs] are the one initialized datum without declared defaults. That is the bare-types decision ([§11.3]), upheld here ([D-068])." | plain | D-376 Position; D-068 Rejected (face-declaration defaults) | U (D-376 cited only in §11.3, which bolds it at 7326) |
| 208 | 11825–11827 | "So a root input's only source before [boundary zero] (…) is the condition." | plain | D-376 Position | U |
| 209 | 11830 | "**Totality is a precondition of starting, checked by the service.**" | bold sentence | D-068 Position | C, adjacent (D-068 at 11825, not in the sentence) |
| 210 | 11830–11832 | "A condition value is legitimately partial. [Fragments] compose, and trim iterations write subsets." | plain | D-068 Rejected (totality as a condition property) | R |
| 211 | 11832–11834 | "So 'every root input covered' is not a property of conditions. It is a property of *every application that establishes a complete world over virgin stores*." | plain | D-149 Position | U (D-149 is bold in §9.3, 4690–4692) |
| 212 | 11835–11837 | "That principle, not an enumeration, names the sites. They are `init!`, trim's setup application to freshly allocated scratch stores, and trim's commit through [boundary] zero ([§14.8])." | plain | D-149 Position | U; omits linearization's `about` application (F2); wrong anchor (F4) |
| 213 | 11837–11838 | "That is one class, one mechanism and one kind." | plain | D-149 Position | U |
| 214 | 11838–11839 | "Each compares the resolved plan's root-input coverage against the `Build`'s `input_faces` before writing anything." | plain | D-068 Position | C, adjacent; the code compares against the structure's root-input list (`assert_total`, `src/conditions.jl` 514–519), the same faces |
| 215 | 11839–11841 | "A shortfall is one collected, declaration-ordered diagnostic (`UninitializedInputs`, a [§13.2] kind) naming every uncovered face." | plain | D-068 Position; D-149 | C, adjacent; "a §13.2 kind" points at the wrong home (F24); the run's faces came back `[:u, :e]` in declaration order |
| 216 | 11841–11844 | "Coverage is a *plan-level fact*, because both operands are resolution-time data. The check is therefore one comparison, and it runs before any evaluation, not merely before any write." | plain | D-149 Rationale | R |
| 217 | 11844–11845 | "Pre-write means all-or-nothing. A rejected init leaves the sim exactly as it was, the same posture as failed trim." | plain | D-068 Position | C, adjacent; the run left the simulation `built` |
| 218 | 11847 | "**The [probe]-value barrier is structural.**" | bold sentence | D-068 bullet 1 | C, adjacent |
| 219 | 11847–11849 | "The `probe_value` synthesis ([§9.3]; zero/false/first-enum/`T()`) exists so build-time probes can exercise code with fabricated inputs." | plain | — | N; §9.3's mechanism, restated |
| 220 | 11849–11851 | "A fabricated zero is a fine probe input and a terrible flight condition. A silently zeroed `mixture` kills the engine and sends the user debugging aerodynamics." | plain | D-068 Rejected (silent zero-fill) | R |
| 221 | 11851–11853 | "The services path simply contains no call to it. A root input gets a condition value or the application errors, with no third branch." | plain | D-068 bullet 1 | C, adjacent |
| 222 | 11853–11856 | "[Replay] likewise never synthesizes. The [trace header] holds every root-input cell as boundary zero left it, and with totality enforced that record is complete by construction (the requirement discharged, [§11.3])." | plain | D-068 bullet 1; D-274 bullet 4 | C, adjacent |
| 223 | 11858–11859 | "**[Baselines] are aircraft-shipped [condition] functions, layered by `override`.**" | bold sentence | D-068 bullet 2 | C, adjacent |
| 224 | 11859–11863 | "Nobody hand-writes ~20 root-input values per script. Today `SystemsInitializer`'s `@kwdef` defaults carry that load. Their successor is ordinary user math in one authoritative home, such as `ready_for_taxi(ac)` or `cold_and_dark(ac)`, returning full-coverage conditions." | plain | D-068 bullet 2 | C, adjacent; `SystemsInitializer` is FlightApps' (F12) |
| 225 | 11863–11865 | "But 'baseline plus tweaks' collides with the duplicate-leaf error ([§14.2]) by design. The collision *is* the intent. Hence the fourth node kind, **`override(base, patch)`**." | bold term | D-068 bullet 3 | C, adjacent |
| 226 | 11866–11868 | "It is ordered and asymmetric, where `combine` is symmetric and collision-intolerant. At resolution a leaf present in both takes the patch's value, with the origin recording both layers ('patch overrode base's `throttle`')." | plain | D-068 bullet 3 | C, adjacent; the quoted origin is not the code's spelling (F25) |
| 227 | 11868–11870 | "Collisions *within* one layer remain errors. Variadic layering (`override(campaign, aircraft, todays_case)`) composes." | plain | D-068 bullet 3 | C, adjacent |
| 228 | 11870–11872 | "Trim uses it on day one. The committed condition is `override(baseline, solution)`, the solver's handful of values over full coverage ([D-068])." | plain | D-068 bullet 3 | C; `solution` stands for `condition(d*)` (F25) |

D-068 is cited twice (11825, 11872) and rules 13 of the 22 rows. D-149 and
D-376 rule the context and the sites, and §9.3 and §11.3 bold them.

Descriptions that read like rules: row 219 (§9.3's synthesis), row 214 (the
check as the code runs it).

Display-block candidates: row 226 could show the layering as two lines,
`override(set(u = (u = 1.0, e = 2.0)), at("plant", set(u = (u = 9.0,))))`
with its origin, which the suite pins (`test/test_conditions.jl` 104–124).

Glossary terms in §14.6:

| term | first use | linked there | use matches the entry |
|---|---|---|---|
| root input | 11823 | yes, no gloss | yes |
| override | 11821 (title), 11859 | **never linked** in the section that defines it; `#g-override` cites §14.6 | yes |
| boundary zero | 11826 | yes, glossed | yes |
| condition | 11827 ("is the condition"), linked 11858 | late link | yes |
| fragment | 11831 | yes, no gloss | yes |
| store, scratch | 11834, 11836 | no | yes |
| boundary | 11837 ("[boundary](#g-boundary) zero") | wrong anchor (F4) | — |
| kind | 11838 | no | yes |
| `Build` | 11839 | no | yes |
| face | 11841 | no | yes |
| probe value | 11847 ("[probe](#g-probe-value)-value") | yes | yes |
| replay, trace header | 11853–11854 | yes, no gloss | yes |
| cell | 11854 | no | yes |
| baseline | 11858 | yes, no gloss | yes; `#g-baseline` adds "the `baseline` keyword `init!`/`trim!` take", false for `init!` (F26) |
| combine | 11866 | no | yes |

Appendix C kinds cited to §14.6: `UninitializedInputs` (13659). The section
names it where it states the shortfall (row 215), but calls it "a §13.2
kind" (F24).

### Tally

| section | rules | C | U | S | R | N | B |
|---|---|---|---|---|---|---|---|
| heading | 22 | 4 | 11 | 0 | 4 | 0 | 3 |
| §14.1 | 21 | 7 | 5 | 0 | 7 | 2 | 0 |
| §14.2 | 45 | 11 | 18 | 0 | 9 | 6 | 1 |
| §14.3 | 21 | 1 | 14 | 0 | 3 | 2 | 1 |
| §14.4 | 52 | 10 | 23 | 0 | 10 | 7 | 2 |
| §14.5 | 40 | 14 | 18 | 0 | 6 | 2 | 0 |
| §14.6 | 22 | 13 | 5 | 0 | 3 | 1 | 0 |
| total | 223 | 60 | 94 | 0 | 42 | 20 | 7 |

The count leaves out the two framing rows of the heading (1, 3), and the
three code blocks of §14.2 (unnumbered rows), and classes each row by its
first code. "C, adjacent" counts as C; of the 60, 24 carry the citation in
the sentence itself. One citation is half-superseded but its row is C by
the other entry it cites: D-060 at 11691 (row 160), whose policy clause
D-316 superseded.

The U rows cluster in entries the half never cites: D-066 (13 rows, §14.3
and §14.4), D-148 (5, §14.3), D-098 (5, §14.4), D-125 (2), D-095 (2), D-108
(9 in the heading, cited once), D-149 (3), D-155 (2), D-126 (1), D-110 (1),
D-413 (1), D-292 (2), D-376 (2), D-306 (1) and D-405 (1). The R rows are
mostly reasons in D-139's Rationale (§14.1, five rows), D-148's Rationale,
D-204's Rationale, D-108's Rationale, D-067's Rejected list and D-276's
annotations. The N rows are framing, code facts and five stale claims (rows
37, 79, 83, 124, 165).

Bold weight now: 44 spans, 203 words. Labels: **Rule.** ×5, **Why.** ×1,
three bold labels. Whole-sentence bolds: rows 19, 29, 131, 172, 186, 209,
218, 223, and the lead-ins 115, 194, 200, 202, 205. Bolds on a term or a
name: rows 2, 40, 48, 56, 73, 90, 96, 102, 103, 225, and the case openers
110–111.

## B. Overlaps

Numbered H1–H19 for overlaps inside the chapter and O1–O16 for overlaps with
other chapters. "Home" says which text keeps the statement; the other becomes
a pointer. For chapters 1 to 13 the home is the one the rewritten text
already chose.

### Inside the half

- **H1. A checkpoint is not a condition, three times.** Heading row 4
  (11278–11281), §14.1 row 33 (11337–11340) and §12.6 (9536–9546). Home: §14.1
  for D-273's ruling that a condition is an initial condition and nothing
  else; §12.6 for the checkpoint itself. The heading keeps the service's name
  and one clause with a pointer to §12.6.
- **H2. Root-input totality's definition, twice.** The heading's gloss
  (11275–11276) and §14.6 (11830–11845). Home: §14.6. The heading keeps the
  gloss as a roadmap gloss.
- **H3. `override`, three times.** The heading table (11298), §14.2 (rows
  85, 93) and §14.6 (rows 225–228). Home: §14.6, which defines it; §14.2's
  two mentions are pointers and stay.
- **H4. The walk that applies the tree.** §14.2 row 61 (11422–11424) and
  §14.4 rows 117–127. Home: §14.4. §14.2's sentence becomes a pointer to the
  specialized `apply!` (F9).
- **H5. The locality law as guidance, twice.** §14.2 rows 79–82
  (11454–11464) and §14.4 row 152 (11671–11673). Home: §14.2; §14.4 points,
  as it does.
- **H6. Overlay base, twice.** §14.1 row 29 (11333) and §14.3 row 114
  (11555–11557, "the overlay-base rule, §14.1"). Home: §14.1; §14.3 states
  the bake, which is its own content.
- **H7. The converter story, twice in the half and once in half 2.** §14.3
  rows 107–113 and §14.7 (11993–11999). Home: §14.3, D-148's section; §14.7
  points.
- **H8. Boundary zero's gloss, three times.** §14.4 (11715–11716), §14.6
  (11826–11827) and §14.5's own title. Each is a first-use gloss in its
  section, as `spec_style.md` asks. Not a double.
- **H9. "No selector for an undeclared value", twice in §14.4.** Rows
  139–140 (11634–11637) and row 155 (11680–11682). Home: rows 139–140; row
  155 merges into them (M5). §14.7 states it a third time (11952–11955), a
  pointer for half 2.
- **H10. The interrupt at a service.** Nothing in half 1; §14.8 12220–12224
  states it. No overlap.

### With half 2

- **H11. `trim!`'s signature and commit door.** §14.5 rows 196–197
  (11795–11801) and §14.8 (12064–12067, 12233–12234). Home: §14.8 for the
  signature; §14.5 keeps the `t₀` rule and names the two entry points with a
  pointer.
- **H12. The two movers of the committed point.** §14.5 rows 202–206
  (11807–11819) and §14.8 (12279–12297). §14.5 states the movers (D-067
  bullet 3, D-126, D-155), §14.8 the report and its warnings. Which section
  bolds D-126 and D-155's first ruling is q8.
- **H13. Totality at trim's setup and commit.** §14.6 rows 211–213
  (11832–11837) and §14.8 (12172–12180, 12204–12209). Home: §14.6 for the
  rule and its sites; §14.8 for setup's check as the reason raw scratch
  instantiation is sound. Each points at the other already.
- **H14. The read side of the trim problem.** §14.4's family (rows 131–149)
  and §14.7's read bullet (11939–11960), which restates the selector list,
  the validation targets, "a value a component computes without declaring it
  is not addressable", the export remedy and the gather twin. Home: §14.4;
  §14.7's restatement is half 2's to trim.
- **H15. Mounting a read set.** §14.4 row 141 (`get_face` of the mount
  level) and §14.2 row 67 (the read side's lifts) against §14.9
  (12409–12423). Home: §14.9 for the mount chain and `ReadSetMisuse`; half
  1's two sentences are pointers.
- **H16. The flattening accumulator.** §14.3 row 95 and §14.9 12405–12407.
  §14.9 points back. No change.
- **H17. Frozen cells at boundary zero's sweep.** §14.5 rows 172–177 and
  §14.8's establishment round (12182–12202), which reuses D-205's rule.
  Home: §14.5 for D-205; §14.8 for the round. Pointers both ways exist.
- **H18. `linearize`'s default operating point.** Heading rows 13–14 and
  §14.10 (12584–12599). Home: the heading for the legality, §14.10 for the
  restore into scratch. No change.
- **H19. `ReadResolution` in `TrimProblemInvalid`.** §14.4 row 147 and
  §14.8 12318–12320. Pointer. No change.

### With other chapters

Part I's restated chapter 2 states the run's semantics. Each Part I overlap
is checked against "Part I's depth" in `spec_style.md`: Part I keeps the
law, the later chapter gives the mechanism.

- **O1. `errored` is terminal.** §12.6 bolds it (9429, D-059); the heading
  bolds it again (row 19). Home: §12.6. The heading states the services'
  consequence plain and points (carried B84).
- **O2. `checkpoint`'s legality.** §12.6 9536–9546 states it with
  `CheckpointMidFrame` named; heading row 9 restates it in the table. Home:
  §12.6 for the mechanism; the table row stays, as the services' one view,
  and names the kind or points (F5).
- **O3. Pause and the roster freeze.** §11.3 7337–7345 bolds the roster
  freeze (D-106) and says the prohibition includes pause. Heading row 7
  states the services' version. Home: §11.3 for the roster; the heading
  keeps the services' rule with D-108 cited.
- **O4. Interval alignment.** §3.2 (680–682, Part I) states "A tick's update
  is the outgoing transition" plain with D-067; Appendix A (12779–12784)
  indexes it to §14.5. §14.5 bolds it (row 186) and works the boundary-zero
  consequence. Home: §14.5 for D-067's ruling and its consequence; §3.2 keeps
  the law at Part I's depth. §14.5's bold sentence is at Part I's depth, and
  the rest of the bullet is mechanism (q4).
- **O5. Boundary zero's laws in Part I.** §5.3 (1360–1376) and §2.4
  (495–507) state that every discrete output stage publishes at `t₀`, that
  only `Φ = 0` components update, that priors start not-holding, that a
  restore runs no boundary zero, and that a run starts only with every root
  input given. §14.5 and §14.6 give the mechanism and the reasons. Home of
  the laws: Part I; of the rulings' bolds: §14.5 (D-205) and §10.6 (D-082,
  D-292). No §14.5 or §14.6 sentence restates a law without its mechanism
  except row 172's bold, which is D-205's ruling home.
- **O6. Boundary-zero dueness.** §10.5 6136–6150 states the due set at
  boundary zero plain, "as §14.5 specifies" (D-205). Home: §14.5 for the
  bold, §10.5 for the gate arithmetic. No change.
- **O7. The prior at boundary zero.** §10.6 bolds "Boundary zero sets every
  prior to not-holding" (6487–6488, D-082, D-292). §14.5 row 179 states it
  plain with a pointer. Correct as is; cite D-292 beside the pointer.
- **O8. The macro-sequence.** §10.6 6640–6647 displays it and says boundary
  zero is the same sequence with an empty integrate (§14.5, D-067). Home:
  §10.6 for the sequence, §14.5 for boundary zero.
- **O9. The service walk and the client table.** §13.3 10220–10288 bolds
  D-414's walk and D-130/D-414's "Which rule applies depends on who is
  resolving", and its table puts condition entries, trim `reads`, taps,
  device read bindings and log extraction by `series` under *service*, with
  snapshot and log inspection on the address table. §14.4 rows 150–158 call
  bindings and `series` *inspection readers* and put snapshot inspection
  among the selector clients. Chapter 13's R2 moved bindings to the service
  row. Home: §13.3 for resolution; §14.4 for the read side's semantics (q5,
  F1, F21).
- **O10. Observation by path.** §13.5 10744–10770 (rewritten) states the
  rejection and its ground, "Rejecting observation-by-path separates
  inspection from the reads a run acts on" (D-409), and says a condition
  binds "at a stopped-sim point where conditions already address state by
  path (§14.1)". §14.1 rows 34–37 argue from runtime coupling through
  generic seams and from `local_wires`' paths. Home: §13.5 for the ground;
  §14.1 keeps one sentence placing conditions outside it (F6, q3).
- **O11. Bindings and `series`.** §11.2 7107–7140 bolds D-407 and D-406's
  binding sentences and states the store-selector refusal at attach. §14.4
  rows 147–148, 157 point there. Home: §11.2 for the clients; §14.4 for the
  source rule, whose D-406 bullet 1 is bold nowhere yet.
- **O12. Totality's sites.** §9.3 bolds D-149, "Every complete-world
  application, namely `init!`, trim setup and trim commit, carries the
  pre-write `UninitializedInputs` check" (4690–4692), and §11.3 lists the
  same three (7334). Home of the bold: §9.3. §14.6 rows 211–213 stay plain
  and cite D-149. All three lists lack linearization's `about` (F2).
- **O13. Root inputs have no defaults.** §11.3 bolds "The init/trim
  services own root-input initial values" (7326, D-047, D-376). §14.6 row
  207 restates it as the reason. Home: §11.3; §14.6 keeps its sentence and
  cites D-376.
- **O14. The workspace is never a condition target.** §7.3 1988 states it
  with D-306. §14.1 row 27 restates. Home: §7.3; §14.1 keeps the clause in
  its list of what a condition never specifies and cites D-306.
- **O15. The value-level constructor.** §4.4 and §8.2 (2941–2958) hold
  D-139's Position. §14.1 rows 40–45 state the condition side. Home: §8.2 for
  the constructor, §14.1 for the escape. No change.
- **O16. §8.2's engine and §14.2's block.** §8.2's engine fixture carries
  `ω_rated` with the comment "unread here; §14.2's shipped condition uses it"
  (2312–2313). §14.2's first code block must keep `eng.ω_rated`.

No sentence in the half restates Part I at Part I's depth in place of a
mechanism, except row 186 (O4), which is D-067's ruling home and works the
mechanism in the rows after it.

## C. Proposed structure

No section is renumbered and none is retitled. 356 inbound rows point at the
half (part D). No file links a `####` anchor of the half (checked with `rg
'read-selector-family|spec.md#14'` over `docs/`: only section-level link
definitions), so `####` labels can be added freely. §1 already puts `####`
labels directly under a `##` heading (151–214), so the chapter heading may
take one.

### Moves

| move | content | from | to | needs a ruling |
|---|---|---|---|---|
| M1 | the `Model` forms paragraph (rows 15–18) | heading 11302–11308 | after the `ServiceLifecycle` paragraph (ends 11318), so the table, its `errored` rule and its kind stay together and the model's statuses follow | no |
| M2 | `set`'s self-vocabulary and the `u` payload's export chain (rows 68–72) | §14.2 11433–11443 | up, after the owner-pull block (ends 11406) and before "Dispatch selects variant-specific methods" (11408), so the payloads are explained beside the blocks that use them and before the tree | no |
| M3 | the per-iteration ledger (row 165) | §14.4 11710–11713 | up, after the **Rule.** that closes the two ways (11593), so the cost account follows the two ways; the closing pointer to boundary zero (row 166, 11713–11716) stays the section's last sentence | no |
| M4 | the activation pairing (rows 129–130) | §14.4 11595–11598 | down, after the gather-twin paragraph (ends 11708), where readers are defined | no |
| M5 | "A service evaluation needing an undeclared intermediate has one remedy" (row 155) | §14.4 11680–11682 | merged into rows 139–140 (11634–11637), one statement (H9) | no |
| M6 | the bold label "**Lifecycle preconditions.**" | heading 11283 | a `#### Lifecycle preconditions` label over rows 5–24 | yes, q1 |

All moves stay inside one section, so each stays inside one unit.

### Order within each section

Define-before-use was checked for each order below against the terms each
block uses.

- **Chapter opening (q1).** Context: the stopped-sim services are `init!`,
  `trim!`, `linearize`, `checkpoint` and `restore!` (F3); three of them share
  the condition, and the checkpoint is a value of its own (D-273). Roadmap:
  §14.1–§14.10 in order. Then `#### Lifecycle preconditions` (M6): the
  non-running rule and pause, the table, `errored`, the kind, then the
  `Model` forms (M1). Checked: the table uses `override` and `baseline`
  (glossed or linked in the heading), "frame top" and `:consistent` (§12.6).
- **§14.1.** Unchanged order: what a condition specifies, the overlay base,
  the doctrine, the pre-sweep doctrine, environment queries. The context
  gains one sentence naming the parts. The two bold labels become topic
  sentences. No subheadings at 476 words.
- **§14.2.** Order after M2: the idea (component-local knowledge, the
  rejected schema entry), the condition method and its block, the pull and
  its block, `set`'s payloads and the `u` export chain (M2), the inert tree
  and its sketch with the allocation account, the empty prefix, the locality
  law, collisions and blends. The context gains a parts sentence. No
  subheadings at 985 words. Checked: `at` and `combine` appear in the pull
  block before M2's paragraph names `at`'s job; "the empty-prefix check
  below" still precedes the **Rule.**; "export chain" is defined by M2's
  paragraph before the locality law uses it.
- **§14.3.** Unchanged order: flattening, the checks, schema and layout, the
  plan and lens, the converter rule and its two cases, overlay partiality.
  The context gains a parts sentence. No subheadings at 566 words.
- **§14.4.** Two `####` labels (q6): an unlabeled first part on the two ways
  (rows 116–128, with M3's ledger after the **Rule.**), then the existing
  `#### The read-selector family` (rows 131–164, M4's pairing paragraph after
  the gather twin, M5 merged), then the closing pointer (row 166). Context
  replaces the aphorism (row 115). Checked: *reader* is first used in M4's
  paragraph after the gather twin defines it; *lens* and *tree type* come
  from §14.3; the ledger's "folded shape check" follows the specialized
  bullet that defines it.
- **§14.5.** Unchanged order, the sequence's pieces in run order, then the
  `t₀` argument, then trim. The context gains a sentence naming the parts.
  The three list labels become plain lead-ins (q8). No subheadings.
- **§14.6.** Unchanged order: context, the check, the barrier, baselines.

### Rewrite units

| unit | lines (original) | moves in | moves out | words |
|---|---|---|---|---|
| A | 11267–11558: heading, roadmap, §14.1, §14.2, §14.3 | M1, M2, M6 within | — | 2,509 |
| B | 11559–11873: §14.4, §14.5, §14.6 | M3–M5 within | — | 2,843 |

Total 5,352 words. Units C to E are unused. Both fall inside 2,500–3,000.
The alternative, A′ = 11267–11487 (1,943, heading to §14.2) and B′ =
11488–11873 (3,409, §14.3 to §14.6), puts B′ over the range and parts §14.3
from §14.2, which it continues; recommendation A and B (q7).

### Code blocks, charts and tables

The half holds three code blocks, four tables, one inline sequence, one
formula and no chart:

- 11293–11300: the lifecycle table, six rows. Carry; row 9 names
  `CheckpointMidFrame` or points (F5).
- 11395–11398: the condition method, a `julia` fence. Carry verbatim (O16);
  `PistonEngine` and `Phase.running` get an introducing clause (F12).
- 11402–11406: the owner's pull, a `julia` fence. Carry verbatim.
- 11412–11416: the node-type sketch, a `julia` fence with comments. Carry;
  the comment on `Scoped` says "stores, never applies", as the code's
  docstring does.
- 11528–11531: the converter table, two rows. Carry; the em dashes inside
  cells go.
- 11697–11703: the selector table, five rows. Carry, except as ruled under
  q5 (its "service reads" column).
- 11722–11723: the boundary-zero sequence, inline arrows. May become a
  display like §10.6's (6642–6644).
- 11778–11781: the tier table inside a list item. Carry.
- 11785: the accumulator formula. Carry.

Lists: §14.3's checks (11497–11502), §14.4's two ways (11568–11591) and
client policy (11667–11693), §14.5's bullets (11730–11819).

### Running the half's code

Loaded with `test/repl.jl` inside `module H1Check` (script
`scratch_survey/h1/run/blocks.jl`, run from the repository root with
`julia --project=test -t 2`; output in `run/output.txt`). Every probe
printed its result; none failed except as listed.

- **11412–11416, the node-type sketch: passed as a shape check.** `Fragment`
  has fields `(:x, :s, :m, :u)`, `Scoped` has `(:prefix, :node)` with
  `prefix::String`, `Combined` holds a tuple. `set(x = (q = 1.0,), u = (u =
  2.0,))` is isbits; `at("a", set())` is not, as "isbits except the prefix
  strings" says. `Override` exists beside them, the fourth node kind §14.6
  introduces.
- **11395–11398 and 11402–11406: cannot run verbatim; ran with stand-ins.**
  The blocks name FlightPhysics' `PistonEngine`, a `C172XSystems` (FlightApps'
  `C172X.Systems` respelled) and a scoped enum `Phase.running`, none of which
  the package has. The script defined stand-ins under those names
  (`PistonEngine` with `ω_rated`, `Phase` a module holding an enum, a
  `Powerplant` assembly and an `Aero` leaf) and ran both blocks unchanged.
  They passed: the pull resolved with its deep `at("pwp/engine", …)`, and
  `init!` wrote `ω = 200.0` (0.8 · 250), `phase = running` and `α_filt =
  0.05`. Tree construction measured `@ballocated` 0 (a plain `@allocated`
  over non-constant globals read 64 bytes, an artifact of the probe). A pull
  to a child with no condition method raised `MethodError`.
- Claims checked in passing:
  - §14.2: `at("", set())` raised `ConditionNodeMisuse` reason
    `:empty_prefix`. **`set(x = 3.0)` raised `ConditionNodeMisuse` reason
    `:set_payload`**, a second composition-time validation (F8).
    `combine(set(), (q = 1.0,))` raised `ConditionNodeMisuse`. A `combine`
    collision raised `DuplicateConditionLeaf`, its message ending
    "`combine` is collision-intolerant by design — use `override(base,
    patch)` to layer (§14.2, §14.6)". **Two spellings of one root input,
    `set(u = (throttle = …))` at the root and `at("pwp", set(u = (throttle
    = …)))`, collided as one leaf** (F11). A `u` payload naming the
    powerplant's output face raised `ConditionResolution` `:no_input_face`;
    one at the engine, fed through the powerplant's face, resolved through
    the export chain.
  - §14.1: a condition naming an output raised `ConditionResolution`
    `:undeclared_field` with role `:output_port`; an unknown path and an
    undeclared field came back in one throw as `PathResolution` and
    `ConditionResolution`; a state field at an assembly path raised
    `:assembly_path`.
  - §14.3: at a `Dual` activation a plain `Float64` leaf compiled to
    `Dual(0.1, 0.0)` and a `Dual` leaf kept `Dual(0.2, 1.0)`; the mode store
    took one whole merged value.
  - §14.4: `compile_plan` returned a `SpecializedPlan`; its `apply!`
    measured `@ballocated` 0; a tree of another type raised
    `ConditionShapeDrift` `:tree_type`, a changed prefix `:prefix`; a prefix
    computed with `string("pwp/", "engine")` paired with the compiled
    literal. A store selector under `source = :table` raised `ReadResolution`
    `:store_selector`; under the executor source a mounted
    `get_state("engine", :ω)` and `get_face(:ω)` compiled. A `.name` step
    on a `Float64` continuous field raised `ReadResolution` `:no_such_field`.
  - The heading's table: `checkpoint` at `built` raised `ServiceLifecycle`;
    `init!` at `built` ran; `checkpoint` at `initialized` returned a
    `Checkpoint`. On a model: `checkpoint(model)` at `:built` raised
    `ServiceLifecycle`; `restore!(model, state)` at `:built` ran; a claimed
    model's `init!` raised `ArgumentInvalid`; its `checkpoint`, a read, met
    the status gate and not the claim.
  - §14.6: `init!` without root-input coverage raised `UninitializedInputs`
    and left the simulation `built`; the faces came back `[:u, :e]`, in
    declaration order. **`linearize(sim, taps; about = set(u = (u = 1.0,)))`
    with a second root input uncovered raised `UninitializedInputs` with
    `op = :linearize`** (F2).

## D. Inbound citations

The rows analysed are the 356 rows of `inbound.tsv` whose target is §14,
§14.1, §14.2, §14.3, §14.4, §14.5 or §14.6 (copied to
`scratch_survey/h1/mine.tsv`). The 47 bare §14 rows belong to half 1; most
rely on the heading's lifecycle block or name the chapter as a whole.

By file: `decisions.md` 177 (Spec 87, Rationale 36, Rejected 25, Position
24, Annotation 5), `spec.md` 132, `implementation.md` 21, companions 24
(`trim_environment_walkthrough.md` 10, `linearization_walkthrough.md` 4,
`flight_case_studies.md` 4, `sample_time_proposal.md` 2,
`migration_outline.md`, `longitudinal_aircraft.md`,
`inbound_periphery_walkthrough.md` and `frame_walkthrough.md` 1 each),
`pending.md` 1, `extensions.md` 1. The 132 `spec.md` rows: Part I 16, Part
II 17, Part III 30, Part IV (§13) 14, Appendix A 3, Appendix B 16, Appendix
C 13, Appendix D 23.

By target: §14 47, §14.1 48, §14.2 46, §14.3 24, §14.4 83, §14.5 63, §14.6
45 (in `spec.md` alone: 18, 17, 16, 11, 26, 23, 21).

Ranges recorded at their ends only: `spec.md` 9916 (the Part IV roadmap) and
13154 (Appendix B's condition algebra), and `implementation.md` 278, all
"§14.1–§14.6", so they also cover §14.2–§14.5. `implementation.md` 973
("§14.5–§14.9") covers §14.6–§14.8, two of them the sibling's.

### Citations relying on moved or trimmed content

M1–M6 reorder within their sections and M5 merges two statements of one
fact. No inbound row names a moved sentence by position, so none is broken.
The rows that rely on content a ruled correction would change:

| file:line | fact relied on | after the correction |
|---|---|---|
| spec 2312–2313 (§8.2) | "§14.2's shipped condition uses" `ω_rated` | holds if block 11395–11398 keeps `eng.ω_rated` (O16) |
| spec 1573 (§6.1) | the `u` export chain "has a name to resolve through (§14.2)" | holds; row 70 stays (M2 moves it within §14.2) |
| spec 1550 (§6.1), 10278–10279 (§13.3), log 16466 (D-414 bullet 4) | the locality law is authoring guidance (§14.2) | holds; rows 79–82 |
| spec 10251 (§13.3) | "absolute paths are a compiled derivative (§14.2)" | holds; row 78 |
| spec 10283 (§13.3), log 4315, 4338 (D-130) | the two ways' internal, never user-facing status (§14.4's precedent) | holds if row 128's **Rule.** stays as a sentence |
| spec 10286 (§13.3) | condition addressing (§14.3) and the readers (§14.4) split their paths through the service walk | holds |
| spec 7127 (§11.2), 13111, 13120 (Appendix B), log 7696 (D-199), 5458–5470 (D-146) | bindings' reads are §14.4 selectors | holds |
| spec 7203–7205 (§11.3), 3470–3473 (§8.6), 13995–13997 (glossary) | service reads speak face names where they want contract (§14.4) | holds under q5's (a) or (b), which keep the guidance |
| spec 7334 (§11.3), 4690–4692 (§9.3), 14770–14774 (glossary) | the totality sites `init!`, trim setup, trim commit (§14.6) | each list lacks `linearize`'s `about` under F2; a loose fix each (q2) |
| spec 13637 (Appendix C) | `ConditionResolution`'s sub-kinds (§14.2, §14.3) | holds; the sub-kind list is Appendix C's to complete |
| spec 13735 (Appendix C) | `ReadSetMisuse` owned by §14.4 | §14.4 never states it (F5); Appendix C's to correct to §14.9 |
| spec 14741 (glossary), log 4042 (D-122) | "§14 owns the word" condition | holds |
| spec 14779–14780 (glossary) | "`errored` is terminal for all four services (§14)" | the table has five services (F3); a loose fix |

### Citations already wrong before the rewrite

The inbound check will flag these whatever the rewrite does; they belong to
track 2 or to their own chapters.

| file:line | claim | what half 1 or the code says |
|---|---|---|
| log 5009 (D-139 Rejected); `trim_environment_walkthrough.md` 65, 537 | "§14.2's by-name rejection of init as a third scheduled sweep" | §14.2 names no such rejection; it rejects the `initialize(::C, spec)` schema entry (row 47). The third-sweep rejection is D-064's Rejected list (log 2084–2085), stated nowhere in the spec |
| spec 4690–4692 (§9.3, bold), 7334 (§11.3), 14770–14772 (glossary) | totality is checked at `init!`, trim setup and trim commit, "namely" | `linearize` with `about` checks it too (`src/linearize.jl` 177–178; the run) (F2) |
| spec 14719 (glossary `#g-baseline`), log 4043–4044 (D-122 Rationale) | "the `baseline` keyword `init!`/`trim!` take" | `init!` takes no `baseline` (`src/sim.jl` 591, `src/model.jl` 170) (F26) |
| spec 14780 (glossary `#g-service-lifecycle`), log 3564 (D-108 Rationale) | "`errored` is terminal for all four services" | five: `checkpoint`, `init!`, `restore!`, `trim!`, `linearize` (the table; Appendix C 13599) (F3) |
| spec 13644 (Appendix C `DuplicateConditionLeaf`) | the leaf is `(path, store, field)` | an input entry's leaf is its root input (`src/conditions.jl` 175–176) (F11) |
| spec 13647 (Appendix C `ConditionNodeMisuse`) | payload: argument type, node kinds, or an empty prefix | also a non-NamedTuple `set` payload, reason `:set_payload` (`src/conditions.jl` 82–83) (F8) |
| spec 13637 (Appendix C `ConditionResolution`) | four sub-kinds | seven reasons in the code (`src/diagnostics.jl` 1756–1757) |
| spec 13735 (Appendix C `ReadSetMisuse`) | owning section §14.4 | stated in §14.9 (12421–12422) and §14.10's tap lists; §14.4 never names it |
| spec 10243 (§13.3) against 11683–11686 (§14.4) | bindings and `series` are service clients (§13.3) or inspection readers (§14.4) | the two rewritten and unrewritten texts disagree (F1, q5) |
| `linearization_walkthrough.md` 370–374 | "`get_state(path, field[, i])` … `get_input(face[, i])` … both with the same index since D-271" | D-276 retired the trailing index for the leaf address (log 12067–12068); the section cited is §14.4 |
| log 3076 (D-095 Position) | the family is `get_state`/`get_deriv`/`get_output`/`get_local`/`get_slot`/`get_face` | five members since D-165 and D-206 (`get_local` retired, `get_slot` renamed `get_input`); no annotation on D-095 |
| log 3172–3176 (D-098 Position) | store selectors are held by "`capture` and post-run inspection" | `capture` retired (D-273); §14.4 says `checkpoint`. No annotation |
| log 2047–2051 (D-063), 2131 (D-066), 2163–2164 (D-067), 3555–3560 (D-108), 3640 (D-110) | `capture` as a condition producer or service | retired by D-273; D-110 and D-067 carry annotations, D-063, D-066 and D-108 none |
| log 4310–4312 (D-130), 9606–9609 (D-242) | device read bindings and GUI panels are *inspection*, by the instance walk | D-414 bullet 1 puts bindings and log extraction under the service walk; D-310 parked the GUI. Chapter 13's survey recorded D-130's |
| log 16348–16350 (D-409 Position) | "Service observation must speak the contract" | D-414 (later) makes the locality law for service reads guidance; D-409 owes an annotation scoping it to the reads a run acts on (part E) |

### Log entries whose Spec field would change

- Under M1–M6: none; every move is inside its section.
- Spec fields stale before any move, entries that rule half 1 without
  listing its section (track 2):
  - D-066: lists §9.5, §9.8; rules §14.3 (rows 105–106) and §14.4 (13 rows),
    and is cited nowhere.
  - D-065: lacks §14.3 (rows 94–101, 114).
  - D-064: lacks §14.1 (rows 38–39, the pre-sweep doctrine).
  - D-026: lacks §14.5 (row 181), though cited there.
  - D-106: lacks §14 (row 7).
  - D-232: lacks §14 (row 20).
  - D-318: lacks §14 (row 18), though cited there.
  - D-273: lacks §14 (row 4), though cited there.
  - D-274: lacks §14.1 (row 33), though cited there.
  - D-364: lacks §14.1 (row 43), though cited there.
  - D-253: lists §14.1, which never cites it, and lacks §14.3, which does
    (row 104).
  - D-407: lacks §14.4 (row 157), though cited there.
  - D-292: lacks §14.5 (rows 178–179).
  - D-306: lists §7.3 alone; rules row 27.
  - D-376: lists §11.3 alone; rules rows 207–208.
  - D-409: lists §13.5 alone; rules row 34.
  - D-413: lists §13.5 alone; rules row 184.

## E. Log repairs and factual problems

Log repairs go to the second track, after landing. The rewrite only adds
citations; it states no repair. Factual problems stay as written and go to
the units' `rulings.md`, unless part G pre-rules them.

### Entries to cite at the rule

From part A's U rows: D-108 (rows 5–14; cited only at 11310), D-232 (20),
D-274 (21, 169, 182), D-306 (27), D-065 (28, 56–59, 69, 71–72, 84, 94–101,
114), D-409 (34), D-064 (38–39, 46, 48, 53, 75), D-405 (48), D-066 (61,
105–106, 116–127, 163–164), D-207 (69–70), D-414 (81), D-113 (90–92), D-068
(93), D-148 (99, 107, 109–111), D-095 (131, 138), D-276 (132), D-277 (141),
D-098 (142–143, 145, 158, 162), D-125 (153–154), D-067 (167–168, 171, 173,
185, 194–195, 200–203), D-292 (178–179), D-413 (184), D-110 (194), D-126
(204), D-155 (205–206), D-376 (207–208), D-149 (211–213).

### Superseded and half-superseded citations

- **D-060** (cited 11691, row 160): its publication and policy clauses (the
  root-exported `Bool` face and `stop_on`) are superseded by D-316 (log
  13966–13971), and the row's fact, the ignore list naming requesters, is
  D-316's. Cite D-316 alone, or D-060 for "termination is state, never an
  exception" only.
- **D-063** (cited 11336, rows 25–31): the overlay clauses stand; its
  `capture → tweak → apply` clause is retired by D-273 with no annotation on
  D-063.
- **D-065** (cited 11464, 11471): its "deep `at` only within owned concrete
  subtrees" clause is amended by D-207 and D-414; its 2026-10-13 annotation
  still says the concrete half "is machine-checked" (log 2108–2109), which
  D-414 retired. The rows cite it for the ownership convention and
  last-writer-wins, which stand.
- **D-067** (cited 11756, 11787): its "every tick due" clause is amended by
  D-205 (annotated); the cited Rejected clauses stand.
- **D-253** (cited 11512): the bullet relied on, structural consumers
  reading the products, stands; the `Dataflow` naming is D-261's.

### Rulings that need an entry stating them in a Position

1. `errored` is terminal for every service (row 19): D-108 Rationale (log
   3564); D-059's Position says only that status goes terminal. §12.6 bolds
   it on D-059.
2. `ServiceLifecycle`'s payload and its sharing with `attach!`/`detach!`
   (rows 22–23): D-108 Rationale.
3. `MissingInit` distinct from `ServiceLifecycle` (row 24): D-108 Rejected.
4. The face head matched on `get_input` and `get_face` (row 134): D-276's
   two annotations.
5. The environment-query escape and the environment-free fallback (rows
   40–45): D-139 Rationale. D-139's Position rules the constructor only.
6. "One way to say everything" (row 68): D-278 Rationale.
7. Last-writer-wins rejected; `Base.merge`'s contract (rows 86, 88–89):
   D-065 Rejected, D-204 Rationale. Reasons; may need none.
8. A foreign `condition` fails loudly, outside the declaration family (row
   51): D-316 Rationale.
9. The converter's shape-fact reason, the untouched exact-match doctrine and
   no converters on views (rows 108, 112–113): D-148 Rationale.
10. The table/store axis wording and table sources (row 144): D-124
    Rationale.
11. Inspection readers admit the whole family (row 156): D-095 Rationale.
12. `ignore_stop_requests` outside the family (row 159): D-095 Rationale and
    Rejected.
13. The `t₀` firing not suppressed, and the insurance lesson (rows 180–181):
    D-067 and D-026 Rejected. Reasons; may need none.

### Rulings with no entry at all

`ConditionShapeDrift` as a kind (row 122; D-066 rules the check, no entry
names the kind); the activation pairing as a framework invariant (row 129);
"Which of the two a service uses is internal" for the two ways (row 128,
assumed by D-130); `init!` on a model legal at any status (row 17);
`restore!` on a simulation legal from `built` (row 11, implied by D-274's
"beside `init!`"); the framework-owned `condition` generic (row 49); the
`===` content comparison (row 121); the two lookup families, schema and
layout (rows 102–103); the tree position (row 96). Descriptions with no
entry, needing none: rows 30, 62, 85, 165, 193, 219.

### Stale entry text and Spec fields

- D-095 Position (log 3075–3079): six members with `get_local` and
  `get_slot`. No annotation.
- D-098 Position (log 3172–3176): `capture`. No annotation.
- D-063 Position (log 2047–2051), D-066 Position (log 2131), D-108 Position
  (log 3555–3560): `capture`. No annotation on any of the three.
- D-065 Position (log 2091–2099): `Merged`, `merge`, `m`/`z`, "slots",
  "deep `at` only within owned concrete subtrees"; its annotation's "Its
  concrete half is machine-checked" (log 2108–2109) predates D-414.
- D-068 Position (log 2192–2206): `UninitializedSlots`, "slot", `merge`. The
  vocabulary rule keeps it; no repair beyond D-206's and D-204's own
  forward renames.
- D-122 Rationale (log 4043–4044): "the `baseline` keyword of
  `trim!`/`init!`" (F26).
- D-130 Position (log 4310–4312), D-242 Position (log 9606–9609): bindings
  and GUI panels as inspection, by the instance walk (D-414, D-310).
- D-409 Position (log 16348–16350): "Service observation must speak the
  contract", read against D-414's later guidance; an annotation scoping it
  to the reads a run acts on, as §13.5 frames it.
- D-149 Position (log 5643–5646): the three sites; `linearize`'s `about`
  is a fourth (F2). Annotate.
- D-139 Rejected (log 5008–5009): "§14.2's by-name rejection of init as a
  third scheduled sweep" (part D).
- Spec fields: part D's list.

### Findings carried from earlier chapters

`docs/spec_rewrite/README.md` 43–89, "Carried to later chapters", holds
seven chapter 14 items; three fall in half 1.

- **The `errored` bold (B84).** Confirmed: 11310 bolds "`errored` is
  terminal for every row" ([D-059], [D-108]), and §12.6 bolds "`errored` is
  terminal" (9429, [D-059]). Proposed: plain, "No service accepts an
  `errored` simulation ([§12.6], D-108)." D-108's Rationale is the source
  for the services (part E, item 1).
- **"Requester roster" unlinked in §14.4.** Confirmed: 11691, "the
  `Build`'s requester roster", no link; `#g-requester-roster` exists
  (14841). Proposed: link at that first use, gloss "(the build's list of stop
  requests, one per `StopFlag` output port)".
- **`set`, `at` and `combine` as §13.7 library material (B83).** Confirmed:
  11464–11465. §13.7 holds components only. Proposed (F7): "`set`, `at` and
  `combine` are ordinary functions with no privileges, as §13.7's blocks are
  ordinary components."

The four other items (§14.10's D-167 citations, §14.10's seedability bold
and tap rejection, §14.9's `product(...)` helper and §14.8's bare §13
citation) are half 2's. Appendix D's `#g-entry` item from chapter 13 also
bears on half 1: §14.1–§14.5 use *entry* bare (F29).

### Factual problems in half 1

None is serious: each is settled by a later entry, by the code, or by a
rewritten chapter. F1 and F2 change most text.

- **F1. §14.4's client policy lags D-414 and §13.3.** Rows 150–153, 156–158,
  162 (11664–11703). Four claims:
  1. "It is D-083's service and inspection sides restated as a resolver
     property" (11664–11665). D-414's Rejected list refuses "a client flag
     on a resolver §14.4 keeps client-free" (log 16520–16522), and the code's
     resolver takes a source and nothing about the client
     (`_resolve_reads(read_set, build, T; source)`, `src/readers.jl`
     429–445; every path selector walks `resolve_authored`, `src/assembly.jl`
     1482–1512, whose past-generic refusal D-414 removed).
  2. "**Service reads speak the contract.**" (11667) is bold as a rule, and
     the next sentence calls it "authoring guidance (D-414)". The table's
     "service reads: named in the contract" column (11699–11703) says the
     same as a rule.
  3. "`get_face` is the set's seam-crossing member" (11673–11674). Since
     D-414 every path selector crosses a generic seam; `get_face` is the read
     meant to outlive the build (D-414 bullet 4, D-125's annotation).
  4. "Output-device bindings, log extraction by `series` and snapshot
     inspection" are "inspection readers" (11683–11686). §13.3's rewritten
     table (10243) lists device read bindings and `series` under *service*
     ("the service walk"), and snapshot and log inspection on the address
     table; chapter 13's R2 made that move. D-083 and §11.2 (7136–7140) still
     call a binding's read *inspection* in the read-semantics sense.
  Proposed: keep the source rule as the one enforced rule (rows 142–149);
  recast the client paragraph as guidance: "On top of the source rule sits
  one piece of authoring guidance ([D-414]). A service read, trim's `reads`
  or a tap, that should outlive the build reads a face with `get_face`,
  which resolves through export chains as mounting does ([§14.9], [D-125]).
  An inspection read, a binding's or `series`', may name any cell the
  structure has, since it promises nothing beyond this build ([D-083]).
  Both resolve under the one service walk ([§13.3])." The table loses its
  client columns or relabels them "guidance". Ruling: q5.
- **F2. Linearization's `about` is a fourth totality site.** Row 212
  (11835–11837): "They are `init!`, trim's setup application …, and trim's
  commit." `linearize(model, taps; about = c)` resolves `c`, calls
  `assert_total(plan, build.structure, :linearize)` and only then applies it
  to its fresh scratch (`src/linearize.jl` 172–181); the run raised
  `UninitializedInputs` with `op = :linearize`. The section's own principle,
  "every application that establishes a complete world over virgin stores"
  (D-149), covers it. The same three-site list sits in §9.3's bold
  (4690–4692), §11.3 (7334), the glossary (14770–14772) and D-149's Position.
  Proposed for §14.6: "They are `init!`, trim's setup application to freshly
  allocated scratch stores, trim's commit through boundary zero ([§14.8]),
  and linearization's operating condition under `about`, applied to its own
  scratch ([§14.10])." The other three are loose fixes (q2).
- **F3. The heading counts services wrong.** Row 1 (11269–11270) names three
  services and row 4 "a fourth", `checkpoint`; the table has five
  (`checkpoint`, `init!`, `restore!`, `trim!`, `linearize`), and Appendix C's
  `ServiceLifecycle` lists `restore!` among its operations (13599). D-319's
  Position calls `checkpoint`, `restore!`, `trim!` and `linearize` doors of
  the `Model` (log 14291–14293). "Everything they share reduces to one
  artifact, the condition value" (row 2) is false of `checkpoint` and
  `restore!`. The glossary's "all four services" (14780) shares the count.
  Proposed: "The stopped-sim services are initialization, trim,
  linearization, and `checkpoint` with its partner `restore!`. The first three
  share one artifact, the condition (…). A checkpoint is a value of its own
  ([D-273])."
- **F4. "boundary zero" linked to `#g-boundary`.** 11274
  ("[boundary](#g-boundary)-zero"), 11762 ("runs no [boundary](#g-boundary)
  zero") and 11837 ("through [boundary](#g-boundary) zero") link the word
  *boundary* inside the term while `#g-boundary-zero` exists; `#g-boundary`
  calls boundary zero its hyponym. Proposed: link `#g-boundary-zero` at the
  section's first use, bare after.
- **F5. Kinds stated without their names (lesson 20).** The heading states
  `CheckpointMidFrame`'s condition (row 9) and the claim refusal,
  `ArgumentInvalid` reason `:claimed` (row 18), unnamed. §14.2 states the
  collision (row 84, `DuplicateConditionLeaf`), the unreachable face (row 69)
  and the internally wired input (row 71), both `ConditionResolution`,
  unnamed. §14.3 states the path refusal (row 97, `PathResolution`), the
  field, conversion and face checks (rows 98–100, `ConditionResolution`) and
  the duplicate (row 101) without one kind name. Appendix C cites §14.4 for
  `ReadSetMisuse`, which §14.4 never states. Proposed: name each kind where
  its condition is stated, with an Appendix C pointer; leave `ReadSetMisuse`
  to §14.9 and Appendix C's owner fix.
- **F6. §14.1's doctrine argues from superseded premises.** Rows 35–37
  (11343–11349). "A condition … is authored in the same vocabulary as
  `local_wires`, which also speaks paths, about children its author owns. The
  composition law (§14.2) makes the parallel exact." D-063's Rejected list
  made that argument when connections spoke deep paths (D-009); D-207 made
  every wire one level, and D-414 lets a condition path reach anywhere the
  structure has it, which §14.2 now says (rows 77, 80). The parallel is no
  longer exact: wiring is checked one level, a condition path is not. And
  "That rejection was about *runtime* coupling, where a root-authored
  predicate reaches through generic seams … and breaks on substitution"
  frames the rejection by substitution; rewritten §13.5 (10757–10762) grounds
  it in "the reads a run acts on" (D-409), and says a condition binds "at a
  stopped-sim point where conditions already address state by path (§14.1)".
  Proposed: "Addressing conditions by path does not reopen the
  observation-by-path rejection ([§13.5], [D-409]). That rejection bars a
  run from acting on reads its model did not declare. A condition is not
  such a read. It is a design-time statement about a concrete build, written
  before the run begins, and the locality law of [§14.2] is how an author
  keeps it to children the author owns." Ruling: q3.
- **F7. `set`, `at` and `combine` are not §13.7 library material.** Row 83
  (11464–11465), carried B83. §13.7 holds components only. Proposed:
  "`set`, `at` and `combine` are ordinary functions with no privileges, as
  §13.7's blocks are ordinary components."
- **F8. Composition validates more than the empty prefix.** Row 60
  (11421–11422): "The one validation is the empty-prefix check below." `set`
  checks that each payload is a NamedTuple and raises `ConditionNodeMisuse`
  reason `:set_payload` (`src/conditions.jl` 74–83), and `at`, `combine` and
  `override` refuse a non-node operand (101, 118–122, 137–143); all run at
  composition, and each reads a type, allocating nothing. The run raised
  `:set_payload` for `set(x = 3.0)`. Appendix C's `ConditionNodeMisuse` row
  (13647) omits the payload case. Row 56's "The three combinators" counts
  `set`, which D-405 calls the leaf constructor, and leaves out `override`.
  Proposed: "Composition checks only types and lengths: each `set` payload
  is a NamedTuple, each combinator operand a node, each `at` prefix
  nonempty. None allocates." and "`set` builds the leaf, and `at` and
  `combine` build the tree's inner nodes".
- **F9. The allocation claims overreach.** (a) Row 58 (11418–11420):
  "rebuilding the tree per trim iteration allocates nothing" rests on "a
  prefix is a reference to the author's own literal". A prefix computed per
  iteration, which row 121 (11575–11577) admits, allocates its string. The
  suite pins the literal case (`test/test_conditions.jl` 52–53). (b) Row 61
  (11422–11424): the zero-alloc property holds "of the walk that *applies*
  the tree (§14.4) alike". Only the specialized `apply!` is zero-alloc; the
  dynamic walk has "allocation permitted" (row 126, 11588). (c) Row 165
  (11711): "plus the tree's few boxes" reads as allocation against (a).
  Proposed: (a) "With literal prefixes, rebuilding the tree per trim
  iteration allocates nothing"; (b) "… and of the specialized `apply!` that
  writes it ([§14.4])"; (c) "plus building the tree, which allocates nothing
  ([§14.2])".
- **F10. Substitution's reach.** Row 79 (11454–11455): "Substituting a
  component invalidates precisely the fragments its owner shipped, nothing
  else." Since D-414 a deep path authored at any ancestor reaches into the
  substituted child and breaks with it; the claim holds for fragments that
  keep the locality law, which the section's next sentences make guidance.
  Proposed: "Under the locality law, substituting a component invalidates
  only the fragments its owner shipped."
- **F11. The duplicate check's key.** Row 101 (11502): "no `(path, store,
  field)` is duplicated." An input entry's leaf is the root input its face
  resolves to, so the root's `throttle` and a component-level face that
  lands on it are one leaf (`_key`, `src/conditions.jl` 151–156, 175–176);
  the run collided them, and §14.6's central use case relies on it (the
  docstring of `override`, 132–135). Appendix C's `DuplicateConditionLeaf`
  row says `(path, store, field)` too. Proposed: "no leaf is written twice,
  an input entry's leaf being the root input it resolves to."
- **F12. Flight.jl and FlightCore names used as if known.** Rows 47, 55, 61,
  110, 165, 203, 224 and the blocks: `f_init!` and `f_ode!` (FlightCore's,
  `Flight.jl/lib/FlightCore/src/modeling.jl` 201–209), `assign!`
  (FlightApps' and FlightPhysics'), `PistonEngine` and `RQuat`
  (FlightPhysics'), `C172XSystems` (a respelling of FlightApps'
  `C172X.Systems`), `SystemsInitializer` and the c172s/c172x split
  (FlightApps'), and "today's" for FlightCore's or Flight.jl's practice
  (11381, 11422, 11571, 11713, 11808, 11860). `spec_style.md` asks an
  introducing clause or a companion. Proposed: an introducing clause at each
  first use naming the owner ("FlightCore's `f_init!`, the initialization
  hook this replaces"); `C172XSystems` glossed as the C172X aircraft's
  systems assembly. Ruling: q9.
- **F13. Names do come from the activation's declarations.** Row 104
  (11509–11512): "The names and the face chains come from `Structure` …,
  never from an activation." The resolver reads the declared field names off
  `act.decls` (`src/conditions.jl` 351–353, 373) and a primitive's input-face
  names off `decls[ci].ins` (`src/readers.jl` 588–594), the activation's
  evaluated declarations. The names are scalar-independent, so nothing
  differs across activations; the face *chains* do come from `Structure`
  (`terminal_producer`). D-253's bullet says structural consumers read the
  products. Proposed: "The face chains come from `Structure` (…), never from
  an activation's typing; the names a declaration evaluates to are the same
  at every activation ([§9.1], [D-253])." Or leave the sentence and record
  the code as lagging D-253 for track 2.
- **F14. The parked GUI as live.** Row 72 (11442–11443, "exactly as it does
  for the GUI (§11.7)") and row 180 (11757–11758, "the stage-on-interaction
  lesson of §11.7 (widgets stage on edit or activation, never per render
  pass)"). D-310 parked the GUI; chapter 12's R2 reads "a front end's".
  Proposed: "exactly as it is for a front end's panels ([§11.7])" and "on
  the lesson of [§11.7]'s stage-on-interaction rule, that insurance masks
  invariant violations ([D-026])".
- **F15. `merge(init_m_defaults, overlay)`.** Row 114 (11555–11557). No
  identifier `init_m_defaults` exists, and the bake covers both `s` and `m`:
  the plan writes `merge(defaults, overlay)`, the defaults being the
  store's declared `s_init` or `m_init` value (`src/conditions.jl` 316–324,
  391–395, 600–620). "The writer holds" uses the periphery's word.
  Proposed: "Each `s` or `m` store's write is one whole value,
  `merge(defaults, overlay)`, with the store's declared defaults resolved at
  compile time (the overlay-base rule, [§14.1])."
- **F16. One validated list, two compiled forms.** Rows 105, 116, 126 and
  the title. The code runs one collecting pass and compiles two plans from
  it: `ConditionPlan`, which bakes the converted values and serves one tree
  (the dynamic walk), and `SpecializedPlan`, which bakes lenses and
  converters and serves every tree of a shape (`src/conditions.jl` 254–275,
  330–342, 640–707). Row 105's "Per leaf, the plan holds a lens, a
  destination offset, and a converter" is the specialized plan's, and the
  `s`/`m` stores take one whole value per store, not a per-leaf offset.
  D-066's Position says "two ways to apply one compiled plan". Proposed: keep
  the title; row 105: "A valid list compiles two ways. For the specialized
  `apply!` it holds, per leaf, a lens, a destination and a converter; for
  the dynamic walk it holds the converted values themselves." Ruling: q6.
- **F17. Two reserved words in other senses.** Row 112 (11550): "a one-time
  boundary decision" uses *boundary* (`#g-boundary`, the published
  consistency point) for the condition write boundary. Row 120 (11574): "A
  `===` sweep over the prefix strings" uses *sweep* (`#g-sweep`, a pass
  through the execution order) for a loop of comparisons; D-066 says the
  same. Proposed: "a one-time resolution decision"; "A `===` comparison of
  each prefix string closes the remainder".
- **F18. The codegen's amortization.** Row 124 (11583–11584): the codegen is
  "noise … against the 10³–10⁴ optimizer evaluations the codegen amortizes
  over". §14.7 gives the LM default as "~5–15 evaluations" (12002). The
  specialized `apply!` compiles once per tree type per session, through
  Julia's method cache for `apply!(…, ::SpecializedPlan{T,NT}, ::NT)`, so the
  cost spreads over every evaluation of every trim of that shape: an
  envelope sweep, or the derivative-free fallback. Proposed: "That cost is
  noise against the model's own first-sweep warmup (seconds), and it is paid
  once per shape per session, across every trim that shape serves, an
  envelope sweep's hundreds included."
- **F19. The dynamic walk's uses.** Row 125 (11585–11586): "`init!` and
  `linearize`'s operating condition". Trim's setup writes its composite to
  the nominal half by the dynamic walk too (`src/trim.jl` 480–483), as §14.8
  says (12186–12187). Proposed: add "and trim's setup write ([§14.8])".
- **F20. Not only cells are addressable.** Row 139 (11635–11636): "because
  only cells are addressable". The store selectors address stores, and
  `#g-store` says "A store is never called a cell". The code's docstring:
  "Only cells and stores are addressable" (`src/readers.jl` 48–49).
  Proposed: "because only declared cells and stores are addressable".
- **F21. Snapshot inspection takes no selectors.** Row 157 (11684–11686).
  Snapshot inspection is `port(snapshot, path, name)` over the address table
  (`src/dataplane.jl` 480–481): a path and a port name, no leaf address, no
  `get_face`. §13.3's table puts it on the address table. Proposed: drop
  "and snapshot inspection" from the list, or "Snapshot inspection reads a
  cell by path and port name instead ([§11.2])".
- **F22. No inspection reader holds stores.** Row 158 (11686–11688): "The
  store selectors reach only the inspection clients that actually hold
  stores (`checkpoint`, post-run inspection)." The code's only live-store
  source is an executor (`src/readers.jl` 36–42: "an `Executor` — the only
  live-store holder there is"), and its only executor-source readers are
  trim's and linearization's (`src/trim.jl` 369, 512; `src/linearize.jl`);
  bindings and `series` resolve for `:table` (`src/bindings.jl` 147,
  `src/sim.jl` 2252). A checkpoint is read through its fields, not through
  selectors. The sentence describes a pairing the code permits and nothing
  uses. Proposed: "A store selector resolves only for a reader that runs
  over live stores, which today are the services' ([§14.7], [§14.10]); a
  snapshot-bound reader is barred from it by source, not by client."
- **F23. "Trim's cost read".** Row 163 (11706). Trim reads a residual
  system, "not a scalar cost" (§14.7, 11961); D-066 kept the old word.
  Proposed: "Trim's residual reads".
- **F24. `UninitializedInputs` is not a §13.2 kind.** Row 215 (11840–11841):
  "(`UninitializedInputs`, a [§13.2] kind)". Its owning section is §14.6
  (Appendix C 13659); §13.2 is the diagnostic value. Proposed:
  "(`UninitializedInputs`, [Appendix C])".
- **F25. `override`'s example spellings.** Row 226 (11867–11868) quotes the
  origin as "patch overrode base's `throttle`"; the code spells it
  "`override[patch 1] → set(u).throttle (overrode override[base] →
  set(u).throttle)`" (`src/conditions.jl` 219–229; `test/test_conditions.jl`
  104–107). Row 228 (11871) writes the commit `override(baseline,
  solution)`; the commit is `override(baseline, condition(d*))`
  (`src/trim.jl` 425–426; §14.9 12379). D-068's Position has the old
  spelling. Proposed: quote the real origin or drop the quotes and say "the
  origin names both layers"; "`override(baseline, condition(d*))`, the
  solved condition over full coverage".
- **F26. `init!` takes no `baseline`.** The glossary's `#g-baseline` (14719)
  and D-122's Rationale (log 4043–4044) say `init!` takes a `baseline`
  keyword. It does not (`src/sim.jl` 591, `src/model.jl` 170); only `trim!`
  does. Not in the half; a loose fix with the glossary, linked from §14.6's
  first use.
- **F27. The simulation's `init!` does not forward a condition.** Row 196
  (11797–11798): "`init!(model, condition; t0)`, which the simulation's
  `init!(sim, condition; t0)` forwards to". The simulation's door resolves
  the condition, checks totality, opens the run and then calls the model's
  plan method, `init!(model, plan; t0, hooks)` (`src/sim.jl` 591–607).
  Minor. Proposed: "… which the simulation's `init!(sim, condition; t0)`
  wraps, resolving the condition and opening the run before the model's
  door writes".
- **F28. §14.4's opening is an aphorism.** Row 115 (11561): "**The
  paradigm-change tax feared at execution does not materialize.**" A bold
  history claim as a topic sentence; `spec_style.md` asks a findable claim.
  Proposed context: "A resolved condition is applied two ways, because a
  one-shot service and an iterating one want different things from the same
  validated entry list ([D-066])."
- **F29. Bare *entry*.** 11329 ("Entries are validated"), 11380 ("a schema
  entry"), 11453 ("the flattened entry list"), 11492 ("each entry's"), 11495
  ("each flat entry"), 11586 ("validated entry list"). `#g-entry` says the
  word is never used bare and lists *condition entry* (§14.3). Proposed:
  "condition entry" or "the condition's entries" at each, and "a schema
  entry" kept as the compound D-064's rejection is about.

## F. Difficulty per section

| section | difficulty | reason |
|---|---|---|
| heading (A) | medium | 482 words that are mostly rules under a bold label; a `####` label (q1) and M1; the services' count (F3); D-108 uncited at nine rows; the double `errored` bold; one table with an unnamed kind (F5) |
| §14.1 (A) | medium | 476 words in good order; two bold labels to convert; the doctrine paragraph argues from superseded premises and needs a ruled rewrite (F6, q3); D-139's Rationale carries six rows uncited; one reserved-word clash (*predicate*) |
| §14.2 (A) | medium to high | 985 words, three code blocks, one **Rule.**, four bold terms; M2; F7–F10 and F12 local fixes; D-405, D-113 and the D-065 rows want citations; collisions and blends are dense with kind names, two missing (F5) |
| §14.3 (A) | medium | 566 words; **Rule.**/**Why.** to convert; D-148 cited nowhere though it rules five rows; F11, F13, F15–F17 local fixes; the converter table's cells carry em dashes |
| §14.4 (B) | high | 1,381 words in two topics under one `####`; three **Rule.** labels; D-066, D-098, D-095, D-125 cited nowhere; the client policy needs a ruled recast (F1, q5) that touches a table; M3–M5; F17–F23 and F28 local fixes |
| §14.5 (B) | medium | 1,018 words in a bullet list with nine bolds, three of them labels; the table sits inside a list item; D-110, D-126, D-155, D-413 cited nowhere; bold homes shared with §14.8 (q8); F4, F14, F27 local fixes |
| §14.6 (B) | low to medium | 444 words in good order; three bold opening sentences; F2 adds a site; F24, F25 local fixes; D-149 and D-376 to cite |

Warnings for the rewriter:

- **Terms of art stay verbatim**: condition, condition method, fragment, the
  inert lazy tree, the overlay base, the pre-sweep doctrine, caller-computable,
  the locality law (third instance), self-vocabulary, tree position, lens,
  schema and layout, decision-descended, held constant, the zero-partial
  embedding, the specialized `apply!`, the dynamic walk, the gather twin,
  resolve-once/execute-many, the read-selector family, deferred read, leaf
  address, table source, live stores, the source rule, integration read,
  boundary zero, establishment, the outgoing transition, interval alignment,
  init-service argument, root-input totality, virgin stores, plan-level fact,
  the probe-value barrier, baseline, the fourth node kind. "Collision is the
  intent", "a fabricated zero is a fine probe input and a terrible flight
  condition", "no third branch", "warn-but-assign" and "one implementation of
  the field math, evaluated one level up" are lines the log fought for.
- **Two plans, one pass** (F16). Whatever q6 rules, never call the dynamic
  walk's input a lens plan, and never say the specialized `apply!`
  allocates.
- **Scope words are exact.** "a prefix is a reference to the author's own
  literal" (F9), "in that case, and in no other" (the zero-partial
  embedding), "before any evaluation, not merely before any write", "the
  first sample the component's `s_update` consumes remains its `Φ·Δt_base`
  tick's", "Only the committed solution executes boundary zero", "the second
  one is unconditional". Keep each.
- **Counts are claims.** "three combinators" (F8), "five short common
  nouns", "four terms" (the ledger), "two cases" (the converters), "five
  selectors", "Three consequences" (§14.6), "~20 root-input values", "one
  class, one mechanism and one kind", the services' count (F3), the
  totality sites (F2). Each must match its list after the rewrite.
- **The half cites by adjacency.** Rows 16, 25–26, 29, 63, 65–66, 73–74, 78,
  133, 135–136, 148, 174–176, 186–190, 197–198, 209, 214–227 carry their
  citation one or more sentences away. A move that separates a rule from its
  citation (M1, M2, M3) needs the citation repeated.
- **Glossary links reset per section, once each.** Unlinked first uses that
  have an anchor: *service lifecycle* and *root input* (heading), *entry*
  (bare, F29), *fragment tree*, *`at`*, *override*, *generic holding*,
  *`Build`* (§14.2), *schema vs. layout*, *nominal*, *scratch* (§14.3),
  *store*, *lens*, *requester roster*, *layout*, *checkpoint* (§14.4),
  *store*, *baseline* (§14.5), *override*, *combine*, *kind* (§14.6). Late
  links: *`Model`* (heading), *condition* (§14.2, §14.3, §14.6), *face* and
  *mounting* (§14.4), *boundary zero* and *tier* (§14.5). One duplicate link
  (*snapshot* in §14.5). Three wrong anchors (F4).
- **Reserved words.** *boundary* (F17, F4), *sweep* (F17), *entry* (F29),
  *predicate* (§14.1 row 35: a stop predicate, not a guard's), *writer*
  (F15), *contract* ("a taught contract", §14.5, a distinct usage left
  unlinked), *kind* (used correctly throughout), *tier* (used correctly).
- **The log's vocabulary is old.** D-063 says `z` and `capture`; D-065 says
  `Merged`, `merge`, "slots" and `m`/`z`; D-068 says `UninitializedSlots`
  and "slot totality"; D-095 lists `get_local` and `get_slot`; D-098 and
  D-108 say `capture`; D-066 says "cost reads"; D-067 says `g` updates and
  "header capture". Never import them.
- **Code blocks are ruled edits only.** Block 11395–11398 keeps
  `eng.ω_rated` (O16); `C172XSystems` and `Phase.running` stay and get an
  introducing clause outside the block (F12).
- **The table inside §14.5's bullet** (11778–11781) is indented two spaces
  under its list item; keep the indentation, or the list breaks.
- **History sentences.** 11561 (the paradigm-change tax), 11808 ("Today's
  hand-written trim asserts"), 11860 ("Today `SystemsInitializer`'s …"),
  11870 ("Trim uses it on day one"). Carry them until q9 is ruled.

## G. Decisions for checkpoint 1

Settled and not asked again: log repair rides track 2, and bold marks one
headline clause per ruling.

**q1. The chapter opening and the lifecycle block (rows 1–24, F3, M1,
M6).** The opening names three services and "a fourth", while the table
lists five, and 482 words of rules sit under a bold label before §14.1.
Options: (a) one context paragraph naming the five services and the
condition three of them share, one roadmap sentence for §14.1–§14.10, then
`#### Lifecycle preconditions` over the rules in M1's order; (b) the same
with no `####`, the bold label becoming a topic sentence; (c) fix only the
count. Recommendation: (a). §1 has `####` labels under a `##` heading, the
block is the bare §14 citations' target (part D: §12.6 9539, §11.3 7341,
Appendix C 13597, 13707, D-232, D-319), and a label makes it findable. The
Part IV roadmap (9914–9919) already describes §14 by its parts and needs no
change.

**q2. Totality's fourth site (F2).** Linearization's `about` application
runs the totality check (`src/linearize.jl` 177–178), and the section's
principle covers it; four texts list three sites. Options: (a) rule §14.6's
list to the code now, and carry §9.3's bold (4690–4692), §11.3 (7334) and
the glossary (14770–14772) as loose fixes, with D-149 annotated in track 2;
(b) state the principle alone in §14.6 with no enumeration and leave the
others; (c) leave all four. Recommendation: (a). §9.3's sentence is a
bold with "namely", so it says the list is complete.

**q3. §14.1's doctrine (F6).** Options: (a) rewrite rows 34–37 to §13.5's
ground, citing D-409, keep "a design-time statement about a concrete
build", and drop the `local_wires` parallel (dictated text in F6); (b) trim
the paragraph to one sentence, "Addressing conditions by path does not
reopen the observation-by-path rejection, which bars a run from acting on
undeclared reads ([§13.5])"; (c) leave it flagged. Recommendation: (a). The
parallel's premise, deep wiring paths, has been gone since D-207, and §13.5
already relies on §14.1 for "conditions already address state by path".

**q4. Interval alignment's bold (row 186, O4).** §3.2 states the law in
Part I; Appendix A indexes it to §14.5; §14.5 bolds it with D-067 three
sentences away. Options: (a) keep the bold in §14.5 on "A boundary's
`s_update` is the outgoing transition", D-067 cited in the sentence; (b)
move the bold to the boundary-zero consequence, "Boundary zero is missing
its incoming transitions on both tiers, and authorship replaces both", and
let the law point to §3.2. Recommendation: (a). D-067 bullet 1 is one
ruling whose headline is the outgoing transition, and §14.5 is where the
entry's boundary-zero consequence is worked, so the bold sits where the
section states what the entry decides.

**q5. §14.4's client policy (F1, F21, F22).** Options: (a) recast the
client paragraph and table as guidance on top of the one enforced source
rule, as F1 proposes, naming bindings and `series` as inspection reads in
D-083's sense that resolve under §13.3's service walk, and dropping
snapshot inspection from the selector clients; (b) keep the paragraph's
shape and correct only the four false claims (the resolver property, the
bold, "seam-crossing member", snapshot inspection); (c) rename the two
sides ("contract reads" and "observation reads") so *service* keeps §13.3's
resolution sense alone. Recommendation: (a). The resolver is client-free by
D-414's Rejected list and by the code, so a two-sided policy table with
"named in the contract" reads as enforcement that does not exist; (a) keeps
D-083's vocabulary, which §11.2 and §13.5 use. Rule jointly with the
sibling, whose §14.7 read bullet (11949–11952) and §14.10 tap lists restate
the service side, and check §13.3's table (10243) as chapter 13's lesson on
moving a member between classes asks.

**q6. §14.4's first part and "one plan" (F16, F28).** Options: (a) give the
first part a `####` label ("Applying a plan") above the existing one, open
the section with a context paragraph replacing the aphorism, and rule F16's
wording, keeping the title; (b) no new label, a parts sentence in the
context; (c) retitle §14.4 ("One resolution, two ways to apply it"), which
costs 83 inbound rows nothing in anchor text but changes every linkified
definition. Recommendation: (a). The section runs two topics over 1,381
words, and the title's "one plan" survives as D-066's phrase with the body
saying what compiles.

**q7. Units.** Options: A (11267–11558, 2,509 words) and B (11559–11873,
2,843); or A′ (heading to §14.2, 1,943) and B′ (§14.3 to §14.6, 3,409).
Recommendation: A and B, both inside the 2,500–3,000 range, with §14.3 kept
beside the §14.2 it continues.

**q8. Bold homes shared with half 2, and §14.5's labels.** D-155's Position
holds two rulings by its semicolon: projection as the second mover with the
report's two residual sets, and `TrimCommitResiduals`. D-126's is one: the
fired set rides the report and raises `TrimCommitEvents`. D-067 bullet 3 is
one: trim bypasses boundaries and the guard firing at commit replaces the
asserts, which §14.5 bolds twice (rows 200, 202). Options: (a) §14.5 bolds
D-067 bullet 3 once (row 200), D-155's first ruling (row 205) and D-126
(row 204), first in reading order; §14.8 bolds `TrimCommitResiduals`; (b)
§14.5 bolds D-067 bullet 3 alone and states the movers plain, §14.8 bolding
D-126 and both of D-155's rulings, where the report is specified. Either
way the three list labels ("Project runs.", "Events run.", "Due `s_update`
calls run.") become plain lead-ins. Recommendation: (a), by
`spec_style.md`'s first-in-reading-order rule; rule jointly with the
sibling.

**q9. Flight.jl and FlightCore names (F12).** Options: (a) an introducing
clause at each first use naming the owner, the "today's" sentences recast
as "FlightCore's" or "Flight.jl's"; (b) move the migration remarks
(`SystemsInitializer`, the hand-written trim asserts, `f_ode!`'s cost) to
`companions/migration_outline.md` with a pointer, keeping the examples'
names with clauses; (c) leave them. Recommendation: (a). Each is one clause,
the examples ground the rules, and chapter 6's lesson prefers a clause to a
companion move for a status-quo fact that gives a rule its scale.

## H. Descriptive passages

One row per passage that describes a rule's mechanism rather than stating
the rule. The source file is the one `implementation.md`'s map and a grep
put it in; where a passage describes something stale or unbuilt, the row
says so. These rows are the normative kernel's migration list; part C
proposes no move on their account.

| id | section | lines | summary | realized in |
|---|---|---|---|---|
| P1 | heading | 11293–11300 | the services' lifecycle gates on a simulation | `src/sim.jl` (`init!` 591–597, `checkpoint` 636–651, `restore!` 707–735, `trim!` 757–766, `linearize` 780–795; `STOPPED_SIM_LEGAL`) |
| P2 | heading | 11302–11308 | the `Model` forms' status gates and the claim gate | `src/model.jl` (`_claimed_gate` 148–150, `init!` 170–198, `checkpoint(model)` 595–606, `restore!` 698), `src/trim.jl` (446–451), `src/linearize.jl` (128–141) |
| P3 | heading | 11314–11318 | `ServiceLifecycle`'s payload | `src/diagnostics.jl` (`ServiceLifecycle` 1173–1190) |
| P4 | §14.1 | 11322–11331 | what a condition may specify and its collecting validation | `src/conditions.jl` (`_resolve_entries` 350–389, `_undeclared` 468–475, `_report_violations` 494–497) |
| P5 | §14.1 | 11333–11336 | the overlay base: a fresh run from the declared defaults | `src/model.jl` (`init!`'s `establish_defaults!`, 182–184), `src/conditions.jl` (`_store_bases` 393–395) |
| P6 | §14.1 | 11358–11374 | the two routes to an environment handle and the fallback | none: an authoring idiom realized in user code; worked in `companions/trim_environment_walkthrough.md` |
| P7 | §14.2 | 11384–11393 | the framework-owned `condition` generic | `src/conditions.jl` (`condition` 52–64) |
| P8 | §14.2 | 11408–11424 | the inert tree: node types, isbits nodes, no path work, the allocation account | `src/conditions.jl` (`Fragment`, `Scoped`, `Combined`, `Override` 20–50; `set` 74–83; `at` 92–101; `combine` 112–122; `override` 137–143) |
| P9 | §14.2 | 11426–11431 | the empty-prefix refusal | `src/conditions.jl` (`at` 92–100) |
| P10 | §14.2 | 11433–11443 | `u` payloads through the export chain; the internally wired refusal | `src/conditions.jl` (`_root_input` 443–457), `src/readers.jl` (`_face_producer` 599–601, `_input_faces_at` 588–594) |
| P11 | §14.2 | 11455–11458 | what the build checks of the locality law | `src/assembly.jl` (`resolve_authored` 1482–1512; wiring's one-level check) |
| P12 | §14.2 | 11467–11486 | the collision error and the blend error methods | `src/conditions.jl` (`_check_duplicates!` 237–250, `combine` error methods 118–122, `_node_misuse` 143–144), `src/diagnostics.jl` (`DuplicateConditionLeaf` 1826–1839, `ConditionNodeMisuse` 1842–1859) |
| P13 | §14.3 | 11490–11502 | flattening with the path accumulator and tree position; the five checks | `src/conditions.jl` (`CEntry` 165–173, `_flat` 179–233, `_resolve_entries` 350–389) |
| P14 | §14.3 | 11504–11512 | schema and layout as the two lookup families | `src/conditions.jl` (`_resolve_entries`, `act.decls` and `act.layout`, 351–353) |
| P15 | §14.3 | 11514–11517 | the plan and the lens | `src/conditions.jl` (`ConditionPlan` 270–275, `SpecializedPlan` 656–664, `Authored{P,L}` 577–579), `src/readers.jl` (`walk_steps`) |
| P16 | §14.3 | 11519–11553 | the converter selected per leaf, the two cases | `src/conditions.jl` (`Authored`'s `convert(L, …)` 579, `_convert` 411–416, `_unconvertible` 485–491) |
| P17 | §14.3 | 11555–11557 | overlay partiality baked as a whole merged store value | `src/conditions.jl` (`resolve_condition` 316–324, `StoreWrite` 600–620); the identifier named is stale (F15) |
| P18 | §14.4 | 11568–11584 | the specialized `apply!`: unrolled writes, the folded shape check, the prefix compare, the drift kind, the codegen cost | `src/conditions.jl` (`compile_plan` 680–707, `apply!` 752–764, `_compare` 774–778, `_shape_drift` 780–786), `src/diagnostics.jl` (`ConditionShapeDrift` 2111–2131) |
| P19 | §14.4 | 11585–11591 | the dynamic walk | `src/conditions.jl` (`apply!(::Executor, ::ConditionPlan)` 536–550) |
| P20 | §14.4 | 11595–11598 | plans and readers paired with their activation | `src/conditions.jl` (549, 763), `src/readers.jl` (375), `_activation_mismatch` (`src/build.jl`) |
| P21 | §14.4 | 11602–11627 | the closed family and the leaf address: grammar, face-head match, step checks, the bake | `src/readers.jl` (`GetState`…`GetFace` 59–90, `parse_leaf`, `match_leaf`, `resolve_leaf`, `walk_steps`; the flatness rule 679–681) |
| P22 | §14.4 | 11642–11662 | the source rule and its refusal | `src/readers.jl` (`_compile_reads` 410–418, `_resolve_reads` 429–445, `:store_selector` 441–442) |
| P23 | §14.4 | 11664–11693 | the client policy on top of the source rule | none: no code enforces a client policy, and the resolver is client-free (D-414); stale as enforcement (F1) |
| P24 | §14.4 | 11695–11703 | the selector table | `src/readers.jl` (as P22); its client columns as P23 |
| P25 | §14.4 | 11705–11708 | compiled readers as the gather twin | `src/readers.jl` (`Reader`, `gather_reads` 372–375, `_read_entries` 381–382), `src/dataplane.jl` (`gather_reads` over a snapshot, 486–487) |
| P26 | §14.4 | 11710–11716 | trim's per-iteration ledger | `src/trim.jl` (`eval!` 524–540: `apply!`, `evaluate!`, `gather_reads`) |
| P27 | §14.5 | 11720–11728 | boundary zero's sequence and the header taken after it | `src/model.jl` (`boundary_zero!` 325–332, `init!` 178–198), `src/sim.jl` (`init!` 608–614, the header) |
| P28 | §14.5 | 11730–11735 | projection first | `src/model.jl` (`_projects!` in `boundary_zero!`, 327–328) |
| P29 | §14.5 | 11736–11748 | every output stage publishes, due or not | `src/model.jl` (`event_phase!(model, ESTABLISH)` 329, `_round!(::Executor, ::Establish)` 342–343) |
| P30 | §14.5 | 11749–11768 | events at `t₀`: priors not-holding, no re-firing under replay, a request read at entry | `src/model.jl` (`fill!(exec.events.prior, false)` 187), `src/sim.jl` (`_advance!`'s entry read of the latest snapshot, D-413) |
| P31 | §14.5 | 11769–11791 | the due `s_update` calls at `t₀` | `src/model.jl` (`model.exec.bodies.ticks(0)`, 330–331) |
| P32 | §14.5 | 11792–11803 | the `t₀` argument on both init-service doors | `src/model.jl` (`init!`'s clock writes 185–186), `src/sim.jl` (`init!` 591, `trim!` 757), `src/trim.jl` (`trim!(model, …)` 446–451) |
| P33 | §14.5 | 11804–11819 | trim's iterations without boundaries; the two movers at commit | `src/trim.jl` (`eval!` 524–540; `_verdict!` and the commit through `init!`, with `TrimCommitEvents` and `TrimCommitResiduals`) |
| P34 | §14.6 | 11830–11845 | the totality check, its operands and its timing | `src/conditions.jl` (`assert_total` 514–519); callers `src/model.jl` 173, `src/sim.jl` 600, `src/trim.jl` 482, `src/linearize.jl` 178 |
| P35 | §14.6 | 11847–11856 | the probe-value barrier and replay's complete header | none for the barrier: an absence by design (`probe_value` is called only by the build's probes, `src/declare.jl` and `src/build.jl`); the header in `src/sim.jl` (612–614) |
| P36 | §14.6 | 11858–11872 | `override`: ordered layering, the origin, within-layer collisions | `src/conditions.jl` (`Override` 46–48, `override` 137–138, `_flat(::Override)` 215–233) |

36 rows. Rule statements the kernel would keep from these passages are in
part A; every row above describes how a ruling is carried out. P23 is the
one stale passage with no realization; P6 is an authoring idiom with none by
design; P17 contains a stale identifier inside an otherwise realized
description.

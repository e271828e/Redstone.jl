# Chapter 14, track 2 plan (agent 1, step 1)

One row per proposal of items B33 to B74 of `rulings_batch.md`, classified
under each item's Status line and its `evidence_check.md` block. Log lines
are working-tree `decisions.md` lines, which match the frozen `c3d29fb` copy
(the landing changed only the `[s14-4]` link definition). Chapter lines are
working-tree `spec.md` lines. Every NEW ENTRY candidate was grepped against
every Position by `scratch_track2/1/entries.py pos`, annotations split out of
the Position; the grep that found nothing is named in the row.

Classes: ANNOTATION, SPEC FIELD, NEW ENTRY, NONE, CLOSED, as the prompt
defines them. One row, B74c, is GLOSSARY, the glossary edit the prompt
assigns to agent 1. NONE (description) marks a sentence that describes
mechanism, which recipe step 8 gives no entry.

## Counts

| class | rows |
|---|---|
| ANNOTATION | 16 |
| SPEC FIELD | 4 |
| NEW ENTRY | 16, in 14 groups (G1 to G14) |
| NONE | 33, one of them NONE (description) |
| CLOSED | 6 |
| GLOSSARY | 1 |
| total | 76 |

The table has 77 rows: B44b and B73a are one proposal, counted once, under
B73a.

## The table

| item | entry | class | the source's words, in brief | topic and §14 section (NEW ENTRY), or note |
|---|---|---|---|---|
| B33a | D-108 | ANNOTATION | Position 3555-3560: "`capture` requires `initialized`/`stopped`" and "`linearize` inherits `capture`'s precondition" | Points to D-274 bullet 2: `checkpoint` is legal in `initialized` and `stopped`. |
| B33b | D-108 | NEW ENTRY | Rationale 3564: "`errored` is terminal for all four ([D-059])" | G1. No service accepts an `errored` simulation. §14 lead, "Lifecycle preconditions" (spec 11311). Grep `errored`: D-059 says only "Status goes terminal". |
| B33c | D-108 | NEW ENTRY | Rationale 3569-3570: "one kind `ServiceLifecycle` (operation, current status, legal statuses)" | G1. `ServiceLifecycle`'s payload. §14 lead (spec 11317-11318). Grep `legal statuses`, `current status`: none; D-319 bullet 2 uses `op` and `legal` without the list. |
| B33d | D-108 | NONE | Rationale 3570: "shared with `attach!`/`detach!`-while-running" | D-232's Position states it. |
| B33e | D-108 | NONE | Rejected 3574: "Folding `MissingInit` into `ServiceLifecycle`: distinct cases" | D-404 bullet 1 uses the two kinds apart, `MissingInit` at `built` and `ServiceLifecycle` otherwise. |
| B34a | D-139 | NEW ENTRY | Rationale 4950: "caller-computable escape is extended to cover environment queries" | G2. Caller-computable reaches environment queries, through the value-level constructor or an isbits handle. §14.1 (spec 11378-11392). Grep `environment quer`: none; D-064 states the escape for swept outputs only. |
| B34b | D-139 | NEW ENTRY | Rationale 4962: "Trim problems never author the environment" | G3. A trim problem never authors the environment. §14.9 (spec 12611-12626). Grep `never author`, `authors? the environment`: none. |
| B34c | D-139 | NONE | Rationale 4968-4969: "the aircraft is never literally the root" softened "from doctrine to default" | D-071 bullet 4's Position: "'root' = shallowest world, one idiom". The chapter cites D-071 there (spec 12636-12644). |
| B34d | D-139 | ANNOTATION | Rejected 5008-5009: "reaffirms §14.2's by-name rejection of init as a third scheduled sweep" | IC1 row 208's text: the rejection is D-064's; §14.2 never stated it. |
| B35 | D-278 | NONE | Rationale: "§14.2 wants one way to say everything" | A reason. D-278's Position rules the empty-prefix refusal the chapter cites. |
| B36a | D-065 | ANNOTATION | Position 2096-2097: "deep `at` only within owned concrete subtrees"; annotation 2108-2109: "Its concrete half is machine-checked" | Points to D-207 (amends the clause by name) and D-414 bullets 1 and 4 (`:past_generic` retires; the locality law is guidance). |
| B36b | D-065 | SPEC FIELD | Spec 2101 lacks §14.3; §14.3 cites D-065 at spec 11541, 11582, 11618 | Add §14.3 after §14.2, keeping the field's order. |
| B36c | D-065 | CLOSED | Rejected: last-writer-wins; D-204 Rationale: `Base.merge`'s contract | Status: no new entry, annotate stale text only. Reasons. |
| B37 | D-064 | SPEC FIELD | Spec 2075 is §14.2 only; §14.1 bolds the pre-sweep doctrine on D-064 (spec 11371) | Add §14.1 before §14.2. |
| B38 | D-316 | NONE | Rationale 13997-13999: "`condition` stays outside the family because a foreign `condition` fails loudly" | The chapter's "no shadowing check covers it" (spec 11412-11415) follows from D-246's Position (family names only) and D-117's family list; the "because" is a reason. |
| B39 | D-148 | NONE | Rationale 5598-5611: shape facts; the exact-match doctrine untouched; "converters still run only on the write paths, never on state views" | Reasons beside D-148's Position; "still" restates standing commitments. |
| B40 | D-124 | NONE | Rationale 4113-4117: the source axis "restated as *table sources*" | Wording. D-406 bullet 1's Position states the source rule. |
| B41a | D-095 | ANNOTATION | Position 3075-3079: the six-member family with `get_local` and `get_slot` | §14.4 has five: `get_slot` is `get_input` (D-206), `get_local` retired (D-165). Status: annotate the six-member list only. |
| B41b | D-095 | CLOSED | Rationale 3086-3087: "inspection readers the whole family" | Status: "Annotate D-095's six-member list only." D-129's and D-276's Positions bear on it. |
| B41c | D-095 | NONE | Rationale 3087-3088: "`stop_on` outside the family entirely" | D-316 bullet 7's Position states the ignore list (Status). |
| B42 | D-098 | ANNOTATION | Position 3172-3176: "a selector resolves against a *source* before any client policy"; "only stopped-sim service evaluations, `capture` and post-run inspection ever hold" live stores | `capture` reads `checkpoint` (D-273, D-274). Per the evidence's caveat, also: the source rule is the resolver's, with no client policy on top (D-406 bullet 1), and of the holders only the services' readers take a store selector (D-406 bullet 1, D-407 bullet 1). |
| B43 | D-063 | ANNOTATION | Position 2047-2051: "(capture → tweak → apply)" | Points to D-273 bullet 4, which retires the cycle. |
| B44a | D-066 | NONE | Position 2131: "`capture`" among the gather twin's uses | Rule 2, as the batch proposes. See flag F4. |
| B44b | D-066 | NEW ENTRY (= B73a) | No entry names `ConditionShapeDrift` | Merged into G10. |
| B45a | D-067 | NONE | Rejected 2178-2182: the `t₀` firing not suppressed | D-292 bullet 1's Position: "an authored condition whose guard holds fires at `t₀`". |
| B45b | D-026, D-067 | NONE | Rejected: the insurance-masking lesson | A reason; the chapter cites it as one (spec 11843-11844). |
| B45c | D-067 | NONE | Position: "every tick due" | Annotation 2026-10-02 (2173-2175) already records D-205's amendment. |
| B46 | D-276 | NEW ENTRY | Annotations 2026-09-30 and 2026-10-01 (12073-12094): the head "matched against the level's face list, the longest face name that is a prefix" | G4. The face head match on `get_input` and `get_face`, and a `Symbol` leaf naming the face whole. §14.4 (spec 11690-11697). Grep `longest`, `face list`, `head` over Positions alone: none. |
| B47 | D-409 | ANNOTATION | Position 16348-16350: "Service observation must speak the contract" | Scopes it to the reads a run acts on, as §13.5 frames it; points to D-414 bullet 4. |
| B48 | D-130 | CLOSED | Position 4310-4312 | Status: the 2026-10-19 annotations exist. |
| B49 | D-242 | CLOSED | Position 9606-9609 | Status: the 2026-10-19 annotation exists. |
| B50a | D-149 | ANNOTATION | Position 5643-5646: three sites, "`init!`, trim setup, trim commit" | Linearization's `about` is a fourth under the Position's own principle (§14.6, §14.10). |
| B50b | D-149 | CLOSED | Rationale 5657-5660: commit's totality "structurally unfailable through the trim path"; no `committed` flag | Status: no new entry. |
| B51 | D-122 | ANNOTATION | Rationale 4043-4044: "the `baseline` keyword of `trim!`/`init!`" | Only `trim!` takes `baseline` (`src/sim.jl` 591, `src/model.jl` 177). See flag F6. |
| B52 | D-253 | SPEC FIELD | Spec 10212 lists §14.1, which never cites D-253; §14.3 does (spec 11572) | In place, per N2: §14.1 reads §14.3, in place of IC1's annotation. See flag F2. |
| B53a | D-118 | ANNOTATION | Position 3903: "closes at seven" | Points to D-262's Position, which adds `checks` and `check_tolerances`: nine. |
| B53b | D-118 | CLOSED | Rationale 3917-3918: shape/key-set checks "at the setup guess evaluation" | Status: no new entry. |
| B54 | D-262 | NONE | Rejected: "checks stay out of the solve"; Rationale 10874-10877: setup's check at the guess | D-262's Position: "The service never solves them" (Status). The guess half is B53b. |
| B55 | D-151 | NONE | Rejected 5753-5758: the permuted bound | D-151's Position states the canonicalization; the hazard is a reason. |
| B56 | D-132 | NONE | Rationale 4432-4434: "the services need no story of their own" | Follows from D-070's per-invocation scratch sets and D-223 bullet 4 ("a service has no stop path"). |
| B57 | D-273 | NONE | Rationale 11904-11906: "`trim!` no longer takes a mid-run capture as its baseline" | Follows from D-273's Position (evidence note). |
| B58 | D-307 | NONE | Rationale 13464-13465: "guidance, not rulings" | Guidance, by the entry's own words. |
| B59a | D-070 | NONE | Bullet 3, 2275-2276: "a `BuildError` at setup" | D-222 replaced the carrier; rule 2 keeps the old word. See flag F5. |
| B59b | D-070 | ANNOTATION | Bullet 5, 2280-2281: "saturation rank-deficiency (LM-tolerated, reported)" | The report's `saturated` list names a decision only at its own bound (`src/trim.jl` 587-596), as bullet 1 scopes it; an in-model saturation shows in zero Jacobian columns. Weak; see flag F5. |
| B59c | D-070 | NONE | The `saturated` scope, "in no Position" | Follows from bullet 1: "saturated-at-solution flagged in the report". |
| B59d | D-070 | NONE | Rejected: the external NLS packages | Constructive rationale (S2-E ruling 13). |
| B60 | D-069 | ANNOTATION | Bullet 2, 2234-2235: "`deriv`/`output` selectors" | Points to D-124, which widens the grammar and names the old form a straggler, and D-095's prefix. |
| B61a | D-071 | ANNOTATION | Bullet 2, 2310-2312: "named by the build" | The build raises nothing (F54); resolution refuses by name. Best landed by agent 2 beside G5, so it can point to the new entry. See flag F3. |
| B61b | D-071 | NEW ENTRY | The `:internally_wired` refusal, "in no Position" | G5. Resolution refuses an internally wired input by name with its producer, `ConditionResolution` for a condition entry and `ReadResolution` for a `get_input`. §14.2 (spec 11447-11449) and §14.9 (spec 12603-12608); two sections, one ruling. Grep `internally.wired`, `untrimmable`: only D-071 bullet 2. |
| B62 | D-072 | ANNOTATION | Bullet 3, 2349-2351: "its default operating point is `capture(sim)`" | Points to D-274 bullet 5. |
| B63a | D-272 | ANNOTATION | Bullet 4, 11779-11780: "The operating point is `capture(sim)` by default." | Points to D-274 bullet 5 (Status: no entry for the default point). |
| B63b | D-272 | NEW ENTRY | Annotation 2026-09-28 (11825-11836): "Two taps resolving to one site are refused at resolution with both labels in hand" | G6. §14.10 (spec 12700-12702). Grep `both labels`, `one site`: none. |
| B63c | D-272 | NEW ENTRY | Same annotation: "the refusal names the tier rather than an entry to promote" | G6. The tier-pinned root input's refusal. §14.10 (spec 12787-12791). Grep `names the tier`, `tier-pinned`: none; D-296 bullet 4 is the entry-pin sibling. |
| B63d | D-272 | NEW ENTRY | Same annotation: "`t0` is admitted only beside `about`" | G7. A `t0` without `about` is `ArgumentInvalid`. §14.10 (spec 12744-12745). Grep `` `t0` ``: D-272 bullet 4 and D-319 place `t0` beside `about`; neither refuses it alone. |
| B64 | D-126 | NONE | Rationale 4182: "`capture`-defaulted `linearize`" | Rule 2; D-274 bullet 5 states the current default. |
| B65 | D-155 | NONE | Position 5896: as B64 | Rule 2; D-274 bullet 5. |
| B66 | D-263, D-167 | NONE | D-167 Rejected 6436-6440: "the opt-in participation trait brings the `T`-signature with it" | D-073's Position records the sampled-data extension unbuilt, and the trait is part of it (spec 12853). The batch's annotation is the retired form (N1). |
| B67 | D-197, D-073 | NONE | D-197 Rationale 7634-7636; D-073 Rejected 2406-2408 | Reasons beside D-197's and D-073's Positions. |
| B68a | D-150 | NEW ENTRY | Rationale 5694-5699: "The tolerance translation into each backend's stopping language is the service's too, per backend family" | G8. Least-squares backends stop on the tolerances; the derivative-free fallback on normalized residuals at `stopval = 1`. §14.8, "The tolerance translation" (spec 12240-12270). Grep `stopping`, `translat`, `per backend`: D-158's Position names "D-150's per-backend translation" without ruling it. |
| B68b | D-150 | NONE | The squaring half | D-069 bullet 5 and D-070's Position. |
| B68c | D-150 | NONE | Rationale 5700-5704: "Soundness (inscribed sphere)" | A consequence of G8's normalization; G8's Rationale. |
| B69 | D-213 | SPEC FIELD | Spec 8264 lacks §14.10 | Held: §14.10 cites D-213 nowhere and states its rule only by pointing to §14.8's mechanism. See flag F2. |
| B70 | D-068 | ANNOTATION | Bullet 3, 2203-2206: "trim commits `override(baseline, solution)`" | The code and D-149's Rationale spell it `override(baseline, condition(d*))` (`src/trim.jl` 612). The evidence notes "`solution`" can read as the solved condition. |
| B71 | none | NEW ENTRY | `:inverted_box`, `:nonpositive_tolerance` (`src/trim.jl` 321, 346; first in `415ed0b`, moved by `3408028`) | G9. The two `TrimProblemInvalid` reasons. §14.8 (spec 12466-12467). Grep `inverted`, `nonpositive`: none. |
| B72 | none | NEW ENTRY | `_check_seedable` (`src/linearize.jl` 336-347); the suite cites "§14.10, D-036, D-276" | G11. A seeded tap reaches its scalar through one index step at most and never a `.name` step, its leaf exactly `Float64`; `:unseedable` and `:vector_tap`. §14.10 (spec 12693-12699). D-272 bullet 6 is the nearest Position. |
| B73a | none | NEW ENTRY | No entry names `ConditionShapeDrift`; reasons `:tree_type`, `:prefix` (`src/conditions.jl` 781, 785) | G10. The shape check's kind and reasons. §14.4 (spec 11646-11650). Grep `ConditionShapeDrift`, `:tree_type`: none. D-066's Position rules the check; B71 sets the precedent for code-sourced reasons. |
| B73b | none | NEW ENTRY | "That pairing is a framework invariant the services uphold" (`_activation_mismatch`, `src/conditions.jl` 549, 763; `src/readers.jl` 375) | G12. A compiled plan or reader applies only to a store set of its own activation; not a user-facing check. §14.4 (spec 11791-11794). Grep `pairing`, `activation … invariant`: none. The batch proposed one entry with G10. |
| B73c | none | NONE | "Which of the two a service uses is internal, never user-facing API" | D-130's Position states the same rule for resolution clients and names §14.4's `apply!` as its precedent; D-066 puts both ways in the `Build`'s client kit. The landed sentence is plain (spec 11664). |
| B73d | none | NEW ENTRY | "`init!` … legal at any status" on a `Model` (`src/model.jl` 170-198) | G13. §14 lead (spec 11328-11329). Grep `any status`, `no status gate`: D-319 bullet 2 says it of `restore!` only. Agent 2 should check `trim!` and explicit-`about` `linearize` on a `Model`, which the same sentence names. |
| B73e | none | NONE | `restore!` legal from `built` | D-274 bullet 3 ("beside `init!`") and D-319 bullet 2 ("no status gate") (Status). |
| B73f | none | NONE | The framework-owned `condition` generic | D-405's Position names the generic; the reason clause is description. |
| B73g | none | NONE | The `===` content comparison | D-066's Position: "literal `===` sweep". Description. |
| B73h | none | NONE (description) | The two lookup families, schema and layout | No entry; `#g-schema-vs-layout` records them. |
| B73i | none | NONE | The tree position | D-066's `Getter{P}` lenses; `#g-lens` records it. Description. |
| B74a | none | NEW ENTRY | Old §14.10 12721-12725: pinned-face validation and the feedthrough-graph lint, recorded | G14. The tooling over declared non-participation, recorded unbuilt and additive. §14.10 (spec 12924-12930). Grep `non-participation`, `feedthrough.graph`, `lint`, `pinned.face`: none. Lesson 17 applies; see flag F1. |
| B74b | none | NONE | The sampled-data walked-leaf parametrization, forward sensitivities, the loud diagnostic | D-073's Position records the extension unbuilt (Status). |
| B74c | glossary | GLOSSARY | `#g-design_world` (spec 14946-14949): "the shipped thin world" | R26 and R29: "the rig this design records for design-time work", `SimpleAtmosphere` and `NoWind` as FlightPhysics', `HorizontalTerrain` with no owner. |

## NEW ENTRY groups

Grouped by source entry and topic. No two items merge except B44b into
B73a, which rule one kind in §14.4.

| group | rows | source | topic | §14 section |
|---|---|---|---|---|
| G1 | B33b, B33c | D-108 Rationale | No service accepts an `errored` simulation, and `ServiceLifecycle`'s payload | §14 lead |
| G2 | B34a | D-139 Rationale | Caller-computable reaches environment queries | §14.1 |
| G3 | B34b | D-139 Rationale | A trim problem never authors the environment | §14.9 |
| G4 | B46 | D-276 annotations | The face head match | §14.4 |
| G5 | B61b | code (`src/conditions.jl` 455, `src/readers.jl` 538); D-071 bullet 2 | The `:internally_wired` refusal at resolution | §14.2, §14.9 |
| G6 | B63b, B63c | D-272 annotation 2026-09-28 | Tap refusals: two taps at one site, the tier-pinned root input | §14.10 |
| G7 | B63d | D-272 annotation 2026-09-28 | `t0` admitted only beside `about` | §14.10 |
| G8 | B68a | D-150 Rationale | The tolerance translation per backend family | §14.8 |
| G9 | B71 | code (`415ed0b`, `3408028`) | The two `TrimProblemInvalid` reasons | §14.8 |
| G10 | B73a, B44b | code; D-066 Position for the check | `ConditionShapeDrift` and its reasons | §14.4 |
| G11 | B72 | code (`_check_seedable`), test 308 | The seeded tap's limits and kinds | §14.10 |
| G12 | B73b | code (`_activation_mismatch`) | The activation pairing invariant | §14.4 |
| G13 | B73d | code (`src/model.jl`) | `init!` on a `Model` at any status | §14 lead |
| G14 | B74a | old §14.10; source in git history to be found | The recorded non-participation tooling | §14.10 |

G6 and G7 share a source and a section and could be one entry with two
bullets. G6 and G11 rule one topic, `TapResolution`'s refusals in §14.10,
from different sources, so they stay apart under the grouping rule.

## Spec field audit, run ahead of step 3

`scratch_track2/1/specfields.py` lists every `D-nnn` the landed chapter
cites, per section, against each entry's Spec field. A bare §14 in a field
covers every section. Output: `scratch_track2/1/specfields_out.txt`. It finds
109 (entry, section) pairs over 72 entries, and 29 pairs whose Spec field
lacks the section. Three are items above (D-064 §14.1, D-065 §14.3, D-253
§14.3). The tentative calls on the other 26, for step 3:

- Add, the entry ruling what the section states (21 pairs): D-066 §14.4;
  D-069 §14.8; D-223 §14.8; D-232 §14; D-273 §14 and §14.8; D-277 §14.7;
  D-286 §14.10; D-292 §14.5; D-297 §14.10; D-306 §14.1; D-317 §14.8; D-318
  §14 and §14.8; D-364 §14.1; D-376 §14.6; D-406 §14.8 and §14.10; D-407
  §14.4; D-409 §14.1; D-413 §14.5. "§14" means the chapter lead, as D-108's
  and D-319's fields already use it.
- Leave (5 pairs): D-026 §14.5 (a lesson cited as a reason); D-139 §14.8
  (cited for a mismatch the checks catch, not for the constructor); D-237
  §14.9 (a pointer to §4.4's reason); D-280 §14.8 (a passing mention of the
  CI probe, which §9.4 holds); D-316 §14.2 (a Rationale reason, B38).

Survey 2's six stale Spec fields (D-070, D-286, D-237, D-406, D-414, D-317)
were measured on the old chapter. The script flags D-286, D-406, D-317 and
D-237, the last left above, and finds no gap in D-070's or D-414's.

## Flags for the orchestrator

- **F1, G14.** The tooling is recorded and unbuilt. An entry restates a
  recorded ruling only (lesson 17), so agent 2 needs its source in git
  history, a commit and section; with none, it goes to the owner.
- **F2, Spec fields.** B52 removes §14.1 from D-253's field, beyond "add the
  missing sections". §14.4 is also in that field and cites D-253 nowhere
  either. B69 adds a section that cites D-213 nowhere; I would decline it
  under the prompt's "only where the entry rules what the section states".
- **F3, B61a.** "Named by the build" is true under one reading (evidence
  note). The annotation can only say the build raises nothing without
  writing G5's ruling into it, unless agent 2 lands it pointing to G5.
- **F4, B44a against B42.** D-098's `capture` is annotated and D-066's is
  not, though both name a role `capture` lost. I followed the batch.
- **F5, B59.** The `BuildError` half follows the rename reading of D-222.
  Bullet 5's "reported" is about the audit's finding and is stale only if
  read as the report listing in-model saturations; the annotation is
  optional.
- **F6, B51.** The evidence says the log does not show whether `init!` took
  `baseline` when D-122 was written. The spec at `8e2505c` (2026-08-30)
  reads "the `baseline` keyword `init!`/`trim!` take", so the clause was
  true then and is overtaken now.
- **Outside the items.** D-071 bullet 4 says "a shipped rig", which R26
  and B11 dropped from the spec. No item annotates it.

## Orchestrator amendments (2026-10-20)

The plan stands except as amended here. Agent 2 writes the NEW ENTRY
groups that remain.

- **G1 narrowed.** "No service accepts an `errored` simulation" follows
  from D-059's Position, terminal status, which §12.6 bolds: no entry
  (lesson 68). G1 keeps `ServiceLifecycle`'s payload alone (operation,
  current status, legal statuses), from D-108's Rationale.
- **G5 is NONE.** D-277 bullet 2's Position already states it: "A face fed
  by a component is refused with the producer named, as a condition's
  `inputs` entry is ([§14.2])". Cite D-277 at §14.2's and §14.9's
  refusal sentences if absent (agent 2, citations only). D-071 bullet 2's
  stale "named by the build" takes an annotation pointing at D-277 and
  resolution (agent 1, F3 resolved).
- **G12 is NONE.** The activation pairing is an internal invariant the
  services uphold, not user-facing: a description of mechanism, which the
  normative kernel moves beside the code (recipe step 8). No entry.
- **G14 needs a source.** Agent 2 searches git history for the text that
  recorded the pinned-face validation and the feedthrough-graph lint
  (`git log -S` over `docs/design/spec.md` and the log). If a design commit
  recorded them, the entry cites that commit and section, as D-408 does.
  If none did, write no entry, and add the finding to `ch14/escalations.md`
  as E2 (lesson 17).
- **G13** stands. Agent 2 checks every operation the sentence names
  (`trim!`, `linearize` with an explicit `about`) against `src/model.jl`
  and restates only what the code does.
- **F2.** B52 stands: D-253's Spec field takes §14.3 in place of §14.1, as
  the inbound check found (its RETARGET row). §14.4 stays: a Spec field
  names the sections an entry rules, not the ones that cite it. B69: add
  §14.10 to D-213's field only if D-213's Position rules what §14.10 states
  (the nominal and seeded halves); otherwise decline.
- **F4.** Follow the batch.
- **F5.** Apply B59's annotation: B12 corrected the spec's saturation
  sentence, and D-070 bullet 5's "reported" overstates what the report
  holds.
- **F6.** Annotate D-122: its clause held at `8e2505c` and was overtaken
  later, when `init!` lost the keyword.
- **D-071 bullet 4's "shipped rig"** takes an annotation beside B74c's
  glossary edit (R26).

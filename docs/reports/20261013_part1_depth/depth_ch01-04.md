# Depth audit: spec chapters 1 to 4 against the Part I depth rule

Scope: `docs/design/spec.md` at `05fface`, from "# Part I — Foundations" to just before "## 5. Evaluation order and feedthrough". That covers the Part I roadmap and chapters 1 to 4, after the readability rewrite. This was a read-only pass, and no repository file other than this report was touched. Each destination was checked by reading it. Word counts are rough (`wc -w` over the passage, less what Part I keeps). The roadmap and chapters 1 to 4 hold about 5,400 words.

Format of each entry: **location**, the rule it breaks, the destination, whether the destination already has it, and what Part I keeps. Entries are numbered P1, P2, ... to avoid clashing with the M-numbers of `depth_ch05-07.md`.

---

## Part I roadmap

**P1. "Part I assumes nothing from later parts. It cites them for spellings only. [§8] shows how an author writes a declaration, [§9] fixes when each declared fact is checked, and [§10] fixes what runs at a step boundary."**
- Not a move. The sentence misstates the rule now in force. Chapters 1 to 4 cite later parts for checks (§8.3, §13.5), mechanisms (§10.4, §10.6, §10.7), Part III terms (§11.3, §11.4, §11.7) and services (§14.1), not for spellings only. And "§10 fixes what runs at a step boundary" conflicts with B1 to B4 and T1 to T7, which put what a boundary computes in Part I and leave §10 the mechanics.
- The suspected problem is confirmed. Rule 5 is the standard the sentence should state: Part I reads without its forward citations, and it cites later parts for spelling, enforcement and mechanism.
- Destination: none.
- Part I keeps: a restated sentence carrying rule 5, and the roadmap's §2 summary updated for decision 2 (chapter 2 as the formalism of a run).

---

## Chapter 2

### §2 intro

No move. The "External inputs" bullet bears on T3. See "Planned additions" below.

### §2.1

**P2. The guard encoding: "A guard defines a predicate … either a `Bool`-valued form or the sign of a continuous function under the normative convention positive = predicate holds … holding means `σ ≥ 0`"; "Which form an author declares is not a free choice. The guard's return type is the declared policy. A `Bool` return declares boundary-detected, and the sign form declares localized"; and "That is why the declaration is named `state_events`".** This passage was suspected, and the suspicion is partly confirmed.
- (a) The two forms and the sign convention are meaning, not spelling. This is the definition of a predicate, and two later sections cite it back. §10.4 "Detection policy" says "That cast is the definition of the predicate ([§2.1])". §10.6 says "The predicate is the one [§2.1] defines, either the `Bool` form true or `σ ≥ 0`". The glossary's *predicate* entry also points here. **The definition should live in §2.1 and stay there.** `Bool` serves only as a label. Refuted as a move.
- (b) "The guard's return type is the declared policy." Rule 1. The law is that the predicate's form fixes the policy. The return type is how an author declares that form.
  - Destination: §8.2 "Events: `state_events`" and §10.4 "Detection policy".
  - Status: duplicate. §8.2 says "Detection policy is declared by the guard's return type instead ([D-179])". §10.4 says "The guard's return type declares its detection policy … No flag is involved". The glossary's *guard*, *boundary-detected* and *localized* entries also state it.
  - Part I keeps: "The predicate's form fixes its policy. A Boolean predicate is boundary-detected and a sign-form predicate is localized ([D-179])."
- (c) "That is why the declaration is named `state_events` ([§8.2], [D-220])". Rule 1, because it is a naming rationale.
  - Destination: the log.
  - Status: duplicate. D-220 says "`state_events` also names the distinction [§2.1] now teaches". The glossary's *state event* entry names the declaration. §8.2 "Events" does not say why the name was chosen, and it does not need to.
  - Part I keeps: the time-event versus state-event law, with "detection versus scheduling" as the criterion and "a guard over an input is still a state event".
- About 40 words move.

**P3. "[D-180] records a per-event `direction` keyword as a guarded addition (a capability the design admits but does not build)."** *Borderline.*
- Rule 1, because it names an unbuilt spelling. Rule 4 also applies.
- Destination: §8.2 "Events: `state_events`", or the log.
- Status: duplicate in the log (D-180). It is unique in the spec. §8.2 "Events" does not mention the keyword.
- Part I keeps: "The opposite crossing direction is declared as a second event with the negated guard", with its stall example.
- It is borderline because Part I names other guarded additions as scope statements (for example the field-projection connector in §4.3). Moving this one is a matter of consistency.
- About 22 words.

**P4. Boundary-detected bullet: "The cost is one guard evaluation per event per round of the boundary's event iteration ([§10.6])."**
- Rule 3. It is a cost statement about the mechanism.
- Destination: §10.6, opening paragraph.
- Status: duplicate in substance. "One round … evaluates all guards" gives the same count.
- Part I keeps: "There is no root-finding and no step rejection", and the fixed-step real-time compatibility.
- About 17 words.

**P5. "The pacer inserts waits between completed frames and never alters the boundary sequence."** *Borderline.*
- Rule 3. It describes how the pacer works.
- Destination: §10.7 "The invariant and the wall-clock map".
- Status: duplicate. §10.7 says "The pacer inserts waits between completed frames … It never reorders, skips or alters the boundary sequence."
- Part I keeps: "Detection policy never depends on real-time pacing." T7 will subsume that sentence.
- About 15 words.

### §2.2

**P6. The per-step hook bullet, from "So there is no equivalent of `f_step!`, FlightCore's per-step hook" through "here that reset becomes an event on the touchdown edge".** This passage was suspected, and the suspicion is confirmed.
- Rules 4 and 1. It maps a legacy spelling onto this design, using FlightCore and Flight.jl cases.
- Destination: `companions/flight_case_studies.md` and §5.3 "Supervisory inputs".
- Status: duplicate.
  - The case-study table row says "`f_step!` quaternion renorm + engine-phase/stall-latch checks → `x_projection` hook + boundary-detected events".
  - Its §2 closing paragraph says "The landing gear's level-triggered cross-component reset (`!wow` re-initializing the friction regulator every step) becomes an edge-triggered event … a semantic tightening".
  - §5.3 states the touchdown edge and the `strut.wow → frc.reset` wiring. `migration_outline.md` and D-141 hold the migration.
- Part I keeps: "No unconditional per-step hook, because its semantics depend on the step size ([D-001]). Its uses decompose into projection and boundary-detected events. A level-triggered reset becomes an edge-triggered event, which tightens the semantics ([D-141])."
- §10.6 "Why the phase iterates" cites "[§2.2] … when killing `f_step!`". That clause reads as history, so §10.6 would need a light edit or nothing.
- About 60 words.

No other move in §2.2. §10.7 cites "deterministic replay ([§2.2])", so the replay guarantee and the RNG-in-`s` sentence must stay.

---

## Chapter 3

### §3.2

**P7. The letter paragraph: "**Each tier carries its own state letter** ([D-195]) … Those outputs are held zero-order between ticks ([D-019])."** This passage was suspected, and the suspicion is mostly refuted. *Borderline.*
- Most of the paragraph is law:
  - `x` is the flow map's argument and `s` the jump map's;
  - `x` has a derivative and `s` does not;
  - a leaf is strictly one tier;
  - no component reads another's state;
  - `s` influences the continuous dynamics only through signals held zero-order.
  These laws stay. "Lives in the flat buffer" and "latched in a store" are representation, which §7.1 and §7.3 state inside Part I anyway.
- Rule 4 applies only to the clause "Nothing is lost by splitting the letter, because …". It is an argument for a notation choice.
- Destination for that clause: the log.
- Status: duplicate. D-195's rationale says "a leaf is strictly one tier ([D-056]) and still implements exactly one name family".
- Part I keeps: the paragraph's laws. Dropping the "nothing is lost" framing is optional.
- About 20 words at most.

The "`m` is continuous-only" paragraph is a law with a short rationale. It is not flagged.

### §3.4

**P8. The opening paragraph ("This section asks why there are two leaf classes … They are ([D-056], [D-263])") and the argument paragraphs ("The settled rules force an all-in-one component's two halves …" and "The all-in-one component is therefore an assembly … The split keeps it a visible wire").** *Borderline.*
- Rule 4, because it argues against an alternative. Rule 1 also applies to the opening, which frames the question as declaration sets: "`x_deriv`, events *and* `s_update`", and "class … is already read off declaration shape ([§8.5])".
- Destination: the log (D-056) and §10.6 "Ticks after quiescence".
- Status: duplicate.
  - D-056's rejected item "All-in-one component kind" has the trench coat, communication through cells, one home per datum, no cross-tier state views, zero expressiveness gained, the enumerated costs and the hidden sampling seam.
  - §10.6 states the deferred decode in full: "`s⁺` is first decoded at the owner's next tick … no combined event/tick fixed point to iterate".
- Part I keeps:
  - the bolded law "The split is between *time bases*, not state classes", with the definitions of sweep and tick;
  - the verdict "an all-in-one leaf is an assembly of two primitives; it buys no expressiveness";
  - the sampling-interface sentence (ZOH plus `z⁻¹`, kept as a visible wire).
- **Rule-6 caution:** this paragraph is the only place in Part I that states the deferred-decode law. The law says a tick's `s⁺` is invisible within its boundary and first read at the owner's next tick, so ticks never trigger events. If the paragraph shrinks, that law must land in B4 or K5 (see PG2).
- It is borderline because the paragraph argues a Part I claim (the taxonomy) in Part I terms, much like M31, which the merged audit keeps.
- About 100 words if trimmed.

**P9. "The hardest case: integrate-and-dump", all of it.** This passage was suspected, and the suspicion is confirmed.
- Rule 4. It is a worked case study against an alternative, with domain math. Rule 5 also applies to "Under a `Dual` activation … the discrete tier is held ([§8.2])". That is law D3, stated here only through a forward citation.
- Destination: §8.6 "A worked assembly: the strapdown IMU" through "The boundary-sampling contract", and the log (D-056).
- Status: partial. §8.6 already has:
  - the reset elimination;
  - the cumulative integrals and the differencing sampler;
  - the exactness condition and its provisos;
  - the error model as a discrete sibling;
  - the latch-back wire.

  D-056 has the escape hatch ("Tick-triggered continuous handlers are the recorded, unbuilt escape hatch") and the linearization objection to discrete writes into `x` ("breaks held-`z` linearization exactness").

  Unique facts that would have to land in §8.6:
  - (a) The direct formulation as spelled: `ẋ.ϑ_c = ω_ic_c`, `ẋ.υ_c = f_c_c`, the coning increment `q_c_cc` and `ẋ.υ_c_sc = q_c_cc(f_c_c)`, read and zeroed at each sample. It also has the interval forms of those four quantities, with `q_c_cc` running from identity and the sculling rotation anchored at the interval start. §8.6 gives only the derived increments and names `q_c_cc` once.
  - (b) "The reset is periodic, not predicate-triggered, so events are the wrong mechanism." D-056 rejects time-guard events for a different reason (it hand-rolls the tick scheduler).
  - (c) "Less code than the direct formulation … the same thirteen integral scalars and the same math, minus the reset block." The count appears nowhere else.
  - (d) The three gains. The sampling interface becomes a wire, which D-056 partly covers. The truth/corrupted sample pair becomes separately loggable, which is unique. Linearization gets sane: "integrators that never reset *is* the cumulative formulation", which is unique in wording, and D-056 has the exactness objection.
  - (e) "No known case needs the escape hatch", and the condition for using it (interval-relative dynamics that neither factor algebraically nor tolerate the latch-back wire). D-056 has the hatch, but not the condition or the "no known case" claim.
- Part I keeps:
  1. The law that §5.3 ("only handlers write `x` ([§3.4])") and `flight_case_studies.md` (line 187) cite here: "An update writes only its own `s`, and handlers are the sole writers of continuous state, so a periodic reset of `x` has no spelling."
  2. A two-sentence summary: "Integrate-and-dump, the strongest challenge, factors exactly into cumulative integrals and a sampler that differences against its latch ([§8.6], [D-056]). A tick-triggered handler on continuous components stays a recorded guarded addition."
  The `Dual` sentence is left to D3 in §7.2.
- **Borderline:** whether the guarded-addition sentence stays. I recommend keeping it, as a scope statement like P3's.
- Back-pointers to retarget:
  - §5.3 "see the strapdown IMU example in [§3.4]" (it should point to §8.6);
  - §8.6 "The strapdown IMU of [§3.4] is spelled here in full" and "the idiom that answers integrate-and-dump ([§3.4])";
  - `flight_case_studies.md` line 16.
- About 370 words move, and about 60 stay.

---

## Chapter 4

### §4.1

**P10. The vocabulary block's staging-cell bullet: "A *staging cell* is a distinct compound term ([D-121]). It is the inbound register of [§11.4], one per device … outside the table's publish-once discipline."** The suspected passage is confirmed for this bullet only.
- Rule 1 and Rule 5. It defines a Part III mechanism and the term *device* in passing, and Part I never uses either again.
- Destination: §11.4 and the glossary (§D.6).
- Status: duplicate. The glossary says "the per-device atomic holding place … mutated frame by frame, hence outside the table's publish-once discipline … Not a table cell". §11.4 opens with the staging cell's role.
- Part I keeps: "**A bare *cell* is the table entry, and only that**" and the *store* bullet.
- The *root input* bullet is Part I material, because T3 and T4 rest on it, and it stays. The suspicion that the whole block defines Part III terms is refuted for the other three bullets.
- About 48 words.

**P11. Consequences of the signal requirement: "Concurrent reads from the GUI and logging threads are safe by construction" and "Isbits payloads allocate nothing, because NamedTuples of isbits are isbits."** *Borderline.*
- Rule 3 for the allocation line. The concurrency line is a Part III property.
- Destination: §11.1 and §9.7, if the lines move.
- Status: duplicate in substance (§11.1 "No shared mutable model", and §9.7 cell storage).
- Recommendation: keep both. They are one-line consequences that argue the law.
- About 25 words.

### §4.2

**P12. "A reader reaches a leaf inside a port value through the port's leaf address (the field name with dotted and bracketed steps below it, [§14.4], [D-276])."** *Borderline.*
- Rule 1. The parenthetical is address syntax.
- Destination: §14.4 "The read-selector family".
- Status: duplicate. §14.4 states the full leaf-address rule.
- Part I keeps: "A reader can reach any leaf inside a port value." §4.3's `"pose.q_eb"` example illustrates it.
- About 20 words.

**P13. "A stage result outside the contract is a build error (`UndeclaredReturnField`, [§8.3]). A presentational *unlisted* flag, skipped in logs and GUI but still connectable, is closed ([D-016], [D-034], [D-363])."**
- Rule 2 for the diagnostic. Rule 4 for the rejected flag.
- Destination: §8.3, Appendix C and the log.
- Status: duplicate. §8.3 says "A *returned port field* declared nowhere is a build error at probe". Appendix C has `UndeclaredReturnField`. §8.3's closing sentence names the `unlisted` flag among the log's rejections.
- Part I keeps: "There are no private intermediates. A value a later function needs is a declared port like any other."
- About 40 words.

### §4.3

**P14. "The port is the atomic unit of the entire periphery ([D-363]). It is each of the following" and its six bullets.** *Borderline.*
- Rules 1 and 5. Four of the six bullets name Part III mechanisms (staged write, device claim, trace address, GUI liveness verdict) and point to §11.3 and §11.7.
- Destination: the glossary *port* entry, or §11.1.
- Status: duplicate in the glossary ("one declared name, one cell, one root input, one staged write, one device claim, one trace address, one GUI liveness verdict"). No Part III section states it as one rule.
- Part I keeps: "The port is the unit of every external read and write." The write-side granularity rule rests on that sentence.
- About 40 words.

**P15. Scatter and gather: "Physically no such object exists. `y` is reconstructed per call from cells, as register-level field loads at zero cost for isbits, and is never stored as an object." and "Name collisions across a component's stages are a build error (`ProducedByTwoStages`, [§8.3])."**
- Rule 3 for the first sentence, the same kind of finding as M29. Rule 2 for the second.
- Destination: §9.7 "Views and construction" and "Cell storage", and §8.3 with Appendix C.
- Status: duplicate. §9.7 has rebuild-per-call views, and gathers that reconstruct through the leaf walk. §8.3 says "Declared-but-unproduced and produced-by-two-stages are build errors". Appendix C has the kind.
- Part I keeps: "Semantically, a component's `y` is the merge of its stage products. It carries declared ports only and exists as no stored object." It also keeps the one-producer law that "Granularity, read side" already states ("each port has exactly one producing function").
- About 40 words.

**P16. "`StopFlag` is the one enum with a framework meaning. An output port of that type is a stop request … and a `StopFlag` nested in a port of another type or declared as a root input is refused (`IllegalPortType`, [§13.5], [D-316])."** This passage was suspected, and the suspicion is confirmed for the refusal clause.
- Rule 2.
- Destination: §13.5 "Placement" and Appendix C `IllegalPortType`.
- Status: duplicate. §13.5 states both refusals with their reasons. Appendix C lists `:stop_flag_nested` and `:stop_flag_at_root`.
- Part I keeps: the definition, "an output port of the framework's stop type is a stop request, which ends the run when it reads requested, unless the advance ignores it". That is semantic, and T6 needs it. **Placement:** T6 lands in chapter 2, which would use the term before §4.3 defines it. The owner may prefer to move the definition into T6 and leave §4.3 the enum-is-one-pinned-leaf fact.
- About 35 words.

**P17. "**A `Symbol` is an opaque leaf too** ([D-243]). Julia classifies it mutable, but it is interned, immutable and never freed, the grounds on which [§7.3] admits it in a store."** *Borderline.*
- Rule 1. The middle sentence is a Julia-language detail.
- Destination: none needed.
- Status: duplicate inside Part I. §7.3 "Stores" says "It is interned, immutable and never freed … The table admits it on the same grounds, as an opaque leaf ([§4.3])".
- Part I keeps: "A `Symbol` is an opaque leaf too, so a `Symbol` mode publishes like any other." Trimming either copy is optional.
- About 25 words.

**P18. "**A mutable type anywhere in a port value is refused, and so is an opaque leaf surfacing as a root input**, which has no synthesis (`IllegalPortType`, [D-237])."** This passage was suspected, and the suspicion is confirmed with a caveat.
- Rule 2. Rule 5 also applies, because "which has no synthesis" makes sense only through §9.3's input synthesis.
- Destination: §8.2 "Input contracts" / "Output contracts", or §9.1's list of structure-step checks. Neither lists the port-type check today. Appendix C also applies.
- Status: partial. Appendix C `IllegalPortType` lists both offending types. Unique in the spec body:
  - the statement that the check exists, outside Appendix C;
  - the reason for the root-input refusal. D-237 gives two reasons: no synthesis and no producer; and the field-emitting component stays the one way bulk data enters a model.
- Part I keeps: the immutability law (§4.1 already states it). **Borderline:** keep one clause stating D-237's semantic reason, "bulk data enters a model only through a component that emits it, never as a root input" (see PG4).
- **Side observation, which I did not resolve:** §14.1 ("a rig where the handle itself is a root-input value") and §14.9 ("Leaving an environment face *unconnected* is legal by construction … an ordinary root input holding the handle **value**"), which trace to D-139, seem to conflict with this refusal (D-237) for bulk-data handles, because those are opaque leaves. They agree only if the rig handles are isbits, as `SimpleAtmosphere` and `HorizontalTerrain` presumably are. The owner may want to check.
- About 30 words.

**P19. "An unbundling component is a `y_direct` leaf that takes the bundle and publishes its fields. It is a candidate for the standard library of [§13.7]."** *Borderline.*
- Rule 1. It is a library candidate.
- Destination: `companions/library_inventory.md` or §13.7.
- Status: unique. Neither mentions an unbundling component.
- Part I keeps: "It destructures the bundle in its own stage or through an ordinary component that publishes its fields."
- About 25 words.

**P20. "`RQuat` is FlightPhysics' rotation quaternion. `RQuat{Float64}` is the spec's form of it, since FlightPhysics' `RQuat` takes no type parameter."** *Borderline.*
- Rule 1. It is a note on a domain type's spelling.
- Destination: §7.1, which introduces `RQuat` as a domain wrapper type with a `normalization` keyword.
- Status: unique. The "no type parameter" fact appears nowhere else.
- Part I keeps: nothing. The sketch reads with `RQuat` glossed as a rotation-quaternion type.
- About 25 words.

`ProducedByTwoStages`, `IllegalPortType` and the stop-request clause are covered by P15, P16 and P18. "Granularity, write side" is all law and is not flagged.

### §4.4

**P21. "Handles are rebuilt per evaluation without allocation, as immutable structs holding existing references. They are never `Ref`s, whose mutable box allocates."** The suspected passage is confirmed for this sentence.
- Rule 3 (allocation mechanics). Rule 1 also applies (`Ref`).
- Destination: §8.2 "Output contracts" (its handle paragraph, "A handle keeps its bulk at `Float64` …"), or §9.7 "Cell storage".
- Status: unique in the spec body. D-237's rationale has both points ("never a `Ref`" and "the allocation-free rebuild [§4.4] promises").
- Part I keeps: "The handle is an immutable struct combining isbits parameters with references to bulk data loaded at build time and frozen."
- About 30 words.

**P22. "Loggers treat field-handle signals specially. They skip or summarize them."**
- Rule 3. It is Part III export behavior.
- Destination: §11.2 "The log" or "Output-device bindings".
- Status: unique. No Part III section states the summarize-or-skip rule. §7.5 cites "The summarize-or-skip rule ([§4.4])", and §7.5 itself moves under M44.
- Part I keeps: nothing.
- About 10 words.

**P23. "The value-level constructor", all of it: the bolded obligation, the `SimpleAtmosphere` example, "The reason is script-side …", the bulk-data relaxation and the code sketch.** This passage was suspected, and the suspicion is confirmed.
- Rules 1 and 5. It is an authoring obligation on shipped components, and its reason is readable only through §14.1's condition math.
- Destination: §14.1 "Conditions are path-addressed overlays", which already uses the constructor ("There are two routes to that handle. One is the value-level constructor … [§4.4]"), or §8.2 as an authoring obligation. Appendix A calls itself "an index, not a second home" and names §4.4 as owner, so it cannot take the text.
- Status: unique in the spec body. Appendix A has a recall line, and the glossary has a definition. D-139 holds all of it in the log. Facts that must land:
  - the obligation: a plain, pure, public function from (component, input values) to the handle, with the swept stage a one-line call to it and never the reverse;
  - the reason: condition math builds a handle bit-for-bit equal to the sweep's, outside any sweep, from one implementation;
  - why only the shipped component's author can write it: the real component composes sub-models;
  - the bulk-data relaxation: the query math must be reachable, and the load cost is acceptable at design time;
  - the `atmospheric_field(atm; T_sl, p_sl, wind)` example and the code sketch.
- Part I keeps: a one-line pointer at most. A field handle is already a pure function of its emitter's inputs, because output stages are pure (§5.3).
- **Borderline:** whether the pointer stays.
- Back-pointers to retarget: Appendix A "The value-level constructor ([§4.4])", the glossary *value-level constructor*, §14.1 (line near "applied to the same values the `baseline` writes"), §14.7 (near "[value-level constructor] … [§4.4]"), and `trim_environment_walkthrough.md` lines 4 and 272. Its line 560 is a historical record.
- About 275 words move, and about 15 stay.

**P24. "Pre-sampling and substitutability": "Resource injection (declare-and-resolve service registries) is closed for the first cut"; "The field-handle mechanism replaces Flight.jl's threading of `atmosphere`/`terrain` … the query a terrain field handle's `ray_intersect` serves"; and "Substitutability behind a stable face … is declared with an abstract input entry … That preserves FlightPhysics' `AbstractTerrain` polymorphism at the declaration layer."**
- Rule 4 for the rejected alternative and the legacy comparison. Rule 1 for the declaration spelling of substitutability.
- Destination: the log (D-008), `flight_case_studies.md`, `trim_environment_walkthrough.md` and §8.2 "Input contracts".
- Status: duplicate.
  - D-008 rejects resource injection and pre-sampling as a mechanism.
  - The case-study table row says "`atmosphere`/`terrain` threaded as arguments through every signature → Field-handle signals through ordinary ports".
  - §8.2 says "**Abstract entries state structural substitutability** … The field handles ([§4.4]) are the demonstrated client, as in `terrain = AbstractTerrainField`".
  - `trim_environment_walkthrough.md` line 141 has "today's `AbstractTerrain` polymorphism moved to the declaration".
  - The only unique piece is the bounded ray query of Flight.jl's landing gear.
- Part I keeps: "Pre-sampling is an idiom built on top, not a separate mechanism", and "a consumer may accept any handle type below a declared bound, so environment models substitute behind a stable face".
- About 110 words.

The first two bullets of §4.4, the no-mutable-cache bullet and the "Ordinary ports carry them as immutable query objects" law are all fine.

---

## Rule-6 issues local to chapters 1 to 4

These are gaps the README's planned additions do not already cover.

**PG1. Discrete components carry no events and no projection.** *Borderline.*
- §3.2's facet list leaves out events and projection. Its "`g` already runs at the only instants at which anything may change" implies the law, but Part I never states it.
- §8.2 "Completeness" mechanizes it: "`m_init`, `state_events` and `x_projection` are continuous-only … `DeclarationOnWrongTier`".
- Place: §3.2, one clause, for example "A discrete component has no events and no projection. Its state changes only at its ticks."

**PG2. The deferred-decode law.**
- The law: a tick's `s⁺` is invisible to every reader within its boundary and is first read at the owner's next tick, so ticks never trigger events and the boundary iteration needs no combined fixed point.
- Today Part I states it only inside §3.4's argument (P8). §10.6 "Ticks after quiescence" mechanizes it.
- B4 places the updates after quiescence. K5 says "a tick's update is the outgoing transition". Neither says that `s⁺` is invisible until the next tick.
- Place: B4 or K5, one sentence. This is needed only if P8 trims §3.4.

**PG3. Bulk data enters a model only through a component that emits it.** *Borderline, tied to P18.*
- D-237 gives this as the semantic reason a handle cannot be a root input. Part I states the refusal only through the mechanism ("no synthesis").
- Place: §4.4, one clause. Check it first against the side observation in P18.

**PG4. Detection policy is inside the semantics.** *Borderline.*
- §2.1 closes with "Detection resolution is an execution-policy detail". §10.7 says "Detection policy is inside the semantics". The two are compatible only if "resolution" means something narrower than "policy", and a reader can take §2.1 to mean the policy does not change the trajectory.
- In fact a boundary-detected event fires at the end of its step, so its instant depends on `h`. §10.6 says so: "Boundary-detection timing remains h-dependent". The exception is a guard over `u` and `m` only, where boundary detection is exact (§10.4).
- Place: §2.1, one clause, for example "The choice of policy is part of the model. A boundary-detected event fires at grid resolution." T7's list of deployment parameters already implies this, so the change could be no more than a rewording of the §2.1 sentence.

I checked and did not count these as gaps, because Part I states them:
- edge semantics and the negated-guard convention (§2.1);
- modes change only through handlers (§3.1);
- a handler resets only its own component's `x` (§3.1);
- a commanded continuous reset is an event (§3.1);
- `m` is continuous-only (§3.2);
- port leaf vocabulary and opaque leaves (§4.3);
- frozen references in signals (§4.1);
- one producer per port (§4.3).

The opaque-leaf identity rule (G4 in `depth_ch05-07.md`) would land in §4.3's opaque-leaf paragraph if M23's material stays in §6.1.

---

## Planned additions targeting chapters 2 to 4: what the rewritten text already states

| Law | Status in chapters 1 to 4 | Where |
|---|---|---|
| T1 time grid | Partly. "Integrated on a fixed step" (§1) and "boundary (a published consistency point)" (§2.1). Missing: the grid `t₀ + k·h`; boundaries at grid points, at localized times and at `t₀`; the grid is never shifted; time is not state. | §1 Capabilities, §2.1 |
| T2 integration | Partly. "Fixed step" only. Missing: a one-step method chosen at deployment, advancing from each published boundary. | §1 |
| T3 inputs | Partly, and the current wording conflicts. §2's bullet says "The runtime injects them asynchronously … under the staging rules of [§11]". That reads as if a model's inputs change at any time. T3 says they change only at frame tops. §4.1 defines a root input as fed by the periphery. Missing: change only at frame tops; hold until written; newest wins; the only outside influence; control commands never change values. The "asynchronously" bullet should be reworded when T3 lands. | §2 intro, §4.1 |
| T4 what a run consists of | Not stated. | |
| T5 what a run publishes | Partly. A snapshot is defined in passing as "the immutable per-boundary publication" (§4.3), and a boundary as a published consistency point. Missing: one snapshot per completed boundary including `t₀` and `t*`, and that intermediates are never published. | §4.3, §2.1 |
| T6 termination | Partly. §4.3 defines a stop request ("a port that ends the run when it reads `STOP_REQUESTED`, unless the advance ignores it"). Missing: end time and grid rounding; read at every published boundary; the first honored request ends the run with no rollback; external stop at the next frame top. See P16 on where the definition lives. | §4.3 |
| T7 what fixes a trajectory | Partly. Bit-identical replay from an input trace (§1); pacing never affects detection (§2.1); RNG state in `s`, so the same seed gives a bit-identical trajectory (§2.2). Missing: the full list of what fixes a trajectory and what never changes it. | §1, §2.1, §2.2 |
| E1 even crossings | Not stated. | |
| E2 localized trigger and time | Partly. "The framework finds the crossing instant by root-finding" (§2.1), and the predicate definition E2 relies on. Missing: the trigger condition, the tolerance, "strictly after the step's start", and the grid-point case. | §2.1 |
| E3 state at `t*`, projection cancels | Not stated. §2 says projection runs "after each accepted step and after any handler reset of `x`", not at a `t*` boundary. | |
| E4 several localized events in one step | Not stated. | |
| E5 input-caused edges | Not stated. §2.1's "The handler fires at the end of the step in which the edge was observed" is the boundary-detected case only. | |
| K1 stateless discrete leaf | Not stated. §3.1's "Any facet may be empty" covers the continuous side only. | |
| K2 harmonic grid | Not stated. §3.2 says only "at a declared rate". | |
| K3 phase | Not stated. | |
| K4 rates declared in the enclosing assembly | Partly. §3.3 says assemblies are retained "as declaration-level rate scopes ([§10.5])". Missing: the relative and absolute forms and composition down the tree. | §3.3 |
| K5 a tick's update is the outgoing transition | Partly. §2 gives `s⁺ = g(s, u, t)`. §3.4's argument says "`s⁺` is decoded only at the owner's next tick, because `s_update` runs last". See PG2. | §2, §3.4 |

Planned additions for other chapters that chapters 1 to 4 already touch:
- **B1**: not stated here. That every prior starts not holding is in the glossary only.
- **B4**: partly stated, through §3.4's deferred-decode sentence (PG2).
- **D3**: partly stated, in §3.4 ("Under a `Dual` activation … the discrete tier is held ([§8.2])"). P9 would move that sentence, which leaves D3 to §7.2 as planned.

---

## Non-findings worth noting

- §1 in full. Purpose, Capabilities, Design criteria, Origins and Scope are introduction, and their forward citations are pointers. §1's "CI asserts it ([§7.5], [§9.7])" is a design criterion. Its §7.5 pointer is among the back-pointers M44 must repoint, as the README notes.
- §2's five-part system list, including the `x_projection` hook and "the cheap end of the projection-methods family". These are labels and short context.
- §2.1's time-event versus state-event paragraph, apart from P2(c). It is a classification law. `sample_times` and `StateEvent(guard, handler)` serve as labels.
- §2.2's DAE and SDE bullets, including the replay guarantee. §10.7 cites the replay guarantee.
- §3.1 in full, and §3.2's "`m` is continuous-only".
- §3.3. It is short, and its pointers are fine.
- §4.3 "Ports and faces" (the first paragraph), "Granularity, read side" (apart from P19) and "Granularity, write side". All are laws argued in Part I terms. The `Kinematics`/`Vehicle` sketch is a brief illustration.
- §4.4's "A field object must hold no mutable cache". It is a corollary of frozen references, and the glossary and §7.3 rely on it.

---

## Tally

| | count | words |
|---|---|---|
| Passages flagged (P2 to P24) | 23 | |
| Roadmap statement to restate, no move (P1) | 1 | |
| Whole passages marked borderline (P3, P5, P7, P8, P11, P12, P14, P17, P19, P20) | 10 | about 320 |
| Partial borderlines inside moving passages (P2(b) de-spelled law, P9 guarded-addition sentence, P16 definition placement, P18 bulk-data clause, P23 pointer) | 5 | |
| Passages that move (excluding whole borderlines) | 13 | about 1,100 |
| Pure duplicates (destination already states it all) | 7: P2, P4, P6, P10, P13, P15, P16 | about 280 |
| Carry unique content that must land first | 6: P9, P18, P21, P22, P23, P24 (P24's one unique piece is the gear ray query) | about 825 |
| Rule-6 gaps local to chapters 1 to 4 (PG1 to PG4) | 4, of which 3 are borderline | about 60 to add |

Part I would lose about 1,100 words from the roadmap and chapters 1 to 4, about 20% of their 5,400. That rises to about 1,420 if every borderline item moves. The README guessed 1,500 before this audit. The bulk is in two places: §3.4's integrate-and-dump case (about 370) and §4.4's value-level constructor (about 275). Next come §4.4's pre-sampling paragraph (about 110) and the §2.2 hook bullet (about 60). Of the whole borderlines, I recommend keeping P7, P8 (trimmed only if PG2 lands), P11 and P14 in reduced form, and moving P3, P5, P12, P17, P19 and P20.

Back-pointers that would need retargeting after the moves:
- §5.3 to §3.4 (the strapdown IMU example), which should point to §8.6;
- §8.6 to §3.4 (twice, "spelled here in full" and "the idiom that answers integrate-and-dump");
- `flight_case_studies.md` line 16 to §3.4's IMU;
- §8.2's `Engine` comment "detection policy by the guard's return type (§2.1)", if P2(b) moves;
- Appendix A, the glossary, §14.1, §14.7 and `trim_environment_walkthrough.md` to §4.4's value-level constructor (P23);
- §7.5 to §4.4's summarize-or-skip rule (P22), unless M44 moves §7.5 first.

These citations stay valid and need no change:
- §10.4 and §10.6 to §2.1 for the predicate definition;
- §10.7 to §2.2 for deterministic replay;
- §5.3 and `flight_case_studies.md` line 187 to §3.4 for "only handlers write `x`", provided P9's kept law stays in §3.4;
- §13.5 and Appendix C to §4.3 for the leaf vocabulary.

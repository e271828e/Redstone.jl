# Unit A rulings and findings

## Corrections proposed

Adopted by the coordinator, 2026-10-20, and applied in new.md: "Each item is
normative only where its owning section settles it", "(the next item)", "a
different sort of thing", and "where the reset command arrives as an
ordinary `Bool` input". The four bullets below that proposed them are kept
as the record.

- **Brief R2, "Stripping partials" row.** "§1 line 1399–1400" is in §5.3,
  "Supervisory inputs: scheduled gains and commanded resets" (frozen 1386 on),
  not §1. The sentence it names ("Linearization holds an unseeded gain root
  input constant and differentiates through a scheduled gain") was read as
  evidence only. The entry carries §14.10's scheduled-gain sentence (frozen
  12821–12824) and cites nothing from §5.3.
- **Reserved word "entry", bare, untouched sentences.** `# Appendices`: "Each
  entry is normative only where its owning section settles it." Same-tick
  reset consumption: "(next entry)". Both left as written, since neither
  sentence was otherwise touched. Proposed: "Each item is normative only
  where its owning section settles it." and "(the next item)".
- **Reserved word "kind", untouched sentence.** Binding traits:
  "`map_input`/`map_output` are a different kind of thing." Proposed: "are a
  different sort of thing".
- **Reserved word "condition", untouched sentence.** Continuous-tier resets:
  "where the condition arrives as an ordinary `Bool` input" uses condition in
  the trigger sense. Proposed: "where the reset command arrives as an
  ordinary `Bool` input".
- **"Taught contracts" and "semantic contracts"** use contract in the taught
  sense, not the declared-interface sense. The heading and the `# Appendices`
  sentence are kept (heading anchor `[sA]`; §14.5 and D-067 call interval
  alignment "a taught contract"). `[contract](#g-contract)` is linked only at
  its first declared-interface use, in "Contracts by type".
- **The startup hole.** §10.5 (frozen 6167) says "A device that is dark until
  its first tick". The entry says "a component dark until its first tick",
  so the word does not read as a periphery device, which the entry list
  links later. Same claim; the owner may prefer §10.5's own word changed the
  same way.
- **D-262 and the always-zero check.** §14.7 cites D-262 for "On a quantity
  the condition writes directly from a decision, a check compares the number
  with itself and is always zero". D-262 does not state it. It is a grounding
  consequence (base commit a3640c3), so the log owes nothing new, but the
  citation reads as D-262's ruling.

## Citations added or replaced

Owners parenthetical entries on old items, added so `check_unit.py`'s bold
rule passes, and kept by the coordinator's ruling of 2026-10-20. I checked
each against the frozen log. In every case the entry's Position carries the
contract, so none was swapped:

- The stage funnel, **D-341**: "The legal set narrows in three levels: stage
  name at its tier ⊇ bundle ⊇ destructured reads." (§5.2 cites it at frozen
  1141.)
- One home per datum, **D-035**: "the table holds produced signals only,
  never transported ones (one home per datum)". (§5.2 cites D-035 at 1838.)
- The value-level constructor, **D-139**: "Environment field handles get a
  value-level constructor … stated in §8.2 as a shipped component's
  obligation (Appendix A taught contract …), because only the component's
  author can write it".
- Boundary sampling, **D-056**: "Boundary-sampling semantics are promoted to
  taught contract." (§8.6 bolds it with D-056 at 3760.)
- Handler-phase visibility, **D-154**: "a component fires at most one event
  per round … a handler executes against exactly the world its guard fired
  on — own `y`, foreign `u` and own `x`/`m` are all the firing round's sweep".
- Stage totality, **D-142**: "stage code must be total over type-valid inputs
  … at runtime the identical throw is a `StepError` … Parameter validation …
  belongs … [in] the constructors of parameter and instance values".
- Stop-request sampling, **D-316**: "every request ends the run at the first
  publication where it holds, unless the advance ignores it"; "After every
  publication the loop scans the `StopFlag` cell block of the just-published
  snapshot."
- Levels, never deltas, **D-024**: "levels-never-deltas doctrine; mappings
  pure, on the device task". (§11.4 bolds it with D-024 at 7487.)
- The device loop idioms, **D-373**: "The two author obligations, the
  `running(handle)` predicate and interruptible blocking, are taught
  (Appendix A) and diagnosed (`DeviceJoinTimeout`, a stale heartbeat), never
  forced." and "`should_close` dissolves into the loop body returning".
- Bad datum vs. bug, **D-105**: "environmental garbage … is tolerated in the
  loop body (catch, stage nothing, `report(handle, MalformedDatum(cause))`,
  continue …), any other exception propagates to the wrapper as
  `DeviceCrash`".
- Derived liveness, **D-045**: "GUI liveness is fully derived"; "Unexported
  ports are unpokeable." Its 2026-10-13 annotation reads "slot unclaimed" as
  "slot inside the GUI's own claim", which is the wording A keeps.

Amendments (R3, R4) and the coordinator's amendment:

- Interval alignment, **D-067**: "a boundary's update is the *outgoing*
  transition … the update at `t₀` is the `t₀` sample's only chance".
  **D-273**: "The executor at rest has one reading for every discrete
  component: the store holds the state its next tick decodes, the cells hold
  the sample its last tick published." The one-tick-ahead copy is in its
  Rationale (below).
- Interval alignment, last sentence, **§12.6** and **D-429** (commit 4f922f7,
  per the coordinator's amendment): D-429 Position, "`overlay!(sim,
  condition)` writes a condition onto a stopped run and continues it as a
  fresh trajectory: the named stores are overwritten on the run's own … An
  overlaid discrete store is therefore the next tick's state"; §12.6 at
  4f922f7 line 9608, "It is the state what-if". The `[s12-6]` and `[d-429]`
  reference definitions exist at 4f922f7, not in the frozen copy, which has
  no `[d-429]`; assembly needs the 4f922f7 link block.
- Same-tick reset consumption, **D-089**: Rationale, "commanded resets are
  same-tick inputs consumed in the *output stage* with `g` storing the
  matching `z⁺` (Appendix A entry …)". §5.3 bolds it with D-089 and D-342.
- Continuous-tier resets, **D-141**: Position, "A continuous component's
  state reset is an event … Even a commanded continuous reset … is spelled as
  an event whose guard reads that input".
- Guard predicates, edges and priors, **D-365**: Position, "Boundary
  detection is exact for a guard whose value within a step depends only on
  modes, root inputs and held discrete outputs. A guard that reads an input
  fed … by continuous state or by time can cross inside a step". **§10.4**
  added (frozen 5740–5744). By the coordinator's ruling the release and
  latching facets moved to a new item right after it.
- Latching and release pairs (new item, coordinator's ruling), **§10.4**
  (frozen 5762–5779), **§10.6**. **D-290**: annotation 2026-10-07, "the gate
  form also serves a predicate that must exclude equality, gated on the
  strict comparison of a wired signal, `u < 0 ? -u : -one(u)`" (below).
  **D-181**: Position, "an event may fire up to `firing_budget` times per
  boundary … eligibility = intra-boundary not-holding → holding edge"; its
  Rationale has the exhaustion "under a `FiringBudget` warning naming the
  chatterer". §10.4's latching sentence cites §10.6 and D-181.
- `shutdown!`, **D-268**: amended bullets, "`shutdown!` may run more than
  once … 'close only what is open' makes a repeated call harmless" and
  "`shutdown!` may run on a device whose `init!` never began".
- The two observation sides, **D-414**: "Every service client resolves under
  that one walk: condition entries, trim reads, taps …"; "`:past_generic`
  retires … A deep path resolves wherever the structure has it"; "`get_face`
  remains the read for a consumer meant to outlive the build". **D-065**:
  only the standing half, Rejected "Machine-enforced ownership: not
  build-visible", as its 2026-10-13 and 2026-10-20 annotations keep it ("Its
  owned half is convention"). **§14.2** (frozen 11520–11527), **§14.7**
  (12091–12093).

New items (R2), owners as the brief names them:

- The startup hole, **D-205**: Position, "At boundary zero every discrete
  component's output stages run … publishing from the authored `s` … an
  offset component's first consumed sample stays its `Φ·Δt_base` tick's."
  The modeling-decision clause is Rationale (below).
- Undeclared modes, **D-345**: "During a run, `m` changes only through event
  handlers, at boundaries." **D-179**: "Detection policy is declared by the
  guard's return type". The §3.1 sentence (frozen 651–658) cites §2.3 and
  D-345 only.
- Never cache `Δt`, **D-019**: "`Δt` arrives as a discrete-bundle field …
  no stored `Δt`-derived parameters". **D-291**: "Anchoring leaves
  never-cache-`Δt` fully intact." The stable-at-every-period sentence is a
  grounding consequence citing both (frozen 6390–6393); neither states it.
- No mutable cache in a field handle, **D-344**: "A field handle holds no
  mutable cache … The build does not look inside a handle, so the rule is
  the author's obligation"; "any data it references is frozen for the
  duration of the run".
- Contracts by type, **D-297**: "A leaf's contract declarations are
  functions of the component's type, type parameters included, never of its
  field values … `ws_init` is exempt … The rule is one authors keep, not a
  check the build can run."
- Deliberate stripping, **D-266**: "A walking producer feeds a pinned entry
  through the `Freeze{V}` library block … the wire then declares a zero
  coupling in every Jacobian along that path"; "A component that must
  participate … keeps its entry tolerant and supplies its own local
  derivative inside the stage". The scheduled-gain sentence is §14.10's
  grounding sentence, which cites §13.7 and D-266.
- The unit delay's tier caveat, **D-348**: "A unit delay is a modeling
  decision, not a transparent wire. In a continuous loop it moves the broken
  signal onto the discrete tier with a `Δt_base`-scale zero-order hold, and
  every place that recommends it says so, the cycle diagnostic included."
- Unwired contributors, **D-084**: "No unconnected-output warning".
  **D-323**: "Every contribution a total includes is a declared wire."
  **D-037** (coordinator's ruling): Position, "Aggregation by explicit
  summing junctions … fold order author-visible". §6.2 bolds fold order with
  D-037.
- Publications, not frames, **D-028**: "monotonic boundary counter …
  newest-wins, no queues". **D-230**: "A snapshot's boundary index is the
  trajectory's published-boundary ordinal … a new trajectory restarts it. The
  §12.3 wait counter is a separate, monotone count that is never reset, its
  absolute value nowhere normative."
- Conditioning upstream, **D-045**: "Faces carry writer-independent
  post-conditioning semantics, the GUI-parity test"; "Mappings are
  declarative binding data with per-axis conditioning params". The
  must-not-ride-along clause is its Rejected "Shaping as per-device mapping
  code" (below).
- Post-commit trim checks, **D-262**: "The service never solves them. It
  evaluates them once, at the committed state". **D-139**: Rationale (below).
  **D-417**: "A trim problem never authors the environment … the problem
  receives the environment and never writes it."
- The held discrete tier, **D-213**: "A service's seeded scratch set takes
  its frozen discrete cells from a nominal scratch set on which the composite
  condition has been applied … copied as zero-partial constants". **D-063**:
  overlay clauses, which its 2026-10-20 annotation keeps, "sparse overlays …
  on the declared `init_*` defaults".
- What-if replay from `init!`, **D-274**: "The parametric what-if of §12.7
  is spelled as `init!` of the modified model under the authored condition …
  The trace is no longer self-sufficient for it: the authored condition comes
  from outside." The structural/parametric sentence cites D-101 and D-391 in
  §12.7; A cites neither, per the brief's owners.

Added after the verifier's fix list (coordinator's rulings, 2026-10-20):

- What-if replay from `init!`, **D-391**: Position, "A structural mismatch is
  an error. A parametric difference is the what-if replay, which promises
  determinism, and reproduction only against the identical build." D-101's
  Position does not carry the sentence, so it is not cited.
- The held discrete tier, **D-072**: Position, "unseeded states stay
  constant, the discrete tier frozen-exact". **D-073**: Position,
  "sampled-data Dual activation recorded unbuilt (§14.10)", which carries the
  item's "recorded, not built" clause. Both Positions use old vocabulary
  (`slot`, `capture`). A cites them only for these clauses.
- Binding traits and mappings: owners punctuation corrected to
  `([§11.6][s11-6]; [D-382][d-382])`, citations unchanged.

## Rationale-only rulings

- D-205, Rationale: "a modeled startup hole (a device dark until its first
  tick) is a modeling decision for a validity flag or mode, never a framework
  default drawn from build plumbing" (decisions.md, D-205 Rationale).
- D-089, Rationale: the same-tick reset consumed in the output stage. §5.3
  also cites D-342.
- D-273, Rationale: "`init!` from the capture treated `s_{k+1}` as an
  authored state … the resumed trajectory stayed one tick ahead".
- D-290, annotation 2026-10-07: the strict-comparison gate.
- D-181, Rationale: the `FiringBudget` warning on exhaustion.
- D-045, Rejected: "Shaping as per-device mapping code: aircraft semantics
  duplicated per device".
- D-139, Rationale: "under elimination a params-vs-world handle mismatch
  converges to a *true* equilibrium at an *unintended operating point*".
- D-065, Rejected list and annotations: ownership as convention.

## Bold on the same entry elsewhere

None. A's only bolds are item labels, which state no ruling, so no ruling
is bold here and in an owning section at once. A is the only unit.

## Inbound citations affected

None (R7). `[sA]` still resolves to the unchanged heading, and no `####`
anchors exist or were added.

## Open questions

None open. The coordinator ruled on the five raised earlier, 2026-10-20:

1. The eleven added owner citations stay (listed above).
2. D-181 is added, on the new "Latching and release pairs" item.
3. D-037 is added to "Unwired contributors".
4. "Guard predicates, edges and priors" is split. The new "Latching and
   release pairs" item runs about 85 words. The original item runs 137 body
   words after I tightened the exactness sentences. Its old claims alone come
   to about 110 words, so it cannot reach 120 without dropping an old claim
   or moving the exactness narrowing out. "Continuous-tier resets",
   "Interval alignment" and "The two observation sides" stand near 145 by
   the ruling.
5. "A continuation is a restore" stays out. Linkify supplies the `[d-429]`
   definition at landing.

Verifier fixes applied (units/A/verify.md): V86, V93, V94, V147, V199, V218,
V221, V222 and V59 reworded as the fix list gives them. The two ruling-sentence
labels became "What `shutdown!` tolerates" and "Binding traits and mappings",
and each old sentence now opens its item's body. Added first-use links for
port, quiescence and `t*` (`#g-t`).

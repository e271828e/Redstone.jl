# Unit G rulings: §13.7 and §13.8

Line numbers are old spec lines at `1fee0fc`; log lines are the frozen
`scratch_survey/h2/decisions.md`.

## Corrections proposed

1. **"The substitutability contract" and "a root contract"** (10993, 11001).
   Both use *contract*, reserved for a component's declared interface, in
   another sense: the first is D-120's phrase for an abstract entry's
   substitutability, the second the rig's root faces. I left both untouched,
   since no ruling covers them. Proposed: "It is structural substitutability
   doing its job" (the glossary's words for an abstract entry, 13689) and
   "the rig mounts one component behind its own root faces".
2. **"Tracing improves error messages and verification"** (11009–11010,
   row 671). No entry states it, and "verification" names nothing §13.8
   describes. Kept. Proposed: "Tracing improves error messages", or name the
   verification meant.
3. **The glossary's feedthrough-tracer entry** (14695–14698) says "local primal-carrying at sampled states" for the mode F63 now calls
   the sampled mode. Track 2: "global value-blind, or sampled
   primal-carrying".
4. **First-use links left without a parenthesized gloss.** *projections* in
   §13.8 (its sentence already carries the guard's gloss, and one
   parenthetical is the limit), *pinned* (`#g-walked`) in §13.7 (inside a
   bold headline; the next three sentences say what the pin means), and
   *component test rig* and `design_world`, which their own paragraphs define
   in the next sentences.

- After verification: R28 applied corrections 1 ("structural substitutability
  doing its job", "behind its own root faces"), kept correction 2 as written,
  and sent correction 3 to track 2.

## Citations added or replaced

- D-257 at "`show(::Structure)` owes face routes" (10755). Bullet 3,
  amended 2026-09-30: "the printer is built ... `show(::Structure)` prints
  the root's routes one line per chain". Needed for the bold, which had no
  citation in its sentence.
- D-322 at the auto-bubbling gloss (R10). Bullet 1: "An unconnected input
  is never bubbled up automatically. Auto-bubbling would promote a forgotten
  wire silently to a live root input."
- D-143 at "`Constant{V}` is the source block" (10778 and 10898). Position:
  "The component library gains a source block, `Constant{V}` ... no inputs,
  no state ... the value itself held by the instance, and a stage-1 body
  returning it".
- D-143 at "No discrete variant is needed" (10912). Position: "§13.7's
  existing tier-transparency argument ... already covers discrete consumers —
  no discrete variant."
- D-143 at "The block's value is instance data, like junction arity, not an
  overridable default" (10952). Clarification (ii): "the value is instance
  data, not an overridable default — like junction arity it is baked into
  the instance".
- D-143 at the stub child as the source block's first shipped instance
  (10988–10989). Rationale only; see below.
- D-313 at F60's sentence, "though a listed block needs none to be built".
  Position: "A listed block is built whenever wanted, with no demonstrating
  model required."
- D-237 and D-364 with §14.9 at F61's added sentence, as R27 words it and R30 narrows
  its first clause.
  D-237's Position: "and so is a handle-typed face surfacing as a root
  input"; D-364's: "A handle that references bulk data enters the rig through
  a constant source holding it, never as a root input".
- D-143 at "Two uses need `Constant`" (verifier's V91). Rationale only; see
  below.
- §6.2 at the `VehicleWrenchSum` example, pointing to `Systems`, whose
  children `aero`, `pwp` and `ldg` §6.2 introduces (spec 1655–1657).
- D-062 at "library blocks are ordinary components" (10806). Bullet 3: "A
  standard component library ... ships as ordinary components". R5's bold.
- D-062 at "Tier-transparency falls out of settled semantics" (10865).
  Bullet 3: "stateless-continuous hence tier-transparent"; the 2026-10-12
  annotation: "tier transparency stand[s]".
- D-062 at the opening's three commitments (F58, dictated). Position: "Three
  tooling commitments are made".
- D-263 at the junction's contracts written at nominal and retyped (10843).
  Position: "Every contract declaration ... is written at nominal `Float64`,
  and is retyped by the framework"; bullet 1, "the leaf walk ... is applied
  to the declared types".
- D-266 at `Freeze{V}` as the declared stop-gradient (10924) and at the zero
  coupling (10941). Bullet 2: "A walking producer feeds a pinned entry
  through the `Freeze{V}` library block ... the wire then declares a zero
  coupling in every Jacobian along that path."
- D-120 at "The rig therefore satisfies that entry *inside* the rig" (10972)
  and at "The rig adds zero new machinery" (10992). Position: "A component
  with abstract input entries is rigged with a concrete stub child ... wired
  to the abstract face ... zero new machinery".
- Appendix C at `AbstractAtRoot` (F62, R14). §8.2 moves out of the example's
  parentheses to sit with the rule.
- D-005 at "The build rejects an algebraic loop" (11008). Position: "Reject
  algebraic loops at build".
- D-140 at "an artificial one gets the remedy ladder" (11015). Position:
  "§5.4's escape hatch becomes a three-rung remedy ladder for artificial
  loops".
- §9.1 at "the nominal evaluation" (11024), R12.
- Moved, not added: D-012 at the per-member variant now ends its sentence
  (F63); D-266 at the inventory's `Freeze` line stays; §13.5 and D-316 at the
  stop-request gloss now follow its parentheses.
- Considered and not added: D-264 at row 632 ("Walking, frozen and
  root-input contributors are all admissible"), which part E lists. D-264's
  Position admits a frozen producer "of an opaque leaf" only, so it does not
  carry a `Wrench` entry. D-348 at row 611, whose bullet is the caveat, not
  the spelling.

## Rationale-only rulings

- D-143 Rationale (log 5208–5212): the rig stub is "typically just a
  `Constant` holding the test handle — the block's first shipped instance"
  (10988–10989). Newly cited.
- D-143 Rationale (log 5213–5214): the two uses, "the dry run demonstrated the
  need twice, at the zero-contributor totals and at the rig". Now cited
  at the count; D-313 carries the second clause.
- Carried, already cited or adjacent, unchanged by the rewrite: D-062
  Rejected (log 1992–1996) for "cheap" (row 609), the toolbox (row 617) and
  the torture test (row 623); D-313 Rationale for "weighed" and the gain
  (rows 615, 617); D-184 Rationale for the model assembler (row 621); D-311
  Rationale for the gate's consumer (row 626); D-312 Rationale and its
  2026-10-06 annotation for the honest pin and the other pinned blocks (rows
  647–648); D-266 Rationale for `Freeze`'s cost and the sampler (rows 651,
  654); D-120 Rejected for the no-framework-support charter (row 668); D-012
  Rejected for the residue and the back edge (row 681); D-349 Rationale for
  interpolation (row 689); D-245 Rationale for the simple-cycle reduction and
  the weighed dead hop (rows 696, 704).

## Bold on the same entry elsewhere

- D-012: §5.5 bolds "Tracing is diagnostic only" (1507), its first chained
  ruling; §13.8 states it plain. §13.8 bolds the SCC ruling (11027) and the
  discrete members (11111). By R20, "conservative on discrete members (…),
  classification optional on the error" is one comma-joined ruling, so
  "Classification is a bonus on the cycle error" stays plain with D-012.
- D-120: bold nowhere else. By R21, §13.7 bolds the stub-child clause, "A
  concrete stub child … is wired to the face", with D-120 in its sentence.
- D-037: §6.2 bolds three of its rulings (1639, 1685, 1694). §13.7 bolds the
  helper sugar, a different ruling, and cites D-037 beside D-323 at the
  bundled-struct bold, which is D-323 bullet 3's.
- D-257: §9.2 bolds bullet 1, "Each artifact renders itself through `show`"
  (4513). §13.7 states it plain (R4) and bolds bullet 3, the face routes,
  which §9.2 states plain with a pointer here.
- D-343: no bold elsewhere. §13.8 now bolds bullets 5, 8 and 9. Bullet 5's
  "offers both exits" (11126) stays plain beside the bold on "only for
  continuous members".
- D-316: unit F bolds "The library spelling is `StopRequest`" (bullet 5).
  §13.7's `StopRequest` sentence is plain.
- D-143 (§6.2, two bolds), D-208 (§8.2), D-184 (§8.5), D-251 (§8.8), D-266
  (§8.2), D-348 (§5.5), D-140 (§5.4), D-364 (§14.9), D-005 (§5.5), D-263
  (§8.2): each is bold elsewhere and plain here.
- D-311: bold only here; §6.2 states it plain at `1fee0fc`.

## Inbound citations affected

- `extensions.md` 346, `migration_outline.md` 20, spec 3326 (§8.5): "§13.7's
  starting inventory" and `Group` "its one persona-admitted member". Both
  phrases survive ("The starting inventory", "admitted by persona").
- `library_inventory.md` 21–22: "Simulink's library is a language, while
  this is a toolbox" survives verbatim.
- spec 4520 (§9.2), `implementation.md` 60, 769, 779: the face routes, one
  line per chain and one per consumer, survive.
- spec 3057, 3066 (§8.2): the tier-transparency argument survives.
- `pid_anti_windup.md` 83–84: `UnitDelay` as the shape of the
  previous-saturation port survives, now with a pointer back.
- spec 4793–4797 (§9.4): calls the classifier "the other tracer variant" that
  "traces each member of a cycle locally". It holds; §13.8 now names it the
  per-member (local) variant.
- log 9663 (D-245 Rejected), 14764 (D-349 Rationale): "the sampled miss
  §13.8 documents" holds; the mode is now named the sampled mode.
- log 5212–5214 (D-143 Rationale): "§13.7's strictly from demonstrated need
  charter" no longer has a referent (F60); it was stale before. Track 2.
- Appendix C 13327–13329 (`AbstractAtRoot`'s remedy hint cites §13.7): the
  kind is now named there.

## Open questions

None. The step-3 questions were ruled as R20 (D-012's one bold) and R21
(D-120's bold on the stub child).

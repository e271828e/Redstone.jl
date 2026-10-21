# Review findings, as ruled by the orchestrator

Two cold reviewers checked the pass against `3685f92`. Reviewer A checked for
lost content and found none. Reviewer B checked the added laws, the depth rule
and style. Every finding below is ruled "fix" unless it says otherwise. Line
numbers are approximate; locate by the quoted text.

## Reviewer B: Part I laws, depth rule, style

- **B1. §2.4 "What fixes a trajectory".** "Nothing else changes a trajectory"
  contradicts the subsection's own optimization-level sentence, and "build"
  means both the compiled code and the `Build` artifact. Open with "Under one
  compiled build, …" or equivalent, and say "identical compiled code" where
  that is meant (D-101, D-289).
- **B2. Same list.** Add the origin `t₀` to what fixes a trajectory (D-067,
  D-274). §2.1 says time is not state, so "initial state" excludes it.
- **B3. §2.1 vs the chapter 7 intro.** §2.1 says "Time is not state", while
  chapter 7's intro lists the clock in a run's full state. Make §2.1 say time
  is not model state (no store holds it, no condition sets it), or name the
  chapter 7 notion "the run's state". Keep both claims true (D-067, D-274).
- **B4. §2.4 "How a run starts".** Add that a run may instead resume from a
  checkpoint, starting from its state and clock with no boundary zero
  (D-274, §12.6).
- **B5. §2.3 interpolant gloss.** "the dense output the step's method
  provides" misstates D-018. Use "a continuous extension built from the
  step's end values and derivatives (D-018)".
- **B6. §7.2.** "a plain value means no seeded direction reached it, and its
  true derivative is zero" ignores deliberate stripping. Add "unless the
  author strips partials deliberately (§9.5, D-286)".
- **B7. §2.3 epoch-caused edge.** Add the condition that the predicate still
  holds at the step's end (§10.4, D-182).
- **B8. §3.2 stateless discrete leaf and the tick definition.** Outputs are
  also computed at boundary zero for every discrete component (§5.3, D-205).
  Say "at its ticks and at boundary zero", and fix the tick gloss if needed.
- **B9. §4.4 bulk-data bullet.** Scope it to signals: bulk data reaches a
  signal only through a component that emits its handle (D-237, D-364). Table
  data and instance data stay as §7.2 and §7.3 say.
- **B10. §2 intro bullet.** "change only at the start of a step" → "change
  only at frame tops" (a remainder step starts at `t*`).
- **B11. §2.4 "How a run ends".** "in one of three ways" claims a complete
  list; a run can also fail. Say "A run that does not fail ends …" or point
  to §13.6.
- **B12. Frame top and boundary zero.** §10.1 says boundary zero is not a
  frame top. Make §2.1 list "every grid point after `t₀`" and say the
  boundary at `t₀` is boundary zero, followed by frame 1's top. Check that
  §2.4's publication sentence and §3.2's "ticks fall only at frame tops"
  read consistently with that (D-230, D-205).
- **B13.** No change.
- **B14. §5.3.** Add D-020 to "Only then does every due update run …".
- **B15. Missing law, §2.2.** At a grid point the boundary that ends a frame
  completes and publishes before the drain that opens the next frame. A tick
  at that instant samples the inputs the ending frame held, and a staged
  value first reaches the model in the next step (§10.1, D-182). Check the
  sources before writing.
- **B16. §7.2 trim sentence.** Add that a converged trim commits its solution
  as a condition through boundary zero, which starts a run (§14.8, D-067,
  D-068).
- **B17. §2.4 stop request.** Drop the enum and value spellings: a stop
  request is an output port of a framework type whose value can request a
  stop (§4.3 keeps the type's name as a label, §13.5 the spelling).
- **B18. §5.2.** "the names-subset predicate applies" → "a present `m` names
  a subset of the component's mode fields, at their declared types".
- **B19. §2.3 and §2.4.** Drop "trial evaluations" from Part I: keep the law
  that projection applies only at the `t*` boundary, and say "the evaluations
  root-finding makes inside a step" where needed.
- **B20. Mechanism remnants.** §5.1's "hot loop runs a flat list … no runtime
  graph logic (D-086)"; §5.3's "no incremental `x_deriv`-only re-evaluation"
  and "the continuous-only variant of §10.5"; §7.3's "No poisoning of scratch
  is attempted". Keep each law (static order computed once; discrete cells
  hold across a step; the workspace carries nothing between calls) and move
  or point the mechanism to §9.7, §10.5 and §8.2. Check that §9.7's citation
  of §5.1's "zero runtime graph logic" still resolves to a statement.
- **B21. Flight.jl material.** §6.2's FlightPhysics generated functions, tree
  walk, `Vehicle{NoVehicleSystems}` and "as in Flight.jl", and §7.1's
  `f_ode!` comparison, move to `companions/flight_case_studies.md`; §6.2
  states the zero-contributor case abstractly. §7.1's `RQuat` example stays
  as a brief illustration.
- **B22. §3.4.** "has no spelling" → "No construct expresses that periodic
  reset of `x`."
- **B23. Used before defined.** Gloss at first use: the event iteration and
  its rounds (§2.3, §2.4), the base tick period (§2.4), "caching inside the
  build" (§2.4).
- **B24. §2.4.** "Values computed inside a step are never published" →
  "Intermediate values are never published", since event rounds run at a
  boundary.
- **B25. §2.4.** Split the garden-path sentence ending "all leave it
  bit-identical".
- **B26. Roadmap.** §5's summary gains the boundary sequence, the firing rule
  and boundary zero; §7's gains the run's full state, numeric genericity and
  what trim and linearization compute.
- **B27. §2.3 structure.** About 700 words without subheadings: add two topic
  subheadings or a sentence naming its parts.
- **B28. One burden per sentence.** Split §3.2's base-tick sentence, §5.3's
  "No guard can see it, so …" sentence, and §7.2's trim sentence.
- **B29. Glosses.** Add 5 to 10 word glosses at first use: §2.3 guard, §2.4
  port, §3.2 ticks (the new paragraph), §2.5 component. Reword §4.4's "A
  script calls it to build the sweep's handle outside any sweep" to "to
  build, outside any sweep, the same handle the sweep would produce".

## Reviewer A: citations and back-pointers

- **A1. decisions.md, D-141's annotation.** "§2.5 now states the gear's
  touchdown edge" → §5.3.
- **A2. Position prose naming sections that no longer hold the ruling.**
  Update the citation, and the Spec field where it lags:
  - "Six state and genericity rulings that §7.1, §7.2 and §7.3 state" →
    match its Spec field (§7.1, §7.3, §8.2, §9.7).
  - "Three connection rulings that §6.1 states" → §6.1, §8.2 and §8.8.
  - "Seven hand-off rulings that §5.2 states" → §5.2, §8.2, §9.5 and §13.2;
    Spec gains §9.5.
  - D-342 "Seven stage-role rulings that §5.3 states" → add §8.1 to Position
    and Spec.
  - "Two rulings … that §6.1 states" (decided at the root build) → §6.1 and
    §9.1.
  - D-323 "Three aggregation rulings that §6.2 states": bullet 3 (no bundled
    contribution struct) has no spec home now. Land one sentence in §13.7's
    junction material stating it (D-323, D-037), and make the Position name
    §6.2 and §13.7.
  - The 2026-10-12 annotation citing §6.1 for `PathResolution` → §13.3 and
    Appendix C.
  - "Type stability under `Dual` is an authoring rule (§7.2)" → §8.2.
- **A3. spec.md.** Glossary *function family*: `BundleFieldError` (§5.2) →
  §13.2. §13.7's "`terrain = AbstractTerrainField`, §4.4" → §8.2. §8.3's
  "the cost is stated where it bites (§5.4, D-343)" → reword, since §8.3 now
  states the cost.
- **A4. Kinds named only in Appendix C.** Name `UnknownPort`,
  `IllegalStateLeaf` and `IllegalStoreField` in §9.1 where those checks run,
  and `PathResolution` in §13.3's one-level sentence. Add §9.1 or §13.3 to the
  four Appendix C entries' citations. Also check the other Appendix C entries
  whose Part I citation no longer names the kind, and add the section that
  does where one exists.
- **A5.** Orchestrator's, not the fixer's.
- **A6. Spec fields.** D-348 gains §13.8. D-267 and D-279 drop §7.4 if the
  new §7.4 holds nothing they rule.
- **A7.** No change; the log holds both.
- **A8. D-364 consistency.** §14.1's "a rig where the handle itself is a
  root-input value" → an isbits handle, or name the constant-source route.
  The same qualifier in `trim_environment_walkthrough.md` (around lines 300
  and 525) and `flight_case_studies.md` (around line 418).

## Not for the fixer

§10.4 and D-290 claim boundary detection is exact for a guard reading only
`u` and `m`. That holds for root inputs and held discrete outputs, not for
inputs wired from continuous producers. It is a design finding for the
owner, outside this pass.

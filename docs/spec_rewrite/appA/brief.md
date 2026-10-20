# Appendix A: the rewrite brief

One unit, A, rewritten by one agent and verified blind by another, as
`appendices.md` plans. The chapter recipe's standing part,
`checks/brief_common.md`, applies with the deviations listed below.

## Base and files

- Base commit `a3640c3`, which landed the eight grounding sentences the
  harvest asked for. Frozen copies, read these and never the working tree:
  `<S>/frozen/spec.md`, `<S>/frozen/decisions.md` and the heading outline
  `<S>/frozen/spec_outline.txt`, where `<S>` is the scratchpad directory the
  launch prompt names.
- `units/A/old.md` is frozen spec lines 12979 to 13134: the `# Appendices`
  lead paragraph, Appendix A whole, and the closing `---` rule. `new.md`
  replaces exactly that span, rule included.
- The survey's role is played by `candidates.md` (the merged list and the
  owner's rulings of 2026-10-20) and `harvest_1.md`, `harvest_2.md`,
  `harvest_3.md` (the evidence, one block per candidate, with the spec
  sentence quoted). The harvests' line numbers refer to an older spec
  (`e2b7393`); re-find each sentence in this brief's frozen copy by phrase.
  The grounding sentences below did not exist when the harvests ran.
- Tools: `python3 checks/check_unit.py appA show-old A`,
  `python3 checks/build_inventory.py appA A`, run from `docs/spec_rewrite`.

## Deviations from the standing brief

- **A is an index, and its entries keep a bold lead-in as their label**,
  as Appendix C bolds its kinds. The lead-in is a topic label of two to six
  words, never a sentence that states a ruling. Nothing else in A is bold:
  the rulings are bold in their owning sections, and A cites them in the
  owners parenthetical. `check_bold.jl` does not scan the appendices, so
  the label bold is legal there.
- **The owners parenthetical** follows the lead-in: the owning section or
  sections, then a semicolon and the entry or entries that rule the
  contract, in linkified spelling, as
  `([§10.5][s10-5]; [D-019][d-019], [D-291][d-291])`. Read each entry
  before citing it. Every old entry keeps its citations; the amendments add
  the ones this brief names.
- **Glossary links**: A is one section, so each glossary term takes one
  inline link at its first use in A, `[prior](#g-prior)`, with the gloss
  only where the entry's own words do not already say what the term is. The
  old A has no links; add the first-use links for the terms the new text
  uses. Link only anchors that exist: Appendix D (frozen line 14055 on)
  declares them, and §10.1 shows the linking form.
- **No survey slices, no `####` labels, no moves.** The unit has no
  subheadings; its parts are the lead paragraph and the three group lists.
- **Names.** An entry names API functions and library blocks the spec names
  (`Freeze`, `UnitDelay`, `init!`, `replay!`, `checks`, `get_state`), and
  keeps the names old A uses. It names no example model, aircraft or
  controller cascade, and no companion-only name: describe the shape ("a
  latched limit", "a cascade of discrete controllers").
- **Length.** An entry runs 40 to 120 words. The old entries keep every
  claim (content preservation), the Simulink and Modelica comparison
  included. A new entry makes no claim its cited spec sentences do not make:
  check each sentence you write against the frozen spec, and let only the
  part the spec states in. The harvests' "Goes wrong without it" lines are
  evidence; a consequence enters only where the spec states it or it follows
  from the cited sentence by nothing more than reading it.

## Rulings

**R1. Three groups.** "For component authors:", "For periphery authors and
consumers:" and, new, "For service users:", the people who write conditions,
trim problems, taps and linearization calls. The lead paragraph widens "an
author" to name the third audience and keeps its other claims. The
`# Appendices` paragraph above it changes only if a claim needs it.

**R2. Thirteen new entries.** Each row names the group, the lead-in (yours
to improve, within the label rule), the owning sections and ruling entries,
the frozen lines of the spec sentences, and the harvest block with the
evidence. Component authors, in the order they appear in the list after R6:

| lead-in | owners | frozen spec lines | evidence |
|---|---|---|---|
| Undeclared modes | §3.1, §2.3; D-345, D-179 | 651–658 (the grounding sentence) | harvest 2 "No home" first bullet |
| The startup hole | §10.5, §14.5; D-205 | 6167–6169, and 6160–6166 above it | harvest 1 "No home" second bullet |
| Never cache `Δt` | §10.5; D-019, D-291 | 6385–6393 (the rule, and the stable-at-every-period sentence that joins this entry) | harvest 1 and 2, first candidates |
| No mutable cache in a field handle | §4.4, §4.1; D-344 | 991–995, and §4.1's "read-only for the duration of the run" | harvest 3, first candidate |
| Contracts follow the type | §8.1, §9.7; D-297 | §8.1's "determined by the component's type" paragraph and its "a rule authors keep" sentence | harvest 1, fifth candidate |
| Stripping partials declares a zero coupling | §13.7, §14.10, §9.5; D-266 | 11092–11098, 12821–12824 (the scheduled-gain sentence that joins this entry), and §1 line 1399–1400 | harvest 2, fifth candidate; harvest 2 "No home" fourth bullet |
| A unit delay is a modeling decision | §5.5, §13.7; D-348 | 11032–11034 | harvest 2, sixth candidate |
| An unwired contributor drops out | §6.2; D-084, D-323 | 1685–1686 and the slot-order sentence after it | harvest 1, sixth candidate |

Periphery authors and consumers:

| lead-in | owners | frozen spec lines | evidence |
|---|---|---|---|
| Boundaries are publications, not frames | §12.3, §10.4; D-028, D-230 | §12.3's "published boundaries" paragraph and the counter's "nowhere normative" sentence; grep `published boundaries` | harvest 3, second candidate |
| Conditioning upstream, aircraft semantics in-model | §11.4; D-045 | 7501 and the "post-conditioning semantics" and "must not ride along" sentences near it | harvest 3, third candidate |

Service users:

| lead-in | owners | frozen spec lines | evidence |
|---|---|---|---|
| Trim checks see what residuals cannot | §14.7, §14.9; D-262, D-139, D-417 | 12140–12157, including the "A check earns its place" sentence that joins this entry | harvest 1 second, harvest 2 third, harvest 2 "No home" fifth bullet |
| The services hold the discrete tier | §14.10, §14.7, §14.8, §8.2; D-213, D-063 | 12816–12818 and 12165–12169 (the closed-loop seeding sentence) | harvest 2 fourth candidate; harvest 3 "No home" first bullet |
| What-if replay starts from your own `init!` | §12.7; D-274 | 9658, 9713 and the "trace is not self-sufficient" sentences; grep `restore = false` | harvest 1, fourth candidate |

**R3. Four amendments.**

- "Guard predicates, edges and priors": replace "positive meaning holding"
  with the convention the spec states, `σ ≥ 0` holds (frozen 374–376);
  narrow the exactness claim to guards over modes, root inputs and held
  discrete outputs (409–414, D-365); add the release-predicate facet, strict
  comparison by the gate form or the `Bool` form (§10.4, grep `exactly
  zero`, D-290); and add the latching-predicate facet from 5774–5779, that a
  latching guard gated on the free mode makes the pair hand each other
  fresh edges and chatter until the firing budget breaks the tie, under a
  `FiringBudget` warning. Owners gain §10.4, D-290 and D-365. Evidence:
  harvest 1 third candidate, harvest 2 second candidate, harvest 2 "No
  home" second bullet.
- "Interval alignment": add the rest-reading facet from 11900–11906, the
  store at rest holds the state the next due tick decodes, the cell the
  sample the last tick published, a counter due at boundary zero and
  authored at 0 holds 1 after `init!`, and a store copied off a stopped run
  into a condition starts that component one tick ahead. Owners gain
  D-067 and D-273. Evidence: harvest 3 sixth candidate and harvest 1 "No
  home" first bullet. The frozen spec has no `overlay!` door; do not name
  one.
- "`shutdown!` closes only what is open": add that a repeated call and a
  call with no `init!` before it both reach `shutdown!` under an operator
  interrupt, and the same tolerance covers them (7951–7963, D-268). Owners
  gain D-268. Evidence: harvest 3 fourth candidate.
- "The two observation sides": widen to the service user's paths, since a
  condition path, a trim read or a tap path may reach any depth and nothing
  is checked past a generic seam (11520 and the ownership-is-convention
  sentences after it; 12091, the "reads a face" guidance). Owners gain
  §14.2, §14.7, D-414 and D-065. Evidence: harvest 3 fifth candidate.

**R4. The two carried lead-ins.** "Same-tick reset consumption" stays as a
label, and its owners parenthetical gains D-089, which §5.3 bolds. "A
continuous component's state reset is an event" is a ruling sentence and
becomes the label "Continuous-tier resets", with D-141 added to its owners
(§5.3 and §3.4 bold it). Grep `D-089` and `D-141` in the frozen spec's
chapter 5 before citing.

**R5. The hidden-mode entry sits right after "Continuous-tier resets"**, as
its sibling, and "The startup hole" right after "Boundary sampling". The
other new entries append to their group in the order of R2's tables. The
old entries keep their order.

**R6. Facets that merge rather than add**, so the verifier knows where to
look for them: the stable-at-every-period sentence is in "Never cache
`Δt`"; the scheduled-gain sentence is in "Stripping partials declares a
zero coupling"; the check-on-a-written-quantity sentence is in the trim
checks entry; the closed-loop seeding sentence is in "The services hold the
discrete tier".

**R7. Inbound citations.** Nothing links into A by anchor except the
`[sA]` section link; no `####` anchors exist or are added.

## What you produce

As `brief_common.md` says: `units/A/new.md`, `units/A/claims.md` with one
`added:` block per new sentence or clause, run to `checks failed: 0`, and
`units/A/rulings.md`. Reply in under 150 words with the checker's last line,
the counts, and every open question.

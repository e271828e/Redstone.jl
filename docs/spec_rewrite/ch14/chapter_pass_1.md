# Chapter 14, chapter pass, half 1 (units A and B)

Read: `chapter_new.md` 1–725 whole, against `chapter_old.md` 1–607, the brief
(R1–R39), `spec_style.md`, `checks/brief_common.md`, `step5_carry.md`, both
units' `verify.md`, the frozen spec and log in `scratch_survey/h1/`, and the
Flight.jl source for owner clauses. Scripts in `scratch_step5/pass1/`.

Counts: 38 findings, EDITORIAL 33, RULING 5.

Checks that found nothing: no ruling is bold twice in half 1, in half 2 or in
the frozen spec's other chapters, except D-149 in §9.3, which R34 already
lands. The D-139, D-319 and D-406 bolds elsewhere are other rulings of those
entries. No reserved word is used bare in another sense. "Taught contract" is
Appendix A's term of art. No glossary link is split across lines. The R3 site
count is the same everywhere in the chapter.

## Findings

**P1-1.** Line 3–20, unit A. EDITORIAL. The roadmap sentence leaves out
§14.4's read-selector family and §14.6's `override`. It says "trim service"
twice in two scopes ("[§14.8] the trim service and [§14.9] mounting, which
together cover the trim service in full"). Mounting also relocates tap sets,
so §14.9 is more than trim. Three "covers" sit in one semicolon chain. Fix:
one verb and a comma list, keeping the §14.6 gloss.
"[§14.1][s14-1] settles the condition's representation, [§14.2][s14-2] its
composition, [§14.3][s14-3] its resolution and [§14.4][s14-4] its
application and the read selectors. [§14.5][s14-5] covers the boundary-zero
sequence, [§14.6][s14-6] root-input totality (gloss) and `override`,
[§14.7][s14-7] the trim problem, [§14.8][s14-8] the trim service,
[§14.9][s14-9] mounting and [§14.10][s14-10] linearization." If R1's "one
sentence" is strict, join the two with "and".

**P1-2.** Lines 10 and 59–60, unit A. EDITORIAL. The `#g-model` link sits
inside checkpoint's gloss at line 10. Its gloss, "(a deployment materialized
at one scalar type)", comes unlinked at line 59. The old text linked it at the
gloss (old 36). Fix: write a plain `` `Model` `` at line 10 and link
"a form on a [`Model`](#g-model) (a deployment …)" at line 59.

**P1-3.** Lines 25 and 638–639, units A and B. EDITORIAL. "While a run exists
the loop owns the stores" uses *run* for an executing `run!`. F27's "opening
the run" (639) uses it for the run record that `init!(sim)` creates
(`_open_run!`, `src/sim.jl` 602). After that a run exists, yet every service
stays legal at `initialized`. Fix at 25: "While the simulation is `running`,
the loop owns the stores between drains". Line 30's "inside a run" can stay.

**P1-4.** Lines 69–71 and 274–277, unit A. EDITORIAL. §14.1's context paragraph
is only the parts list. §14.3's is one sentence of input before the list.
Under the section template, context says first what problem the section
solves. Fix for §14.1: open with "A condition is the value an author writes to
say which state a build starts from." Then the parts sentence. Fix for §14.3:
"Resolution turns a composed tree into plans the services can apply. It takes
the root node plus a `Build` (gloss)." Then the parts sentence.

**P1-5.** Line 124–125, unit A. EDITORIAL. "The second escape already covers
the case" refers to the pre-sweep doctrine's second case (line 110), but §14.1
never calls it an escape. The phrase is D-139's own wording. Fix: "the
doctrine's second case already covers it ([D-139][d-139])".

**P1-6.** Lines 152–169 and 108, unit A. EDITORIAL. Unit A's verifier listed
these as reader-cold: `n_eng`, `ω_rated`, `α_a`, `β_a`, `α_filt`/`β_filt`,
`"pwp/engine"` and `"aero"`. None has a clause. Each is checked in Flight.jl:
`ω_rated` is `PistonEngine`'s rated speed (FlightPhysics `piston.jl` 222,
235), and `α_filt`/`β_filt` are the filtered airflow angles (FlightApps
`c172s.jl` 274). Fix: after line 154, "`n_eng` is the engine speed as a
fraction of `ω_rated`." After line 163, "`α_filt` and `β_filt` are the
aerodynamics' filtered airflow angles, set to the angle of attack `α_a` and
the sideslip `β_a`." At line 108, "trim's `α_filt = α_a`" can point to §14.2's
block.

**P1-7.** Lines 162, 188, 209, 649 and 711, units A and B. EDITORIAL. The
owner of the C172 code has several names: "FlightApps' `C172X.Systems`",
"FlightApps' C172 variants, c172s and c172x", "Flight.jl's Cessna 172 model
(`c172.jl`)" (R12's), "Flight.jl's Cessna 172 models" and "the C172X
aircraft". All three files are in Flight.jl's `lib/FlightApps/src/c172/`.
Fix: keep R12's spelling for `c172.jl`. Write the variants as "Flight.jl's two
Cessna 172 variants, c172s and c172x" at 188 and 649. Line 649's plural is
right: the asserts are in both `c172s.jl` 256–257 and `c172x.jl` 317–318.

**P1-8.** Line 187–188, unit A. EDITORIAL. "Dispatch selects variant-specific
methods…" comments on the pull example. It now follows the `set`-payload
paragraph, away from the block it explains, and reads worse than old 142. Fix:
move it to just after the `C172XSystems` block (line 169). The parts order
does not change.

**P1-9.** Lines 193/269 and 673/709/717, units A and B. EDITORIAL. `override`'s
glossary link comes late in both sections. In §14.2 the first use is at 193
and the link is at 269. In §14.6 the first prose uses are at 673 and 709 and
the link is at 717. Fix: link at 193 and at 673, and make the later ones plain.

**P1-10.** Lines 209–214, unit A. EDITORIAL. One sentence has two burdens: the
Cessna trim writes through `assign!`, and the zero-alloc property holds of the
construction and of `apply!`. The paragraph also ends with an unwrapped
"feeds.". Fix: "The trim of Flight.jl's Cessna 172 model (`c172.jl`) writes
each trial state through FlightPhysics' `assign!`, a loop that allocates
nothing. That property holds of the construction with literal prefixes and of
the specialized `apply!` that writes the tree ([§14.4][s14-4]) alike." Then
reflow.

**P1-11.** Line 254–255, unit A. EDITORIAL. "That rejection is also why **the
combinator is not `Base.merge`**" frames D-204's ruling as a consequence. The
style rule is rule first, reason after. Fix, with the bold span unchanged:
"**The combinator is not `Base.merge`**, and is no longer named after it
([D-204][d-204]). The last-writer-wins rejection is the reason."

**P1-12.** Line 264, unit A. RULING (bold words). The bold "**It is
`ConditionNodeMisuse`**" has a pronoun subject, so the headline clause does not
say what is decided. Fix: "**The blend rejection is `ConditionNodeMisuse`**
([Appendix C][sC], [D-113][d-113])".

**P1-13.** Lines 330, 333 and 335, unit A. EDITORIAL. "Decision-descended"
(330, 333; §14.7 912) and "decision-dependent" (335) name one leaf within
three lines. Fix: "every decision-descended leaf is `Dual`-typed".

**P1-14.** Line 362 (heading), unit B. RULING. "14.4 One plan, two ways to
apply it" contradicts R37. §14.3 (313–316) states two plans, and §14.4 says
"the compiled plans" (375), "its own plan" (379, 401). D-066's "one compiled
plan" is the old reading F16 corrected. Fix: "14.4 Two ways to apply a
resolved condition" or "14.4 Applying a condition, and the read selectors".
The spec's TOC (line 98) is a landing edit, and inbound citations use the
number only.

**P1-15.** Lines 364–375, 379 and 401, unit B. EDITORIAL. "Two ways" comes three
times in twelve lines (365, 374–375, and the heading). Three pointers to §14.3
sit in one subsection (375, 379, 401). Fix: end line 374–375 at "Execution is
therefore resolve-once/execute-many." The context paragraph already says two
ways, and each bullet keeps its pointer.

**P1-16.** Line 397, unit B (carried). EDITORIAL. "An envelope of trims" is
reader-cold, and its first use is here (§14.8 1231 reuses it). Fix: "an
envelope of trims (one trim per point of a grid of flight conditions)
included".

**P1-17.** Lines 418 and 447–449, unit B. EDITORIAL. *Selector* is used and
linked at 418 without a gloss, and it is defined at 447 ("A selector is a
*deferred read*…"). Fix: "The family of read [selectors](#g-selector) (values
describing a read the compiled gather will perform) is closed
([D-095][d-095])."

**P1-18.** Lines 423–445, unit B. EDITORIAL. One 23-line paragraph holds five
bolds and three topics: the address grammar, face-head matching, and step
checking. Fix: start a new paragraph at line 435 ("**Each step is
checked…**"). This also fixes the ragged "([D-276][d-276]). A" line.

**P1-19.** Lines 455–458, unit B. EDITORIAL. The remedy has two names in four
lines: "declare it an output" (456), then "that one remedy too … The component
exports it" (457–458). Fix: "A service evaluation needing an undeclared
intermediate has the same remedy, whatever its client ([§14.7][s14-7])." Keep
"The component exports it" only if the orchestrator reads R6 as needing it
here.

**P1-20.** Lines 460–465, unit B. EDITORIAL. The Mounting sentence (461–463)
sits between "an output face of the mount level" and "At the root that
face…", so "that face" loses its antecedent. "Read set" is unintroduced in
§14.4. Fix: put the Mounting sentence first, then "`get_face` addresses an
output face of the mount level, the level a problem's or tap set's reads are
mounted at ([§14.9][s14-9], [D-277][d-277]). At the root that face is
root-exported. …"

**P1-21.** Lines 488–514, unit B. EDITORIAL. After R5 the service/inspection
split is spread over three paragraphs, and some of it is said twice. "As
authoring guidance ([D-414])" comes at 488–489 and again at 504–505. "A
service read, trim's `reads` or a tap" (489) is followed by "Trim's `reads`
and linearization's taps name…" (501). "An inspection read … may name any
cell" (496–498) is followed by "Inspection reads admit the whole family"
(507). "Both reads resolve under the one service walk" closes the service
paragraph before the inspection one opens. Fix: two paragraphs, all wording
kept.
(a) "On top of the source rule sits one piece of authoring guidance
([D-414][d-414]). Trim's `reads` and linearization's taps name
`get_state`/…/`get_face` within the scopes the locality law ([§6.1][s6-1])
and fragment scoping ([§14.2][s14-2]) describe. A service read that should
outlive the build reads a face with `get_face` ([D-125][d-125]). [get_face
sentence] [equilibrium sentence]"
(b) "An inspection read, a binding's or `series`', may name any cell the
structure has, since it promises nothing beyond this build ([D-083][d-083]).
Inspection reads admit the whole family, within the source rule. [bindings
and series sentence] [snapshot sentence] [store-selector sentences] Both kinds
of read resolve under the one service walk ([§13.3][s13-3])."

**P1-22.** Line 510–511, unit B. RULING (citation scope). The pointer in
"Snapshot inspection reads a cell by path and port name instead
([§11.2][s11-2])" does not reach its claim. §11.2 (frozen 6912–7166) never
states a path-and-port-name read. F21's evidence is the code,
`port(snapshot, path, name)` (`src/dataplane.jl` 480–481), and Appendix B
lists only `port(model, path, name)` (frozen 13039). Options: keep §11.2 for
"snapshot" alone and flag §11.2 as owing the sentence (landing), or state it
here uncited, as F21 checked it against the code.

**P1-23.** Line 511–513 against 475–477, unit B. RULING (citation scope). Two
problems.
- The pointer in "a reader that runs over live stores, which today are the
  services' ([§14.7][s14-7], [§14.10][s14-10])" misses its claim in §14.7.
  §14.7's reads (807–834) never say that trim's readers run over stores.
  §14.8's "Scratch stores" (1048–1060) does.
- Lines 475–477 say `checkpoint` and post-run inspection also hold live
  stores. A cold reader sees a conflict, because F22's evidence is that they
  take no selector.

Fix: "which today are the services' readers ([§14.8][s14-8],
[§14.10][s14-10])". Optionally add "`checkpoint` and post-run inspection hold
live stores but take no selector" (F22, `src/readers.jl` 36–42).

**P1-24.** Lines 516–518, unit B. EDITORIAL. "…(the build's list of stop
requests, one per `StopFlag` output port), period" leaves "period" dangling
after the gloss. Fix: "…output port) and nothing else".

**P1-25.** Lines 533–534, unit B. EDITORIAL. The citation splits the bold
sentence: "**Compiled readers are the gather twin** ([D-066][d-066]) over
this family and the layout tables". Fix, with the bold span unchanged: "Over
this family and the [layout](#g-schema-vs-layout) tables (where each value
physically lives), **compiled readers are the gather twin**
([D-066][d-066])."

**P1-26.** Lines 539–547, unit B. EDITORIAL. "`apply!` ends at established
stores. Making the model coherent…" closes the section under "#### The
read-selector family", but it is about applying a plan. A reader who skims the
labels will not find it. Fix: move that paragraph to the end of "Applying a
plan", after the ledger (414). The plan-activation paragraph (539–542) can
stay, since it names readers.

**P1-27.** Lines 563, 545 and 670, unit B. EDITORIAL. Boundary zero's gloss in
§14.5 is "(the initialization boundary at `t₀`)". §14.4, §14.6 and §14.10
(1515) use "(the initialization boundary, the ordinary macro-sequence with an
empty integrate)". Fix: use the shared gloss at 563.

**P1-28.** Lines 590–593, unit B. EDITORIAL. *Prior* is linked at 590 with no
gloss and glossed at its second use (592). Fix: write "The prior rule" plain at
590 and link at 592: "every guard [prior](#g-prior) (the event's stored
predicate sample…)".

**P1-29.** Lines 607–608, unit B. EDITORIAL. "Sibling to the boundary-sampling
line ([§8.6])" uses a second name for the same rule. §8.6 calls it "the
boundary-sampling contract" (frozen 3392, 3548). Fix: "sibling to the
boundary-sampling contract ([§8.6][s8-6])".

**P1-30.** Lines 648–653, unit B (carried). EDITORIAL. Weight-on-wheels and
warn-but-assign are reader-cold. Warn-but-assign is never defined: §14.8 1116
uses it bare too. Flight.jl's trim warns on a failed optimization and assigns
the result anyway (FlightApps `c172.jl` 934–939). Fix: fit R32's
parenthetical as "(no gear strut in ground contact, engine speed `ω` above
`ω_idle`)". Then: "Saying nothing would relocate warn-but-assign, the habit of
Flight.jl's Cessna 172 trim of warning on a failed optimization and assigning
its result anyway." Also apply P1-7's owner name.

**P1-31.** Lines 655–658, unit B. RULING (bold). The bold "**A commit-fired
handler is not the only mover**" sits on a framing clause. D-155's headline
is "Projection is named the second legitimate mover of the committed point",
and R7 places it here. Fix: "A commit-fired handler is not the only mover.
**Projection is the second, and it is unconditional** ([D-155][d-155]).
Boundary zero's *first* act is …"

**P1-32.** Line 661, unit B. EDITORIAL. "The point the verdict was read at":
*verdict* is unintroduced in §14.5. Fix: "the point the solver's convergence
verdict was read at ([§14.8][s14-8])".

**P1-33.** Lines 699–700, unit B (carried). EDITORIAL. `mixture` is
reader-cold. It is the mixture setting that FlightPhysics' `PistonEngine`
takes as an input (`piston.jl` 260, 272). Fix: "A silently zeroed `mixture`,
the mixture setting of FlightPhysics' `PistonEngine`, kills the engine…"

**P1-34.** Lines 704–706, unit B. EDITORIAL. "That discharges the requirement
([§11.3])" has no antecedent in §14.6. Fix, from frozen 7326–7327: "That
discharges the requirement that every root input hold a defined value from
the first frame ([§11.3][s11-3])."

**P1-35.** Many lines, units A and B. EDITORIAL. These glossary links have no
gloss at the first use in their section (`scratch_step5/pass1/links.py`):
- the opening: store 25, boundary zero 15, root input 18, control-plane 29;
- §14.1: tier 74, root input 77, baseline 118;
- §14.2: condition 143, contract 174, fragment tree 190, local wire 226,
  seam 228, generic holding 230, cell 234, kind 264, root-input totality 270;
- §14.3: condition 281, schema/layout 303, nominal 340, scratch 345;
- §14.4: store 379, boundary and snapshot 469, replay 476, buffer 478,
  fragment 504, device 508;
- §14.5: store 551, sweep, guard, due and snapshot 555, trace header 557,
  projection 570, tick 576, probe 583, predicate 586, stage-on-interaction
  595, stop request 602;
- §14.6: root input 666, fragment 677, replay 702, trace header 703.

The old text mostly lacked them too, and the units added none. Fix: the
fixer takes each gloss from its glossary entry. In §14.2, also move the
`#g-condition` link off "condition method" (143), a function's name, onto the
section's first use of the value. The orchestrator may limit the list to the
reader-cold ones: generic holding, fragment tree, seam, nominal, scratch,
probe, stage-on-interaction and stop request.

**P1-36.** Wrap, units A and B. EDITORIAL. Lines over 80 rendered columns: 381
(the carried unit B line 20), 401 (117 columns), 428, 463, 467 and 496. Ragged
lines: 213–214 ("feeds."), 435–437, 490–491. A double blank line falls at
360–361. Lines 618–619 (an indented table) and 664 (a heading) are exempt.
Fix: reflow.

**P1-37.** Line 644–647 against §14.8 1095–1097, units B and F (across the
split). EDITORIAL, fixed in half 2. The raw write → sweep → read iterations
are stated in full in both places. Under R6 their home is §14.5 and §14.8 is
a pointer. §14.8's "over the continuous chain and `x_deriv` alone" is the one
addition it keeps. Fix in §14.8: "The iterations are untouched
([§14.5][s14-5]). They run over the continuous chain and `x_deriv` alone."

**P1-38.** §14.10 1522–1523 against lines 9, 94 and 558, units H and A/B
(across the split). EDITORIAL, fixed in half 2. §14.10 glosses checkpoint as
"(the model's state …)". Half 1 and the glossary write "(the `Model`'s state
at a frame top as one value)". Fix in §14.10: use the shared gloss.

## Carried items, disposed

- Unit B line 20 over 80 columns: P1-36 (chapter line 381).
- `mixture`: P1-33. Weight-on-wheels and warn-but-assign: P1-30. "An
  envelope of trims": P1-16.
- Unit A verifier's reader-cold list (the example symbols): P1-6. Unit B
  verifier's list: all covered above. `ω_idle` takes P1-30's clause.

# Chapter 14, step 5: the chapter pass, half 2

Half 2 is units F, G and H, §14.7 to §14.10, `chapter_new.md` lines
726–1734 (old lines 608–1464). Units by line: F is 726–1125, G is
1127–1450, H is 1451–1734. The roadmap check is half 1's.

Counts: 50 findings. 41 are EDITORIAL and 9 are RULING (P2-6, P2-21, P2-24,
P2-28, P2-32, P2-35, P2-40, P2-47, P2-48).

## Checks that found nothing

- Bold: no ruling is bold twice. I grepped half 1 and the frozen spec's
  other chapters for bolds citing every entry half 2 bolds. The only
  overlaps are distinct rulings of D-139, D-155, D-156, D-266, D-274,
  D-295, D-296 and D-319, each as R7, R25 or the units ruled. D-069
  (8 bolds), D-070 (5), D-071 (7), D-072 (7) and D-277 (4, plus the one it
  shares with D-071 at 1334) each match their Position's ruling count
  under the one-bold test. No bold in half 2 sits on a consequence or a
  lead-in.
- Glossary links: no term is linked twice in a section (§14.8 included,
  across F and G). The misplaced or misaimed links are P2-13, P2-20 and
  P2-34.
- R6 pointers into half 1: §14.4 states the undeclared-intermediate rule
  (452–458) and the gather twin (533); §14.3 the converter selection
  (320–346); §14.5 the raw iterations and `t0` (631–648); §14.2 the
  export-chain refusal (175–177) and the empty-prefix refusal (216). The
  frozen targets also hold up: §7.2 the frozen-exact answer, §8.2 the FFI
  door, the seedability retyping and the fan-out meet, §9.5 the legality
  of mid-expression stripping, §13.7 `Freeze{V}`, §12.4 the boundary
  masking, §12.6 the recorder restart.
- R5's `get_face` pointer to §14.9: 1369–1372 and 1380 carry the export
  chain. P2-47 covers the other R5 pointer.
- Reserved words: only P2-27 and P2-40.

## Findings

**P2-1.** Line 740 and 784, unit F. §14.7 states the decisions' shape twice:
the bold bullet at 740 and "Decision variables, initial guess and box bounds
are plain, same-*named*, all-`Float64` NamedTuples" at 784. Fix: open 784's
paragraph at "FlightPhysics' decision-variable supertype,
`AbstractTrimState{N}`, is dropped." EDITORIAL.

**P2-2.** Line 756, unit F. "[Worked](#g-worked), the cruise case … reduces to
its three-equation core" is inherited and ungrammatical, and the link has no
gloss. Fix: "The problem below is [worked](#g-worked) (spelled in full against
a concrete case). It is the cruise case of Flight.jl's Cessna 172 model
(`c172.jl`), reduced to its three-equation core." EDITORIAL.

**P2-3.** Lines 849–851, unit F. "and the framework never sees it" repeats the
bold at 802–803 in the same section. Fix: end the sentence at "exactly as
`condition` already holds it." EDITORIAL.

**P2-4.** Lines 852–855, unit F. The gloss says the constructor builds a
field handle, and the sentence then says "that builds such a handle". Fix:
"[§8.2][s8-2] gives the [value-level constructor](#g-value-level-constructor)
that builds such a handle, a plain exported function of the component and its
input values. [§14.1][s14-1] gives the pre-sweep doctrine." EDITORIAL.

**P2-5.** Line 861, unit F. "canonical for the r-side" is jargon. Fix:
"canonical for the residuals". EDITORIAL.

**P2-6.** Lines 895–899, unit F (carried). The bold names FlightPhysics as the
owner of a core whose 7-variable search is `c172.jl`'s `TrimState`
(`lib/FlightApps/src/c172/c172.jl` 796). Only `θ_constraint` is FlightPhysics'
(`aircraftbase.jl` 110). Under R23 the bold names the wrong owner. Fix:
"**Flight.jl's trim formulation is correct at its core and survives verbatim
as user math** ([D-069][d-069])", with the next sentence unchanged. RULING
(bold wording).

**P2-7.** Line 955, unit F. "A model that a simulation has claimed" means a
`Model`. Fix: "A `Model` that a simulation has claimed". EDITORIAL.

**P2-8.** Lines 957 and 1392, units F and G. The two baseline glosses
disagree. §14.8's gloss says "condition function" for what the keyword takes,
and §14.9 says "the full-coverage condition `trim!` takes as a keyword". The
keyword takes a condition, the value `override(baseline, …)` layers. Fix
§14.8: "takes a [baseline](#g-baseline) (a full-coverage condition, such as an
aircraft-shipped function returns)". EDITORIAL.

**P2-9.** Lines 962, 978, 1014, 1110 and 1303, units F and G. "LM" is never
introduced in §14.8, and "iff" is not plain vocabulary. Fix: "dense
Levenberg–Marquardt (LM)" at 962, and "It fills `J` exactly when
`J !== nothing`" at 978. EDITORIAL.

**P2-10.** Lines 1024, 1046, 1633 and 1680, units F and H (1046 carried). These
lines run 99, 91, 92 and 81 rendered columns. Fix: rewrap. EDITORIAL.

**P2-11.** Line 1287, unit G. §14.8 introduces "Flight.jl's Cessna 172 model
(`c172.jl`)" a second time; the first is at 1024. Fix: "A migration audit of
the Cessna 172 model against this obligation …". EDITORIAL.

**P2-12.** Line 1055, unit F. The activation gloss follows "*layout*", so it
reads as the gloss of layout. Fix: "The set is built from the *layout* of the
[activation](#g-activation) (the build's typed products at a given scalar
type)." EDITORIAL.

**P2-13.** Lines 1093–1094 and 1267, units F and G. The link at 1093 targets
`#g-probe` (the build's single evaluation of a user function). "The probe's
synthesized values" are probe values, `#g-probe-value`. "The [§14.6][s14-6]
barrier" names what §14.6 calls "the probe-value barrier". At 1267, "probe"
takes a third sense in the same section. Fix: "No scratch cell holds a
synthesized [probe value](#g-probe-value) (a fabricated value a build-time
probe runs on). That is the probe-value barrier of [§14.6][s14-6] reaching the
scratch world, …". At 1267: "The empty problem asks "is this operating point
an equilibrium?"" EDITORIAL.

**P2-14.** Lines 1097, 1260 and 1266, units F and G. One problem has three
names: "the zero-decision problem", "an *empty* problem" and "the degenerate
problem". Fix: "the empty problem" at 1097 and 1266. EDITORIAL.

**P2-15.** Lines 1101–1102, unit F. The commit expression is stated at 1102,
again in full at 1130, and also in §14.6 (723) and §14.9 (1326). 1102 points
to §14.9, away from the subsection below that states it. Fix: "The commit
applies the same composite over the same `baseline` (below), so its coverage
is setup's." EDITORIAL.

**P2-16.** Line 1106, unit F. "The no-throw doctrine" is used before
"Non-convergence never throws" (1230), with no pointer. Fix: "the no-throw
rule (below)". EDITORIAL.

**P2-17.** Lines 1115–1116, unit F. "Flight.jl's warn-but-assign" is
reader-cold. `c172.jl` 934–939 warns with `@warn` on a failed optimization,
then calls `assign!`. Fix: "Flight.jl's warn-but-assign, where the Cessna 172
trim warns on a failed optimization and assigns its result anyway, is
structurally impossible." Half 1's §14.5 uses the same name. EDITORIAL.

**P2-18.** Lines 1125–1126, the F/G seam. There are two blank lines before
"#### The commit, in full". Fix: delete one. EDITORIAL.

**P2-19.** Line 1144, unit G. "Unattended mode" is not the glossary's term,
which is "unattended run". Fix: "is the natural shape of an
[unattended run](#g-unattended-run) (a run with empty staging and no snapshot
readers)". EDITORIAL.

**P2-20.** Lines 1145–1147 and 1522–1523, units G and H. In §14.8 the
checkpoint link sits on the second use. In §14.10 the gloss splits the bold
noun phrase and says "model's" where §14.8, the glossary and the old text say
"`Model`'s". Fix §14.8: "spelled as a [checkpoint](#g-checkpoint) (the
`Model`'s state at a frame top as one value) of the flight, then a trim
baseline authored from what the checkpoint shows". Fix §14.10: "**The default
operating point is the [checkpoint](#g-checkpoint)** of the simulation or the
`Model` as it stands, the `Model`'s state at a frame top as one value
([D-274][d-274], [D-319][d-319])." EDITORIAL.

**P2-21.** Line 1179, unit G. The `residuals`/`tolerances` field cites
"[§14.5][s14-5], [D-155][d-155]". §14.5 does not state the two residual sets.
It says the remedy is "specified with the report in [§14.8][s14-8]" (661–662), so
the two pointers point at each other. The move the §14.5 pointer is for is
named at 1215–1216, which cites §14.5 already. Fix: drop
"[§14.5][s14-5]" at 1179 and keep D-155. RULING (citation scope, R7).

**P2-22.** Line 1202, unit G. "An offset component" is reader-cold. Fix:
"of a [component](#g-component) whose schedule has a nonzero
[phase](#g-phase)". EDITORIAL.

**P2-23.** Lines 1204–1205 and 1209–1210, unit G. "A `linearize` at its
default operating point reads" this point appears in two adjacent paragraphs,
and only the second carries the pointer. Fix: put "([§14.10][s14-10])" on the
first, and end the second at "not the reported solution, and that is the
point it reads." EDITORIAL.

**P2-24.** Lines 1207, 1214 and 1222, unit G. Nothing in the chapter says the
three `TrimCommit…` kinds are logged warnings. D-262 says "a logged warning
that rides the report", and Appendix C says "Warning · service · logged".
"Raises", close to "Non-convergence never throws", can read as a throw. Fix,
once at 1207: "also raises `TrimCommitEvents`, a logged warning
([Appendix C][sC], [D-126][d-126])". RULING (adds a claim; it pairs with
F79's landing edit).

**P2-25.** Line 1218, unit G. "The numbers ([D-150][d-150]) stand as
reported" puts the citation mid-phrase. Fix: "It gated the commit at the
solved point, and the numbers stand as reported ([D-150][d-150])."
EDITORIAL.

**P2-26.** Line 1231, unit G. "An envelope of trims" is reader-cold, as in
half 1's carry. Fix, after D-070's "envelope-sweep": "In a sweep of trims
across the flight envelope, hitting the infeasible edge is information."
EDITORIAL.

**P2-27.** Line 1296, unit G. "Jacobian entries" uses bare *entry*. Fix:
"Jacobian elements". EDITORIAL.

**P2-28.** Line 1348, unit G. The sketch's comment, "the prefix joins the read
set's mount chain", reads against the prose at 1360 and D-277: "prepends the
prefix to that chain and joins nothing". It is inherited, and comments change
only by ruling. Fix: "#inert selector data: the prefix is prepended to the read
set's mount chain". RULING.

**P2-29.** Lines 1356 and 1361, unit G. §14.9 never introduces `Scoped` or
`Reads`. Fix: "enters each `Scoped` wrapper (the node `at` builds over a
condition node)", and after the bold at 1359 add "A read set is a `Reads`
value." EDITORIAL.

**P2-30.** Lines 1317, 1393–1396, 1416 and 1620, units G and H. "Thin rig"
and "thin world" name one thing, and neither is introduced. "Full world"
appears once. Fix: use "thin rig" (D-364's word) throughout, 1416 and H's
gloss at 1620 included. Introduce it at 1395: "In a thin rig (a world holding
the aircraft and the least environment its design task needs)". EDITORIAL.

**P2-31.** Line 1409, unit G. The method is FlightPhysics'
(`lib/FlightPhysics/src/world.jl` 49), and `f_init!` and `Model` are
FlightCore's. This is the first foreign `Model` in §14.9, and its owner is not
named until 1423. Fix: "FlightPhysics' world initializer, its method of
FlightCore's `f_init!` on a FlightCore `Model{<:SimpleWorld}` (initialize
environment, then call the aircraft's trim), has no successor method."
EDITORIAL.

**P2-32.** Lines 1416 and 1435, unit G. "Shipped rig" appears twice, the
second restating the first. No source holds a `design_world` (unit H's
rulings, item 3), and R26 dropped "shipped" from §14.10's gloss. D-071's
bullet 4 says "shipped rig". Rule whether §14.9 keeps D-071's word or writes
"the rig this design records", and whether 1435 goes. RULING (bold wording).

**P2-33.** Lines 1441–1442, unit G. In "trim lead, commit, trim wing", the
lead is never introduced. Fix: "trim the lead aircraft, commit, trim the
wingman against the committed world". EDITORIAL.

**P2-34.** Lines 1480 and 1563, unit H. "Root input" is first used at 1480,
but its link and gloss sit at 1563. Fix: move them to 1480 ("a whole state
field or [root input](#g-root-input) (the root's own input face)") and leave
1563 bare. EDITORIAL.

**P2-35.** Lines 1504–1505, unit H. "That is the no-silent-zeros rule again"
has no antecedent in §14.10, since the zero-column rejection comes later
(1575). The rule's prose is §9.5's "Deliberate stripping". D-197 is also cited
in two consecutive sentences. Fix: "That is the no-silent-zeros rule
([§9.5][s9-5])." RULING (citation change).

**P2-36.** Lines 1505 and 1527, unit H. "The frozen tier" is used before
§14.10 says the discrete tier is frozen (1565). M62's move of "The operating
point" made this worse. Fix at 1505: "The discrete tier is frozen
([§8.2][s8-2]), so its only possible partials are zeros". EDITORIAL.

**P2-37.** Lines 1541–1545, unit H. One sentence carries four burdens. Fix:
"… default 8** ([D-272][d-272]). The default width's scalar type is public.
A build can therefore pre-materialize its activation (gloss) through
`activations` ([§9.4][s9-4]), and a tap set of any size then linearizes with
no compile at the keyboard." EDITORIAL.

**P2-38.** Line 1557, unit H. "jacobians" is lowercase, and the chapter
writes "Jacobians" elsewhere. EDITORIAL.

**P2-39.** Line 1578, unit H. "([§8.2][s8-2]; [D-168][d-168])" uses a
semicolon where the chapter uses commas. EDITORIAL.

**P2-40.** Line 1595, unit H. The verbatim table says "a root input whose
entry is declared `Pinned`", a bare *entry*. The prose says "input entry".
RULING (the brief keeps the table verbatim).

**P2-41.** Line 1607, unit H. "FlightPhysics' `LinearizedSS` the *component*"
reads oddly. Fix: "**FlightPhysics' `LinearizedSS`, the
[component](#g-component), survives separately, as an ordinary continuous
component**", which keeps the contrast with the `Linearization` value.
EDITORIAL.

**P2-42.** Lines 1606, 1618–1619, 1632, 1665, 1674 and 1680, unit H
(carried). Unit H's verifier listed these names as needing one clause each,
and they still have none. Fix: "LQR (linear-quadratic regulator)", "built on
north-east-down (NED) kinematics", "a ZOH (zero-order hold) constant",
"saltation corrections (the jump terms a sensitivity takes across an event)",
"plus Tustin's discretization", "an FMU (a Functional Mock-up Unit, a
packaged external model)". EDITORIAL.

**P2-43.** Lines 1697–1699, unit H. The sentence nests an appositive list
inside a comma list. Fix: "… by whatever means it has, such as a finite
difference at a step its own grid suggests or the table's analytic slope. It
then chains it onto the incoming partials ([D-266][d-266])." EDITORIAL.

**P2-44.** Line 1714, unit H. "The stripping" has lost its antecedent. The old
text spelled out "strip with `ForwardDiff.value` inside the stage" before
this point, and the R6 pointer removed that. Fix: "The block strips the
partials with `ForwardDiff.value` mid-expression, which [§9.5][s9-5] leaves
legal at an unpinned leaf, …". EDITORIAL.

**P2-45.** Line 1724, unit H. The antecedent of "that visibility" is 1682, now
40 lines back, past the local rule. Fix: "the remaining tooling over the
schema's declared non-participation". EDITORIAL.

**P2-46.** Lines 1330, 1360–1363, 1482–1483, 1621–1622 and 1636–1637, units
G and H. These source wraps are ragged: short lines are left from the edits,
and a bold is split mid-clause at 1360–1363. Fix: rewrap. EDITORIAL.

**P2-47.** Half 1 lines 512–513 (§14.4, unit B; the target is unit F). R5's
"which today are the services' ([§14.7][s14-7], [§14.10][s14-10])" points to
§14.7, which never says trim's reads run over live stores. §14.8's "Scratch
stores" (1050–1060) states that store set. Fix: [§14.8][s14-8] in place of
[§14.7][s14-7]. RULING (R5 dictated the citation).

**P2-48.** Line 1531, unit H. D-272 places the `about` point "under `init!`'s
legality", and R3 makes it a totality site, but §14.10 has no pointer back to
§14.6. The R3 pointer's target, the application to its own scratch, holds
(1531, 1537–1539). Optional fix: "… without touching the sim, its coverage
checked as [§14.6][s14-6] requires". RULING (adds a claim).

**P2-49.** Lines 1043, 1080 and 1087, unit F. "Projection" takes two senses
in §14.8: the box bounds' "step projection" and the linked `x_projection`
hook. The [projection](#g-projection) and [tier](#g-tier) links have no
gloss; tier's gloss exists only in §14.10. Fix: "no
[projection](#g-projection) (the per-component `x_projection` hook)" and
"the discrete [tier](#g-tier) (the discrete side of the hybrid formalism)".
EDITORIAL.

**P2-50.** Line 1637, unit H (carried). §14.10 now names
`frozen_discrete_walkthrough.md` once; the double the carry describes is
gone. §7.2 names it too, but one mention per section is fine. Confirm, no
edit. EDITORIAL.

# Chapter 13, step 5: chapter pass, half 2

Half 2 is `chapter_new.md` lines 613–1392 (§13.5 to the chapter's end),
units F (§13.5, §13.6) and G (§13.7, §13.8), read against `chapter_old.md`
535–1233, the frozen spec and log in `scratch_survey/h1/`, `brief.md`
(R1–R30) and `step5_carry.md`. Line numbers are `chapter_new.md` lines at
`5f21eba`.

Counts: 29 findings, 20 EDITORIAL and 9 RULING.

Checked and clean: every bold in the half against the frozen spec's other
chapters and half 1 (script in `scratch_step5/pass2/bold.py`). No ruling is
bold twice. §12.6 bolds the per-advance declaration and `errored` is
terminal, and §9.2 bolds `show`; the half states each plain with its
pointer. Each entry bolded more than once in the half (D-060, D-316, D-203,
D-312, D-349, D-245, D-012) takes one bold per Position sentence or bullet.
The R4 pointer targets hold. §12.6 states the declaration, the keywords and
the lifetime but not the defaults, so 714–715 is their only home. §12.6
bolds the quarantine clauses that 945–948 point to. §6.1 bolds D-084. No
glossary anchor is linked twice in a section. The §13.6 and §13.8 parts
sentences match their sections.

## Findings

**P2-1** (EDITORIAL; F, G; wrap). Two lines run over 80 rendered columns:
616 (82) and 981 (103). Several paragraphs are left ragged from source-width
wrapping: 714–720 (717 ends at 47 columns, 718 at 36), 779–786 (781 at 43),
872–882, 910–915 (911 at 46) and 1077–1083, where 1081 breaks after
"([§6.2][s6-2])." mid-paragraph. Fix: rewrap each paragraph to 80 rendered
columns, link markup collapsed.

**P2-2** (RULING; F; 699–705). The requester roster's gloss (R12) states
the bold ruling before the bold does. The gloss says "one
`Requester(path, port, reason)` per `StopFlag` output port, in build order".
The next sentence bolds "The build records one `Requester(path, port,
reason)` per `StopFlag` output port", and 704–705 add "requester roster order
is build order". That is one claim three times in six lines, the first time
plain. Fix: open the paragraph with the bold sentence, then "This list is
the requester roster (gloss), and it names every request." Drop "and
requester roster order is build order", since the gloss carries it. The
ruling is needed because the deletion removes a claim instance and the
bold's place changes.

**P2-3** (RULING; F; 756–758 and 878–879). One claim twice in one section.
756 says "The request is the author's and the ignore list the
integrator's"; 878 says "The trigger is the author's knowledge and the
ignore list the integrator's" (R9 folded it into the doctrine). 756–758 also
sits under "The scan and the source order" but is about the policy. Fix:
cut 756's first clause and keep "The ignore list sits beside `t_end` at the
same declaration site." Move that sentence to the end of "The policy per
advance" (after 720), or cut it as implied by 712–714.

**P2-4** (EDITORIAL; F; 854–860). The R9 sentence reads worse than the old
text. It hangs two relative clauses on items mid-list: "root-type-declared
stop policy, which the per-advance policy is not" and "…named by the
advance, which fell to stop requests". The second can be read as covering
the whole list. Fix: keep one sentence naming the mechanisms (R9), ending
"…and the `Bool` face re-exported level by level to the root and named by
the advance." Then add "The per-advance policy is not the root-declared one,
and the re-exported face fell to stop requests." The `blessed` sentence
stays as written.

**P2-5** (EDITORIAL; F; 877–878). "Substitution is answered by the ignore
list" reads cold. The objection it answers was in D-060's Rejected list
(log 1930–1932, "swapping an aircraft silently changes when runs end"), and
the rewrite leaves it unstated. Fix: "A substitution that changes when runs
end is answered by the ignore list." If the fixer judges the clause a new
claim, it becomes RULING.

**P2-6** (EDITORIAL; F; 852, 864, 629–632). The label "Inspection and the
reads a run acts on" heads the rejected-mechanisms paragraph too, and the
parts sentence says "inspection beside the reads a run acts on". The
doctrine's topic sentence, "The observation-by-path line leaves doctrine
behind it", is not a findable claim. Fix: label "Rejected mechanisms and
the reads a run acts on", with the parts sentence matching. Topic sentence:
"Rejecting observation-by-path separates inspection from the reads a run
acts on, a line [D-316][d-316] narrows."

**P2-7** (EDITORIAL; F; 841–844). `robot2d` throws twice. R10's
introducing clause says it "throws `LostBalance` … past 45° of tilt", and
the next sentence says "It *throws* when it falls". Fix: "`robot2d`,
FlightApps' self-balancing robot in Flight.jl, *throws* `LostBalance`, a
`SimulationTermination`, past 45° of tilt, because it has no other way to
say "my dynamics are no longer meaningful"."

**P2-8** (EDITORIAL; F; 765). "Authors are taught this rule." is a topic
sentence that points forward and states nothing. Fix: "Authors are taught
that stop requests are sampled at completed boundaries, and that a stop
that must be localized needs a sign-form event." This replaces the next
sentence too.

**P2-9** (EDITORIAL; F; 904). "The abnormal path rests on this." is the
same kind of forward-pointing topic sentence. Fix: "The abnormal path is
safe because the boundary is all-or-nothing outside the loop
([D-030][d-030])." It replaces 904's two sentences.

**P2-10** (EDITORIAL; F; 901–902). The gloss forced "no task of a
[device](#g-device) (…) hangs", which reads worse than the old "no device
task hangs". Fix: "so no [device](#g-device) (an attached participant in
the periphery) is left with a hanging task."

**P2-11** (EDITORIAL; F; 907–911). R23's split turned one clause into three
sentences: "They never live in the scratch of a component (…). That scratch
is its workspace (…), as §7.3 defines it." Fix: "Integration intermediates
live in framework-owned integrator buffers, never in the scratch of a
[component](#g-component) (a leaf or an assembly of components). That
scratch is its [workspace](#g-workspace) (declared by allocation and
excluded from state semantics), as [§7.3][s7-3] defines it." This keeps one
gloss per sentence.

**P2-12** (EDITORIAL; F; 946). `[trace](#g-trace)` is linked at its first
use in §13.6 with no gloss, and the gloss after it is replay's. Fix: "…and
the reproduction tool is [trace](#g-trace) replay, not resurrection
([§12.6][s12-6], [D-059][d-059], [D-387][d-387]). The trace is the session's
record of drained inputs, and [replay](#g-replay) re-drives the ordinary loop
from it." These are sentence glosses, since R23 bars two in one sentence.

**P2-13** (EDITORIAL; F; 950). "The roster operations" is the device
roster, bare and unlinked, one section after §13.5 kept "requester roster"
in full (R12). A cold reader takes it for the requester roster. Fix:
"Operations on the [roster](#g-roster) (the list of attached device
entries) refuse it with them ([§11.3][s11-3], [D-232][d-232])."

**P2-14** (EDITORIAL; F; 733). The bare `frame!` is reader-cold in §13.5.
Fix: "the `Model`'s `frame!`", R7's form for the function.

**P2-15** (EDITORIAL; F, G). One gloss per term: five terms are glossed
differently across the half.
- *guard*: 636 "the declared function that detects an event"; 1305 and
  the glossary say "the declared function(s) defining each event's
  predicate".
- *component*: 684 and 908 "a leaf or an assembly of components"; 964 "the
  units of modeling". The glossary has both.
- *replay*: 868 "the ordinary loop re-driven from a recorded trace"; 946
  "re-driving the ordinary loop from the session's recorded inputs".
- *blessed*: 860 "explicitly sanctioned by the spec"; 972 "explicitly
  sanctioned where a neighboring practice is forbidden", the glossary's.
- *contract*: 958 "the `u_types` and `y_types` declarations"; 1373 "its
  declared interface", the glossary's.
Fix: use one wording per term. Take the glossary's where it fits in 5–10
words: guard at 636 as at 1305, with 638's predicate gloss becoming "(the
`Bool`-valued form or sign a guard returns)" to avoid a loop. Component as
"the unit of modeling, a leaf or an assembly of components" at all three.
Replay as at 868 in both. Blessed as at 972 in both. Contract as "a
component's declared interface" at 958.

**P2-16** (RULING; G; 1017–1018). The *stop request* gloss "(a port that
ends the run when it reads `STOP_REQUESTED`)" claims too much: an ignored
request does not end the run (722, D-316's Position "unless the advance
ignores it"). The old text had it too. Fix: the glossary's gloss, "(an
output port of the framework enum `StopFlag`)", as at 646.

**P2-17** (RULING; G; 1004–1005 and 1013–1014). The pointer to the
companion appears twice in nine lines. The guidelines paragraph says "The
inventory, and the Simulink mapping that prunes it, is
`companions/library_inventory.md`." R13's added sentence says "The shipped
list lives in `companions/library_inventory.md`." R13 was written for the
old order, before the survey's move put the guidelines ahead of the
inventory. Fix: drop R13's sentence, or cut the companion clause at 1004
and keep R13's.

**P2-18** (EDITORIAL; G; 1015–1016, 1134, 1171). Two sentences appear
verbatim twice in one section. "`Constant{V}` is the source block
([D-143][d-143])" is at 1015 and 1134. "`Freeze{V}` is the declared
stop-gradient ([D-266][d-266])" is at 1016 and 1171. The old text had the
second of each in bold, and unit G dropped the bold without the repeat.
Fix: 1134 becomes "`Constant{V}` has no inputs, no state, and a stage-1
body returning the value the instance holds ([D-143][d-143])". 1171 becomes
"`Freeze{V}` feeds a walking producer into a pinned entry, which the walk
clause ([§6.1][s6-1]) otherwise refuses." D-266 is still cited at 1016 and
1189.

**P2-19** (EDITORIAL; G; 1187). The antecedent is wrong in "…until a model
needs one. Under a `Dual` activation it drops the partials": the nearest
noun is "a model". The old text had the same. Fix: "the block drops the
partials".

**P2-20** (EDITORIAL; G; reserved words and spelling).
- 1102 "No tier-neutral class is needed" uses *class* outside primitive
  versus assembly. Fix: "No tier-neutral variant is needed."
- 1078 "generated slots" is the log's old vocabulary. Fix: "generated
  input ports".
- 1080 "whose entries name" uses a bare *entry*. Fix: "whose input
  entries name".
- 1071 "its contracts are written" uses *contract* in the plural for one
  component. Fix: "its contract is written".
- 1189 "modelling" is the spec's only British spelling of the word (21
  occurrences of "modeling"). Fix: "modeling".

**P2-21** (RULING; G; 1292, 1335–1339). F63's gloss uses *local* for two
different things. It glosses the sampled mode, "(the local,
primal-carrying mode)", and the per-member variant, "*per-member* (local)".
1338–1339 then say that these two must not be conflated. A cold reader
cannot see that *local* is an old name. Fix: tie each gloss to its source,
"(the local mode of D-349)" and "(the local variant of D-012)", or drop
*local* from both. Also 1335–1336 says "the *per-member* … variant of
tracing, the order-free per-member trace" twice over. Fix: "uses the
*per-member* variant of tracing, an order-free trace at the probe point
([D-012][d-012])".

**P2-22** (RULING; G; 1381–1382 against 1345–1349). F64's sentence, "The
dead hop is the member's input face that its stage-2 function does not route
to the output port", makes the dead hop a face. 1345–1349 define a hop as
running from a face to a port, and a dead hop as one the member's map does
not route. D-245 bullet 1 agrees with 1345. The sentence also comes after
four earlier uses of "dead hop". Fix: "The dead hop runs from the member's
input face that its stage-2 function does not route to the output port", or
for the example "Here the dead hop is `systems/aero`'s, from `a` to `F`."

**P2-23** (RULING; G; 1216–1218). The bold carries a whole parenthetical
gloss: "**A concrete stub child (a provider of `SampleTerrainField`, an
illustrative concrete terrain) is wired to the face**". The bold weight is
twice the headline clause. Fix: "**A concrete stub child is wired to the
face**, and the concrete remainder is exposed via
`input_passthrough(rig, "strut"; except = ("terrain",))` ([D-120][d-120]).
The stub provides `SampleTerrainField`, an illustrative concrete terrain."

**P2-24** (EDITORIAL; G, F; glossary links at first use). Check each
against `check_glossary.jl`'s WHITELIST before adding.
- Linked with no gloss: [component test rig] 1199, whose glossary gloss is
  "a one-child assembly exporting the child's entire input face set";
  [projections] 1306, glossed "the optional per-component hook
  `x ← x_projection(x)`".
- Unlinked glossary terms: *constant source* 1168 (`#g-constant-source`);
  *conditions* 1202 (`#g-condition`); *leaf walk* 1072 (`#g-leaf-walk`);
  `Δt_base` 1129 (`#g-dt_base`); *algebraic loop* 1252
  (`#g-algebraic-loop`).
- *abstract entry* is first used at 1210 ("An *abstract* input entry") but
  linked at 1238. Move the link and gloss to 1210.
- §13.5 lost the old text's `#g-port` link (old 747), and §13.5 now has
  none. Confirm this is intended.

**P2-25** (EDITORIAL; G; 1167–1169; carried from step 4). The R30 sentence
says "bulk data" twice. Fix: "…a rig holds such a handle through a constant
source instead…". This is the verifier's optional note in
`step5_carry.md`.

**P2-26** (RULING; B and F, across the split; 872). R4 (q28) has §13.3 and
§13.5 point at each other: the three-client rule and the stop scan as the
one read a run acts on. §13.5 points to §13.3 (872, R29's wording). §13.3
(half 1, lines 299–360) has no pointer back to §13.5. R29 decided the two
lines differ. Rule whether §13.3 still owes the pointer, and if so, add one
clause at §13.3's inspection warrant: "The stop scan, the one read a run
acts on, is §13.5's ([§13.5][s13-5])."

**P2-27** (RULING; F, G; inherited doubles brought closer by the moves).
None is wrong, and each could become a pointer or be cut.
- The operator path is the control plane: 624–625 (moved up by M51) and
  695–696.
- The termination record carries the ending policy: 718–720 (kept from "Why
  one binding site") and 801–802.
- `StopRequest` holds no privilege: 648 "whoever publishes it", 684–685
  and 1019–1020.
- "The library's spelling of a request": 657, 660 (bold) and 1017.
- `show(::Structure)` prints the face routes: 962, 981–983 (bold) and
  986–987.
Proposal: cut 695–696's sentence and 657's "the library's spelling of a
request". Reduce 1019–1020 to the pointer already at 1018.

**P2-28** (EDITORIAL; F; 762–763). "the recorded source" comes before
"source" is defined (800, 809). Fix: "When two sources hold at one boundary,
the [termination record] names the first in that order
([D-203][d-203])." The record is already linked at 718, so add no second
link.

**P2-29** (EDITORIAL; G; 1314–1317 and F; 653). Two define-before-use
slips.
- `Dual` is used at 1314 and 1316 and glossed at 1317. Fix: put "`Dual`
  being ForwardDiff's dual number" at 1316 and end 1317 at "genericity".
- 653 "gathered at its owning boundary" uses *boundary* in the structural
  sense two sentences after 641 glossed it as a published consistency
  point. Fix: "gathered at the boundary of the assembly that owns it, in one
  visible block".

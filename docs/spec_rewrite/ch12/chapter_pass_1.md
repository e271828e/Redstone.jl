# Chapter 12, step 5: the chapter pass, half 1

Scope: `chapter_new.md` lines 1–650 (the opening, §12.1 to §12.4; units A
and B), read against `chapter_old.md` 1–581. The other half was grepped, not
read. Lines are `chapter_new.md` lines. Old spec text is quoted from the
frozen `scratch_survey/h1/spec.md`.

Counts: 35 findings, 25 EDITORIAL and 10 RULING. Of the two step 4 carry
items, the unit B item is P1-11. The unit G item (line 1341, "arm. One grid
is thus an invariant of") falls in half 2 and is left to that pass.

## RULING

**P1-1. Line 90, unit A. `step!` "never waits" contradicts the section.**
§12.1 says "`step!` takes neither and never waits". Lines 64–65 of the same
section say "`step!` shares the frame top and blocks the same way, until
`resume!` or a stop from another task". F79 scoped the same claim in §12.6,
which now reads "it never waits on the pacer, whatever pace the control
plane holds" (line 895). F79 named only unit F's lines, so §12.1 kept the
unscoped form. Fix: "`step!` takes neither and never waits on the pacer."

**P1-2. Line 253, unit A. F17's correction missed one instance.** F17 changed
"skips frames" to "skips boundaries" at line 259, because the counter counts
boundaries. Six lines earlier the idiom still "handles … frames skipped
while transmitting". R10 says to grep for each phrase and fix every
instance. Fix: "boundaries skipped while transmitting".

**P1-3. Lines 230–233, unit A. D-114's bold does not state the order.** The
bold "The order of the two publications is normative" says only that an
order is ruled. The order itself, that the `latest` release-store comes
before the counter increment, is in the next sentence and is plain.
`spec_style.md` asks for the headline clause, the shortest clause that
states what is decided. D-114's Position: "publication order is normative:
the release-store of `latest` happens before the counter increment under
the lock". Fix: make the first sentence plain, and bold "**The
release-store of [`latest`](#g-latest) (gloss) ([§11.2][s11-2]) happens
before the counter increment under the lock**" with `([D-114][d-114])` at
the end of that sentence.

**P1-4. Lines 53–55 (unit A) and 1034 (unit F). D-255 bullet 4 is bold in
two places.** §12.1 bolds "`ControlRequestedStop` sits outside the stop
policy" and §12.6 bolds "The stop policy is declared per advance". Both
come from D-255 bullet 4. Unit A's `rulings.md` flagged this, and no ruling
after step 3 settles it. Under the bullets reading of the one-bold test,
that is one ruling bold twice. Fix: the orchestrator rules which reading
applies. If bullets, keep §12.6's bold, since there the advance's policy is
described, and make §12.1's plain with its citation.

**P1-5. Lines 337–338 and 419–420, unit B (also line 98, unit A). The cap's
home is stated three times in the half.** Step (5) says "The cap lives on
`Control`, the tail's own owner ([§12.1][s12-1], [D-256][d-256])". Line
419–420, which F6 dictated, says "The cap therefore lives on `Control`, not
on the `Deployment` ([D-256][d-256])". §12.1 bolds it at line 98, and §12.6
points at §12.1 (line 814). Two statements within §12.4 are one too many.
Fix: in step (5), drop the sentence and fold the pointer into the next one:
"It is a keyword of the `Simulation` constructor, held on `Control`
([§12.1][s12-1]), a positive real …". Keep line 419–420 as F6 dictated.

**P1-6. Lines 346, 579 and 622, unit B. "Sweep" names two things in one
section.** Line 579 links [sweep](#g-sweep) and glosses it as "one pass
through the execution order". Lines 346 and 622 use "the run's-end sweep",
the loop's final collection of every diagnostic cell (D-201, "the loop
sweeps every cell once more at the run's end"). The run's-end sweep is
established spec vocabulary: four uses in the frozen spec, among them §13.5
10430 and Appendix C 13478. Renaming it is outside this chapter. Fix:
either leave the name and gloss it at line 346 (P1-13), or have track 2
rename it spec-wide, for example "the run's-end collection". Line 413's
third sense is P1-22.

**P1-7. Line 158, unit A. Two links without a gloss in the E2 text.** The
links to `snapshot` and `staging cell` are the first uses of those terms in
§12.2, and neither has a gloss. R2 freezes old 8711–8716 apart from a
rewrap, and unit A's `rulings.md` left them unglossed for that reason. Fix:
the orchestrator either lets the glosses in ("a [snapshot](#g-snapshot)
acquire-load (a read of the immutable per-boundary publication)" is
clumsy) or moves the links to the next uses outside the frozen lines. Line
163 "stale snapshots" can take the snapshot link with its gloss. The staging
cell has no later use in §12.2. Otherwise both wait for E2.

**P1-8. Line 461, unit B. A code line of 131 columns.** R19's comment made
the init sketch's `report!` line 131 columns wide. The old line was 95. The
rest of the block stays within 87. Comments change only by ruling. Fix:
move the comment onto its own line above the call:

```julia
            # pre-spawn: the entry is the address, no task holds a handle yet
            report!(entry, DeviceCrash(e, entry.should_abort))
```

**P1-9. Lines 313–315, unit B. The issuers are listed in §12.1 and again in
step (1).** "The control-plane stop's issuers are a front end
([D-310][d-310]), a device handle, code, or an operator interrupt" repeats
§12.1 lines 34–37. The old text had both, and R2 edited both, so they are
not an artefact of the moves. Low priority. Fix, if wanted: "The
control-plane stop's issuers are those of [§12.1][s12-1], an operator
interrupt among them (Ctrl-C, treated below)."

**P1-10. Lines 270–282 (unit A) and 1145–1147 (unit G). The three indices
are stated in both halves.** R17's sentence in §12.7 restates §12.3's
paragraph and cites only §10.4. Low priority. Fix: add
`[§12.3][s12-3]` beside `[§10.4][s10-4]` at line 1147, so §12.7 points at
the chapter's own statement.

## EDITORIAL

**P1-11. Line 318, unit B (carry item). The frame link sits on its second
use, and its gloss sentence splits the sequence.** "…which a stop at
[`t*`](#g-t) (the localized event time) places inside a frame. A
[frame](#g-frame) is one iteration of the loop. The loop then publishes…".
Fix: "…places inside a [frame](#g-frame), one iteration of the loop. The
loop then publishes the final snapshot." The apposition keeps the sentence
to one parenthetical and puts the link on the first use.

**P1-12. Lines 561–563, unit B. The control plane is glossed twice in
§12.4.** Step (1) glosses it at line 308–309. Line 562 repeats the gloss as
an appositive: "the control plane, the separate atomic surface carrying
pause, pace and stop ([§12.1][s12-1])". Fix: "The stop already rides on the
control plane ([§12.1][s12-1])." This also mends the ragged wrap at 562.

**P1-13. Lines 346 and 532–533, unit B. Two reader-cold names.** "Tail
residue" at 532 has no gloss or pointer. §13.5 defines it (frozen 10430):
"the post-account diagnostics the run's-end sweep folds in". "The run's-end
sweep" at 346 also arrives unintroduced. Fix at 346: "The run's-end sweep
(the loop's last pass over every diagnostic cell) collects…", from D-201's
"the loop sweeps every cell once more at the run's end". Fix at 531–533:
"…whose terminal snapshot is the one the run started from, and whose
termination record holds the `DeviceCrash` in its tail residue, the
diagnostics the run's-end sweep folds in ([§13.5][s13-5])."

**P1-14. Lines 344–345, unit B (also lines 15–16, unit A). Glosses disagree
across sections.** The diagnostic cell is "a writer's own holding place for
runtime diagnostics and liveness" in §12.2 (185–186) and §12.6 (811–812).
In §12.4 it is "each writer's bounded ring of diagnostics and its
heartbeat". That gloss is also inexact. Per the glossary, the cell *holds*
a bounded ring plus suppressed counts and a heartbeat timestamp. Fix at
344–345: use §12.2's gloss. Smaller case: §12.1 glosses drains as "the
points where the loop applies staged device writes", §12.2 as "the
frame-top swap that applies staged device writes". The glossary says "the
single point at the top of each frame". Fix: use §12.2's wording in §12.1.

**P1-15. Lines 13–32, unit A. §12.1's context paragraph opens on rules, not
on the problem.** The paragraph begins "The control plane … is not staging,
structurally ([D-022][d-022])" and argues determinism before it says what
the plane carries. That comes only in the second paragraph ("Pause,
un-pause, pace changes, `margin` changes and stop are a few scalar fields
on that separate atomic surface"). The section template puts context first.
Fix: open with the second paragraph's first sentence, carrying the link and
gloss: "Pause, un-pause, pace changes, `margin` changes and stop are a few
scalar fields on a separate atomic surface, the [control
plane](#g-control-plane) (gloss). It is not staging, structurally
([D-022][d-022]). Staged writes apply at …". The second paragraph then
starts "The loop consults them at frame top…".

**P1-16. Lines 22–25, unit A. The parts sentence ends in two appositives
with a citation between them.** "…and the fields of `Control`, one of the
periphery's own types ([D-256][d-256]), the one that holds the control
plane." Fix: "…and the fields of `Control`, the periphery's own type that
holds the control plane ([D-256][d-256])."

**P1-17. Lines 42–43, unit A. The stop word's gloss sentence repeats the
bold.** "**The stop word carries its issuer** ([D-203][d-203]). The stop
word is the control plane's stop command, one atomic word holding its
issuer." The second sentence says "holding its issuer" right after the bold
said it. The brief lets a dictated wording be fitted to its sentence while
keeping its claims, and the bold keeps this one. Fix: "The stop word is the
control plane's stop command, held in one atomic word."

**P1-18. Line 17, unit A. The trace link in §12.1 has no gloss.** "Riding
outside the drain/[trace](#g-trace) path" is the term's first use in the
section. Fix: "Riding outside the path through the drain and the
[trace](#g-trace) (the primary record of a session) is safe for
determinism…".

**P1-19. Line 352, unit B (also line 274, unit A). Glossary terms used
throughout a section and never linked.** `should_abort` appears in §12.4 at
352, 487, 517–524 and in the sketch. Its anchor `#g-should_abort` is linked
only in §11.6. Fix at 352: "With [`should_abort`](#g-should_abort) (the
per-attachment failure policy, an `attach!` keyword) set, …". In §12.3,
"the log" at 274 is unlinked. Fix: "whether the [log](#g-log) (the retained
sequence of published snapshots) or a post-run inspector". Note only:
*periphery* (`#g-periphery`) sits unlinked inside the device gloss in every
section from §12.1 to §12.4.

**P1-20. Lines 168, 186, 223, 232, 345, 514, 582 and 638, units A and B. A
gloss and a citation sit in two touching parentheses.** For example, "the
frozen [roster](#g-roster) (the list of attached device entries)
([§11.3][s11-3])". That makes two parentheticals in one sentence, against
`spec_style.md`. Chapter 10 has one such case and chapter 11 four. Fix:
turn the gloss into an appositive, as line 182 does for framework status:
"the frozen [roster](#g-roster), the list of attached device entries
([§11.3][s11-3])". Where the sentence continues, move the citation to the
clause's end instead (232: "…happens before the counter increment under the
lock ([§11.2][s11-2])").

**P1-21. Line 406, unit B. "The default of five seconds" has no near
antecedent.** The old label ("Why the default is five seconds") is gone. The
default it explains was last named in step (5), about 65 lines earlier, and
two paragraphs on `t_end` and the log now come between them. Fix: "The
`join_timeout` default of five seconds is generous for front-end window
teardown and socket closes."

**P1-22. Lines 412–413, unit B. "Deployment contexts" and "an unattended
sweep".** Line 412 opens "Deployment contexts legitimately differ in
patience", two sentences before F6's "not on the `Deployment`". At the start
of a sentence, the capital reads as the type. Unit B proposed "Usage
contexts" and no ruling took it up. Line 413's "unattended sweep" means a
series of runs. That is a third sense of *sweep* in §12.4 (P1-6), and it
echoes the [unattended run](#g-unattended-run) the section links at 571.
Fix: "Usage contexts legitimately differ in patience. A series of
unattended runs wants to fail fast, …".

**P1-23. Lines 410–412, unit B. D-198 is cited twice in two sentences.**
"…not an implementation constant** ([D-198][d-198]). That is the
disposition [§10.4][s10-4] gives its own two constants, extended here to an
operational one ([D-198][d-198])." Fix: drop the second citation.

**P1-24. Lines 386–388, unit B. The `t_end` landing is stated a third
time.** "The run takes whole frames until the boundary time first covers the
duration" repeats lines 381–383 ("first grid boundary whose time reaches or
exceeds `t_end`", "whole frames only"). It is also verbatim §12.6's `t_plus`
rule (line 898–899), which R5 makes §12.6's home. The pointer before it
already sends the reader there. Fix: delete the sentence.

**P1-25. Opening, lines 5–6, unit A. The roadmap leaves out the heartbeat.**
"[§12.2][s12-2] loop scheduling, in turn its wait primitive, its yields and
the thread budget" leaves out §12.2's fourth subsection, the liveness
heartbeat. R1 asks for each section by subject. Fix: "…its yields, the
thread budget and the liveness heartbeat".

**P1-26. Line 88, unit A. Bare *entry*.** "`run!` and `replay!` take both as
keywords and write them at entry." *Entry* is reserved and never bare. Fix:
"…and write them when called."

**P1-27. Line 30, unit A. `h/p` is used before `p` is introduced.** "At most
one frame budget `h/p` later" comes 53 lines before `pace!(sim, p)`. Fix:
"at most one frame budget (`h/p`, the step over the pace) later". Or keep
"one frame budget later" and leave `h/p` to [§10.7][s10-7].

**P1-28. Line 244, unit A. "The device side's predicate" names half of
it.** "The device side's predicate, `counter > last_seen` (below)" calls
the predicate the first conjunct alone. Line 252 gives the predicate as
`counter > last_seen && running`. Fix: "The device side's test `counter >
last_seen` (below) therefore implies…".

**P1-29. Line 260, unit A. "CAS" is unexpanded.** The coalescing gloss "the
CAS merge that leaves one pending batch per device" uses the abbreviation
cold. §12.1 spells out "compare-and-swap". Fix: "the compare-and-swap (CAS)
merge that leaves one pending batch per device". This also brings line 261
(82 rendered columns) back under 80 once it is rewrapped.

**P1-30. Line 146, unit A. "The scheduler stall" arrives with a definite
article and no antecedent.** F16 replaced "Julia's cooperative-scheduler
freeze" with "Julia's scheduler is cooperative, and the scheduler stall
requires a thread monopolist". Nothing before it names a stall. Fix: "…and
a stall of that scheduler requires a thread monopolist…". Line 155's "The
scheduler stall" then has its antecedent.

**P1-31. Lines 524–528, unit B. The pending-stop paragraph states its
conclusion before its reason and says "already" twice.** "…that stop is
simply *already pending* at the run's first frame top. This protocol already
has that path. The loop reads that stop at the frame top, before any frame,
so the run advances no frame. No new exit protocol is needed, therefore."
Fix: "…that stop is simply *already pending* at the run's first frame top.
The loop reads it there, before any frame, so the run advances no frame.
This protocol already has that path, so no new exit protocol is needed."

**P1-32. Lines 492–498, 500–506, 508–515, 537–547, 575–584 and 620–627,
unit B. A bold rule stands as a one-sentence paragraph, cut off from its
reason.** These are the old **Rule.** paragraphs with the label removed and
the split kept. "That needs no machinery" (503) and "This is the
death-is-not-detach disposition" (510) open paragraphs whose subject is the
previous one-sentence paragraph. `spec_style.md` says "A reason follows its
rule with a plain connective." Fix: join each rule paragraph to the one
after it. At 578, "The reason is that an `InterruptException` is delivered
asynchronously" then reads as a continuation.

**P1-33. Line 634, unit B. "The published record" next to the termination
record.** In §12.4 "the record" bare means the termination record (613,
618), and the same paragraph names its source. "The published record is
consistent, since the frame published nothing" means the published
snapshots. Fix: "What the run published is consistent, since the frame
published nothing."

**P1-34. Lines 188, 247 and 261, unit A. Wrap.** Line 247 holds only
"stale. The". Line 188 ("The diagnostic cell carries the single liveness
timestamp.") is left from an insertion and breaks the paragraph's fill.
Line 261 is 82 rendered columns (P1-29). Fix: rewrap the three paragraphs
at 80 rendered columns.

**P1-35. Lines 649–650, assembly. Two blank lines before §12.5's heading.**
Fix: one blank line.

## Checked and found sound

- The roadmap's other six sections match the headings and their content.
- The R5 pointers in the half: `t_plus` (§12.6, line 895–899),
  `CheckpointMidFrame` after an abandoned frame (§12.6, 975–977), the harness
  mode (§12.6, 902), `join_timeout` (§12.6's ownership list points back),
  the unmask points and the tail (§12.4 586–590 and 301 onward), and the
  `:done` init failure (§12.2, 197–198). Each target states the claim.
- The R8, F4, F10, F14, F20, F22 and F23 corrections hold wherever their
  phrases recur in the half. The remaining instance is F17 (P1-2).
- Bold: no other cross-half or cross-chapter double besides P1-4. §10.7's
  bold on the 2 ms `margin` (frozen 6723) matches §12.1's plain mention.
- Unit B's other open correction (`disable_sigint`) and unit A's ("a few
  scalar fields") are known to the orchestrator and are not raised again.

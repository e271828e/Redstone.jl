# Chapter 11, chapter pass, half 1 (lines 1–940, units A to D)

Read whole against `spec_style.md`, `brief.md` (R1–R32) and `chapter_old.md`
1–802. The other half was grepped, never read whole. Line numbers are
`chapter_new.md`'s. 37 findings: 7 RULING, 30 EDITORIAL.

Checked and clean, so not listed: R13's drain gloss (identical in §11.1,
§11.3 and §11.4); *frame* linked once in each section; the parts sentences of
§11.1, §11.2, §11.3 and §11.4 against their sections and labels; no ruling in
the half is bold in the other half or in the frozen spec's other chapters
(Appendix A's "Levels, never deltas" is an index label citing §11.4, not a
ruling); D-022's four bolds, D-024's four and D-047's three are distinct
Position rulings; every repeated claim I grepped across the split (status
contents, terminal snapshot, `totals`, `EmptyGreedyClaim`, the standard GUI
binding, the orphan, `map_output`'s NamedTuple, D-201's account) has one home
and a pointer, as R5 and R30 set out.

## Findings

**P1-1.** Lines 9–10, unit A. EDITORIAL. The roadmap calls §11.8 "the third
cross-task channel", but it named the first two "data channels" and never
called them cross-task channels. So "third" counts nothing the reader has
been given. The roadmap also drops "representation" from §11.4's title.
Fix: "…; and [§11.8][s11-8] runtime diagnostics and liveness, a third channel
between tasks beside the two data channels." Optionally "its per-device
staging, staged representation and drain".

**P1-2.** Lines 21–22, unit A. EDITORIAL. The gloss "a boundary being a
published consistency point" is wedged between the rule and its "because".
That reads worse than the old text. Fix: "That lock does enforce the
[boundary](#g-boundary)-visibility rule ([§10.3][s10-3]), because the lock is
only ever free between steps. A boundary is a published consistency point."

**P1-3.** Line 32, unit A. EDITORIAL. The paragraph opens "The replacement has
five planes." and then talks only about the frame. The list it introduces
comes after the paragraph. Fix: open with "The replacement's unit of account
is the [frame](#g-frame) (…)". Put "The replacement has five planes." on its
own line just before the list.

**P1-4.** Lines 55–56 and 85–86, unit A. EDITORIAL. The topology is stated
three times in 30 lines: plane 5, the bold "The loop runs on the calling
task", and the next sentence, "The calling task runs the loop itself, and
every rostered device runs on a spawned task." That last sentence used to
carry the calling-task gloss, which now sits in plane 5. Fix: cut it. "This is
what the synchronous rethrow presupposes" then binds to the bold headline.

**P1-5.** Lines 65–66, unit A. EDITORIAL. "which makes these patterns hard"
has no antecedent (unit A's open question 4, still unfixed). "RCU" is never
expanded. Fix: "(hazard pointers, epochs, read-copy-update grace periods)
which makes lock-free handoffs hard in non-GC languages."

**P1-6.** Lines 109–110, unit A/B seam. EDITORIAL. There are two blank lines
before `### 11.2`. Fix: keep one.

**P1-7.** Lines 55–56, 80, 85; 118–119, 127; 384–388, 428, 568; units A, B,
C. RULING. A preview states a ruling plain before its bold. Plane 5 states
D-093's and D-310's rulings before the bolds at 80 and 85. §11.2's context
says "One immutable value is published per boundary, handed out through a
single atomic reference" before the D-023 bold at 127. §11.3's context states
exclusivity and the per-run freeze before the bolds at 428 and 568. Under
`spec_style.md`'s mechanical test, the first statement in reading order keeps
the bold. Proposed ruling: a context paragraph or an overview list that the
section later restates in full is a preview, and the bold stays at the full
statement. The section template puts context before rule, so the test cannot
mean to pull bold into context. No text change if ruled so.

**P1-8.** Lines 148, 155 (and 331 onward), unit B. RULING. "The binding rule"
(nothing reachable from a snapshot is written again) and
[binding](#g-binding) (the value passed at `attach!`) share one section.
In the old text, "**Binding rule:**" read as a label. The new "The binding rule
states that" makes it a name, which clashes with the glossary term 180 lines
later. The name also appears at §11.8 (1805, 1808), spec old 8304 and D-136
Rejected (log 4440). Fix if ruled: "the immutability rule" at 148, 155, 1805
and 1808, with the log following in track 2. Otherwise hold.

**P1-9.** Lines 160 and 163–164, unit B. EDITORIAL. The port gloss "(each one
declared name with its cell)" is garbled. The cell gloss "(the typed entries
of the signal table)" uses bare *entry*, and it is circular with the
signal-table gloss at 130 ("the cells holding every produced signal"). Fix:
"[ports](#g-port) (the addressable unit, one declared name with one cell)" and
"[cells](#g-cell) (the signal table's typed value holders, one per output
port, [§8.3][s8-3])". The second fix also merges the two §8.3 citations three
lines apart.

**P1-10.** Lines 171 and 358, unit B. EDITORIAL. *face* is first used at 171
("the root component's own input faces") but linked and glossed at 358. Fix:
link and gloss at 171, "own input [faces](#g-face) (the names ports wear on
their component's boundary)". Unlink 358 and drop its gloss.

**P1-11.** Line 182, unit B. RULING (bold). "**The snapshot deliberately does
*not* carry the state stores (`x`, `s`, `m`)**" bolds the store list. Fix:
"**The snapshot deliberately does *not* carry the state stores** `x`, `s` and
`m` ([D-038][d-038])."

**P1-12.** Lines 283–288, unit B. RULING (bold). After M3, the third guarantee,
"The endpoints below are kept.", sits directly before the bold "The endpoints
are retained unconditionally". "below" now points at the next sentence, and
the plain sentence states the ruling first. Fix: end the guarantees with
"Coverage is global at the effective stride. And **the endpoints are retained
unconditionally** ([D-137][d-137])." Then open the next paragraph plain:
"The run's first snapshot and its terminal snapshot ([§12.4][s12-4],
[§13.5][s13-5]) survive any `log_every` …".

**P1-13.** Line 292, unit B. EDITORIAL. "the snapshot the door publishes under
`restore!` and `replay!`". *Door* is §12.6's word, with no glossary entry, so
it is reader-cold here. Fix: "and the snapshot `restore!` or `replay!`
publishes as it builds the run ([§12.6][s12-6])".

**P1-14.** Line 319, unit B. EDITORIAL. `totals` is never introduced in
§11.2. Fix: "The monotonicity of `totals`, the status's cumulative
per-writer counters, across logged snapshots ([§11.8][s11-8]) is untouched."
The source is §11.8 line 1830.

**P1-15.** Lines 352–354, unit B. EDITORIAL. "Every cell is reachable,
because the table is public throughout" and "An intermediate a device wants
to stream is one promoted to a declared output" restate 159–166 in the same
section. Both were in the old text. Fix: cut the second sentence, or reduce
it to "(promotion, above)".

**P1-16.** Lines 384–402, unit C. EDITORIAL. Three issues:
(a) *root input* is used twice in the context paragraph (384, 386) before its
link at 396.
(b) It is glossed twice at 396–399: first the parenthetical "(the inputs no
component produces)", then the definition sentence. Line 402 repeats
"produced by no component".
(c) The inserted component/face gloss sentence (400–401) now sits before "It
is routed inward…", so "It" can bind to *a face*.
Fix: link and gloss at 384, "[root inputs](#g-root-input) (the root
component's own input faces)". Drop the parenthetical at 396–397. Start 401
with "A root input is routed inward…".

**P1-17.** Lines 393 and 462, unit C. EDITORIAL. The labels "The write surface"
and "Write surfaces and claim sources" nearly repeat each other. The first
part is about what root inputs are and how writers name them. Fix: retitle it
"Root inputs". The parts sentence at 389 then reads "root inputs, exclusivity
and claims, …".

**P1-18.** Line 415, unit C. EDITORIAL. "through the resolution" is
reader-cold. Fix: "through port resolution ([§11.7][s11-7])".

**P1-19.** Lines 416–418, unit C. EDITORIAL. "The trace is the primary record
of a session." stands as its own sentence. It cuts the face-name versus
slash-path argument in two. Fix: "Devices, mappings, the [trace](#g-trace)
(the primary record of a session) and the GUI write path address root inputs
by face name ([§8.6][s8-6])." The sentence carries no other parenthetical.

**P1-20.** Lines 437–441, unit C. EDITORIAL. "CAS" is never expanded in
§11.3. The coalescing gloss "(the CAS merge keeping one pending batch per
device)" follows a list that already named "the CAS merge", so the CAS merge
seems to serve itself. Fix: "…, the compare-and-swap (CAS) merge and the
atomicswap drain all stay. They serve atomicity and
[coalescing](#g-coalescing) (keeping one pending batch per device), not
arbitration."

**P1-21.** Lines 480–481 and 532–534 against 836–843, units C and D. RULING
(placement). Two staging diagnostics are stated in both §11.3 and §11.4:
`OutOfClaimEntry` for a device's out-of-claim face, and `ClaimedFaceEntry` for
a harness write to a claimed face, cited to D-174 at both sites. The old text
did the same, and survey 1's part B did not list it. Proposed: §11.4's
"Diagnostic sites" is the home, and §11.3 keeps its clauses with a
[§11.4][s11-4] pointer. Or hold as both.

**P1-22.** Lines 516–518 and 524, unit C. EDITORIAL. Two issues:
(a) The harness writer's gloss "(the one writer whose surface is derived, not
claimed)" anticipates the topic sentence at 529, which states the same thing
with its citation.
(b) "a task-free entry point" followed by "stages a batch from any task"
reads as a contradiction after R4.
Fix: gloss "(the framework-owned writer beside the roster)", and write "an
entry point with no task of its own". Note for landing: the glossary entry
still says "the framework-owned write path of the calling task", which R4
made stale.

**P1-23.** Line 579, unit C. EDITORIAL. "(entries, claims, attachment order)"
uses bare *entry*. Fix: "(roster entries, claims, attachment order)".

**P1-24.** Line 585, unit C. EDITORIAL. "a stable device id" is used before
"Device identity and admission" (602) introduces it. Fix: "a stable device id
(described below)".

**P1-25.** Several lines, units A to D. EDITORIAL. These glossary terms have no
link at their first use in a section. Check `check_glossary.jl`'s WHITELIST
before applying.
- *batch*: §11.1 line 46 ("the staged batches"), §11.2 line 185, §11.3 line
  395.
- *greedy claim*: §11.3, the claim mechanism's home under R5, at its first
  use (485, "`is_greedy(b) = true`", or 501, "greedy claimant"). It is linked
  only in §11.4 (807).
- *activation*: §11.3 line 545.
- *probe*: §11.3 line 546.
- *boundary*: §11.3 line 638.
- *snapshot*: §11.4 line 887.

Each takes its glossary gloss.

**P1-26.** Lines 664–666, unit D. EDITORIAL. "(the CAS merge, CAS being
compare-and-swap, that keeps …)" nests a gloss inside a gloss. Fix: "(the
compare-and-swap, or CAS, merge that keeps one pending set of writes per
device)".

**P1-27.** Lines 674–676, unit D. EDITORIAL. The face gloss sits between the
bold and its citation: "…newest wins per face** (the name …) ([D-104])".
That makes two parentheticals in a row. Fix: end the bold sentence at
"([D-104][d-104])". Move the link and gloss to 681, "Untouched
[faces](#g-face) (the names ports wear on their component's boundary)
survive".

**P1-28.** Line 682, unit D. EDITORIAL. "the per-face ZOH" is never expanded in
the chapter. The spec expands it elsewhere (old 746, 6066). Fix: "That is the
per-face zero-order hold (ZOH)."

**P1-29.** Lines 683–689, unit D. EDITORIAL. R4's harness sentence comes right
after "Intercepted writes are already applied, and must not be re-staged". So
"is the exception" reads as an exception to re-staging. It is meant as an
exception to the single writer and the bounded retry. Fix: move the sentence
to follow "so the retry is bounded". Or write "is the exception to the single
writer, since several tasks may stage into it concurrently, …".

**P1-30.** Lines 697–699, unit D. RULING. "The worked example at the end of
this section works that hazard through. A pending `flaps` edit is clobbered
…". The example has no `flaps` or `gear` (unit D's open question). Splitting
the old colon also makes the clobber read as a free-standing fact. Proposed:
"Under overwrite, a pending `flaps` edit is clobbered by an unrelated `gear`
message, undrained and undiagnosable. The worked example's corrections name
the hazard."

**P1-31.** Lines 721–723, unit D. EDITORIAL. "…on the device task, as the
shared pure helper with an owner" is ambiguous ("as" what?). It reads worse
than the old "That is the shared pure helper, with an owner". Fix: "…in its
generic `map_input` on the device task. `TableBinding` is the shared pure
helper, with an owner ([§11.6][s11-6])."

**P1-32.** Lines 744–747, unit D. EDITORIAL. "…are both known at attach. Both
are known because …" repeats itself. Fix: "…are both known at attach, because
`claims(binding)` ([§11.6][s11-6]) is read against the root
[contract](#g-contract) (the root component's declared interface)."

**P1-33.** Lines 756–758, unit D. EDITORIAL. "roster entry (the writer's record
…) ([D-104])" puts two parentheticals in a row. Fix: "The writer's
[roster](#g-roster) entry, its record in the list of attached devices, holds
the face-name → position schema ([D-104][d-104])."

**P1-34.** Lines 853–859, unit D. EDITORIAL. The drain section says taken cells
apply "in attachment order" and never mentions that the harness cell drains
last (§11.3, 541). A reader of "The drain" alone misses it. Fix: "…through its
compiled scatter, in attachment order, the harness cell last
([§11.3][s11-3], [D-024][d-024])." This is a pointer, not a new claim.

**P1-35.** Lines 882–883, unit D. EDITORIAL. The port gloss "(a port being the
addressable unit of the model)" lands after "panel reuse", away from "port",
as an absolute phrase. Fix: end the sentence at "panel reuse" and add "A port
is the addressable unit of the model."

**P1-36.** Lines 880–883 against 935–936, unit D. RULING (R7 froze the rest).
R7's framing sentence now names the same two products as the Discoveries
bullet, almost word for word. Proposed: Discoveries keeps only its second
sentence, "*Discoveries.* The port-resolution answer came from asking how the
filter's panel survives …". Or hold under R7.

**P1-37.** Wrap, units B to D. EDITORIAL.
- Over 80 rendered columns: 172 (87), 333 (94), 369 (86), 384 (91),
  386 (91), 657 (117), 666 (121), 668 (83), 808 (122).
- Ragged mid-paragraph lines, from verifier patches: 133–135, 161–164,
  186–187, 411–413, 417, 428–431, 437–438, 452, 458, 494–498, 509–510,
  632–633, 674–680, 869–870, 887–888.

Fix: reflow those paragraphs to 80 rendered columns. Unit A's §11.1 is clean.

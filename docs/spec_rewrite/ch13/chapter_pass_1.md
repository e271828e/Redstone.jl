# Chapter pass, half 1 (units A and B, `chapter_new.md` lines 1–612)

Read against `chapter_old.md` 1–534, `brief.md` R1–R30, `spec_style.md`,
`checks/brief_common.md` and the frozen spec. Scratch scripts are in
`scratch_step5/pass1/`.

Checks that found nothing:

- The roadmap names §13.1 to §13.8 in order. Each subject matches its
  section. P1-1 is about wording only.
- No ruling is bold twice. Every D-entry bold in half 1 was grepped against
  half 2 and the frozen spec's other chapters. D-128, D-250, D-317, D-341 and
  D-274 are bold elsewhere only for other bullets or sentences of their
  Positions.
- The R5 pointer targets state what the pointers leave out: §9.2 (warnings,
  `warnings(x)`, throw or complete), §6.1 (D-207, D-084), §12.4 (the forced
  throw's disposition, D-398), §11.8 (the ring as rate limit, D-136) and §11.6
  (`MalformedDatum`, `should_abort`, D-105).
- R4's split pairs hold across the halves: "retained", "promote",
  `UnboundedRun` and `SimulationTermination`. No glossary link appears twice
  in one section.

## Findings

**P1-1.** Lines 5–11, unit A. EDITORIAL. The roadmap gives §13.4 as "the
runtime failure story", which is vague. It gives §13.3 as "the build
primitives, `resolve` and the face-list accessors", which leaves out the
section's main subject, how resolution is scoped by client. Fix: "[§13.3] the
build primitives and how path resolution is scoped by client; [§13.4] how a
runtime failure is caught, carried and reproduced".

**P1-2.** Lines 41 and 47, unit A. EDITORIAL. One bullet glosses probes as
"evaluations of a user function with real values". Six lines later it glosses
probe values as "the fabricated values a build-time probe runs on". A cold
reader sees a contradiction. Fix: use the shorter gloss the spec already uses
at line 3111, "(the build's single evaluations of a user function)".

**P1-3.** Line 43, unit A. EDITORIAL. In "the activation at `T`", the `T` is
introduced nowhere in the chapter. Fix: "the activation at the scalar type
`T`".

**P1-4.** Line 65, unit A. EDITORIAL, low. "An unreadable or mixed class" uses
*class* in its glossary sense (`ClassUnreadable`), but the word is not
linked. Fix: "[class](#g-class) (a component's primitive-vs-assembly
status)".

**P1-5.** Lines 103–105, unit A. EDITORIAL. §13.2 glosses did-you-mean as
"the offending name plus the list it should have matched". §13.1 (line 79),
§13.3 (line 344) and Appendix D all say "the list-in-hand". The gloss also
sits after "a did-you-mean needs", so it reads as a gloss of *list-in-hand*.
Fix: use the glossary words, and attach the gloss so it clearly follows
"did-you-mean".

**P1-6.** Line 114, unit A. EDITORIAL. `StepError` first appears here,
undefined. Line 125 is where it is introduced as the runtime carrier. Fix:
"`BundleFieldError`, for example, is raised at the probe and, at runtime, as
a species of the runtime carrier `StepError` ([§13.4][s13-4]). A species is a
`StepError` whose `cause` is a diagnostic." Moving the gloss into its own
sentence keeps its claim. Check it reads correctly on its own.

**P1-7.** Lines 149 and 154, unit A. EDITORIAL, low. "The first is strings,
never instances." reads worse than the old bold label. Fix: "The first rule
is *strings, never instances*." and "The second rule is that the didactic
style is policy."

**P1-8.** Lines 217–218, unit A. EDITORIAL, low. "Slot" is on the list of
log words never to import (`brief_common.md`). Fix: "so the
*collected*-warning category stays open and empty".

**P1-9.** Lines 232–239, 267 and 285, unit A. EDITORIAL. Bare *cell* is used
for the diagnostic cell: "the cells" at 233 and 239, "the device's own cell"
at 267, "the loop's own cell" at 285. Bare *cell* means only a signal-table
cell. Separately, "The stream is per-occurrence" (232) has no antecedent. Fix:
"the diagnostic cells" and "own diagnostic cell". Open the paragraph's second
sentence with "The runtime's warnings form a per-occurrence stream."

**P1-10.** Line 247, unit A. EDITORIAL. "`ChatteringBudget`, chattering, or
localization-budget exhaustion" reads as a list of three items. Fix:
"`ChatteringBudget`, for [chattering](#g-chattering) or localization-budget
exhaustion".

**P1-11.** Lines 280–283 against 604–607, units A and B. RULING. The crash
path appears twice, almost word for word, in two sentences each. R4 asks for
one clause each. At line 280, "A genuine bug" also has no antecedent inside
the index. Fix: the §13.2 line becomes "`DeviceCrash`, a device crash
([§12.4][s12-4], [§13.4][s13-4]). The framework wrapper catches a device
task's failure, and the run goes on without the device unless its attachment
set `should_abort` ([§11.6][s11-6])." "A genuine bug takes the per-device
crash path" stays in §13.4 alone. `should_abort` then needs its §13.2 link
(P1-29).

**P1-12.** Line 228 against line 783, across the split. EDITORIAL, low. The
diagnostic cell gets two glosses. §13.2 has "the single-writer cell each
writer owns for diagnostics and heartbeat". §13.5 has "the per-writer cell for
runtime diagnostics". Fix: give both Appendix D's words, "the per-writer cell
for runtime diagnostics and liveness".

**P1-13.** Lines 290–294, unit B. EDITORIAL. §13.3's context paragraph
contains the ruling. "**All three are normative…**" comes before the parts
sentence. The template puts context first, and the parts sentence closes the
context paragraph. Fix: end the paragraph with the parts sentence. Open the
next paragraph, the list's lead-in, with the bold sentence and its D-061.

**P1-14.** Line 300, unit B. EDITORIAL. "they return the entries of
`input_wires(c)`" uses bare *entry*, a reserved word. Fix: "they return what
`input_wires(c)` / `output_wires(c)` list".

**P1-15.** Lines 312–314 and 369–371, unit B. RULING. F2 and F3 coin "the
service walk". The term is introduced nowhere, has no glossary entry, and
appears nowhere else in the frozen spec. Line 371 cites §14.3 and §14.4 for
"split their own paths through the service walk", but neither section names a
walk or describes the split. Line 313's "the read side" is also reader-cold.
Fix: introduce the term at line 314 in D-406's words. "It is enforced by the
service walk, the read-selector family's one collecting resolver
([D-406][d-406]), which follows declared field types alongside instances."
At line 371, cite where the claim is stated, or say the pointer's scope.

**P1-16.** Line 324, unit B. RULING, since R17 dictated the wording. "Three
kinds of client" uses bare *kind*, a reserved word. Fix: "Three clients
share one resolution, and each gets the rule its promises require." This
matches line 350's "the three clients".

**P1-17.** Lines 308, 322 and 365, unit B. EDITORIAL. *Rule* names two
different sets. At 308–313 the "two duties" are the one-level rule and the
generic-holding rule. At 322 and 365, "which rule applies" and "the three
rules" mean the three client treatments in the table. Fix at 365: "Which of
the three treatments a client resolves under is internal framework fact".

**P1-18.** Line 331, unit B. RULING (R16). The inspection row reads "snapshot
and log inspection ([D-310][d-310])". That cites D-310 as if it ruled
inspection. D-310 parks the GUI, and the row no longer shows the removal the
citation stands for. Fix: drop the citation, or move it to a clause that
says what it rules.

**P1-19.** Lines 375–381, unit B. EDITORIAL. §13.4's context paragraph uses
"macro-sequence" (377) before line 388 defines it. It also frames the section
as "a runtime failure of model code", but its parts include device-side
failures. Fix: write "the ordinary boundary macro-sequence" at 377, or move
line 388's arrow sentence up. Then "A runtime failure of model code, or of
device code in its own domain, …", or leave that half to the parts sentence.

**P1-20.** Lines 385–388, unit B. EDITORIAL. `Model` is linked without a
gloss. It is defined in the sentence after the bold, between the two catch
statements. Fix: move "The [`Model`](#g-model) is the deployment and its
executor at one scalar" into the context paragraph, with the link there. The
bold then uses the bare term.

**P1-21.** Lines 395 and 465–467, unit B. EDITORIAL (R7). "Framing
information", "unframed" and "the framed path" give *framing* a third sense,
the `StepError` wrapping. §13.2 uses "the framing" for `UserCodeFraming`.
Fix: line 395 "Where execution stood does not need to be *caught* into
existence"; line 467 "…does not move as it does on the path through the catch
site".

**P1-22.** Line 403, unit B. EDITORIAL. The `Outputs` gloss says "the port
classes", which is *class* in another sense. Appendix D says "per component
the output port names each stage produces". Fix: "(the nominal evaluation's
product, the output ports each stage produces and the execution order)".

**P1-23.** Lines 429–431, unit B. EDITORIAL, low. In "A `StepError` carries
… the cursor frame (the copy of the cursor a `StepError` carries)", the R7
gloss repeats its own sentence. Fit the target: "(the cursor's copy at the
catch)".

**P1-24.** Lines 447, 488 and 490, unit B. EDITORIAL. "The guarded sequence"
is never introduced. At 488, "the branch" has no antecedent. Fix: after line
389, add "The code inside that `try` is the guarded sequence." At 488, write
"never reaches the interrupt branch".

**P1-25.** Line 473, unit B. RULING, because it edits a code comment. "# the
cursor's frame at the catch" uses *frame* outside R7's senses. Fix: "# the
cursor frame: the cursor's copy at the catch".

**P1-26.** Lines 537–542, unit B. EDITORIAL. "The pointer is `0`." comes
right after the sentences about a raw `InterruptException`. It reads as that
interrupt's pointer. Fix: move it to line 537: "Its cursor frame comes from
the cursor, its time is `t₀`, its pointer is `0`, and the species rule
applies."

**P1-27.** Lines 550 and 562–563, unit B. EDITORIAL. *Condition* is used in
its glossary sense, §14's word, three times in §13.4 with no link and no
gloss. Fix: at line 550, after the bold, add "[condition](#g-condition) (the
path-addressed sparse overlay that sets a build's state)".

**P1-28.** Line 581, unit B. EDITORIAL. "Placement is the whole value." is an
aphorism as a topic sentence, with the ruling after it. Fix: "**The pass is
the boundary's first act** ([D-157][d-157]), and that placement is the whole
of its value." The bold words do not change.

**P1-29.** Throughout, units A and B. EDITORIAL. 51 of the 71 first-use
glossary links in half 1 have no gloss. Chapter 12 glosses about two thirds
of its links. The ones that matter most:
- §13.2: payload (95, glossed only in §13.4 at 451), carrier exception (121),
  framework status (238), chattering (247), localized (248), drain (257),
  root input (263), device (265), replay (269), trace (271), termination
  record (277). `should_abort` (283) is not linked in §13.2.
- §13.3: port (318), taps, binding and snapshot (330–331), seam (346).
- §13.4: boundary (386), tick (389), component (390), guard (405), RHS (413),
  replay (434), roster (503), termination record (565), buffer (576),
  error-locality (587).

Fix: take the glosses from Appendix D's words, and split sentences where two
glosses would meet (R23). If the unit checks accepted this density on
purpose, the orchestrator says so.

**P1-30.** Wrap, units A and B. EDITORIAL. These lines exceed 80 rendered
columns: 168 (138), 260 (114, carried), 504 (120) and 583 (95). Lines 263 and
375 (carried, unit B line 88) need rewrapping by rendered columns. Lines
286–287 are two blank lines before §13.3. The table rows at 329–331 are
exempt.

## Counts

EDITORIAL 25, RULING 5 (P1-11, P1-15, P1-16, P1-18, P1-25).

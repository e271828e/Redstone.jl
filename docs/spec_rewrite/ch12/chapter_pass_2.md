# Chapter 12, step 5: the chapter pass, half 2

Half 2 is `chapter_new.md` lines 651–1362, §12.5 to the chapter's end
(units F and G). Old text: `chapter_old.md` 582–1151. Line numbers below are
`chapter_new.md` lines. Counts: 10 RULING, 32 EDITORIAL.

Of the two step 4 carry items, unit G's rewrap is P2-39. Unit B's *frame*
link (line 318) sits in half 1 and belongs to that half's pass.

## Findings

**P2-1** (658, 663, 707; F; EDITORIAL). `user_callback!` is used in the
context paragraph (658) and in the survey (663) before the section says what
it is. The introduction comes only at 707 ("FlightCore's unconditional
per-step hook"). Fix: at 658, "eliminates FlightCore's per-step hook
`user_callback!`". 707 keeps its sentence.

**P2-2** (692–694; F; EDITORIAL). Line 693 renders at 84 columns. Fix: rewrap
the bullet.

**P2-3** (700–704; F; EDITORIAL). §11.7 is cited in two adjacent sentences.
"renders the corresponding GUI widgets read-only with its source shown" has
a singular "its" for plural widgets, so it reads as §11.7's source. Fix:
"[§11.7][s11-7] therefore renders the corresponding GUI widgets read-only,
each showing its source. Its port-resolution rule resolves FlightCore's
demo-vs-GUI dead-slider fight." The second citation goes.

**P2-4** (667, 702–703; F; RULING). §12.5 still describes the built-in GUI
as live in the present tense ("renders the corresponding GUI widgets
read-only"). D-310 parked it, and R2's front-end wording covered units A and
B only. Frozen §11.7 says the same, so this may wait for chapter 11's
treatment. Ruling needed: extend R2 to 702–703, or leave it as written. Line
667 is FlightCore history and can stay.

**P2-5** (720–721; F; EDITORIAL). "(first-class services, [§14][s14])" puts
a citation inside a gloss's parentheses. Fix: "Initialization and trim are
stopped-sim workflows, first-class services of [§14][s14]."

**P2-6** (725–726; F; EDITORIAL). This is *sweep*'s only use in §12.5. It
is linked inside the verbatim chain "project → sweep → publish" but has no
gloss. Fix: keep the chain verbatim and add a sentence after it, "A sweep is
one pass through the execution order against the current state."

**P2-7** (746–749; F; EDITORIAL). The context names the section's parts, but
not the last one, "The stop policy per advance" (1032). Fix: add "and the
stop policy each advance declares" to the sentence's list.

**P2-8** (749–757, 771, 865–870; F; EDITORIAL). The context paragraph R13
added states facts that the body states again in §12.6. `feed` is "the
recording `replay!` attached, or `nothing`" at 751–752 and word for word at
771. The mode's two sources (staging cells or the recording) appear at
755–757 and again at 868–870. Because the context's staging-cell gloss uses
"batch" and "drains", both terms are used before their links at 868–869.
Fix: at 771, "`feed` is the attachment described above." At 754–757, keep
"The input mode says where the next frame takes its inputs from" and drop
the sentence on the two sources. At 869, give the staging cells their link
and gloss: "the [staging cells](#g-staging-cell) (where each device's
pending batch waits between drains) or the attached recording". The context
also lists the five states again, and 835 restates them. R13 dictated that,
so it stays.

**P2-9** (765; F; EDITORIAL). "`nothing` under the trace switch" comes before
the `trace` keyword is named at 766. Fix: "which is `nothing` under
`trace = false`". `src/sim.jl` 708 confirms `trace = true` is the keyword's
default.

**P2-10** (778, 786, 1084; F, G; EDITORIAL). The *checkpoint* gloss "the
`Model`'s state at a frame top as one value" leaves off the rest of the
glossary entry, "a `ModelState`, beside the run's two counters". §12.6 then
separates the bare `ModelState` from the `Checkpoint` (966–971). As written,
the gloss describes the wrong one of the two. In §12.6 the first use is 778
("to the checkpoint's"), before the link at 786. Fix: move the link to 778.
At both 778 and 1084, gloss it "(the `Model`'s state at a frame top, beside
the run's frame index and boundary ordinal)".

**P2-11** (783, 803–806; F; EDITORIAL). "The executor's clock holds it" uses
*executor* 20 lines before its link and gloss (803, 806). Fix: link and
gloss it at 783, "the [executor](#g-executor)'s clock (the executor being
the compiled form of the stage execution order)". At 803–806 it becomes
plain, and the sentence "The executor is the compiled form …" goes.

**P2-12** (785, 840–842; F; EDITORIAL). *Boundary zero* is glossed twice in
§12.6: "the initialization boundary" at 785, and "the initialization
boundary run as the ordinary macro-sequence with an empty integrate" at 841.
Fix: put the full gloss at 785. At 840–842, write "*Initialized* means
`init!` has completed boundary zero ([§14.5][s14-5]), or `restore!` or
`replay!` has restored a checkpoint."

**P2-13** (800, 815–816; F; EDITORIAL). "The data plane" has no
introduction in §12.6. "are the plane's" then comes right after both planes
are named, so it could mean either. `src/roster.jl` 196–204 shows that the
`DataPlane` holds `loop_diag`, `loop_account` and `published`. Fix: at 800,
"the data plane ([§11][s11])". At 816, "are the data plane's", and "the
published holder" becomes "the published-snapshot holder
([§11.2][s11-2])".

**P2-14** (861; F; RULING). "**`errored` is terminal**" (D-059) is bold
here, and frozen §14 (spec 11031) bolds "`errored` is terminal for every
row" (D-059, D-108). That is one ruling bold in two places. Unit F's
`rulings.md` lists it and proposes that §12.6 keeps the bold, with
chapter 14 making its sentence plain. Ruling needed.

**P2-15** (887–890; F; RULING). "Deviceless, `run!` is fully synchronous,
and [§11.1][s11-1] says where …" joins two unrelated claims with "and". The
sentence also opens "Partial advance" with a claim about `run!`. R5
dictated one sentence. Fix, if R5 allows: two sentences, "Deviceless,
`run!` is fully synchronous. [§11.1][s11-1] says where the loop and the
device tasks run, and defines the unattended run (…)."

**P2-16** (914–917; F; EDITORIAL). *Harness writer* is first used inside the
harness-cell gloss (916), but its link sits on the second use. "§11.3
specifies that harness writer" also reads awkwardly. Fix: "(the
always-present staging cell of the [harness writer](#g-harness-writer)).
The harness write path is `stage!(sim, "face" => value, …)`, and
[§11.3][s11-3] specifies the writer."

**P2-17** (936; F; EDITORIAL). "Termination policy is honored" names, under
a second name, what §12.6 calls the stop policy (819, 1034). It is also the
only "honor" spelling in the chapter: 740, 1042 and 1153 spell "honour".
Fix: "The stop policy is honoured throughout, as bit-identity requires."

**P2-18** (938; F; EDITORIAL). "[holding](#g-edge-semantics)" is linked with
no gloss. Fix: "[holding](#g-edge-semantics) (publishing `STOP_REQUESTED`)",
the sense half 1 gives at 310.

**P2-19** (961–962, and half 1's 534 and 556; F, B; RULING; E1). §12.4's
pointers "resumable by the next `run!` ([§12.6][s12-6])" land on a section
that says the opposite: "From `stopped`, nothing advances until `init!`,
`restore!` or `replay!` opens a new run". The pointer's target does not
state the claim the pointer makes. This is E1, already escalated. It is
listed here only because the pointer check finds it.

**P2-20** (981–984; F; RULING). `restore!(model, model_state)` names a kind
only for the off-grid state (`CheckpointMidFrame`). It never names the kind
of a fingerprint or deployment mismatch, so "Every mismatch of either kind"
has only one named antecedent. `src/model.jl` 637 collects
`CheckpointMismatch` and `CheckpointMidFrame`. Fix: "checks the state's
fingerprint and deployment against the model, and a mismatch is
`CheckpointMismatch`." This adds a claim.

**P2-21** (1024–1025; F; RULING). "Each `run!` re-initializes every rostered
device and spawns its task ([D-093][d-093])" says every device gets a task.
Three sources say otherwise:
- §11.1 (frozen spec 6878–6880): "A device whose `init!` failed gets no
  task".
- §12.4 (half 1, 541): the bracket "spawns no task for it".
- This section's own pointer at 1028.
The old text had the sentence uncited, and unit F added D-093. Fix: "Each
`run!` re-initializes every rostered device and spawns a task for each whose
`init!` succeeds ([§11.1][s11-1], [D-093][d-093])". The alternative is to
stop after "re-initializes every rostered device" and let 1028's pointer
carry the rest.

**P2-22** (1048–1057; G; EDITORIAL). The §12.7 context is six definition
sentences in a row. It never says what problem replay solves, which
`spec_style.md`'s template asks the context to state first. "the
[§11.5][s11-5] trace" uses a section number as an adjective. Fix:
- End the first sentence with the workflows the section itself names
  (1213–1224): "…on a recorded input trace, so that a recorded session can
  be inspected, its errors reproduced and its run continued live".
- Move the *device* gloss to its first use in the body, "Devices are
  readers" (1244).
- Write the last sentence as "`replay!` is the entry point the trace exists
  for ([§11.5][s11-5]):".

**P2-23** (1072, 1324–1326; G; EDITORIAL). *What-if replay* is glossed twice
in §12.7: "re-driving the recorded inputs through a modified model" (1072)
and "the deterministic re-driving of the recorded inputs through a modified
model" (1325). Fix: 1324 becomes "Replaying against the same structure with
changed parameters is the what-if replay." "Deterministic" is still carried
by 1332, "promises determinism". Rewrap 1324–1328.

**P2-24** (1080–1083; G; EDITORIAL). "The default form" is used at 1081 one
sentence before 1083 defines it. Listing the restored start beside the drain
also makes "exactly one substitution" read as two, which is D-101's old
count. D-274 bullet 4 made it one. Fix: "The substitution is the drain,
which reads the trace. Under the default form, `replay!(sim2, trc)` above,
the loop also starts from a restored state."

**P2-25** (1090; G; EDITORIAL). "the totality ([§14.6][s14-6])" is
reader-cold. Fix: "the [root-input totality](#g-root-input-totality) (every
root input must hold a value) ([§14.6][s14-6])", in half 1's gloss (513).

**P2-26** (1103–1108; G; EDITORIAL). Two gloss sentences (write surface,
face) sit between "The write-surface rule … ran at recording time" and the
claims sentence that completes the reason. The old single sentence read
better. Fix: "The [write-surface](#g-write-surface) rule (the bound on the
faces a writer's batch entries may reach) ran at recording time
([§11.3][s11-3]), and [claims](#g-claim) (the set of faces a device may
write) are a live-roster fact of the recorded session that replay does not
reconstruct. A [face](#g-face) is the name a port wears on its component's
boundary."

**P2-27** (1110–1112; G; RULING). The D-218 bold covers the whole
23-word sentence. Its headline clause is "the mode decides which source that
one drain branch reads". The Position sentence's first half (a simulation
carries an input mode, read as `mode(sim)`) is also stated earlier, plain,
in §12.6 at 865–870, which cites D-218. Fix: bold only "**the mode decides
which source that one drain branch reads**".

**P2-28** (1131–1135; G; EDITORIAL). F68's "Anything else is refused" now
follows the sentence on where the feed starts. Its antecedent therefore
reads as the feed's start frame rather than the range. Fix: "Either keyword
names a frame from the one the feed starts from through the recording's
last, and anything else is refused (`ArgumentInvalid`). The feed starts
from …"

**P2-29** (1142; G; RULING). "The frame-entry pointer ([§13.4][s13-4]) lands
the same way" once contrasted the published-boundary `k` with §13.4's
pointer. After F83 and R17, `to_boundary` takes the frame-entry index itself
(1137), so the sentence now compares the pointer with itself. "Frame-entry
pointer" is also a name found nowhere else: 1130 and §13.4 say "replay
pointer". Fix: delete the sentence. This removes a claim.

**P2-30** (1143–1144; G; EDITORIAL). The *localized* gloss follows "inside
the frame", so it reads as a gloss of "the frame". Fix: "A
[localized](#g-localized) `t*` boundary (the crossing instant bracketed by
root-finding over trial sweeps) inside the frame is reproduced but not
stoppable-at".

**P2-31** (1152; G; EDITORIAL). The first "stop request" in §12.7 has no
link and no gloss. Fix: "[stop request](#g-stop-request) (an output port of
the framework enum `StopFlag`)", as §12.5 and §12.6 gloss it.

**P2-32** (1157; G; RULING). The bold's subject "The keyword" depends on the
sentence before it, so the headline clause does not name what it rules on.
Fix: "**`to_time` halts at the last frame top at or before the time given**,
the same halt addressed by time, and it is mutually exclusive with
`to_boundary` ([D-219][d-219])." The topic sentence before it goes.

**P2-33** (1169; G; EDITORIAL). "Validation is the other keywords'." is
cryptic (the old text says the same). Fix: "`to_time` is validated as the
other keywords are."

**P2-34** (1173, 1182–1183; G; EDITORIAL). "The halt flips the mode only at
the recording's end" (1173) is said again nine lines later: "The flip above
is automatic, and it happens only at the recording's end." Fix: 1182–1183
becomes "The flip above is automatic. `live!(sim)` performs it by hand."

**P2-35** (1122–1124, 1216–1218; G; EDITORIAL). The error-reproduction
workflow is stated twice in §12.7: "halts at the frame top the error names,
then `step!`s the failing frame on its recorded inputs", and "replays to
the frame-entry boundary `k` the error names, then `step!`s the failing
frame under instrumentation". Fix: end 1121 at "with no replay-only
spelling of `step!`", and make 1217–1218 "then `step!`s the failing frame
on its recorded inputs, under instrumentation ([§13.4][s13-4])".

**P2-36** (1208; G; EDITORIAL). The M56/M57 order puts "a complete recording
of *itself*" before the rule that makes it true, "Replay re-records"
(1228–1233). Fix: add a pointer, "…flown live after it, since replay
re-records (below)."

**P2-37** (1237; G; EDITORIAL). The control-plane gloss the rewriter added
brings "the stop word" into §12.7 bare. R11 and R15 gloss that term at
first use per section, and §12.6 801 says "pause, pace and stop". Fix: "The
control plane is the separate atomic surface carrying pause, pace and
stop."

**P2-38** (1231, 1306–1307, 1347; G; EDITORIAL). Three sentences in §12.7
say that under `restore = false` the new trace's header is the simulation's
own checkpoint. Fix: at 1306–1307, end the sentence at "its origin must
equal the recording's". 1231 (with its "(below)") and 1347 keep the claim.

**P2-39** (1341; G; EDITORIAL; step 4 carry). "arm. One grid is thus an
invariant of" is a short line. Fix: rewrap 1340–1343.

**P2-40** (wrap; F, G; EDITORIAL). These lines are short in the middle of a
paragraph: 671 (29 columns), 753 (19), 803 (43), 817 (9), 888 (45), 1036
(43), 1085 (47), 1266 (46), 1325 (51) and 1327 (49). Fix: reflow each
paragraph.

**P2-41** (half 1 line 91; A; RULING; across the split). §12.1 says "`step!`
takes neither and never waits". §12.6 (895) keeps F79's scope, "never waits
on the pacer", and F79 says never to shorten it to "never waits". Fix at
91: "`step!` takes neither and never waits on the pacer."

**P2-42** (half 1 lines 386–389; B; EDITORIAL; across the split). §12.4
points at the `t_plus` spelling ([§12.6][s12-6]) and then restates §12.6's
sentence (899): "The run takes whole frames until the boundary time first
covers the duration." Fix: drop the restatement in half 1. The pointer
carries it.

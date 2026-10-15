# Chapter 12: evidence check (step 6a)

Step 6a of `docs/spec_rewrite/recipe.md`. One entry per non-blocking item of
`rulings_batch.md`, B22 to B88. Spec and log lines are the frozen
`scratch_survey/h1/` copies at `17ad42d`. `src/`, `implementation.md`, the
companions and `pending.md` are the working tree. Chapter text is quoted by
its words, not its line numbers: `chapter_new.md` was reassembled during this
check (commit 509ea77), so the batch's chapter line numbers have moved.

Verdicts: CONFIRMED means the cited source says what the item claims.
"Caveat" marks a detail (a line number, a count) that is off without
touching the claim. UNCONFIRMED means the source says something else, or the
proposal claims more than its source.

Reserved-word check: no dictated wording in B22–B88 uses a reserved word of
`checks/brief_common.md` in another sense. The only hits are *door* in B25's
"A writing door" (B29's ruling) and *derived* in B26's companion line, which
the companion already uses and which is not spec text.

## Part 1: Landing (B22–B40)

**B22. CONFIRMED.** Spec 12855: "the device is dead from boundary zero
([§12.4][s12-4])". Chapter §12.4: "No task is spawned for a failed device, so
it is dead from the run's first frame top ([D-138][d-138])". Brief R8 orders
the change. Proposal: the chapter's own words; apply as written.

**B23. CONFIRMED.** Spec 7714–7716 cites "([§12.6][s12-6], [D-274][d-274])"
for "The header is the checkpoint `init!` takes at the end of boundary zero".
Old §12.6 (spec 9241–9484) never says it; its only header sentence is
`restore!`'s "opens a fresh run with the checkpoint as its trace header".
D-274 bullet 4 (log 11663): "The trace header is the checkpoint `init!` takes
at the end of boundary zero, after the first publication." Proposal: D-274
carries the whole claim.

**B24. CONFIRMED.** Spec 11948 "The recorders are cleared exactly as §12.6
states", 12914 "recordings cleared ([§12.6][s12-6])", 14370 "They are cleared
together at `init!`, at `restore!` and at a trim commit". Chapter §12.6: "the
trace, the log and the termination record … are new objects rather than
cleared ones, and each clears any batches still in staging cells". D-255
(log 10047–10048): "`init!` allocates fresh objects rather than clearing."
Proposal: all three wordings match §12.6; *batch* is used in its reserved
sense.

**B25. CONFIRMED.** Spec 12759–12763: "Checks the state's fingerprint
(`CheckpointMismatch`) and its `t` against its grid (`CheckpointMidFrame`)
… It takes no status gate ([§12.6][s12-6])." Neither old nor new §12.6
contains "status gate". D-319 bullet 2 (log 14016): "It has no status gate."
Proposal: the D-319 citation carries the gate clause. Its last sentence, "A
writing door", keeps *door* for a `Model` entry point, against R14; it waits
on B29.

**B26. CONFIRMED.** §11.3 (spec 7263–7267): the harness cell "is drained,
traced and surface-checked exactly as any device's", and "The harness
writer's surface is the one thing in the design that is *derived*". Spec
12997 still says "surface-checked exactly as the GUI's writes (the harness
cell, [§12.6][s12-6])". Chapter §12.6 keeps "Staged batches are ordinary
batches. They are traced" and "Both entry points work under `run!` too".
Walkthrough line 5 lists "[§12.6][s12-6] (harness cell)"; line 197 cites
§12.6 for the derived surface. Proposal: each retarget names a clause §11.3
states; 14220's "drained last" is §11.3's too (spec 7278).

**B27. CONFIRMED.** Spec 11018 "a checkpoint whose fingerprint matches", 12928
"and the fingerprint", 12933 "checks the checkpoint's fingerprint
(`CheckpointMismatch`)", 12942 "the same fingerprint check", 13394 "a
checkpoint's fingerprint disagrees". §11.5 (spec 7719–7720): "the fingerprint
(the structural layout) and the [deployment]". Proposal: R12's naming; the
old lines are narrower, not false. Caveat: the batch's lines 12931, 12939,
12945 and 13393 are one to three lines early.

**B28. CONFIRMED.** Spec 14374–14376: "validates the checkpoint's fingerprint
(stores, root-input faces and the `Deployment`) up front, restoring the clock
with the rest of the state". Chapter §12.7: "Under the default form the clock
is *restored*, not compared … Under `restore = false` the simulation's own
clock runs", and the fingerprint is "the structural layout". Proposal: every
clause is §12.7's.

**B29. CONFIRMED, caveat.** R14 (brief): "Every 'door' that names a `Model`'s
entry point … becomes 'entry point'". Spec 12735 "`Model`'s own doors", 4336
"its doors are the only way in", 14073 "Its doors are listed in the `Model`
block of [Appendix B][sB]", after a citation that includes §12.6. Caveat:
"Only 14073 cites §12.6" holds for the *door* sentences only. Appendix B's
`checkpoint(model)` and `restore!(model, …)` rows cite §12.6 too, and the
`restore!` row ends "A writing door". Proposal: sound; option (b) leaves a
§12.6-citing row in the old sense.

**B30. CONFIRMED, caveat.** Spec 13032 (not 13037): "A halt names a frame at
or after the one the feed starts from." Chapter §12.7: "Either keyword names a
frame from the one the feed starts from through the recording's last."
Proposal: the chapter's words.

**B31. CONFIRMED.** Spec 13301: "**`MissingInit`** ([§12.6][s12-6]) … the
entry point called (`run!`/`step!`)". 13303–13305: `ServiceLifecycle`'s list
lacks `live!` and `replay!`. 13428–13433: `ArgumentInvalid` cites §12.6 but
not §12.7, and lists `replay!` but not `live!`. Chapter §12.7: `live!`
refuses "with `MissingInit` at `built` and `ServiceLifecycle` in the rest. A
simulation already `:live` refuses too, with `ArgumentInvalid`"; `restore =
false` meets "`MissingInit` when it is `built` and `ServiceLifecycle` in any
other state". Proposal: matches the chapter.

**B32. CONFIRMED, caveat.** Spec 6892–6893 (the batch says 6893): "the same
loop with staging fed from a recording". Chapter §12.7: "It does not swap the
staging cells of the roster". Proposal: true to §12.7.

**B33. UNCONFIRMED (807).** 762 and 1260 hold. `implementation.md` 762: "(§12.1,
D-256, D-317)"; chapter §12.6: "**`Simulation` is a mutable struct of four
fields**". 1260: "A deviceless loop never yields (§12.2)"; §12.2 bolds only
"With devices attached, every frame yields at least once"; `src/sim.jl` 1424
`isempty(roster) || yield()`; `src/control.jl` 186 `remaining > 0 &&
sleep(remaining) # the coarse phase: yields`. But 807 reads "§12.6's input
mode: `mode(sim)`, `to_time` and `live!`", and `mode(sim)` is §12.6's
(chapter: "read as `mode(sim)`" under "Lifecycle states and the input mode").
Only `to_time` and `live!` are §12.7's. Proposal: 807 should read "§12.6 and
§12.7", not "§12.7".

**B34. CONFIRMED.** Spec 14172–14174: "carrying pause, un-pause, pace,
`margin`, the stop word, the running flag, the wait and `join_timeout`".
Chapter §12.1: "`Control` keeps the stop word, the sticky stopped status, the
running flag". Proposal: one added item.

**B35. CONFIRMED, caveat.** Spec 10240 and 14240–14241: "a frame-top or wait
unmask point". Chapter §12.4: "the frame top … and points inside its wait and
pause blocks". Caveat: the glossary phrase occurs once. 14243 is the same
entry's citation line, so there are two places, not three.

**B36. CONFIRMED.** Log 4316: "stated once in [§12.4][s12-4](1)"; 4321 lists
"[§12.4][s12-4], [§12.4][s12-4](1)". Chapter §12.4 states the landing rule
after the chart, not in step (1). Log 3492: "[§11.1][s11-1] and
[§12.4][s12-4] carry the canonical statement"; 3494: "shorthand elsewhere
([D-093][d-093], [§12.6][s12-6])". §12.6 now says only "Which devices get a
task at each `run!` is decided as [§11.1][s11-1] specifies." Proposal: the
three edits follow.

**B37. CONFIRMED, caveat.** Log 11153–11154: "[§12.6][s12-6] defines the
unattended run as the deviceless one". §11.1 (spec 6890–6891): "An unattended
run is the same loop with empty staging and no snapshot readers." Caveat: the
proposal's clause "which a deviceless run is" is §13.4's, not §11.1's (spec
10253–10254: "With no device rostered the run is unattended and rethrows").
Proposal: sound; §13.4 is already in the sentence.

**B38. CONFIRMED, caveat.** The frozen spec defines `[d-128]` (14724) but has
no `[d-127]`. Log 4053: "### D-127 — Add a deployment block to the trace
header for replay validation", whose slug is the proposed anchor. Caveat:
`linkify.jl` runs in step 7 (recipe 481), not step 6. Proposal: run linkify
first; never hand-write the anchor (`decisions_style.md` rule 3).

**B39. CONFIRMED, caveat.** Spec 11001, 11060 and 12930 cite §12.6 for "A
checkpoint is not a condition and has no algebra"; old §12.6 has no
"algebra". D-273 Position (log 11556–11558): "carried by a checkpoint
([D-274][d-274]), a distinct value with no algebra". Chapter §12.4: "replay
… neither records nor compares the cap ([§11.5][s11-5], [§12.7][s12-7]), just
as for `log_max` ([§11.2][s11-2])". Caveats: 12931's sentence cites §14.1,
D-274 and D-319, not D-273. §12.4 covers `log_max` only by analogy, so 7087
takes an added §12.4 citation better than a retarget. D-137's Spec field may
list §12.7 for its own Rationale (log 4589: "what replay from the trace
recovers, [§11.5][s11-5], [§12.7][s12-7]").

**B40. CONFIRMED.** Log 3482 (D-109 Rationale, from 3477): "the affine device
is outside [§12.4][s12-4]'s join and abandonment"; log 6530 (D-175 Position):
"the detach sitting in [§12.4][s12-4]'s shutdown tail". Both entries read
"**Status.** superseded → [D-310][d-310]"; old §12.4 has no affine device.
Proposal: no edit is right.

## Part 2: Track 2 (B41–B81)

**Note on form (N1).** Many items propose to "state X in the Position" of an
existing entry. The batch says `decisions_style.md` rule 10 governs that. Rule
10 says otherwise: "The older entry gets an annotation, and a new entry states
the position if none does." Rule 1: "Historical entries are annotated, never
rewritten … do not retrofit a changed position into old prose." The log's own
precedent is a new entry: D-373's Rationale says "Each bullet restates a
clause of [D-102][d-102]'s Rationale that its Position does not state."
About thirty later entries open the same way (log 12579 onward: "Each
bullet restates what an existing entry recorded outside …"). Rule 8 adds "Do not expand the terse early entries", which bears on D-027,
D-030, D-031, D-059 and D-081 ("Recorded only through the rejections below").
So the evidence below is checked as stated, but the Position-writing form
claims more than rule 10 gives. Read each such item as "a new entry states
it". Items affected: B42, B45–B49, B51, B52, B55, B57, B58, B60, B63, B64,
B66, B68, B69, B71, B72, B74, B75, B77, B78.

**B41. CONFIRMED, caveat.** The Spec fields read: D-021 "[§10.7]"; D-022
"[§2], [§11.1]"; D-045 "[§4.3], [§11.4], [§11.6], [§11.7]"; D-060 "[§9.3],
[§13.5], [§14.4]"; D-108 "[§11.3], [§13.6], [§14]"; D-200 "[§11.3], [§11.4],
[§11.8], [Appendix D]"; D-228 "[§11.8], [Appendix C]"; D-366, D-372 and
D-373 "[§11.6]"; D-381 "[§11.6], [§D.6]". D-108 Rejected (log 3453) names
`MissingInit`. Caveat: D-374's field is "[§11.3], [§11.4], [§11.6]", not one
section alone. Which sentence each entry rules is the surveys' reading; spot
checks hold (D-045's "Edge logic is staged counters" against old 9220; D-200's
"on whichever task stages" against old 9374).

**B42. UNCONFIRMED.** The evidence says "The spin never yields … rest[s] on the
Rejected text". D-027's Position (log 980–981) already says "spin never
yields". Only the spin's reason (Rejected 995, "µs precision traded for
scheduler noise") and the monopolist (993–994, "no framework thread
monopolist, no stall coupling, GUI on the calling task") are Rejected text.
The withdrawn ground is confirmed: D-310 bullet 1, "every rostered device runs
on a spawned task". The three bolds (`sleep`, the per-frame yield, the thread
budget) do rest on the Position. Proposal: the Position clause should cover
only the monopolist and the spin's reason, and see N1 and rule 8.

**B43. UNCONFIRMED (annotation wording).** The stale text holds. D-030
Position (log 1042–1043): "device crash = `should_close` path". The entry has
no **Spec.** field, and the frozen spec cites D-030 nowhere. But the proposed
annotation, "a device crash enters the tail through the abnormal path (D-138,
D-373)", is in neither source. D-373 says only "`should_close` dissolves into
the loop body returning, a voluntary exit". D-102's Rationale says "The
wrapper is try/catch/finally with `DeviceCrash` on catch". Chapter §12.4 step
(6) says a crashing task "is caught by the framework wrapper and follows the
same path" as a voluntary exit, and the tail starts only if `should_abort` is
set. Proposal: annotate with that reading, citing D-102 and D-373.

**B44. CONFIRMED.** D-031 Position (log 1059–1062): "manual events = slot +
guard; … mid-run intervention command = guarded addition with shape on
record". No entry gives the shape: the log's only "intervention" is line 1061.
D-106 (log 3364–3365, Rationale): "[§12.5][s12-5]'s doctrine reaches final
form". Proposal: annotation sound; the shape question is the owner's.

**B45. CONFIRMED.** D-059 Rejected (log 1851–1852): "stores may be
mid-boundary; reproduction is trace replay, not resurrection". Bullet 4:
"Status goes terminal `stopped`/`errored`". Chapter §12.6: "**`errored` is
terminal** ([D-059][d-059]). Reproduction is trace replay". Proposal: see N1
and rule 8.

**B46. CONFIRMED.** D-081 Rejected (log 2579–2580): "*A frame counter in
[§12.3][s12-3]:* devices assuming fixed-`h` wake spacing — nothing settled
does." Chapter §12.3 says the counter counts "*published boundaries* … not
frames", citing §10.1 and §10.4, not D-081. Proposal: see N1 and rule 8.

**B47. CONFIRMED.** D-088 Position (log 2778): "a distinct diagnostic from
`UninitializedSlots`". Rationale (log 2784–2791): "trace *and* log cleared at
`init!`", "`t_end`/`stop_on`", "re-bindable per run at `run!`
([D-091][d-091])"; D-091 reads "superseded → [D-255][d-255]". Rejected
2794–2795: "neither is a [§12.5][s12-5] script". Chapter bolds "`stopped →
init! → run!` remains the authored re-run" and "Device attachments persist
across re-initialization", both citing D-088. Proposal: see N1.

**B48. CONFIRMED.** D-093 Rejected (log 2929–2930): "falsifies
[§12.2][s12-2]'s cannot-fail-to-be-scheduled argument". The annotation of
2026-10-13 (2913–2915) covers the Rationale's GUI clause only. Rationale
2897–2902: "what persists across `stopped → init! → run!` is the roster entry
… unplug-while-stopped surfaces as the next run's device-`init!` failure";
2908–2909: "Stepping sessions are deviceless by construction". Chapter bolds
"**A stepping session is deviceless by construction** ([D-093][d-093])".
Proposal: see N1; waits on E2.

**B49. CONFIRMED.** D-096 Rationale (log 3015–3020): "`latest(sim)` = the
current published snapshot … `step!` gains the duration spelling `t_plus`".
Rejected 3036–3037: "an inspection *accessor* returning the immutable snapshot
is not it". The old chapter cites D-096 nowhere. Proposal: see N1.

**B50. CONFIRMED.** D-097 Position (log 3044–3045): "`DeviceCrash` (device id,
exception as `cause`, the `should_abort` disposition)". D-228 (log
8752–8754): "names its subjects in the payload and never its writer".
`src/dataplane.jl` 134–137: `struct DeviceCrash` holds `cause::Any` and
`abort::Bool`. Proposal: annotation only, as rule 1 asks.

**B51. CONFIRMED.** D-101 Position (log 3156): "exactly two substitutions".
Rationale: "captures … BEFORE the boundary-zero sequence" (3163–3164),
"boundary zero is re-executed under replay" (3166–3167),
"(`ReplayHeaderMismatch`, `ReplayUnknownFace`)" (3173), "the interactive
writer's sparse records … the header's schemas" (3174–3175). D-274 (log
11665–11666): "[D-101][d-101]'s two substitutions become one". D-101 has no
annotation. Three chapter bolds cite D-101: "Replay re-records", "Pacing and
the control plane are unchanged", "Validation is loud and up front".
Proposal: annotations sound; see N1.

**B52. CONFIRMED.** D-106 Rejected (log 3381–3382): "per-attach thread-budget
re-checks — all priced for a hypothetical workflow". Rationale (3364–3365):
"[§12.5][s12-5]'s doctrine reaches final form". Proposal: see N1.

**B53. CONFIRMED.** D-110 Rationale (log 3518–3519): "resume-at-time spelled
explicitly via `capture`'s returned `t` passed as `t0`". D-273 bullet 4:
"The cycle capture → tweak → apply retires with `capture`'s condition form."
Proposal: annotation sound.

**B54. CONFIRMED.** D-114 Position (log 3634–3636): "the boundary index is
carried *in* the snapshot (with `t`) … and additionally mirrored in the loop
state the wait predicate tests". D-230 Position (8843–8847): the snapshot's
index is "the trajectory's published-boundary ordinal", and the wait counter
"is a separate, monotone count that is never reset". Proposal: annotation
sound.

**B55. CONFIRMED.** D-127 Position: "`n`" (4058), "`event_budget`" (4061),
"mismatch = `ReplayHeaderMismatch`" (4062), "`t₀` applied rather than
compared" (4065). The annotation (4075–4077) covers the `t_end`/`stop_on`
pair only. Rejected (4081–4082): "a recorded `stop_on` termination reproduces
itself anyway". Chapter §12.7: under `restore = false` "its origin must equal
the recording's". Proposal: annotations sound; see N1.

**B56. CONFIRMED.** D-128 Rationale (log 4108): "The boundary counter stays
the reporting index". Position (4094–4095): "running through the frame whose
execution published boundary `k`". Spec field (4106): §10.4, §12.6, §12.7,
§13.4, Appendix C, with no §12.3, though chapter §12.3 cites D-128 ("a frame
count that names no `t*` boundary ([D-128][d-128])"). Proposal: sound.

**B57. CONFIRMED.** D-132 Position (log 4232–4236): "It joins `t_end`,
`stop_on` … resumable by the next `run!`." Rationale 4256: "cannot repair
[§12.4][s12-4](5)'s honest asymmetry". The annotation (4272–4275) names "the
topology clause" only. The chapter bolds "Masking across the boundary is
normative" and "A second interrupt during the tail collapses the remaining
joins". Rejected 4285 and 4289 (`interrupt!`, `exit_on_sigint(false)`) are
cited plain. D-310 bullet 1: "every rostered device runs on a spawned task".
Proposal: the annotation text holds; see N1 for the Position part.

**B58. CONFIRMED.** D-133 Position (4316): "stated once in [§12.4][s12-4](1)";
Rationale 4343: "differs in kind from `stop_on`". D-198 (log 7425): "This
amends [D-133][d-133]". D-133's annotation (4346) names "[D-256][d-256],
[D-234][d-234] and [D-181][d-181]" only. Rationale 4335–4337: "heartbeat
staleness is deliberately loose: the heartbeat is advisory … tolerate a device
legitimately parked"; 4340–4344: the `t_plus` precedent and "`t_end`, a grid
fact"; 4327–4330: the semantic constants are trajectory-determining.
Proposal: see N1.

**B59. CONFIRMED.** D-134 Rationale (log 4398–4399): "its read path is the
handle's primitive read — VSync-paced `latest` per render, [§12.3][s12-3]".
Chapter §12.3 keeps "The GUI does not use the wait. Being VSync-paced". Waits
on E2.

**B60. CONFIRMED, caveat.** D-138 Rationale: "`DeviceCrash`'s payload (device
id, `cause`, …)" (4668); "reads stale against [§12.2][s12-2]'s threshold
from the first frame ([§11.8][s11-8], [D-136][d-136])" (4671–4672); "the
orphaned slots holding their initial values, well-defined by
[§14.6][s14-6]'s slot totality" (4674–4675); "**already pending at boundary
zero**" (4679–4680); "boundary zero is published" (4682). The Position
(4653–4657) states the bracket only. Caveat: R8 also covers "**dead from
boundary zero**" (4670) and "absent from frame zero — (6)'s semantics shifted
to `t₀`" (4678), which the evidence omits. Proposal: annotate those too; see
N1.

**B61. CONFIRMED.** D-198 Position (log 7421–7424): "a `Simulation`
deployment keyword … outside the trace header's deployment block". D-256
bullet 3 (10136): "`join_timeout` into `Control`". D-317 bullet 2
(13753–13754): "`Simulation(model::Model{Float64}; join_timeout = 5.0)`".
D-198 has no annotation. Its Rationale says "Deployment contexts legitimately
differ in patience". Proposal: sound.

**B62. UNCONFIRMED (proposal).** The stale text holds. D-217 bullets (log
8222–8225): "as a `ReplayHeaderMismatch` discriminator", "`ReplayHeaderMismatch`
and `ReplaySchemaMismatch` are collected". But "D-319's `CheckpointMismatch`
rename" names a ruling that does not exist. D-319 (log 14010, 14032) uses
`CheckpointMismatch` without ruling a rename, and no entry rules it (survey 2
part E; B78). Proposal: the annotation should say the kind is now
`CheckpointMismatch` (Appendix C), not credit D-319.

**B63. CONFIRMED.** D-218 bullet 3 (log 8284–8285): "`init!` and a fresh
`replay!` reset it with the trajectory", with no `restore!`. Rationale
8292–8293: "replay as the ordinary loop with two substitutions". Rationale
8289–8292: "a mode outliving the call supplies" the consumer. Four D-218 bolds
in §12.7: "the mode decides which source that one drain branch reads",
"`replay!` attaches the recording and enters `:replay`", "In `:replay` the
recording is the bound", "The mode becomes `:live` exactly when that halt
lands". Proposal: see N1.

**B64. CONFIRMED, caveat.** `live!` keeping the header is Rationale, log
8337–8339 (not bullet 2 at 8326–8327): "the trace register keeps the header
it inherited, so the frames flown after the call append to the re-recorded
prefix". Rejected 8359–8362: "The asymmetry with `t_end`'s reach-or-exceed
rule is the point of the keyword". Proposal: see N1.

**B65. CONFIRMED.** D-223 Position (log 8554): "A throw inside boundary zero,
under `init!` or `replay!`". D-274 bullet 4: "`init!` is the only door that
runs boundary zero". Proposal: annotation sound.

**B66. CONFIRMED, caveat.** D-230 Position (8845): "a new trajectory restarts
it". Chapter §12.6: "The boundary ordinal continues, being the trajectory's
([§12.3][s12-3], [D-274][d-274])". Rationale 8856–8857: "a `last_seen` taken
from a previous run must never exceed it"; Rejected 8870–8871: "a handle
surviving `init!` would hold a `last_seen` ahead of the counter". Caveat: the
Position already says the counter "is never reset" (8846–8847); only the
reason is Rationale-only. Proposal: annotation sound; see N1.

**B67. CONFIRMED.** D-249 bullet 4 (log 9696–9697): "`StopFaceInvalid`'s
binding site is one of three, the constructor, `run!` or `replay!`". D-316
(13666): "The `stop_on` keyword and `StopFaceInvalid` retire." Proposal:
annotation sound.

**B68. CONFIRMED.** D-254 Rationale (log 10006–10008): "A deployment that is an
artifact can be compared, which is what replay's header check does with the
deployment block today by hand". The Position (9986–9987) has only "Replay
compares two deployments as values." Chapter §12.7: "Comparison by value is
what makes the check one expression rather than a field-by-field walk."
Proposal: see N1.

**B69. CONFIRMED, caveat.** D-255 Position (10045–10047): "`Control.lifecycle`
says whether it started … `Control`, which keeps the stop word, the lifecycle
and the wait". D-317 Supersedes (13821): "[D-255][d-255]'s clause keeping the
lifecycle on `Control`". D-260 Supersedes (10346): "[D-255][d-255]'s first
bullet". Placeholder (10044): "(`t₀ = zero(T)`, `mode = :live`, empty log and
trace, no termination)". Rationale 10077–10078: "the surface anyone may
poke"; 10091–10093: "The placeholder run at construction is preferred to a
`nothing` field". Rejected 10105–10106: "the control plane is what anyone may
poke". Caveat: the annotation of 2026-10-13 (10117–10118) does cite D-260,
though for the trace length, not the superseded bullet. Proposal: see N1.

**B70. CONFIRMED.** D-260 bullet 1 (log 10324): "`Run{T}` is a mutable struct
of four fields". D-317 Supersedes (13823): "[D-260][d-260]'s four-field
`Run`". D-260 has no annotation. Proposal: annotation sound.

**B71. CONFIRMED.** D-261 bullet 7 (log 10442–10444): "keywords of `init!` and
`replay!` … `Simulation(deployment, T)` keeps `join_timeout` and
`chunk_size`". D-317 Supersedes (13823–13824): "its clause keeping
`chunk_size` on `Simulation(deployment, T)`". No log line says `restore!`
takes the four keywords. D-319 bullet 3 implies it ("`restore!(sim,
cp::Checkpoint; kw…)`", "the checkpoint form's lifecycle, recording and
fingerprint checks"). Rationale 10500–10503: "Per-run recording comes with
the move". Proposal: see N1.

**B72. CONFIRMED.** D-268 bullet 2 (log 11087–11088): "yields to a stop face".
Annotation 11172: "mid-boundary until the next `init!`". Annotations
11161–11163 ("a frame that throws while an interrupt is pending ends
`errored`") and 11168–11171 ("reaches [§13.4][s13-4]'s defensive arm …
disposition is `stopped`") match the §12.4 bolds "A frame that throws with
an interrupt pending ends `errored`" and "A forced throw reaches the defensive
arm". Rejected 11192: "*Clearing the pause at a run's start, as the stop word
is*". Proposal: annotations sound; see N1.

**B73. CONFIRMED.** D-270 Position (log 11332): "`orphaned(record)` is a
`:done` or `:failed` task". Annotation (11410–11421): "so `orphaned` is
exactly `:done`". Chapter §12.2 bolds "`task_state` has three values"
([D-270][d-270]). Proposal: rewriting the Position clause is retrofitting
(rule 1); the annotation already states the rule, so a new entry or nothing.

**B74. CONFIRMED.** D-274 bullet 2 (log 11652): "a stopped-sim service
([§13.7][s13-7])"; Spec field (11691) lists §13.7. Spec 10577: "### 13.7
Tooling consequences: face routes and the component library"; 10988: "## 14.
Stopped-sim services". Rationale 11709–11711: "the checkpoint records the
post-firing state faithfully and suppresses nothing"; 11713–11714: "a long
run becomes seekable". Proposal: the §13.7 → §14 fix is allowed by rule 2
("cites the CURRENT § numbering"); for the Position part see N1.

**B75. CONFIRMED.** D-319 Spec field (log 14054): "[§9.2], [§11.5], [§12.6],
[§14], [§14.5], [§14.8], [§14.10], [Appendix B], [Appendix C]", with no §12.4
and no §12.7. Rationale 14080–14081: "A standalone model publishes nothing,
so a state carried from one has no trajectory whose ordinals could
continue." Survey 1 row 195 ties §12.4 old 9152–9154 to D-319. Proposal: Spec
field sound; see N1.

**B76. CONFIRMED.** D-028 Rejected (log 1010–1014): "*`Event`-based per-frame
gate:*" and "*Per-consumer every-boundary queues:*". D-203 Rationale
(7614–7615): "first-CAS-wins … names the request that actually initiated the
tail". D-269 Rationale (11250–11252): "a stepping session is the harness mode
([§12.6][s12-6])". The D-028, D-203 and D-269 bolds rest on Positions or
bullets (unit A rulings). Proposal: no action is consistent.

**B77. CONFIRMED.** Survey 1 part E, "Rulings with no entry at all", lists the
same six rulings and rows 50, 54, 72, 89, 121. Spot check: the log's only
`systemsleep` (990) is D-027's rejection, with no guarded-addition ruling;
no entry defines "tight". Proposal: putting them "in the entry that is
closest" is retrofitting (N1); a new entry fits rule 10.

**B78. CONFIRMED.** Survey 2 part E, "Rulings with no entry at all", lists
every bullet. Commits exist: `75911b9` "Conform the spec to D-273 and D-274:
… one-substitution replay", `7203798` "… the clock a restore = false replay
shares, and the abandoned frame". D-319 uses `CheckpointMismatch` (14010) and
the log never rules the rename. Proposal: a new entry for `restore = false`
fits rule 10; "Position clauses" in D-218, D-274, D-319 and D-088 does not
(N1).

**B79. CONFIRMED.** Brief R11: "Its glossary entry waits for track 2." R15:
"The gloss becomes 'the control plane's stop command, one atomic word holding
its issuer'". Spec 14542: "**stop request / termination is a state** —
graceful termination is model state". Proposal: sound; no reserved word.

**B80. CONFIRMED.** Spec 14159: "**calling task** — the task that invoked
`run!`". Unit A verify, "Other": "The calling-task gloss says 'invoked
`run!`' in a sentence about `run!` or `replay!`. It matches the glossary, so
this is for track 2 only." Proposal: sound.

**B81. CONFIRMED.** Spec 13807: "**sweep** — one pass through the execution
order against the current state". "the run's-end sweep" appears at spec 8878,
9137, 10430 and 13478, four uses. D-201 Position: "the loop sweeps every cell
once more at the run's end". The current chapter already glosses it: "the
run's-end sweep, the loop's last pass over every diagnostic cell". Proposal:
keeping the name is sound.

## Part 3: Carried (B82–B88)

**B82. CONFIRMED.** Spec 10334: "**Policy** is declared per advance"; 10336:
"**Every request is honoured unless the advance ignores it**
([D-316][d-316])"; 10347–10348: "The value lives as long as the call … ([§12.6][s12-6],
[D-260][d-260])". Brief R5: "§12.6 keeps old 9472–9480 whole as the home.
§13.5's repeat is carried to chapter 13." Proposal: carry.

**B83. CONFIRMED, caveat.** Spec 10515: "The wall-clock channel (GUI stop
button, device handle, code) is orthogonal". Spec 10240: "deferred to a
frame-top or wait unmask point". Spec 10239–10240 ("a single interrupt never
reaches the branch") matches chapter §12.4's "The catch site
([§13.4][s13-4]) never sees a single interrupt". Caveat: "GUI stop button"
occurs once, at 10515. Line 10518 is the same paragraph's §12.4 citation.
Proposal: carry.

**B84. CONFIRMED.** Spec 11031: "**`errored` is terminal for every row**
([D-059][d-059], [D-108][d-108])". Chapter §12.6: "**`errored` is terminal**
([D-059][d-059])". Proposal: carry, with B10.

**B85. CONFIRMED, caveat.** §11.7 (spec 8201, "The GUI write path") speaks in
the present tense: "**A widget is live exactly when the underlying input is
yours to command in this configuration**" (8230–8231), and the dead-slider
text follows (8231–8235). Caveat: D-310 bullet 3 says "[§11.7][s11-7]'s
semantics stand unchanged", so chapter 11 changes the naming, not the rules.
Proposal: carry.

**B86. CONFIRMED.** Spec 5478–5480: "[§12][s12] is the orchestration around
them: the control plane, the wait primitives and thread budget, the shutdown
protocol, the five run states, and replay." No §12.5. Brief R1: "The Part III
roadmap (old 5478–5480) is not edited". Proposal: carry.

**B87. CONFIRMED.** `flight_case_studies.md` 408: "*Window close.*
[§12.4][s12-4] applies verbatim: complete the boundary, final snapshot, sticky
stopped, wake waits, unblock hooks, named-timeout joins." D-310: "The built-in
Julia GUI is parked". Proposal: carry.

**B88. CONFIRMED, caveat.** `src/sim.jl` 1152: "so either door checks once
per run against the"; 1183: "# §12.2: one check per run, either door". Spec
8720: "A run warns, at `run!` or `replay!`". Caveat: the first comment is at
1152, not 1153–1155. Line 1153's "The doors that build a run" already uses
R14's sense and stays. Proposal: "either entry point" at 1152 and 1183 only.

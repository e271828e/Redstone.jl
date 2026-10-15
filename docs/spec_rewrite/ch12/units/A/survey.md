<!-- Sliced from survey_1.md for unit A (§12.1, §12.2, §12.3) by checks/slice_survey.py. -->
# Survey of spec chapter 12, half 1, before its readability rewrite — 2026-10-15

Scope: `docs/design/spec.md` lines 8588–9168 at commit `17ad42d`, 4,714
words: the chapter heading and roadmap (8588–8594), §12.1 (8595–8669), §12.2
(8670–8755), §12.3 (8756–8825) and §12.4 (8826–9168). Half 2 (§12.5–§12.7,
9169–9738, 5,101 words) is the sibling survey's. The convention is
`docs/design/tools/spec_style.md`; the method is `docs/spec_rewrite/recipe.md`
step 1; the model is chapter 11's half-1 survey (`git show
e5cbb77:docs/spec_rewrite/ch11/survey_1.md`).

Line numbers are lines of the frozen copies in `scratch_survey/h1/`
(`spec.md` and `decisions.md` at `17ad42d`). Lines marked `log` are
`decisions.md` lines. Entry claims rest on the entry as read in full; the log
line is given where the point sits outside the Position's first sentence.
`src/` was read at the working tree where a name or a claim was in doubt. The
scratch script that ran the half's claims against the package is
`scratch_survey/h1/run/blocks.jl` (part C, "Running the half's code").

Classification codes used in part A, as in chapters 10 and 11:

- **C** cited, and ruled by the cited entry's Position (at the spot or in the
  same paragraph, marked "adjacent").
- **U** ruled by an entry's Position that the section does not cite at that
  spot.
- **S** cited to a superseded entry.
- **R** ruled only in an entry's Rationale, Rejected list or annotation
  (whether or not the entry is cited).
- **N** no entry found. Where the sentence reads as a description of an
  inherited status quo rather than a ruling, the row says so.
- **B** borderline; both readings are given.

"Marking" is how the spec marks the rule now: **Rule.**/**Why.** label, a
labelled bold lead-in ("**Why the bracket.**"), bold sentence, bold lead-in
(a bold phrase opening a paragraph, used as a heading), bold step label (the
tail's numbered list), bold word, or plain.

Section sizes (words): heading and roadmap 44; §12.1 661; §12.2 712; §12.3
501; §12.4 2,796 (context 125, "The tail" 1,083, "Initialization: the
pre-spawn bracket" 787, "The operator interrupt" 801).

Bold now: 64 spans and 281 words in the half. §12.1 8 spans (57 words), §12.2
8 (20), §12.3 6 (15), §12.4 42 (189). Labels: **Rule.** ×16 (§12.1 1, §12.2
4, §12.3 2, §12.4 9), **Why.** ×4 (§12.1 1, §12.2 2, §12.4 1), and three
labelled "**Why …**" lead-ins in §12.4.

Two entries that rule most of §12.4 are cited nowhere in the spec: D-030 (the
shutdown protocol) and D-114 (the publication order). D-138 (the init
bracket) and D-132 (the operator interrupt) are cited elsewhere but nowhere in
§12.4, their home.

## A. Per section

### §12 heading and roadmap (8588–8594, 44 words)

| # | line | quote | marking | entry | class |
|---|---|---|---|---|---|
| 1 | 8590 | "Where §11 fixes how data crosses the loop boundary, this chapter covers the machinery that drives the loop itself" | plain | — | framing; "the loop boundary" is figurative, a sense the glossary's *boundary* (a published consistency point) does not admit |
| 2 | 8590–8593 | "…: the control plane and the scheduling primitives, the shutdown protocol, and the run lifecycle from `init!` through replay." | plain | — | roadmap; a colon as connector; names no section numbers; omits §12.5 (scripts and the mid-run mutation doctrine) and §12.3 except as "scheduling primitives" |

Glossary terms: periphery (title only), control plane (8591, linked, no
gloss), replay (8593, linked, no gloss). Appendix C kinds: none.

The Part III roadmap (5478–5480) names §12 as "the control plane, the wait
primitives and thread budget, the shutdown protocol, the five run states, and
replay"; it also omits §12.5 (q1).

### §12.1 Control plane (8595–8669, 661 words)

Purpose: what the control surface holds, when the loop reads it, the stop
word and its issuers, the pause verbs, and the pace and `margin` verbs.

Subheadings: none, and no context paragraph; the section opens on a
description of the fields. Bold lead-ins or sentences: 8610, 8617, 8621–8622,
8629, 8638, 8659. Labels: **Rule.** 8647, **Why.** 8650.

| # | line | quote | marking | entry | class |
|---|---|---|---|---|---|
| 3 | 8597–8598 | "Pause, un-pause, pace changes, `margin` changes and stop are a few scalar fields on a separate atomic surface." | plain | D-022 Position ("control on a separate atomic surface"), bold at §11.1 6839 | U; "scalar fields" is loose, since `Control` also holds a `Threads.Condition` and the counter (`src/control.jl` 62–72) |
| 4 | 8598 | "The loop consults them at frame top." | plain | D-269 bullet 3 | C, adjacent |
| 5 | 8598–8600 | "A change issued while a frame runs or waits is observed at the next frame top, at most one frame budget `h/p` later (D-269)" | plain, cites D-269 | D-269 bullet 3 | C |
| 6 | 8600–8601 | "The pause block is the one wait that wakes at once (below)." | plain | D-269 bullet 3 ("the pause block stays the one wait woken at once") | C, adjacent; "(below)" has no single target (8635 or 8642) |
| 7 | 8601–8603 | "`margin` (§10.7) rides here for the same reason `pace` does. It tunes the wait, never the arithmetic, so retuning … mid-run is safe by construction." | plain | D-021 Position (pacing outside the semantics, `margin` the single knob); D-269 bullet 1 (live setters) | B: U by D-269 for the live setting; R/U by D-021 for the reason |
| 8 | 8603–8605 | "The stop's issuers are the operator's channels (GUI button, device handle, calling code) and, in an interactive session, Ctrl-C." | plain | D-203 bullet 3 (issuers: device, `:code`, `:interrupt`); D-132 Position | U; "GUI button" names the parked GUI (F2) |
| 9 | 8605–8608 | "An operator interrupt is caught at one of the loop's unmask points and sets exactly this stop, with no separate entry point involved (§12.4)." | plain | D-132 Position (a control-plane stop); D-132 Rejected log 4285–4288 (no public `interrupt!`) | B: U for the stop; R for "no separate entry point". Restated at 9085–9087 (row 177) |
| 10 | 8610 | "**The stop word carries its issuer.**" | bold sentence | D-203 bullet 3 | C (cited 8615) |
| 11 | 8610–8612 | "Each issuing site writes its identity (the device's name, `:code`, or `:interrupt`) by compare-and-swap from empty, and the first writer wins." | plain | D-203 bullet 3 | C, adjacent |
| 12 | 8612–8615 | "The loop's frame-top read consults the word for non-empty, so the recorded issuer is the request that actually initiated the tail. It lands in the termination record's `ControlRequestedStop` (§13.5, D-203)." | plain | D-203 bullet 1; Rationale log 7611–7615 (first CAS names the initiator) | C; R for the "so" clause. "the tail" is used before §12.4 defines it |
| 13 | 8617 | "**`ControlRequestedStop` sits outside the stop policy** (D-255)" | bold lead-in | D-255 bullet 4 | C |
| 14 | 8618–8619 | "The policy is what the caller declares for one advance (§13.5); the stop word is what anyone can issue at any moment." | plain | D-255 bullet 4 | C; a semicolon joining two clauses |
| 15 | 8621–8623 | "**Beside pause, pace and `margin`, `Control` keeps the stop word, the running flag, the wait and the shutdown tail's `join_timeout`** (§12.4, D-256, D-317)" | bold sentence, 23 words | D-256 bullet 3 (`join_timeout` into `Control`); D-255 bullet 2 (stop word, wait); D-317 bullet 6 (running flag) | C; the sticky stopped status, a `Control` field (`src/control.jl` 64), is not listed (F7); whole-sentence bold |
| 16 | 8623–8624 | "The lifecycle state is not stored, and `lifecycle(sim)` derives it (§12.6)." | plain | D-317 bullet 6, bold at §12.6 9310 | C, adjacent |
| 17 | 8624–8626 | "A run's outcome is not a control surface, so `termination` belongs to the `Run` … (§12.6, D-255) and not here." | plain | D-255 bullet 2; Rejected log 10105–10106 | C |
| 18 | 8626–8627 | "The control plane is what anyone may poke." | plain | D-255 Rationale log 10077–10078, Rejected log 10105–10106 | R |
| 19 | 8629 | "**Control is not staging, structurally.**" | bold lead-in, no citation | D-022 Position parenthetical ("staging cannot un-pause a drainless loop") | U; one ruling with row 3, already bold at §11.1 6839 (part B) |
| 20 | 8629–8631 | "Staged writes apply at drains, and a paused loop drains nothing, so un-pause via staging would deadlock by construction." | plain | D-022 Position | U (the reason) |
| 21 | 8631–8633 | "Riding outside the drain/trace path is safe for determinism precisely because §10.7 put pacing outside the semantics." | plain | D-021 Position | U |
| 22 | 8633–8634 | "Control changes *when* frames execute, never what they compute, and stop merely truncates the trajectory." | plain | D-021 Position; §2.2 359–361 and §2.4 545–548 state it | U; Part I's depth (part B) |
| 23 | 8635–8636 | "While paused the loop blocks on a condition (notified on un-pause and stop), not a spin." | plain | D-269 bullet 3 (the pause block woken at once) | B: U for the wake; N for "a condition, not a spin" (mechanism; `wait_resume!` parks on `Control.wake`) |
| 24 | 8638 | "**The pause is two verbs on the simulation** (D-268)" | bold lead-in | D-268 Position, sentence 1 | C |
| 25 | 8638–8640 | "`pause!(sim)` sets the pause flag and `resume!(sim)` clears it, from any task and in any lifecycle state; `paused(sim)` reads it." | plain | D-268 Position, bullet 1 | C, adjacent |
| 26 | 8640–8642 | "The loop consults the flag at frame top, so a `pause!` issued before `run!` starts the run paused at its first frame top." | plain | D-268 bullet 1 as amended by D-269 (annotation log 11177–11179); start-paused: D-268 Rationale log 11136–11139 | B: C for the consultation; R for the consequence |
| 27 | 8642–8643 | "A stop issued while paused wakes the loop, which observes the stop word and enters the tail with no further frame (§12.4)." | plain | D-269 bullet 3; D-030 Position ("wake framework waits") | U |
| 28 | 8643–8645 | "`step!` shares the frame top and blocks the same way, until `resume!` or a stop from another task." | plain | D-268 bullet 1 ("`step!` blocks while paused") | C, adjacent |
| 29 | 8647–8648 | "**Rule.** The tail clears the pause flag beside the sticky stopped status. The flag is never cleared at a run's start." | **Rule.** | D-268 bullet 1, sentence 2 | C (D-268 cited 8638, not at the rule) |
| 30 | 8650–8651 | "**Why.** The stop word is cleared at the top of each run because a stop belongs to the run it ended." | **Why.** | D-268 Rejected log 11192 ("as the stop word is"); no Position states the stop word's clearing | R |
| 31 | 8651–8654 | "A pause left set by a run that stopped while paused would instead hold the next run … Clearing it in the tail removes that trap and keeps the start-paused spelling above." | plain | D-268 Rationale log 11136–11139 | R (reason) |
| 32 | 8656 | "The handle carries no pause (§11.6)." | plain | D-268 bullet 1, sentence 3; D-310 bullet 4 | B: U by D-268; C adjacent by D-310 (cited 8657) |
| 33 | 8656–8657 | "Whether it gains the control verbs for the bridge is pending (`pending.md`, D-310)." | plain | D-310 bullet 4 | C |
| 34 | 8659 | "**Pace and `margin` are two more verbs and two readers** (D-269)" | bold lead-in | D-269 bullet 1 | C |
| 35 | 8660–8661 | "`pace!(sim, p)` and `margin!(sim, m)` set them from any task in any lifecycle state, and `pace(sim)` and `margin(sim)` read them." | plain | D-269 bullet 1 | C, adjacent |
| 36 | 8661–8663 | "`run!` and `replay!` take both as keywords and write them at entry, the advance's declaration as `t_end` is, `Inf` and 2 ms by default (Appendix B)." | plain | D-269 bullets 1, 2; D-133 Position (`margin` = 2 ms), bold at §10.7 6724 | C; U for 2 ms. §12.7 9651–9652 restates (part B) |
| 37 | 8664 | "`step!` takes neither and never waits." | plain | D-269 bullet 1 | C, adjacent; §12.6 9352–9353 restates (part B) |
| 38 | 8664–8666 | "A stepping session is the harness mode (§12.6), and its frames are bit-identical to `run!`'s by §10.7's invariant." | plain | D-269 Rationale log 11250–11253 | R |
| 39 | 8666–8668 | "`pace` is a positive real, `Inf` admitted, and `margin` a non-negative real, `Inf` admitted. Each of the four calls refuses anything else under `ArgumentInvalid` (Appendix C)." | plain | D-269 bullet 1 | C, adjacent; "the four calls" has no antecedent (F8) |

D-022's Position rules rows 3, 19 and 20 and is cited nowhere in §12.1; §11.1
bolds it (6839). D-268 and D-269 are cited at their lead-ins and rule rows
24–37; the pause rule (row 29) and the handle sentence (row 32) carry no
citation of their own.

Descriptions that read like rules: row 3 ("a few scalar fields"), row 23.

Display-block candidates: the seven control calls as one fence, `pause!(sim)`,
`resume!(sim)`, `paused(sim)`, `pace!(sim, p)`, `margin!(sim, m)`,
`pace(sim)`, `margin(sim)`, with `stop!(sim)` beside them (Appendix B 13015
lists them that way). An addition the inventory declares.

Glossary terms in §12.1 (lesson 35):

| term | first use | linked there | use matches the entry |
|---|---|---|---|
| control plane | 8595 (title); text 8626 | no; the chapter opening's link (8591) sits outside the section | yes; the entry (14173–14177) lists exactly row 15's fields, and also omits the sticky stopped status |
| frame | 8598 ("frame top") | no | yes |
| device | 8604 | yes, no gloss | yes |
| operator interrupt | 8606 | yes, no gloss | yes |
| termination record | 8614 | yes, no gloss | yes |
| stop policy | 8617, inside a bold lead-in | no | yes |
| `Run` | 8625 | yes, glossed | yes |
| drain | 8630 | yes, no gloss | yes |
| trace | 8631 | yes, no gloss | yes |
| pacing | 8633 | yes, no gloss | yes |

"Stop word" (seven uses in the half, more in §13.5) has no glossary entry; the
control-plane entry names it. "The tail" (8613, 8642, 8647, 8653) is §12.4's
coinage, used in §12.1 before it is defined.

Appendix C kinds cited to §12.1: `ArgumentInvalid` (13427), named at 8668.

### §12.2 Loop scheduling: wait primitive, yields, thread budget (8670–8755, 712 words)

Purpose: the coarse phase's primitive, the per-frame yield, the thread
budget, and the liveness heartbeat with `task_state` and staleness.

Subheadings: none; the context paragraph (8672–8677) names three questions
and the section answers four (the heartbeat is the fourth). Bold: four
**Rule.**, two **Why.**, the lead-in "**Liveness heartbeat.**" (8730) and the
bold sentence at 8750.

| # | line | quote | marking | entry | class |
|---|---|---|---|---|---|
| 40 | 8679–8680 | "**Rule.** The coarse phase uses task-yielding `sleep`. There is no `systemsleep` variant (D-027)." | **Rule.** | D-027 Position | C; §10.7 6743–6745 states it plain with D-027 and points here |
| 41 | 8682–8686 | "**Why.** What the choice buys is the wait slot. `sleep` releases the loop's thread … the natural scheduling window for co-resident device tasks … staging slot (§10.7) … drain source (§11.4)." | **Why.** | D-027 Rejected log 990–992 (`systemsleep` "starves co-resident tasks silently") | R |
| 42 | 8688–8690 | "A `systemsleep` variant for dedicated-thread hard-RT deployments is a guarded addition" | plain | none; D-027 Rejected rejects `systemsleep` without admitting it as an addition | N |
| 43 | 8692 | "**Rule.** With devices attached, every frame yields at least once." | **Rule.** | D-027 Position | U |
| 44 | 8694–8695 | "**Why.** The rule is semantically free. Pacing, and hence yielding, is outside the semantics (§10.7)." | **Why.** | D-021 Position | U (reason) |
| 45 | 8697–8699 | "The yield is implicit in the coarse-phase `sleep` whenever that phase runs. An explicit `yield()` covers the frames where it does not run: unpaced runs, and pure-spin frames with budget ≤ margin." | plain | D-027 Position ("explicit `yield()` in unpaced/pure-spin frames") | U; the code yields explicitly in every frame with a roster (F19) |
| 46 | 8699–8700 | "The spin phase itself never yields. Yielding there would trade its µs precision for scheduler noise." | plain | D-027 Position; Rejected log 995; D-294 bullet 3 (the safepoint is not a yield) | B: U for the rule; R for the reason |
| 47 | 8702–8706 | "The consequence is a bound on thread occupancy. The loop holds a thread for at most one frame … Julia's cooperative-scheduler freeze requires a thread monopolist … structurally absent from framework tasks." | plain | D-027 Rejected log 993–994 ("no framework thread monopolist") | R |
| 48 | 8708–8709 | "**Rule.** The thread budget is a documented sizing rule and a startup warning, not a hard error (D-027)." | **Rule.** | D-027 Position | C |
| 49 | 8711–8716 | "The freeze FlightCore's `nthreads` error prevented cannot reproduce here, for two reasons. The loop yields every frame. Nothing couples a stall to anyone else, the GUI least of all. It waits on nothing, ever. … Under any starvation, then, the front end keeps rendering and the stop button keeps working." | plain | D-027 Rejected log 993–994 ("no framework thread monopolist, no stall coupling, GUI on the calling task") | R; the third ground was withdrawn by D-310 bullet 1, and D-027 carries no annotation (F2) |
| 50 | 8717–8718 | "Undersized sessions degrade to laggy inputs and stale snapshots, which are visible, recoverable states." | plain | D-027 Rejected log 991–992 ("worse failure mode than diagnosed overruns") | B: R; or N, a description |
| 51 | 8720–8721 | "A run warns, at `run!` or `replay!`, when `Threads.nthreads()` is tight for the attached population, naming the `julia -t` remedy." | plain | D-027 Position ("startup warning") | U; the kind, `ThreadBudget`, is not named (F15) |
| 52 | 8721–8722 | "That is one check per run, against the frozen roster (§11.3)." | plain | D-106 Rejected log 3382 ("per-attach thread-budget re-checks") | R |
| 53 | 8722–8725 | "Tight means fewer threads than the roster plus one. Every rostered device is a task, and the calling task hosts the loop, so a run occupies one task more than its roster." | plain | threshold: none (`src/sim.jl` 1335–1339); topology: D-310 bullet 1 | B: N for the threshold; U by D-310 for the reason |
| 54 | 8725–8728 | "The sizing guidance … one thread for the loop and headroom for compute-heavy or blocking-ccall devices. libuv-backed I/O yields. Raw blocking ccalls pin their thread … There is no pinning and there are no sticky tasks." | plain | none; D-093 Rejected log 2929–2930 rejects pinning the GUI | N, description |
| 55 | 8730–8731 | "**Liveness heartbeat.** Since starvation is survivable, it must be diagnosable." | bold lead-in | D-027 Position ("per-device liveness heartbeat in framework status") | U |
| 56 | 8731–8735 | "The record is the published framework status … It includes per-device liveness (the liveness timestamp and the device's `task_state`) next to the pacer diagnostics." | plain | D-027 Position; D-193 Position (cited 8739); D-369 bullet 3 | C, adjacent (D-193) |
| 57 | 8735–8737 | "The mechanism is the per-writer cell, specified in full by §11.8, plus the device `Task` handles the loop already owns, and nothing besides." | plain | D-136 Position; D-193 Position and Rationale log 7216–7217 | B: U by D-136; C adjacent by D-193 |
| 58 | 8737–8739 | "The cell carries the single liveness timestamp. The loop reads `task_state` off those handles where it publishes (D-193)." | plain | D-193 Position; D-240 Position (the heartbeat read at publication, bold at §11.8 8485) | C |
| 59 | 8739–8740 | "A starved, blocked or crashed device task shows in the GUI as a stale heartbeat with a name on it, not as mysteriously frozen physics." | plain | D-374 bullet 1 ("the heartbeat reports it") | U; "in the GUI" (F2) |
| 60 | 8742 | "**Rule.** `task_state` has three values." | **Rule.** | D-270 annotation 2026-09-28 (log 11413–11421) | R |
| 61 | 8742–8745 | "Outside a run every device reads `:none`. Inside a run a device reads `:running` while its task lives and `:done` once that task has ended, whether the body returned or the wrapper caught its crash (§11.6)." | plain | D-270 annotation; D-193 Position (the field) | R |
| 62 | 8745–8746 | "A device whose `init!` threw, and so spawned no task, reads `:done` as well." | plain | D-270 annotation log 11415–11420 | R |
| 63 | 8746–8747 | "The record's crash count tells a crash from a return." | plain | D-270 annotation log 11421 | R |
| 64 | 8747–8748 | "`orphaned` on a record is exactly `:done` (§11.7, D-270)." | plain, cites D-270 | D-270 annotation; the Position still reads "a `:done` or `:failed` task" (log 11332) | R |
| 65 | 8750 | "**Stale means a liveness timestamp more than 2 s behind wall clock.**" | bold sentence, no citation | D-133 Position log 4312 | U |
| 66 | 8750–8751 | "The threshold is deliberately loose, because the heartbeat is advisory." | plain | D-133 Rationale log 4335–4337 | R |
| 67 | 8751–8753 | "It is a liveness display and a record, never a kill trigger, never a detach." | plain | D-133 Rationale ("never a kill trigger"); D-374 bullet 1 (death is not detach) | B: R for the trigger; U for the detach |
| 68 | 8753–8754 | "It must also tolerate a device legitimately parked in a blocking read between rare data." | plain | D-133 Rationale log 4336–4337; D-193 Rejected log 7221–7223 | R |

D-027 is cited twice, at the first and third rules; its Position also rules
rows 43, 45, 46, 51 and 55. D-133 (the 2 s threshold) is cited nowhere in
§12.2. The `task_state` rule (rows 60–64) rests on D-270's annotation alone.

Descriptions that read like rules: rows 50 and 54 ("There is no pinning and
there are no sticky tasks").

Display-block candidates: `task_state`'s three values as a two-column table
(outside a run, `:none`; inside, task alive, `:running`; inside, task ended or
never spawned, `:done`). An addition.

Glossary terms in §12.2 (lesson 35):

| term | first use | linked there | use matches the entry |
|---|---|---|---|
| frame | 8675 | no | yes |
| device | 8684 | yes, no gloss | yes |
| drain | 8685 | yes, no gloss | yes |
| guarded addition | 8689 | yes, glossed | yes |
| pacing | 8694 | yes, no gloss | yes |
| the freeze | 8704 ("Julia's cooperative-scheduler freeze"), 8711 | no | no: the glossary's *the freeze* (`#g-the-freeze`) is the roster freeze, which the same section uses at 8722 ("the frozen roster"). Two senses in one section (F16) |
| snapshot | 8714 | yes, no gloss | yes |
| staging cell | 8715 | yes, no gloss | yes |
| roster | 8722 | yes, no gloss | yes |
| calling task | 8724 | no | yes |
| framework status | 8732 | yes, glossed | yes |
| diagnostic cell | 8735 ("cell") | yes, no gloss | yes |

"Heartbeat", "stale" and "front end" have no glossary entry; §11.8 8479 owns
the heartbeat.

Appendix C kinds cited to §12.2: `ThreadBudget` (13474). §12.2 states its
condition (8720–8723) without naming it (F15).

### §12.3 The next-snapshot wait (8756–8825, 501 words)

Purpose: how a device learns that a boundary was published, the two indices,
the publication order, and newest-wins delivery.

Subheadings: none. Bold: two **Rule.**, the bold term "**boundary
counter**" (8763), the bold word "**before**" (8799), and the lead-ins
"**Two indices, and where each lives.**" (8785) and "**Semantics:
newest-wins, no queues.**" (8816).

| # | line | quote | marking | entry | class |
|---|---|---|---|---|---|
| 69 | 8758–8760 | "Rate-matched output devices (telemetry, disk streaming) act once per boundary. What they need … is a way to learn that a boundary has happened without polling for it." | plain | D-028 Rejected log 1016–1017 (polling `latest` on a timer) | context; R |
| 70 | 8762–8764 | "**Rule.** Two artifacts provide it: a monotonic **boundary counter**, the loop's own, plus one `Threads.Condition`." | **Rule.**, bold term | D-028 Position | U (D-028 cited at 8781 and 8821, for its rejections) |
| 71 | 8766–8768 | "The counter counts *published boundaries*, that is grid, `t*` and boundary zero (§10.1, §10.4), not frames. Consecutive wakes are therefore not necessarily `h` apart." | plain | D-081 Position (boundaries); Rejected log 2579–2580 ("A frame counter in §12.3") | B: U for the count; R for "not frames" |
| 72 | 8770–8772 | "The loop's publication is `lock; counter += 1; notify; unlock`, nanoseconds of framework-only code. Waiters never block it. One parked in `wait` has released the lock as part of parking." | plain | D-022 Position (no unbounded work in a critical section) | U; mechanism |
| 73 | 8774–8775 | "The device side is `wait_next_snapshot(handle)`, which blocks until `counter > last_seen && running` under the canonical predicate-loop idiom." | plain | D-028 Position | U |
| 74 | 8775–8779 | "That idiom handles waiters at different paces, frames skipped while transmitting, and shutdown, all with no per-frame reset. Shutdown works because §12.4 wakes all waiters and each predicate then routes its owner out." | plain | D-028 Position ("shutdown-interruptible via the predicate"); D-030 Position | U |
| 75 | 8781 | "A `Base.Event` latch is the wrong primitive here (D-028)." | plain, cites D-028 | D-028 Rejected log 1011–1013; D-367 Position | R (adversarial; q6) |
| 76 | 8781–8783 | "Conditions carry no facts, only 'look again'. The facts that matter, the counter and `running`, live in state each waiter tests privately." | plain | D-028 Rejected log 1011–1012 | R (constructive reason) |
| 77 | 8785–8787 | "**Two indices, and where each lives.** The snapshot carries the trajectory's *published-boundary ordinal* with `t`. Boundary zero is 0, and every publication after it, grid or `t*`, counts one." | bold lead-in | D-230 Position | C, adjacent (cited 8796) |
| 78 | 8787–8789 | "Any holder of a snapshot therefore indexes it without consulting the loop, whether the log or a post-run inspector." | plain | D-114 Position ("what boundary indexing from retained snapshots presupposes"); Rejected log 3651–3652 | U |
| 79 | 8789–8790 | "A new trajectory restarts the ordinal at zero, with everything else `init!` resets." | plain | D-230 Position | C, adjacent |
| 80 | 8790–8792 | "The boundary counter is a different number. It is the loop's monotone count of every publication it has ever made, never reset across trajectories, and its absolute value is nowhere normative." | plain | D-230 Position | C, adjacent |
| 81 | 8792–8794 | "It exists for the wait predicate alone, and it is never reset because a waiter's `last_seen` must never run ahead of it (D-230)." | plain, cites D-230 | D-230 Rationale log 8855–8858; Rejected log 8870–8871 | R |
| 82 | 8794–8796 | "An error's replay pointer is a third index, the frame-entry boundary index of §13.4, a frame count that names no `t*` boundary." | plain | D-128 Position; D-230 Rationale log 8861–8863 | U |
| 83 | 8798–8800 | "**Rule.** The order of the two publications is normative. The release-store of `latest` (§11.2) happens **before** the counter increment under the lock." | **Rule.**, bold word | D-114 Position | U; D-114 is cited nowhere in the spec |
| 84 | 8802–8809 | the publication-order sketch | `julia` fence | D-114 | code (part C) |
| 85 | 8811–8813 | "`counter > last_seen` therefore implies that `latest` holds at least that boundary, and a waiter can never wake onto a stale snapshot." | plain | D-114 Position | U |
| 86 | 8813–8814 | "The converse, observing a *newer* snapshot than the increment that woke you, is expected and correct. Newest wins." | plain | D-114 Position | U; "you" is the only second person in the half |
| 87 | 8816–8817 | "**Semantics: newest-wins, no queues.** A slow consumer skips frames and always receives the current world." | labelled bold lead-in | D-028 Position | U; "skips frames" where the counter counts boundaries (F17) |
| 88 | 8817–8819 | "This mirrors the inbound side. Coalescing to the newest batch (in) and to the newest snapshot (out) are the same ZOH decision." | plain | D-028 Position ("outbound coalescing mirrors inbound ZOH") | U; "the newest batch" misstates coalescing (F17) |
| 89 | 8819–8820 | "No backpressure exists in either direction, and the loop never waits on anyone." | plain | D-022 Position (no unbounded work in critical sections) | B: U by D-022; N as stated |
| 90 | 8820–8821 | "Per-consumer every-boundary queues are rejected (D-028)." | plain, cites D-028 | D-028 Rejected log 1014–1015 | R (adversarial; q6) |
| 91 | 8823–8824 | "The GUI does not use the wait. Being VSync-paced, it reads `latest` at each render." | plain | D-134 Rationale log 4398–4399 (D-134 retired in substance by D-174; the GUI parked by D-310) | R; describes a parked device (F2) |

D-028's Position (rows 70, 73, 74, 87, 88) is cited only at its two
rejections. D-114 (rows 78, 83, 85, 86) is cited nowhere. D-230 is cited once,
at the end of its paragraph.

Descriptions that read like rules: row 72 ("Waiters never block it"), row 89.

Display-block candidates: the wait call, `snap = wait_next_snapshot(handle)`
inside the predicate loop, as §11.6 7954 already spells it. An addition, or a
pointer to §11.6's loop body.

Glossary terms in §12.3 (lesson 35):

| term | first use | linked there | use matches the entry |
|---|---|---|---|
| next-snapshot wait | 8756 (title) | no link anywhere in the section | yes (14233–14236) |
| device | 8758 | yes, no gloss | yes |
| boundary | 8759 | yes, no gloss | yes |
| boundary counter | 8763 | yes, bold, no gloss | yes (14153–14157) |
| boundary zero | 8767 | yes, no gloss | yes |
| frame | 8767 | no | yes |
| snapshot | 8785 | yes, no gloss | yes |
| replay | 8795 | yes, no gloss | yes |
| `latest` | 8799 | no | yes |
| batch | 8818 | no | no: "coalescing to the newest batch" reads as batch replacement, while *coalescing* (14167–14170) is the per-face merge, untouched faces surviving (F17) |
| coalescing | 8818 | yes, no gloss | see batch |

Appendix C kinds cited to §12.3: none.

### §12.4 Shutdown protocol (8826–9168, 2,796 words)
(§12.4 is another unit's; see the full survey.)

### Tally

| section | rules | C | U | S | R | N | B |
|---|---|---|---|---|---|---|---|
| heading | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| §12.1 | 37 | 21 | 7 | 0 | 4 | 0 | 5 |
| §12.2 | 29 | 4 | 7 | 0 | 11 | 2 | 5 |
| §12.3 | 21 | 3 | 11 | 0 | 5 | 0 | 2 |
| §12.4 | 107 | 17 | 40 | 0 | 34 | 2 | 14 |
| total | 194 | 45 | 65 | 0 | 54 | 4 | 26 |

The count leaves out six rows that are framing, context, code or the chart
(1, 2, 69, 84, 122, 147), and classes each row by its first code. "C,
adjacent" counts as C, so §12.1's 21 overstates how often a rule carries its
own citation: only 8 of §12.1's rows carry a citation in the sentence itself.

The U rows cluster in five entries the half cites nowhere or only for a
rejection: D-030 (12 rows, cited nowhere in the spec), D-138 (5 Position rows
in §12.4, its home, where it is never cited), D-132 (3), D-028 (5), D-114 (4,
cited nowhere in the spec). The R rows cluster in three Rationales and one set
of annotations: D-138 (13 rows, the init bracket's dispositions), D-132 (11,
the masking and the escalations), D-133 (6, the `t_end` landing and the
staleness threshold), D-270's annotation (5, `task_state`) and D-268's
annotations (4). No citation is to a superseded entry. One bold (row 168)
rests on a clause D-138's own annotation calls historical.

Bold weight now: 64 spans, 281 words. Labels and labelled lead-ins: 23
(**Rule.** ×16, **Why.** ×4, three "**Why …**"). Bold step labels: seven, plus
five bold step numbers in the chart. The rest are lead-ins acting as headings
("**Liveness heartbeat.**", "**What survives the tail.**", "**A second
interrupt during the tail**") or whole-sentence rulings (rows 15, 145, 172).

## B. Overlaps

### Inside the half

| # | the fact | places | proposed home |
|---|---|---|---|
| B1 | the stop's issuers, and the interrupt as "exactly this stop" with no entry point | §12.1 8603–8608 (rows 8, 9); §12.4 8848–8851 (row 95), 9085–9087 (row 177) | §12.1; §12.4 (1) keeps one clause naming the three sources and points |
| B2 | a stop issued while paused wakes the loop | §12.1 8642–8643 (row 27); §12.4 (2) 8855–8857 (row 99) | §12.4 (2), the wake step; §12.1 keeps the clause with "(§12.4)" |
| B3 | `join_timeout` lives on `Control` | §12.1 8621–8623 (row 15, bold); §12.4 (5) 8870–8871 (row 107, bold step label citing D-256) | §12.1's bold; §12.4 plain |
| B4 | a failed `init!` spawns no task; the run proceeds or ends at once | §12.4 9020–9022, 9038–9051 (rows 158, 163–166); 9057–9060 (row 168) | rows 158–166; row 168 merges into them (M8) |
| B5 | the unmask points | §12.1 8605–8607 (row 9); §12.4 9104–9106 (row 182) | §12.4 |
| B6 | staleness and the 2 s threshold | §12.2 8750–8754 (rows 65–68); §12.4 9024–9027 (row 159) | §12.2 |
| B7 | `task_state` of a device whose `init!` threw | §12.2 8745–8746 (row 62); §12.4 9020–9027 (rows 158–159) | §12.2 for the value; §12.4 points |
| B8 | the counter is never reset or re-armed | §12.3 8790–8794 (rows 80, 81); §12.4 8957–8959 (row 142) | §12.3; §12.4 keeps the `last_seen` read at spawn |
| B9 | the ordered tail, twice | §12.4 numbered list 8845–8898; chart 8900–8906 | the list; the chart is q4 |

### With the other half (§12.5–§12.7)

| # | the fact | half 1 | half 2 | proposed home |
|---|---|---|---|---|
| H1 | the lifecycle is derived, not stored | §12.1 8623–8624 (row 16) | §12.6 9310 (bold, D-317) | §12.6; §12.1 plain, as now |
| H2 | `join_timeout` is `Control`'s | §12.1 row 15; §12.4 row 107 | §12.6 9285 ("`join_timeout` is `Control`'s (§12.1)") | §12.1 |
| H3 | `step!` takes no pace and never waits; a stepping session is the harness mode | §12.1 8664–8666 (rows 37, 38) | §12.6 9352–9353 (cites D-269) | §12.1, which owns D-269 bullet 1; §12.6 keeps "never waits" as a pointer |
| H4 | `replay!` takes `pace` and `margin` | §12.1 8661–8663 (row 36) | §12.7 9651–9652 (cites D-269) | §12.1 |
| H5 | what survives a stop; the next run re-initializes and re-spawns | §12.4 8947–8963 (rows 137–144) | §12.6 9460–9466 ("**Device attachments persist across re-initialization**", bold); 9468–9470 ("**Task topology follows the roster each time**", bold) | q5 |
| H6 | topology after initialization | §12.4 9057–9060 (row 168, bold) | §12.6 9468–9470 (bold, cites §11.1) | §11.1 6880–6882 states it plain since chapter 11; both bolds go (q5, carried items) |
| H7 | `t_end` lands by whole frames; `t_plus` covers a duration | §12.4 8920–8927 (rows 127–130) | §12.6 9354–9356; §12.7 9585–9589 (the opposite rounding of `to_time`) | §12.4 for `t_end`; §12.6 for `t_plus` |
| H8 | a stopped simulation's next `run!` | §12.4 9054, 9080 (rows 167, 174: "resumable by the next `run!`") | §12.6 9301 ("terminally **stopped**"), 9403–9405 (`stopped → init! → run!`) | contradiction, F1 |
| H9 | `checkpoint` after an abandoned frame | §12.4 9152–9153 (row 195) | §12.6 9426–9431 (`CheckpointMidFrame`) | §12.6; §12.4 names the kind |
| H10 | reproduction is trace replay | §12.4 9153–9154 (row 195) | §12.6 9482–9483 (D-059) | §12.6 |
| H11 | the loop runs on the calling task | §12.2 8723–8725 (row 53) | §12.6 9343–9348 | §11.1 (bold, D-310); both halves point |

### With other chapters

Part I. `spec_style.md`'s "Part I's depth" puts laws in Part I and spellings,
enforcement and mechanisms in Parts II to IV.

- Row 22 (8633–8634, "Control changes *when* frames execute, never what they
  compute, and stop merely truncates the trajectory") restates §2.2 359–361
  and §2.4 545–548 at Part I's depth. In §12.1 it is the reason control may
  bypass the trace, so it can stay as one clause pointing to §2.2.
- Rows 127–129 (8920–8925, the `t_end` landing) restate §2.4 533–535 ("the
  first grid boundary at or after it … pass the end time by up to one step").
  The mechanism stays in §12.4: whole frames by grid indexing, the check
  against boundary times, the termination record's actual `t`. The law can
  point to §2.4.
- Row 131's second sentence (stop requests at every published boundary)
  restates §2.4 538–542 and §13.5. It is a pointer in §12.4.
- No other sentence in the half restates Part I.

Chapter 10, rewritten. Chapter 10 already chose its homes:

- §10.7 6743–6745 states "The coarse phase uses task-yielding `sleep`" plain
  with D-027 and points here; §12.2 (row 40) is the home and bolds it.
- §10.7 6747–6753 states the frame-top consultation (D-269) and the wait as
  an unmask point (D-132, D-294) plain, pointing to §12.1 and §12.4. Homes:
  §12.1 for D-269 bullet 3 (rows 4–6), §12.4 for the unmask points (row 182).
- §10.7 6724 bolds "The default `margin` is 2 ms" (D-133). §12.1 row 36's
  "2 ms by default" stays plain.
- §10.7's invariant (pacing outside the semantics, D-021) is cited by rows 21,
  22 and 44; the home is §10.7.

Chapter 11, rewritten. Chapter 11 already chose these homes, and half 1 must
not bold them again:

- §11.1 6839 bolds D-022's control plane ("**Control places pause, pace and
  stop on a separate few-word atomic surface**"). §12.1's "**Control is not
  staging, structurally.**" (row 19) is D-022's parenthetical reason for the
  same ruling, so its bold is a double.
- §11.1 6866 bolds D-093 (device tasks are run-scoped). §12.4 rows 137 and
  141 state it plain; keep them plain.
- §11.1 6880–6882 states the topology after initialization plain (D-310,
  D-138) and points to §12.4 for "a device whose `init!` failed gets no
  task". §12.4 is the home of that fact (D-138's Position); row 168's bold
  "**Topology is derived after initialization**" goes.
- §11.2 7050–7052 bolds the retained endpoints (D-368 bullet 5). §12.4's
  "**Rule.** That terminal snapshot is retained in the log unconditionally"
  (row 126) is a double; it becomes a plain pointer.
- §11.3 7361 bolds "Device death does not detach" (D-374). Rows 116, 139 and
  160 point.
- §11.6 7885 bolds `shutdown!`'s tolerance (D-138, D-372); 7906 bolds "The
  tolerance also covers a call with no `init!` before it" (D-268 bullet 7);
  7916 bolds "An `InterruptException` is never a `DeviceCrash`" (D-132);
  7971 bolds "`should_close` dissolves" (D-373); 7984 bolds `should_abort` as
  an `attach!` keyword (D-138, D-381). §12.4's "**The entry is listed for
  release before its `init!` begins**" (row 151) is the second bold of D-268
  bullet 7, the carried item. Rows 104, 113, 114, 150 and 171 stay plain.
- §11.8 8485 bolds the heartbeat read at publication (D-240); row 58 is
  plain. §11.8 8538 bolds "The terminal snapshot carries the run's final
  cumulative counters" (D-369, citing §12.4); row 124 is plain. §11.8
  8536–8552 ("The run's end") states D-201's and D-203's residue plain, so
  neither entry is bold anywhere yet (q3).
- §11.3 7310–7314 and §14's opening (11008–11011) cite §12.1 for "Pause is a
  control-plane state *inside* a run"; §12.1 never says it (F21).

Chapter 13, not yet rewritten:

- §13.6 10532–10535 bolds "discards the failed boundary, promotes the previous
  snapshot to final, and rejoins the ordinary tail". §12.4 (7) (row 120)
  restates it; §13.6 is the home, and (7) keeps the pointer.
- §13.4 10235–10246 ("The one exception never wrapped") restates the masking
  and the forced throw (rows 181–183, 193–194), citing §12.4 and D-268. §12.4
  is the home; chapter 13's rewrite points.
- §13.5 10356–10362 states the stop-request initiation of the tail and the
  terminal counters, pointing to §12.4.

## C. Proposed structure

No section is renumbered and none is retitled. 239 inbound rows point at the
half's sections (part D). No file links a `####` anchor of chapter 12: the
only `spec.md#` links to it are the section-level link definitions (checked
with `rg 'spec.md#12'` over `docs/`), so `####` labels can be added or
retitled freely.

### Moves

| move | content | from | to | needs a ruling |
|---|---|---|---|---|
| M1 | the reason control is a separate surface: staging cannot un-pause a drainless loop; control changes when frames run, never what they compute | §12.1 8629–8634 (rows 19–22) | up, as §12.1's context paragraph, before 8597; the bold goes (q3) | no |
| M2 | "`margin` rides here for the same reason `pace` does …" | §12.1 8601–8603 (row 7) | down, into the pace and `margin` paragraph (8659–8668) | no |
| M3 | the stop's issuers and the interrupt as "exactly this stop" | §12.1 8603–8608 (rows 8, 9) | down, to open the stop-word paragraph (8610–8619), so the stop is one block | no |
| M4 | what `Control` keeps | §12.1 8621–8627 (rows 15–18) | down, to the end of §12.1, as the summary of the fields the section has introduced; its "stop word" then follows the stop block, and the running flag, the wait and `join_timeout` carry their pointers (§12.6, §12.3, §12.4) | no |
| M5 | the loop's side of the wait: the publication under the lock and the normative order with its sketch | §12.3 8770–8772 and 8798–8814 (rows 72, 83–86) | together, directly after the counter's definition (8766–8768) and before the device side (8774–8779) | no |
| M6 | newest-wins, no queues | §12.3 8816–8821 (rows 87–90) | up, directly after the device side (8774–8779) and before the `Event` rejection (8781–8783) | no |
| M7 | "`t_end` lands on the grid" and "The two termination sources differ in kind" | §12.4 8920–8931 (rows 127–131) | up, directly after the chart (8906), before "Why the final snapshot goes out …" (8908): both elaborate step (1), and the paragraphs after them elaborate (1)'s order, then (5) | no |
| M8 | "**Topology is derived after initialization** …" | §12.4 9057–9060 (row 168) | merged into the no-task rule (9020–9022) and the `should_abort` split (9038–9051), which state its content; the bold and the "(§11.1)" go | yes, q5 |
| M9 | "Initialization is a step of this protocol …" | §12.4 8967 (row 145) | merged into the **Rule.** that follows (8969–8971), one ruling | no |
| M10 | "**Interactive-session scope, stated plainly.**" | §12.4 9163–9167 (rows 199, 200) | up, after the opening paragraphs of "The operator interrupt" (ends 9090) and before the masking rule (9092): the scope bounds everything after it | no |
| M11 | the failed boundary discarded, the previous snapshot promoted | §12.4 (7) 8894–8895 (row 120) | trimmed to a clause pointing to §13.6, which bolds it (10532–10535) | no |
| M12 | the overlaps with half 2 (part B, H1–H11) | — | each kept in its home with a pointer at the other | yes, q5 |

All moves stay inside one section, so each stays inside one unit. M8 and
M12 change only half 1's text; the matching half 2 pointers belong to the
sibling's units.

### Order within each section

Define-before-use was checked for each order below against the terms each
block uses.

- **Chapter opening (q1).** One context sentence: the chapter specifies the
  machinery that drives the loop itself, taking §11's data plane and §10's
  loop as given. One roadmap sentence naming §12.1–§12.7 in order, §12.5
  included. "The loop boundary" goes (row 1).
- **§12.1.** Context (M1). When the loop reads the plane (8597–8601, the
  frame top glossed). The stop: issuers and the interrupt (M3), the stop word
  and its issuer (8610–8615), outside the stop policy (8617–8619). The pause
  (8638–8657). Pace and `margin` (8659–8668 with M2). What `Control` keeps
  (M4). "The tail" (8613, 8642) gets a gloss at first use, "the shutdown
  sequence (§12.4)"; "unmask points" (8607) gets one, "the points where the
  loop takes a deferred Ctrl-C (§12.4)". With F21 ruled, one sentence after
  the pause verbs says a paused run is still running. No subheadings are
  needed at 661 words; the context ends with one sentence naming the parts.
- **§12.2.** Unchanged order: the primitive, the yield, the thread budget,
  the heartbeat, `task_state`, staleness. The context's parts sentence
  (8675–8677) names three questions and must name the fourth, the heartbeat.
  The two senses of "freeze" (F16) must part: "the scheduler freeze" at
  8704 and 8711, "the frozen roster" at 8722.
- **§12.3.** Context (8758–8760). The rule, two artifacts (8762–8764). What
  the counter counts (8766–8768). The loop's side (M5): the publication
  under the lock, the normative order, the sketch, its consequence. The
  device side (8774–8779). Newest-wins (M6). The `Event` latch (8781–8783,
  q6). Two indices (8785–8796): `last_seen`, used at 8793, is then defined at
  8775. The GUI note (8823–8824, q2). `latest` (8799) gets its glossary link
  and a gloss at first use.
- **§12.4.** Context (8828–8837), unchanged; it already names the three
  parts. "The tail": the rule and the seven steps, the chart (q4), then M7's
  order: `t_end`'s landing, the two sources, why the final snapshot goes
  first, the retained terminal snapshot as a pointer, why five seconds, the
  cap's disposition, what survives, the next run. "Initialization": the rule
  (M9), the sketch, why the bracket, the listing (plain, q3), the report, the
  no-task rule with staleness, claims persist, the `should_abort` split (with
  M8), the interrupt inside `init!`. "The operator interrupt": stop not
  failure, the escape and no entry point, the scope (M10), the masking rule,
  its reason and mechanism, then the five D-268 rulings in their present
  order, then the second interrupt. Each step label of the tail's list stays
  as the item's first words, unbolded (q4).

### Rewrite units

| unit | lines (original) | moves in | moves out | words |
|---|---|---|---|---|
| A | 8588–8825: heading, roadmap, §12.1, §12.2, §12.3 | M1–M6 within | — | 1,918, plus the context and roadmap sentences |
| B | 8826–9168: §12.4 | M7–M11 within | — | 2,796 |

Total 4,714 words. Units C to E are unused.

A falls under the 2,500-word floor. The alternative cut is A′ = 8588–8964
(3,126 words: §12.1–§12.3 plus §12.4's context and tail) and B′ = 8965–9168
(1,588 words: the bracket and the interrupt). It splits §12.4 at a clean
`####` and puts the tail with §12.1–§12.3, which it cites most (the wait,
`Control`, the heartbeat). But M7 and the tail's step labels then sit in A′
while the init bracket's references to (6) and "the pending-stop path above"
cross into B′, and B′ falls further under the floor than A does.
Recommendation: A and B by section (q9).

### Code blocks, charts and tables

The half holds two code blocks, one chart and no table:

- 8802–8809: the publication order, a `julia` fence of pseudo-code (`@atomic
  latest = snap` on a free name, `lock(cond) do`). Carry verbatim; its
  comments cite §11.2. `norm.py` folds it into one code span.
- 8900–8906: the ordered tail in one line, a blockquote with five bold step
  numbers, arrows and code spans. `norm.py` treats it as prose, so its terms
  must be covered by the claim's span. Carry verbatim or drop under q4.
- 8973–8990: the init bracket, a `julia` fence of pseudo-code (free `roster`,
  `live`, `control`). Comment edits are ruled edits only. It differs from
  `src/devices.jl` 454–474 in two places (part E, F24).

The tail's numbered list (8845–8898) is prose with seven bold step labels;
each label becomes plain under q4. Inline math: `h/p`, `tₖ = t₀ + k·h`, both
plain text.

New display blocks (part A candidates): the control calls (§12.1), the
`task_state` values (§12.2), the wait call (§12.3). Each is an addition the
inventory declares.

### Running the half's code

Loaded with `test/repl.jl` inside `module H1Check` (script
`scratch_survey/h1/run/blocks.jl`, run with `julia --project=test -t 2`). Each
check printed its result; none failed except as noted.

- **8802–8809, the publication order: cannot run** (pseudo-code). Its claim
  matches `publish!` (`src/sim.jl` 1955–1974): the release-store of `latest`,
  then `lock(control.wake)`, `counter += 1`, `notify`. Run: after `init!` and
  a three-frame run the counter read 4 and the final ordinal 3; after a second
  `init!` the counter read 5 and the ordinal 0, as §12.3's two indices say. A
  device waiting in `wait_next_snapshot` woke 11 times over 10 frames (ten
  publications and the stop wake) and returned.
- **8973–8990, the init bracket: cannot run** (pseudo-code). Its structure
  matches `_init_devices!`. Run with three entries, the second a `BadInit`
  attached with `should_abort = true`: `init!` ran on the calling task in
  attachment order (first, third; the second threw); the run advanced zero
  frames, ended `stopped` at `t = 0.0`, logged only boundary zero, and
  recorded `ControlRequestedStop("device 2 (BadInit)")`. The sketch's
  `stop!(control)` hides that issuer (F24).
- **8900–8906, the chart: cannot run.**
- Claims checked in passing:
  - §12.1: `paused` false and `pace`, `margin` `Inf`, `0.002` at
    construction; `pace!` refuses 0, −1 and `NaN`, accepts `Inf`; `margin!`
    refuses −1 and `NaN`, accepts 0 and `Inf`; each refusal is
    `ArgumentInvalid`. `pause!` before `run!` held the run at frame 0 with
    the lifecycle `running`; `stop!` from another task ended it `stopped`
    with zero frames, the pause flag cleared, source
    `ControlRequestedStop(:code)`.
  - `join_timeout` defaults to 5.0, accepts `Inf`, refuses 0 and −1 as
    `ArgumentInvalid` (collected). `Control`'s fields are `stop_issuer`,
    `stopped`, `paused`, `pace`, `margin`, `wake`, `counter`, `running`,
    `join_timeout` (F7).
  - §12.2: a rostered device reads `task_state` `:none` after `init!` and
    after `step!` (both outside a run) and `:done` inside a run when its
    `init!` threw; its never-beaten heartbeat `0.0` reads stale. One device
    on two threads raises no `ThreadBudget`, as "fewer threads than the
    roster plus one" says.
  - §12.4: `t_end = 0.25` at `h = 0.1` ends at `t ≈ 0.3` after three frames,
    `EndTimeReached`. Under `log_every = 7, log_max = 2`, 23 frames retain
    frames `[0, 7, 14, 23]`, the terminal frame 23 kept outside the stride.
  - **`run!` on a `stopped` simulation is refused**: `ServiceLifecycle:
    run! on a stopped simulation: re-running is the stopped → init! → run!
    cycle` (F1).
  - **A run that does not start at boundary zero**: after `step!(sim;
    frames = 3)`, an `attach!` of a `BadInit` with `should_abort = true` and
    a `run!`, the run ended `stopped` at frame 3, `t ≈ 0.3`, not at `t₀`
    (F9).
  - **A device that beat in an earlier run**: a device whose `init!`
    succeeded in run 1 and threw in run 2 (after a re-`init!`) read `:done`
    in run 2's first published record but **not stale**, its heartbeat 0.036
    s old (F10).

## D. Inbound citations

The rows analysed are the 239 rows of `inbound.tsv` whose target is §12,
§12.1, §12.2, §12.3 or §12.4 (copied to `scratch_survey/h1/mine.tsv`). The
eight §12 rows are shared with the sibling; none of them relies on a sentence
of either half.

By file: `decisions.md` 112 (Spec 48, Rationale 29, Position 20, Rejected 10,
Annotation 5), `spec.md` 94, `implementation.md` 27, `flight_case_studies.md`
4, `frame_walkthrough.md` 1, `inbound_periphery_walkthrough.md` 1. The 94
`spec.md` rows: Part I 5, Part III outside chapter 12 43, Part IV 17,
Appendix A 2, Appendix B 11, Appendix C 7, the glossary 9.

By target: §12 8, §12.1 34, §12.2 42, §12.3 36, §12.4 119 (in `spec.md`
alone: 5, 14, 13, 13, 49).

Ranges recorded at their ends only: `implementation.md` 318 and 449
("§12.1–§12.4") also cover §12.2 and §12.3; `implementation.md` 827
("§12.1–§12.7") also covers §12.2–§12.6 (the §12.7 end is the sibling's).

### Citations relying on moved or trimmed content

M8, the topology bold (§12.4 9057–9060):

| file:line | fact relied on | after M8 |
|---|---|---|
| spec 6882 (§11.1) | "A device whose `init!` failed gets no task (§12.4, D-138)" | holds; row 158 keeps it |
| log 3492 (D-109 annotation) | "§11.1 and §12.4 carry the canonical statement" of topology after initialization | historical (D-109 superseded → D-310); holds in substance through row 158 |
| spec 9468–9470 (§12.6) | "**Task topology follows the roster each time** (§11.1)" | the sibling's; ruled with q5 |

M11, the promotion clause (§12.4 (7)):

| file:line | fact relied on | after M11 |
|---|---|---|
| spec 10554 (§13.6) | "This fills the seat §12.4 reserved for it. A loop-side failure runs …" | holds if (7) keeps "runs steps (1) through (5) from the catch path" |

Row 126 made plain (the retained terminal snapshot):

| file:line | fact relied on | after |
|---|---|---|
| spec 7052 (§11.2) | the terminal snapshot (§12.4, §13.5) survives any bound | holds; §12.4 keeps the pointer sentence |
| log 4607 (D-137 Rationale) | terminal snapshots "(§12.4(1), §13.5)" | holds; step (1) still publishes the final snapshot |

Row 19 made plain (control is not staging):

| file:line | fact relied on | after |
|---|---|---|
| spec 14177 (glossary, control plane) | "structurally not staging, since a paused loop drains nothing (§12.1)" | holds; M1 keeps the sentence as context |
| spec 7165 (§11.3), 13013 (Appendix B) | control commands are not writes, never staged (§12.1) | holds |

M1–M7, M9, M10 reorder within their sections; no row names a moved sentence
by position. D-133's "stated once in §12.4(1)" (log 4316) is wrong before and
after M7.

The corrections part G proposes touch these rows:

- F1 ("resumable by the next `run!`"): log 4235–4236 (D-132 Position) states
  it; no other row relies on it.
- F9 (the init failure at boundary zero): spec 12855 (Appendix B, "the device
  is dead from boundary zero (§12.4)") and log 4670–4683 (D-138 Rationale)
  rely on the wording; both hold for a run that starts after `init!`.
- F2 (the parked GUI): spec 10515 (§13.5, "GUI stop button, device handle,
  code") and `flight_case_studies.md` 408 ("*Window close.* §12.4 applies
  verbatim") use the same GUI; the steps they rely on hold.

### Citations already wrong before the rewrite

The inbound check will flag these whatever the rewrite does; they belong to
track 2 or to the other chapter.

| file:line | claim | what half 1 says |
|---|---|---|
| spec 7312 (§11.3), 11010 (§14's opening) | "Pause is a control-plane state *inside* a run (§12.1)" | §12.1 never says it. D-106 Position log 3347–3348 does; F21 proposes the sentence |
| `implementation.md` 762 | "The mutable `Simulation` of four fields … (§12.1, D-256, D-317)" | §12.1 lists `Control`'s fields; the four-field `Simulation` is §12.6 9274–9277 |
| log 4316 (D-133 Position) | `t_end`'s landing rule "stated once in §12.4(1)" | it is the paragraph at 8920, not step (1) |
| log 4256–4257 (D-132 Rationale); spec 9160 | "§12.4(5)'s honest asymmetry (nothing can abandon the task `run!` stands on)" | (5) has had no asymmetry since D-310 removed the calling-task device (F3) |
| log 4232–4233 (D-132 Position) | the interrupt joins "`t_end`, `stop_on` and the GUI/handle/code stop among §12.4(1)'s initiation sources" | `stop_on` retired (D-316); (1) says "stop request". Otherwise holds |
| log 4670–4672 (D-138 Rationale) | a failed device's cell "reads stale against §12.2's threshold from the first frame (§11.8, D-136)" | §11.8 never states it, and it fails for a device that beat in an earlier run (F10) |
| log 4398–4399 (D-134 Rationale) | the GUI's read path, VSync-paced `latest` per render (§12.3) | §12.3 8823–8824 still says it; D-134 is retired in substance (D-174) and the GUI parked (D-310) (F2) |
| log 2929–2930 (D-093 Rejected) | "falsifies §12.2's cannot-fail-to-be-scheduled argument" | §12.2's argument (8711–8716) still leans on the GUI (F2) |
| log 3482 (D-109 Rationale), 6530 (D-175 Position) | the calling-task device outside §12.4's join; the `gui = true` detach in §12.4's tail | both entries superseded → D-310; §12.4 holds neither. Historical, no repair needed beyond the status lines |
| spec 14240 (glossary, operator interrupt), 10240 (§13.4) | raised "at a frame-top or wait unmask point" (§12.4) | §12.4 9104–9106 also names the pause block. Minor |
| `flight_case_studies.md` 408 | "*Window close.* §12.4 applies verbatim" | the window is the parked GUI's; the steps listed hold |

### Log entries whose Spec field would change

- Under M1–M11: none; every move is inside its section.
- Under q12 (naming `ThreadBudget`, `ArgumentInvalid` and `CheckpointMidFrame`
  where §12.2 and §12.4 state their conditions): none; D-027, D-198 and D-319
  are the entries, and only D-319 lacks §12.4 (below).

Spec fields stale before any move, entries that rule half 1 without listing
its section (track 2):

- D-030: no **Spec.** field at all; rules §12.4's tail (rows 92–103, 109,
  119).
- D-022: lacks §12.1 (rows 3, 19, 20) and §12.3 (rows 72, 89).
- D-021: lacks §12.1 and §12.2 (rows 7, 21, 22, 44).
- D-128: lacks §12.3 (row 82).
- D-270: lacks §12.2 (rows 60–64, through its annotation).
- D-133: lacks nothing, but lists "§12.4(1)" for a rule that sits elsewhere.
- D-060: lacks §12.4 (rows 96, 121, 178).
- D-228: lacks §12.4 (rows 155, 157).
- D-319: lacks §12.4 (row 195).
- D-366, D-372, D-373, D-374, D-381: each lists §11.6 or §11.3 alone and rules
  a §12.4 sentence (rows 100, 150, 104 and 112–113, 115–116 and 139 and 160,
  114). D-374 also rules §12.2 row 67.
- D-368 and D-369: list §11.2 and §11.8 alone; rows 126 and 124 restate them
  as pointers, so no change is owed if those rows stay pointers.

## E. Log repairs and factual problems

Log repairs go to the second track, after landing. The rewrite only adds
citations; it states no repair. Factual problems stay as written and go to
the units' `rulings.md`, unless part G pre-rules them.

### Entries to cite at the rule

From part A's U rows: D-030 (rows 92–94, 96–103, 109, 119; cited nowhere in
the spec), D-138 (145, 146, 149, 158; cited nowhere in §12.4), D-132 (8, 9,
95, 172–174; cited nowhere in §12.4), D-028 (70, 73, 74, 87, 88; cited only
for its rejections), D-114 (78, 83, 85, 86; cited nowhere in the spec), D-133
(36, 65, 127–129; cited nowhere in the half), D-022 (3, 19, 20, 72, 89), D-027
(43, 45, 46, 51, 55), D-021 (21, 22, 44), D-093 (137, 141), D-097 (110, 118),
D-102 (100, 103, 106), D-189 (156, 157), D-228 (157), D-316 (94, 96, 131,
176), D-060 (96, 121, 178), D-373 (104, 112, 113), D-374 (59, 67, 116, 117,
139, 160), D-381 (114), D-366 (100), D-372 (150), D-136 (57), D-128 (82),
D-230 (142), D-310 (53), D-319 (195), D-106 (140).

### Superseded and half-superseded citations

- No citation in the half is to an entry whose status reads superseded.
- **D-255** (cited 8617, 8626): D-317's Supersedes line (log 13821) retires
  "D-255's clause keeping the lifecycle on `Control`". D-255's Position still
  says "`Control.lifecycle` says whether it started" and "`Control`, which
  keeps the stop word, the lifecycle and the wait" (log 10045–10047), with no
  annotation for D-317. The clauses the half cites (the stop word outside the
  policy, `termination` on the run) stand.
- **D-268** (cited seven times): bullet 2 still says "stop face" (log
  11087–11089), which D-316 replaced with stop requests; no annotation names
  D-316. The spec already says "stop request" (9110).
- **D-270** (cited 8748): its Position says "`orphaned(record)` is a `:done`
  or `:failed` task" (log 11332); the annotation of 2026-09-28 (log
  11413–11421) narrows it to `:done`, which is what row 64 cites.
- **D-198** (cited 8939): its Position makes `join_timeout` "a `Simulation`
  deployment keyword … outside the trace header's deployment block" (log
  7421–7425). D-256 bullet 3 moved it to `Control` and D-317 bullet 2 put it
  on `Simulation(model; join_timeout = 5.0)`. D-198 carries no annotation.
- **D-133** (not cited in the half): amended by D-198 for the join timeout
  ("This amends D-133", log 7425), but D-133's annotation (log 4346–4349)
  names only D-256, D-234 and D-181.

### Rulings that need an entry stating them in a Position

1. `task_state`'s three values, `:done` for a device with no live task of its
   own, the crash count telling a crash from a return, `orphaned` as exactly
   `:done` (rows 60–64): D-270 annotation 2026-09-28 (log 11413–11421).
2. A frame that throws with an interrupt pending ends `errored`; a forced
   throw reaches the defensive arm and ends `stopped` with the frame abandoned
   (rows 186, 187, 193, 194): D-268 annotations 2026-09-26 (log 11161–11172).
3. Boundary masking is normative; `disable_sigint`; the unmask points at the
   frame top and the pause block; the catch site never sees a single
   interrupt; a second interrupt collapses the joins and never reclassifies;
   the interactive-session scope (rows 179–183, 196–200): D-132 Rationale
   (log 4241–4260). D-294 bullet 1 states only the wait as an unmask point.
4. The init bracket's dispositions: no new kind, dead from boundary zero, the
   claims persist, the `should_abort` split, the pending stop, every entry
   still initialized (rows 148, 154, 155, 158–167): D-138 Rationale (log
   4662–4692). D-138's Position states only the bracket.
5. The stop word cleared at the top of each run (row 30): D-268 Rejected log
   11192.
6. What survives a stop, the run-scoped observables, the unplug-while-stopped
   path (rows 138, 143, 144): D-093 Rationale (log 2897–2901).
7. `t_end` a grid fact against stop requests at every boundary; the `t_plus`
   precedent (rows 130, 131): D-133 Rationale (log 4340–4344).
8. The 2 s threshold as advisory and loose, tolerating a parked device (rows
   66–68): D-133 Rationale (log 4335–4337); D-193 Rejected.
9. The control plane as what anyone may poke (row 18): D-255 Rationale and
   Rejected.
10. One thread-budget check per run against the frozen roster (row 52):
    D-106 Rejected log 3382.
11. The counter counts boundaries, not frames (row 71): D-081 Rejected log
    2579–2580.
12. The counter never reset because `last_seen` must not run ahead (row 81):
    D-230 Rationale and Rejected.
13. The interrupt needs no entry point of its own (rows 9, 177): D-132
    Rejected log 4285–4288.
14. The spin never yields, and the freeze needs a monopolist (rows 46, 47,
    49): D-027 Rejected.

### Rulings with no entry at all

The `systemsleep` variant admitted as a guarded addition (row 42); "tight"
as fewer threads than the roster plus one (row 53); the wrapper treating an
`unblock!`-provoked raise as shutdown, not a crash (row 101); each task
reading `last_seen` at spawn (row 142); the pause block parking on a
condition (row 23); `checkpoint`'s test that the latest snapshot is of the
clock's boundary (row 195, which §12.6 9429–9431 also states). Row 120 (the
promotion) is §13.6's and may have its entry there. Descriptions with no
entry, needing none: rows 50, 54, 72, 89, 121.

### Stale entry text and Spec fields

- D-027 Rejected (log 993–994): "GUI on the calling task" as a ground against
  the hard `nthreads` error; withdrawn by D-310 bullet 1, no annotation.
- D-030 Position (log 1040–1043): "device crash = `should_close` path";
  `should_close` dissolved (D-373). No **Spec.** field. No annotation.
- D-093 Rejected (log 2929–2930): the pinned-GUI rejection rests on §12.2's
  "cannot-fail-to-be-scheduled argument"; the annotation of 2026-10-13
  covers the Rationale only.
- D-097 Position (log 3043–3046): `DeviceCrash` carries "device id"; D-228
  dropped writer ids from payloads (log 8752–8754), and `DeviceCrash` is
  `(cause, abort)` in `src/`. No annotation.
- D-114 Position (log 3633–3640): "the boundary index is carried *in* the
  snapshot … and additionally mirrored in the loop state the wait predicate
  tests". Since D-230 the snapshot carries the trajectory's ordinal and the
  wait counter is a separate, never-reset count. No annotation.
- D-132 Position (log 4232–4236): "`stop_on`" (D-316) and "resumable by the
  next `run!`" (F1). Rationale (log 4256–4257): "(5)'s honest asymmetry",
  historical since D-310; the annotation of 2026-10-13 names only the
  topology clause.
- D-133 Position (log 4316): "stated once in §12.4(1)"; Rationale (log 4343):
  "`stop_on`".
- D-138 Rationale (log 4668): `DeviceCrash`'s payload "(device id, …)"
  (D-228); (log 4674–4675): "orphaned slots", "slot totality" (D-206 renamed
  slots to root inputs); (log 4670–4672): stale "from the first frame",
  overbroad (F10); (log 4679–4683): the stop "already pending at boundary
  zero", boundary zero "published" by the run (F9).
- D-198 Position (log 7421–7425): the cap as a deployment keyword (above).
- D-255 Position (log 10045–10047): the lifecycle on `Control` (above).
- D-268 Position bullet 2 (log 11087): "stop face" (above).
- D-270 Position (log 11332): "`:done` or `:failed`" (above).
- Spec fields: part D's list (D-030, D-022, D-021, D-128, D-270, D-060,
  D-228, D-319, D-366, D-372, D-373, D-374, D-381).

### Findings carried from earlier chapters

`docs/spec_rewrite/README.md` 48–61 lists four chapter 12 items. Three fall in
half 1:

- **§12.2 may use "door" for `run!` (chapter 11's F23).** It does not: §12.2
  says "A run warns, at `run!` or `replay!`" (8720), with no "door". The word
  survives in `src/sim.jl` 1153–1155 and 1183 ("either door checks once per
  run"), a code comment outside the rewrite. Nothing for this chapter to
  settle; the code comment is a one-word track 2 note.
- **§12.4 bolds "The entry is listed for release before its `init!` begins"
  (D-268 bullet 7), which §11.6 bolds (7906).** Confirmed (row 151). Proposed:
  §12.4 states the listing plain with D-268. The item's second half, §12.6's
  "Task topology follows the roster each time" citing §11.1, is the sibling's;
  note that §11.1 still says "Task topology" (plane 5, 6840) and states the
  after-initialization rule plain (6880–6882), so the pointer has a referent,
  but the bold doubles §11.1's D-310 bold (6871). §12.4's own topology bold
  (row 168) is the same case (F18, q5).
- **§12.4's "reads stale … from the first frame" points at §11.8, which
  never states it.** Confirmed: §11.8's heartbeat (8479–8489) and run's end
  (8536–8552) say nothing of a never-beaten cell. `src/dataplane.jl` 496 says
  "the never-heartbeated cell's `0.0` reads stale unconditionally". Proposed:
  cite D-138 and drop the §11.8 pointer, and scope the sentence (F10).

The fourth item (§12.6 and §12.7 naming the header's compared part) is half
2's.

### Factual problems in half 1

- **F1. "Resumable by the next `run!`" — serious.** §12.4 9054 ("fully
  serviceable by §14 and resumable by the next `run!` (§12.6) once the device
  is plugged back in") and 9080 ("fully serviceable by the §14 stopped-sim
  services and resumable by the next `run!` (§12.6)"). D-132's Position says
  the same (log 4235–4236: "resumable by the next `run!`"). Against it:
  §12.6 9300–9301 ("terminally **stopped** or **errored**"), 9403–9405
  ("`stopped → init! → run!` remains the authored re-run"), D-088's lifecycle
  (log 2777–2778) and the code: `_assert_advanceable` (`src/sim.jl` 400–411)
  admits only `:initialized`, and the run raised `ServiceLifecycle: run! on a
  stopped simulation: re-running is the stopped → init! → run! cycle`. A
  Position (D-132) and the code with §12.6 contradict each other, and no
  later entry annotates D-132. Two readings: "resumable" meant
  "re-runnable after `init!`" or a warm restart (`checkpoint` → `restore!` →
  `run!`, §12.6 9404–9405), in which case the fix is wording; or the design
  once meant `run!` to continue a stopped run, which the code no longer
  allows. Proposed correction under the first reading: "and can be re-run
  through `init!` or restarted from a checkpoint (§12.6)". Escalate (q7).
- **F2. The parked GUI.** D-310 parks the built-in GUI (log 13216–13231). Half
  1 still names it as a live device: 8604 ("GUI button"), 8711–8716 ("the GUI
  least of all. It waits on nothing, ever. It uses a snapshot acquire-load,
  its own staging cell and atomic control. Under any starvation, then, the
  front end keeps rendering and the stop button keeps working"), 8739 ("shows
  in the GUI"), 8823–8824 ("The GUI does not use the wait. Being VSync-paced
  …"), 8849 ("the GUI"), 8882 ("a window ✕"), 8933 ("GUI window teardown").
  Most are examples a clause can fix ("a front end", "a front end's window").
  Two are not. 8711–8716 rests on D-027's withdrawn ground ("GUI on the
  calling task", log 994): a front end is now a spawned device task like any
  other, so "under any starvation … the stop button keeps working" is no
  longer true by construction; it holds only while the loop's per-frame
  yield lets the front end's task run. And 8823–8824 describes the read path
  of a GUI that does not exist, from D-134's Rationale. Possibly serious for
  8711–8716, since it promises a property the topology no longer gives.
  Proposed correction: 8711–8716 keep the two reasons that stand (the loop
  yields every frame; nothing couples a stall to anyone else) and say a front
  end's stop reaches the loop through its handle's atomic stop word (§11.6);
  8823–8824 dropped, or "A front end need not use the wait; one paced by its
  display reads `latest` at each render" (q2).
- **F3. "(5)'s honest asymmetry."** 9159–9161: "Nor can a second interrupt
  repair (5)'s honest asymmetry, since nothing can abandon the task `run!`
  stands on." Step (5) holds no asymmetry. The paragraph that stated it, "The
  calling-task device sits outside the join", was deleted by D-310's commit
  `0242e4e`; the sentence citing it stayed. Proposed correction: delete the
  sentence.
- **F4. "Never stops mid-frame."** 8830 ("stop on a boundary rather than
  mid-frame") and 8851–8852 ("completes the current boundary sequence and
  never stops mid-frame"). A stop request holding at a `t*` boundary ends the
  run inside its frame: §12.6 9428–9429 ("a `t*` stop, which leaves the clock
  mid-frame with the remainder abandoned"), D-317 bullet 5 (log 13771–13773:
  "A `true` from `settled!` abandons the frame's remainder"), §13.5 10348–10351.
  Proposed correction: "never stops mid-boundary: it completes the boundary
  sequence in progress, which a `t*` stop places inside a frame".
- **F5. "Reported by name, through the §12.2 heartbeat."** 8873–8875. The
  join begins after the final snapshot is published, and nothing is published
  after it (8912–8915, D-201): no heartbeat publication can report the
  timeout. The name reaches the operator through `DeviceJoinTimeout`, which
  carries the device id (D-228 Rationale log 8769–8770) and lands in the
  termination record and the logging backend (8877–8880). Proposed
  correction: "A device task exceeding it is abandoned, reported *by name* in
  a `DeviceJoinTimeout` diagnostic …", dropping the heartbeat clause.
- **F6. "Like `log_max` … it lives on `Control`", and "the cap is
  deployment".** 8943–8945. `log_max` is a keyword of the doors that build a
  run (D-261 log 10442–10443; Appendix B 12793–12795), held by the run's log
  (`src/dataplane.jl` 736), never on `Control`. The likeness holds only for
  "replay neither records nor compares it" (D-368 bullet 6). And 8937 ("The
  cap is deployment, not implementation") uses D-133's older sense of
  "deployment parameter", while 8944 ("rather than the deployment") and the
  glossary mean the `Deployment` artifact. Proposed correction: "The cap is a
  per-simulation setting, not an implementation constant …"; "Like `log_max`
  (§11.2), replay neither records nor compares it. It lives on `Control`, not
  on the `Deployment` (D-256)."
- **F7. `Control`'s field list.** 8621–8622 lists the stop word, the running
  flag, the wait and `join_timeout` beside pause, pace and `margin`. The
  sticky stopped status, which §12.4 (1) sets and `running(handle)` reads, is
  also `Control`'s (`src/control.jl` 64, `@atomic stopped::Bool`). The
  glossary entry (14173–14177) omits it too. Proposed correction: add "the
  sticky stopped status".
- **F8. "Each of the four calls."** 8667. The paragraph names six calls
  (`pace!`, `margin!`, `pace`, `margin`, `run!`, `replay!`); the four that can
  refuse are `pace!`, `margin!`, `run!` and `replay!`. Proposed correction:
  "The two setters and the two keywords refuse anything else …". Row 6's
  "(below)" (8601) likewise has two candidate targets.
- **F9. The init failure assumes the run starts at boundary zero.** 9020–9022
  ("dead from boundary zero"), 9033 ("hold their initial values"), 9040–9042
  ("absent from frame zero … shifted to `t₀`"), 9044–9047 ("already pending
  when the run reaches boundary zero … The boundary-zero check (§13.5) ends a
  run at `t₀`"), 9049–9050 ("The run publishes boundary zero. It ends
  `stopped` at `t₀`"), 9059 ("ends at `t₀`"). Three things are wrong. `init!`
  publishes boundary zero, and the bracket runs at `run!`'s top, after it:
  the should-abort run logged only boundary zero and published nothing of its
  own. The stop that ends it is the stop word read at the first frame top
  (`src/sim.jl` 1419–1421), recorded as `ControlRequestedStop("device …")`,
  not §13.5's request scan of the boundary-zero snapshot. And a run need not
  start at boundary zero: after `step!(frames = 3)` the same failure ended
  the run at frame 3, `t ≈ 0.3`; a run after `restore!` or a partial replay
  starts mid-trajectory too. The root inputs a failed device claimed then
  hold whatever was last applied, not their initial values. Proposed
  correction: "dead from the run's first frame top"; "the stop is pending at
  the run's first frame top, which the loop reads before any frame, so the
  run advances no frame and ends `stopped` where it started, with the
  termination record naming the device"; "the orphaned root inputs hold the
  values the run started with". A Position (D-138's bracket) and the code
  agree; only the Rationale's narrative is wrong, so the orchestrator can rule
  it (q8).
- **F10. Stale "from the first frame".** 9024–9027. §11.8 does not state it
  (carried item). And it holds only for a device that never beat: the run in
  part C showed a device whose `init!` threw in its second run reading fresh
  (heartbeat 0.036 s old) at that run's first publication, since nothing
  resets the heartbeat between runs. Proposed correction: "Its `task_state`
  reads `:done` from the first publication (§12.2). A device that never ran
  never beat, so its cell also reads stale from the start", citing D-138 and
  dropping "(§11.8)".
- **F11. `DeviceCrash`'s payload.** 9007–9009: "the device id, the cause
  exception, and whether `should_abort` was set". D-228's Position (log
  8752–8754) keeps writer ids out of payloads; Appendix C 13482–13485 lists
  "The original exception as `cause`, whether `should_abort` was set"; `src/`
  builds `DeviceCrash(err, entry.should_abort)` (`src/devices.jl` 466). The
  cell identifies the device. Proposed correction: "the cause exception and
  whether `should_abort` was set; the cell it is written to names the device
  (§11.8)".
- **F12. "Every blocking point interruptible."** 8867–8868: "Steps (2) and
  (3) are what make every blocking point interruptible." Step (2) wakes the
  framework's own waits; step (3) reaches only a blocking call the author
  covers with `unblock!`. D-373 bullet 2 says the obligations are "taught …
  and diagnosed …, never forced", and (5)'s abandonment exists because a
  device may still block. Proposed correction: "Steps (2) and (3) are the
  framework's half: they wake its own waits and call each device's
  `unblock!`."
- **F13. "Such a run is deviceless."** 9082–9083. `UnboundedRun` fires for
  any `:live` run with `t_end = Inf` and no honoured request (D-316 bullet 9;
  `src/sim.jl` 1107–1108), devices or not, and a rostered device that never
  requests a stop leaves the run as unended. D-132 Rejected (log 4282–4284)
  called the deviceless case "the very run that has no other escape", the
  sharpest case, not the only one. Proposed correction: "The interrupt is the
  escape from a run nothing else ends, and the deviceless run has no other."
- **F14. "The catch site never sees it."** 9108, then 9144–9147 ("That is the
  one way the branch §13.4 keeps is reached"). §13.4 10239–10241 scopes it:
  "a single interrupt never reaches the branch". Proposed correction: "The
  catch site (§13.4) therefore never sees a single interrupt."
- **F15. Kinds cited to the half but unnamed (lesson 20).** `ThreadBudget`
  (Appendix C 13474, cites §12.2): 8720–8723 states the condition without the
  name. `ArgumentInvalid` (13427, cites §12.4): 8872 states "a positive real"
  without it. `CheckpointMidFrame` (13416, its body cites §12.4): 9152 says
  "`checkpoint` refuses such a run". Proposed correction: one clause each
  (q12).
- **F16. "Freeze", two senses in §12.2.** 8704 and 8711 mean Julia's
  cooperative-scheduler freeze; 8722 ("the frozen roster") means the roster
  freeze the glossary reserves (`#g-the-freeze`). Proposed correction: "the
  scheduler stall" for the first sense.
- **F17. Coalescing "to the newest batch"; "skips frames".** 8817–8819 says
  coalescing to the newest batch (in) mirrors the newest snapshot (out). The
  glossary's coalescing (14167–14170) is the per-face merge, untouched faces
  surviving; a batch is not replaced whole. 8816 says a slow consumer "skips
  frames", where the counter counts boundaries (8766–8768). Proposed
  correction: "Inbound coalescing keeps the newest level per face, and the
  wait delivers the newest snapshot: the same ZOH decision"; "skips
  boundaries".
- **F18. "Topology is derived after initialization."** 9057–9060, bold. The
  clause comes from D-138's Position, whose annotation (log 4694–4698) calls
  the topology clause historical since D-310: no device can move the loop.
  What remains, a failed device spawns no task, is rows 158 and 163–164.
  §11.1 6880–6882 states it plain. Proposed correction: M8, the bold and the
  paragraph go (q5).
- **F19. The explicit yield.** 8697–8699 says the explicit `yield()` covers
  the frames where the coarse `sleep` does not run, as D-027's Position does.
  The code yields in every frame with a non-empty roster (`src/sim.jl` 1424),
  before the wait. The rule (row 43) holds either way. No correction needed;
  recorded so a rewriter does not "fix" the spec toward the code.
- **F20. "`stopped` is where `detach!` removes an entry."** 8952–8953.
  `detach!` is legal in `built`, `initialized` and `stopped` (D-106 Position
  log 3346–3347). Proposed correction: "Once stopped, `detach!` can remove an
  entry and release its claims."
- **F21. Pause inside a run.** §11.3 7312 and §14's opening 11010 cite §12.1
  for "Pause is a control-plane state *inside* a run"; §12.1 never says it.
  D-106's Position (log 3347–3348) does, and the run in part C showed the
  lifecycle `running` while paused. Proposed addition to §12.1: "A paused run
  is still running: the lifecycle reads `running` and the roster stays frozen
  (D-106)."
- **F22. Resetting the stores after a forced throw.** 9150: "until the next
  `init!` or `restore!` resets them". `replay!` resets them too (it restores a
  checkpoint, §12.7). Proposed correction: "until the next door resets them".
- **F23. The doctrine's home.** 9088 cites §13 for "the exceptions-are-abnormal
  doctrine"; §13.5 states it (10295–10297). Proposed correction: §13.5.
- **F24. The init bracket sketch.** 8973–8990 against `src/devices.jl`
  454–474. The sketch's `entry.should_abort && stop!(control)` records no
  issuer, where the code calls `stop!(entry.handle)` and the record names the
  device (part C); and `DeviceCrash(e)` omits the `should_abort` field the
  payload carries. Proposed correction: `stop!(entry.handle)` and
  `DeviceCrash(e, entry.should_abort)`, ruled edits to a code block.

Outside the half, met while checking citations: spec 7312 and 11010 (F21),
`implementation.md` 762 (§12.1 for §12.6's content), spec 10515 and
`flight_case_studies.md` 408 (the GUI), spec 14240 (the operator interrupt's
unmask points). All in part D.

## F. Difficulty per section

| section | difficulty | reason |
|---|---|---|
| opening (A) | low | 44 words recast as one context and one roadmap sentence (q1) |
| §12.1 (A) | medium | 661 words, no context paragraph, four moves (M1–M4) that change the section's spine; D-022's bold to drop (row 19); the stop word and "the tail" used before their definitions; F7, F8, F21 are one-clause fixes; one **Rule.** and one **Why.** |
| §12.2 (A) | medium | 712 words in order; four **Rule.**, two **Why.**; F2 reaches its central argument (8711–8716, q2); D-133 and the `task_state` rule (D-270's annotation) uncited; F15 (`ThreadBudget`), F16 (two senses of freeze) |
| §12.3 (A) | low to medium | 501 words; two moves (M5, M6) reorder one argument; D-028 and D-114 cited only for rejections or nowhere; F17; the sketch carried verbatim; the GUI note waits on q2 |
| §12.4 (B) | high | 2,796 words, the half's longest section: nine **Rule.**, one **Why.**, three "**Why …**" lead-ins, seven bold step labels, seventeen bold lead-ins. D-030, D-138 and D-132, its three home entries, are cited nowhere in it. 34 R rows, most in D-138's and D-132's Rationales. Three doubles of chapter 11's bolds (rows 126, 151, 168). F1 (serious) and F9 change the init subsection's narrative; F3, F4, F5, F6, F10–F14, F20, F22–F24 are local fixes. Two code blocks and the chart |

Warnings for the rewriter:

- **Terms of art stay verbatim**: the tail, the stop word, the sticky stopped
  status, the pause block, the frame top, unmask point, the next-snapshot
  wait, boundary counter, published-boundary ordinal, `last_seen`,
  newest-wins, the pre-spawn bracket, listed for release, dead from boundary
  zero (as ruled under q8), death is not detach, orphaned, the run's-end
  sweep, the tail residue, the defensive arm, the forced throw, operator
  interrupt. "A stop, not a failure", "deployment, not implementation" (as
  ruled under F6), "escalation shortens the tail, never reclassifies the
  run" and "newest wins, no queues" are each a distinction the log fought
  for; a paraphrase that drops one half changes the rule.
- **Two counters, never one.** The boundary counter is monotone, never reset,
  and nowhere normative in value; the published-boundary ordinal restarts per
  trajectory. Do not let a gloss call either "the boundary index" (D-230).
- **Scope words are exact.** "With devices attached, every frame yields at
  least once"; "outside a run every device reads `:none`"; "first writer
  wins"; "at most one frame budget `h/p` later"; "the pause block is the one
  wait that wakes at once"; "steps (1) through (5) … on every stop"; "a
  positive real", "a non-negative real, `Inf` admitted". Keep each.
- **Counts and defaults are rulings.** 2 s, 5 s, 2 ms, `Inf`, "fewer threads
  than the roster plus one", "three values", "two artifacts", "at most one
  frame". Each carries its entry (part A).
- **The log's vocabulary is old.** D-030 says "`should_close` path", D-132
  and D-133 say "`stop_on`", D-138 says "slots" and "slot totality", D-268
  bullet 2 says "stop face", D-097 and D-138 give `DeviceCrash` a device id,
  D-255 keeps the lifecycle on `Control`, D-027 puts the GUI on the calling
  task. Never import them when citing an entry.
- **The half cites by adjacency.** Rows 4, 6, 11, 16, 25, 28, 29, 35, 37, 56,
  77, 79, 80, 135, 152, 153, 170, 185, 189, 192 have their citation one or two
  sentences away. A move that separates a rule from its citation (M1–M7)
  needs the citation repeated.
- **Glossary links reset per section, once each.** §12.1 never links
  *control plane*; §12.3 never links *next-snapshot wait* or `latest`;
  §12.4's first uses of *device* (8830) and *operator interrupt* (8836) sit
  before their links (8849, 8850). "Frame" is unlinked in every section of
  the half.
- **Labels and lead-ins are headings.** 23 labels, seven step labels, five
  bold chart numbers and 29 other bold spans (lead-ins, sentences, one term, one word). Each becomes a
  plain list item, a `####` label, a plain topic sentence or a bold headline
  clause with its D-citation. Count before and after.
- **History sentences.** 8711 (FlightCore's `nthreads` error), 8861–8863
  (FlightCore's EOT convention), 8896–8898 (FlightCore's
  `SimulationTermination`), 8956–8957 (FlightCore's network.jl). Carry them
  until q6 and q11 are ruled. 9159–9161 is not history but an orphan (F3).
- **Code**: part C, "Code blocks". Comment edits to the init bracket sketch
  are ruled edits only (F24).

## G. Decisions for checkpoint 1

Settled and not asked again: log repair rides track 2, and bold marks one
headline clause per ruling.

**q1. The chapter opening and the Part III roadmap (rows 1, 2).** The opening
is one sentence with a colon list, "the loop boundary" in a sense the
glossary does not admit, no section numbers, and no mention of §12.5. The
Part III roadmap (5478–5480) also omits §12.5. Options: (a) recast the
opening in chapter 11's form, one context sentence (the machinery that drives
the loop, taking §10's loop and §11's data plane as given) and one roadmap
sentence naming §12.1–§12.7 in order; and add §12.5's scripts doctrine to
the Part III roadmap as a declared, ruled edit; (b) keep the sentence, fixing
only "loop boundary"; (c) (a) for the opening, the Part III roadmap left to
track 2. Recommendation: (a), ruled jointly with the sibling, whose §12.5 the
roadmap names.

**q2. The parked GUI (F2).** Seven places in the half name the built-in GUI
D-310 parked. Options: (a) rule now: the examples become "a front end" or
drop (8604, 8739, 8849, 8882, 8933); 8823–8824 drops or becomes "a front end
paced by its display reads `latest` at each render"; 8711–8716 keeps the two
grounds that stand (the per-frame yield, no stall coupling) and says a
front end's stop reaches the loop through its handle's atomic stop word,
dropping "under any starvation … keeps working"; (b) escalate 8711–8716 as
serious, since it promises a property the D-310 topology no longer gives,
and rule the examples as in (a). Recommendation: (b). The examples are
prose; the starvation promise is a design claim the owner should confirm or
withdraw, and D-027's Rejected list needs the same annotation.

**q3. Bold homes for the half's uncited Positions, and the doubles.** The
half states several Positions nowhere bold: D-030 (the tail's order), D-138
(the bracket), D-132 (the interrupt is a stop), D-114 (the publication
order), D-028 (the counter-plus-condition wait, newest-wins), D-133 (the
`t_end` landing; the 2 s threshold), D-201 (the terminal account closes at
the final frame top) and D-203 bullet 4 (`DeviceJoinTimeout` to the loop's
cell). It also bolds rulings chapter 11 bolds: row 19 (D-022, §11.1 6839),
row 126 (D-368, §11.2 7051), row 151 (D-268 bullet 7, §11.6 7906), row 168
(D-138's historical clause; §11.1 6880 is plain). Options: (a) bold each
uncited Position at its headline clause here, D-201 and D-203 bullet 4 at
row 125 and row 111, since §11.8 states them plain; make rows 19, 126, 151
and 168 plain with their citations; merge row 145 into row 146; (b) leave
D-201 and D-203 for chapter 13's rewrite. Recommendation: (a). §12.4 is the
section the Spec fields of D-030, D-138, D-132, D-201 and D-203 name.

**q4. The tail's numbered list and the chart (rows 93–122).** The list's
seven bold step labels are labels; the chart (8900–8906) repeats steps
(1)–(5) in one line with bold numbers. Options: (a) keep the list with plain
step labels as each item's first words, keep the chart verbatim as the
section's one-line summary with its numbers unbolded; (b) drop the chart as
a double of the list; (c) keep both as they are. Recommendation: (a). The
chart is the one place the order reads at a glance, and several citations
use "(5)" and "(6)" by number.

**q5. Overlaps across the split and the topology bolds (M8, M12, H1–H11).**
Options: (a) one home each with a pointer at the other: §12.1 for `Control`'s
fields, `step!` taking no pace, and `replay!`'s pace keywords; §12.4 for what
a stop leaves behind and for `t_end`'s landing; §12.6 for the lifecycle's
derivation, attachments persisting across re-initialization, `t_plus`,
`checkpoint`'s refusal and reproduction by replay; §11.1 for where the loop
runs; both topology bolds (row 168 here, §12.6 9468 there) dropped, their
content kept as rows 158 and 163–164 and as a plain pointer in §12.6; ruled
together with the sibling's matching question; (b) leave every duplicate.
Recommendation: (a), ruled once for both halves so neither unit cuts what
the other keeps.

**q6. Adversarial and history lines.** Candidates: 8781 (the `Event` latch,
D-028 Rejected); 8820–8821 (per-consumer queues rejected); 8861–8863 (EOT
demoted, D-030 Rejected); 8711 (FlightCore's `nthreads` error); 8896–8898
(FlightCore's `SimulationTermination` precedent); 8956–8957 (FlightCore's
network.jl precedent); 9085–9087 (no interrupt entry point, D-132 Rejected).
Options: (a) keep the one-clause verdicts with their citations; keep 8781,
whose reason (8781–8783, conditions carry no facts) is constructive; cut
8896–8897 to "Exception-based termination has no place here (§13.5)"; keep
8956–8957 as the per-run acquisition's precedent with FlightCore named;
(b) keep all. Recommendation: (a). Each entry carries its rejection.

**q7. "Resumable by the next `run!`" (F1), serious.** D-132's Position and
§12.4 (9054, 9080) say a stopped run resumes by the next `run!`; §12.6, D-088
and the code refuse `run!` on `stopped` and re-run through `init!`. Options:
(a) leave both sentences as written, the rewriter flags them, and the
orchestrator escalates to `escalations.md`; (b) rule the wording now as
"re-runnable through `init!`, or restartable from a checkpoint (§12.6)",
reading D-132's "resumable" loosely; (c) delete the clause. Recommendation:
(a). A Position and the code disagree, and reading the Position loosely is
the owner's call.

**q8. The init failure at boundary zero (F9).** Options: (a) rule now:
"dead from the run's first frame top"; the stop "pending at the run's first
frame top, so the run advances no frame and ends `stopped` where it
started"; "the orphaned root inputs hold the values the run started with";
drop "The run publishes boundary zero" and the §13.5 boundary-zero check as
the mechanism; Appendix B 12855 and D-138's Rationale follow in track 2;
(b) leave it to rulings. Recommendation: (a). D-138's Position and the code
agree; only the Rationale's narrative, which the spec copied, assumed the
first run.

**q9. The units.** Two units as in part C: A 1,918 (heading to §12.3), B
2,796 (§12.4). The alternative is A′ 3,126 (to §12.4's tail) and B′ 1,588
(the bracket and the interrupt). Recommendation: A and B. Each move stays in
one unit and §12.4 stays whole; A's shortfall below the floor costs less than
splitting the section the half's hazards concentrate in.

**q10. The clear factual corrections.** F3 (delete the orphaned asymmetry
sentence), F4 ("mid-boundary"), F5 (the name through `DeviceJoinTimeout`, not
the heartbeat), F6 (`log_max` and "deployment"), F7 (add the sticky stopped
status), F8 ("the four calls"; "(below)"), F10 (stale scoped, cite D-138),
F11 (`DeviceCrash`'s payload), F12 ("every blocking point"), F13
("deviceless"), F14 ("a single interrupt"), F16 (the scheduler stall), F17
(per-face coalescing; "skips boundaries"), F20 (`detach!`), F21 (a paused run
is still running), F22 ("the next door"), F23 (§13.5), F24 (the sketch's
issuer and payload). Options: (a) rule them all at checkpoint 1 with part E's
evidence and proposed wording, grepping the chapter for each phrase first
(chapter 8's lesson; "GUI", "mid-frame", "boundary zero" and "deployment"
also occur in half 2); (b) leave them for rulings. Recommendation: (a). F19
needs no edit; F1, F2 and F9 are q7, q2 and q8.

**q11. Reader-cold names.** FlightCore's `nthreads` error (8711), its EOT
convention (8862), its `SimulationTermination` (8896) and network.jl (8957);
"ZOH" (8819), never expanded in the half; "VSync" (8824); "hard-RT" (8688);
"libuv" (8726). Options: (a) give each an introducing clause that claims
nothing beyond its source: "FlightCore's" kept where named (it needs
nothing), network.jl as "FlightCore's network device", ZOH expanded as
zero-order hold with a pointer to Part I, "libuv, the I/O library under
Julia's tasks"; (b) cut the FlightCore precedents to the log. Recommendation:
(a), with q6 deciding which precedents stay at all.

**q12. Kinds cited to the half but unnamed (F15).** Options: (a) add one
clause each, as ruled edits: §12.2 names `ThreadBudget` where it states the
warning (8720); §12.4 (5) names `ArgumentInvalid` for a non-positive
`join_timeout` (8872); 9152 names `CheckpointMidFrame`; (b) leave them for
track 2. Recommendation: (a), lesson 20.

**q13. "The stop word" as a glossary term.** The coinage has seven uses in
the half and more in §13.5 and Appendix B, with no entry of its own; the
control-plane entry names it. `spec_style.md` gives a glossary entry to a
term "used in three or more places, or far from its definition". Options:
(a) add `#g-stop-word` in track 2 ("the control plane's stop request: one
atomic word holding its issuer, set by compare-and-swap from empty"), and
gloss it inline at first use per section meanwhile; (b) inline glosses
only. Recommendation: (a).

<!-- Sliced from survey_1.md for unit B (§12.4) by checks/slice_survey.py. -->
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
(§12.1 is another unit's; see the full survey.)

### §12.2 Loop scheduling: wait primitive, yields, thread budget (8670–8755, 712 words)
(§12.2 is another unit's; see the full survey.)

### §12.3 The next-snapshot wait (8756–8825, 501 words)
(§12.3 is another unit's; see the full survey.)

### §12.4 Shutdown protocol (8826–9168, 2,796 words)

Purpose: the tail every stop takes, the pre-spawn initialization bracket at
a run's top, and the operator interrupt.

Subheadings: "The tail: the ordered sequence every stop takes" (8839),
"Initialization: the pre-spawn bracket" (8965), "The operator interrupt"
(9073). The context paragraph (8828–8837) names the three parts in order.
Bold: nine **Rule.**, one **Why.**, three labelled "**Why …**" lead-ins, seven
bold step labels in the numbered list, five bold spans in the chart, and
seventeen bold lead-ins or sentences.

#### The context and the tail (8828–8963)

| # | line | quote | marking | entry | class |
|---|---|---|---|---|---|
| 92 | 8828–8837 | "A run ends when its time is up, when someone stops it, or when the model itself says so. … The loop has to stop on a boundary rather than mid-frame, every device task has to be woken …, and every resource … released before `run!` returns. … the tail …" | plain | D-030 Position | U; context. "rather than mid-frame" (F4) |
| 93 | 8841–8843 | "**Rule.** Steps (1) through (5) below run in that order on every stop, whatever initiated it. Steps (6) and (7) specify what happens when a device task or the loop itself ends first." | **Rule.** | D-030 Position | U; D-030 is cited nowhere in the spec, and has no Spec field (part E) |
| 94 | 8845–8848 | "1. **Initiation.** Three events start a shutdown: `t_end` is reached, a control-plane stop is issued, or a stop request the advance honours reads `STOP_REQUESTED` in the just-published snapshot." | bold step label | D-030 Position; D-316 bullet 8 (the scan after every publication); D-203 bullet 5 (source order) | U |
| 95 | 8848–8851 | "The stop's issuers are the GUI, a device handle, code, or an operator interrupt (Ctrl-C, treated below)." | plain | D-203 bullet 3; D-132 Position | U; restates row 8; "the GUI" (F2) |
| 96 | 8851 | "The third event is model-detected termination (§13.5)." | plain | D-316 Position; D-060 Position | U |
| 97 | 8851–8852 | "The loop always completes the current boundary sequence and never stops mid-frame." | plain | D-030 Position ("complete the boundary"); Rejected log 1051 ("Mid-frame abort") | B: U for the completion; R for the mid-frame rejection. "never stops mid-frame" is false for a stop request holding at a `t*` boundary (F4) |
| 98 | 8853–8854 | "It then publishes the final snapshot. Only then does it set the sticky stopped status." | plain | D-030 Position | U |
| 99 | 8855–8857 | "2. **Wake all framework waits.** The waits are the next-snapshot wait and the pause. Each waiter observes the stopped status and unwinds. A stop issued while paused therefore works." | bold step label | D-030 Position; D-028 Position; D-269 bullet 3 | U; restates row 27 |
| 100 | 8858–8859 | "3. **Unblock device-specific blocking calls.** The hook is `unblock!(device)`, default no-op." | bold step label | D-030 Position; D-102 Position; D-366 Position (the no-op default, bold at §11.6 7860) | U |
| 101 | 8859–8861 | "A network input's override closes its own socket, which raises in the blocked task. The framework wrapper catches that raise and treats it as shutdown." | plain | D-030 Position ("close-own-socket idiom"); the wrapper's treatment: no entry found | B: U for the idiom; N for the treatment |
| 102 | 8861–8863 | "This demotes FlightCore's EOT convention from essential shutdown mechanism to an optional wire-protocol courtesy between remote peers." | plain | D-030 Position ("EOT demoted to wire courtesy"); Rejected log 1048–1049 | U |
| 103 | 8864–8865 | "4. **Loop bodies exit.** The exit is the author's own `while running(handle)` loop, the authoring contract of §11.6." | bold step label | D-102 Position | U |
| 104 | 8866–8867 | "That authoring contract teaches two obligations: the predicate check and interruptible blocking." | plain | D-373 bullet 2 | U; home §11.6 |
| 105 | 8867–8868 | "Steps (2) and (3) are what make every blocking point interruptible." | plain | none; D-373 bullet 2 says the obligations are "taught … and diagnosed …, never forced" | N; overclaims (F12) |
| 106 | 8868–8869 | "The wrapper's `finally shutdown!(device)` is guaranteed on every exit path." | plain | D-102 Position | U |
| 107 | 8870–8871 | "5. **Join under the `join_timeout` cap.** The cap lives on `Control`, the tail's own owner (§12.1, D-256)." | bold step label | D-256 bullet 3; Rationale log 10156–10157 | C; row 15 bolds the same ruling |
| 108 | 8871–8873 | "It is a keyword of the `Simulation` constructor, a positive real in seconds of wall clock, defaulting to 5 (Appendix B)." | plain | D-198 Position; D-317 bullet 2 (`Simulation(model; join_timeout = 5.0)`) | U (D-198 cited at 8939); the refusal's kind, `ArgumentInvalid`, is not named (F15) |
| 109 | 8873–8875 | "A device task exceeding it is reported *by name*, through the §12.2 heartbeat." | plain | D-030 Position ("join with named timeout") | U; "through the §12.2 heartbeat" is false (F5) |
| 110 | 8875–8877 | "It is then abandoned with a `DeviceJoinTimeout` diagnostic (Appendix C) rather than left to hang `run!`." | plain | D-097 Position; D-030 Rejected log 1050 ("Unbounded join") | B: U by D-097; R for the reason |
| 111 | 8877–8880 | "The diagnostic is written to the loop's own cell, collected by the run's-end sweep into the termination record and presented through the logging backend, with the terminal snapshot preceding the join (D-201, D-203)." | plain | D-203 bullet 4; D-201 Position | C |
| 112 | 8881–8882 | "6. **Device-initiated paths.** A device exits voluntarily when its loop body returns, at a window ✕ or a peer EOT." | bold step label | D-373 bullet 1 | U; "a window ✕" names the parked GUI's window (F2) |
| 113 | 8882–8883 | "No `should_close` hook exists (§11.6)." | plain | D-373 bullet 1, bold at §11.6 7971 | U |
| 114 | 8883–8884 | "With `should_abort` set, the wrapper's exit path also requests a sim stop." | plain | D-381 Position (bold at §11.6 7984); D-097 Position (the payload's disposition); D-138 Rationale log 4687–4692 | U |
| 115 | 8884–8886 | "Otherwise the sim continues with the device's *task* absent. Its cell stops filling, and the loop is structurally indifferent." | plain | D-138 Rationale log 4688–4689 ("(6)'s narrative default"); D-374 bullet 1 | B: R by D-138; U by D-374 |
| 116 | 8886–8888 | "Its roster entry and its claims persist to run end, because §11.3 freezes the roster for the run and death is not detach." | plain | D-374 bullet 1 (bold at §11.3 7361); D-106 Position | U; pointer |
| 117 | 8888–8890 | "The orphaned root inputs hold their last-drained values, visibly (§11.7)." | plain | D-374 bullet 1; D-270 bullet 3 (the orphan fact) | U |
| 118 | 8890–8892 | "A crashing device task is caught by the framework wrapper and follows the same path, logged with the device's name (`DeviceCrash`, Appendix C)." | plain | D-097 Position; D-102 Rationale log 3207 | U |
| 119 | 8893–8894 | "7. **Loop-side failure.** A failure on the loop's own side runs steps (1) through (5) from the catch path, specified in §13.6." | bold step label | D-030 Position ("loop failure runs the same protocol from the catch path") | U |
| 120 | 8894–8895 | "The failed boundary is discarded and the previous snapshot is promoted to final." | plain | none; §13.6 10532–10533 bolds it | N; home §13.6 |
| 121 | 8896–8898 | "FlightCore's `SimulationTermination` catch path was the precedent, though the exception-based termination idiom itself has no place here (§13.5). Devices therefore unwind cleanly regardless of who died." | plain | D-060 Position (no `SimulationTermination`) | B: U; N for the last sentence (a consequence) |
| 122 | 8900–8906 | "The ordered part, in one line: > **(1)** stop observed → … → `run!` returns" | blockquote chart, five bold step numbers | D-030 Position | chart (part C) |
| 123 | 8908–8909 | "**Why the final snapshot goes out before the status is set.** Publishing first guarantees that output devices can flush the true final state." | labelled bold lead-in | D-201 Rationale log 7508 | R |
| 124 | 8909–8912 | "The status in that terminal snapshot carries the run's cumulative diagnostic counters (§11.8), the warning account of a run nobody watched, complete up to that snapshot's own frame top." | plain | D-369 bullet 5 (bold at §11.8 8538); D-201 Position | B: U by D-369; C adjacent by D-201 |
| 125 | 8912–8915 | "What the tail itself produces comes later by construction. It is folded into the termination record and presented through the logging backend, never published (D-201, D-203)." | plain | D-201 Position; D-203 Position | C |
| 126 | 8917–8918 | "**Rule.** That terminal snapshot is retained in the log unconditionally, under any `log_every` and any `log_max` (§11.2)." | **Rule.** | D-368 bullet 5, bold at §11.2 7051 | U; a second bold of one ruling (part B) |
| 127 | 8920–8921 | "**`t_end` lands on the grid.** The run ends at the first grid boundary whose time reaches or exceeds `t_end`." | bold lead-in | D-133 Position log 4316–4319 | U; §2.4 533–535 states the law (part B) |
| 128 | 8921–8923 | "Whole frames only, never a shortened final step, which grid integrity forbids (§10.4; `tₖ = t₀ + k·h`, indexed and never accumulated)." | plain | D-133 Position ("whole frames only"); Rejected log 4365–4366 | B: U; R for the reason |
| 129 | 8923–8925 | "The final boundary may therefore overshoot `t_end` by up to `h`. The termination record carries the actual final `t` (§13.5)." | plain | D-133 Position; D-203 Position (the final boundary time) | U |
| 130 | 8925–8927 | "This is the `t_plus` spelling (§12.6) applied to the run's own clock. The run takes whole frames until the boundary time first covers the duration." | plain | D-133 Rationale log 4340–4342 | R; §12.6 9354–9356 states the `t_plus` phrase (part B) |
| 131 | 8929–8931 | "**The two termination sources differ in kind.** `t_end` is a grid fact, checked against boundary times on the grid. Stop requests are checked at *every* published boundary, `t*` included (§13.5)." | bold lead-in | D-133 Rationale log 4342–4344; D-316 bullet 8 | B: R for the contrast; U by D-316 for the scan |
| 132 | 8933–8935 | "**Why the default is five seconds.** It is generous for GUI window teardown and socket closes. It is short enough that an abandoned join reads as a diagnosed timeout rather than a hang." | labelled bold lead-in | D-133 Rationale log 4331–4333; D-198 Rationale log 7436–7438 | R; "GUI window" (F2) |
| 133 | 8937–8939 | "**The cap is deployment, not implementation.** That is the disposition §10.4 gives its own two constants, extended here to an operational one (D-198)." | bold lead-in | D-198 Position and Rationale log 7430–7432 | C; "deployment" collides with the glossary's `Deployment` (F6) |
| 134 | 8939–8942 | "Deployment contexts legitimately differ in patience. An unattended sweep wants to fail fast, a test battery … faster still, while a device with slow teardown may warrant more." | plain | D-198 Rationale log 7434–7436 | R |
| 135 | 8942–8943 | "The cap is not trajectory-determining, because the trajectory has ended at the final snapshot before any join begins." | plain | D-198 Position ("operational rather than trajectory-determining"); Rationale log 7438–7441 | C, adjacent |
| 136 | 8943–8945 | "So, like `log_max` (§11.2), it lives on `Control` rather than the deployment, and replay neither records nor compares it (§11.5, §12.7)." | plain | D-256 bullet 3 (`Control`); D-198 Position ("invisible to replay"); D-368 bullet 6 (`log_max`) | U; "like `log_max` … lives on `Control`" is false (F6) |
| 137 | 8947–8949 | "**What survives the tail.** After (5) the task set is empty, device tasks being per-run artifacts (§11.1), and `shutdown!` has released each device's OS resources." | bold lead-in | D-093 Position (bold at §11.1 6866); Rationale log 2897–2898 | U |
| 138 | 8949–8951 | "What survives a stop is the roster entry: binding, claims, stable device id (§11.3). Never a task, never a live resource." | plain | D-093 Rationale log 2897–2899 | R; §12.6 9460–9463 says the same (part B) |
| 139 | 8951–8952 | "That holds for a device whose task died mid-run too, its entry being indistinguishable at this point from any other's." | plain | D-374 bullet 1 | U |
| 140 | 8952–8953 | "`stopped` is where `detach!` removes an entry and releases its claims." | plain | D-106 Position (`attach!`/`detach!` legal in `built`, `initialized`, `stopped`) | U; narrower than D-106 (F20) |
| 141 | 8955–8957 | "**The next run re-acquires everything.** The next `run!` re-runs device `init!`, since resource acquisition is per-run. FlightCore's create-a-new-socket-each-`init!` in network.jl is the precedent." | bold lead-in | D-093 Position | U; "network.jl" is FlightCore's file, reader-cold (q11) |
| 142 | 8957–8959 | "It also spawns fresh tasks against the §12.3 counter, which is never re-armed. Each task reads its `last_seen` off the counter at spawn." | plain | D-230 Position (never reset); `last_seen` at spawn: no entry (`src/devices.jl` 477–481) | B: U by D-230; N for the spawn read |
| 143 | 8959–8961 | "While stopped there are no device tasks at all, so voluntary exit and the §12.2 liveness heartbeat are run-scoped observables." | plain | D-093 Rationale log 2900–2901 | R |
| 144 | 8961–8963 | "A device unplugged while stopped surfaces as the next run's `init!` failure, disposed of by the initialization bracket below." | plain | D-093 Rationale log 2901 | R |

#### Initialization: the pre-spawn bracket (8965–9071)

| # | line | quote | marking | entry | class |
|---|---|---|---|---|---|
| 145 | 8967 | "**Initialization is a step of this protocol, taken at the top of a run.**" | bold sentence, no citation | D-138 Position | U; D-138 is cited nowhere in §12.4, its home |
| 146 | 8969–8971 | "**Rule.** Before any task is spawned, the loop calls `init!` once per roster entry, in attachment order, on the calling task. Each call sits in its own bracket." | **Rule.** | D-138 Position | U; one ruling with row 145 (a double bold inside one subsection) |
| 147 | 8973–8990 | the init bracket sketch | `julia` fence | D-138; D-268 bullets 3, 7 | code (part C) |
| 148 | 8992–8994 | "**Why the bracket.** It is what makes 'guaranteed on every exit path' (§11.6) true of the path outside that wrapper." | labelled bold lead-in | D-138 Rationale log 4662–4664 | R |
| 149 | 8994–8995 | "A device that throws half-way through acquisition is handed back to `shutdown!` right there, so its partially acquired OS resources are released rather than leaked." | plain | D-138 Position ("calls `shutdown!(dev)` on the failing device right there") | U |
| 150 | 8995–8997 | "That is exactly why `shutdown!` owes tolerance of a partially initialized device, a rule §11.6 teaches." | plain | D-372 Position (bold at §11.6 7885) | U; pointer |
| 151 | 8999 | "**The entry is listed for release before its `init!` begins** (D-268)." | bold lead-in | D-268 bullet 7 (amended 2026-10-01), bold at §11.6 7906 | C; the second bold of one ruling, the carried item (part E) |
| 152 | 9000–9003 | "The bracket unlists it once its own `shutdown!` has returned. An operator interrupt that escapes the bracket therefore finds listed every device whose `init!` began and that the bracket has not released, and the run releases each before it ends." | plain | D-268 bullet 7 | C, adjacent |
| 153 | 9003–9004 | "A device listed and not yet initialized can be released having opened nothing, which `shutdown!` tolerates (§11.6)." | plain | D-268 bullet 7 | C, adjacent |
| 154 | 9006–9007 | "**The report is the ordinary `DeviceCrash`, not a kind of its own** (Appendix C)." | bold lead-in | D-138 Rationale log 4667–4669; Rejected log 4708–4709 | R |
| 155 | 9007–9010 | "Its payload already carries everything an init-time failure has to say: the device id, the cause exception, and whether `should_abort` was set. The name is honest. A device that cannot acquire its resources has crashed before it lived." | plain | D-138 Rationale; D-228 Position (payloads name no writer) | R; "the device id" is stale (F11) |
| 156 | 9012–9014 | "**Rule.** The report is written through the ordinary `report!(address, diagnostic)` entry point, addressed by the roster entry rather than by a handle." | **Rule.** | D-189 Position | U |
| 157 | 9016–9018 | "There is no device task to hold a handle before the spawn. The address supplies the device identity either way, which is why no call passes a device id (§11.8)." | plain | D-189 Position; D-228 Position and Rationale log 8759–8761 | U |
| 158 | 9020–9022 | "**Rule.** No task is spawned for a failed device, so it is dead from boundary zero (the initialization boundary: the ordinary macro-sequence with an empty integrate)." | **Rule.** | D-138 Position ("no task being spawned"); Rationale log 4670 ("dead from boundary zero") | B: U for no task; R for "dead from boundary zero", which holds only for a run that starts at boundary zero (F9). A colon inside the gloss |
| 159 | 9024–9027 | "That needs no machinery. Its diagnostic cell … never receives a heartbeat timestamp. The cell therefore reads stale against the §12.2 threshold from the first frame (§11.8)." | plain | D-138 Rationale log 4670–4672; D-160 annotation log 5812–5814 | R; §11.8 never states it, and it fails for a device that beat in an earlier run (F10) |
| 160 | 9029 | "**Rule.** The claims of a failed device persist to run end." | **Rule.** | D-138 Rationale log 4672–4673; D-374 bullet 1 | B: R by D-138; U by D-374 (death is not detach) |
| 161 | 9031–9036 | "This is the death-is-not-detach disposition (§11.3), applied one step earlier than (6)'s. … the orphaned root inputs hold their initial values, well-defined by root-input totality (§14.6 …). An orphan of (6) holds a last drained batch instead." | plain | D-138 Rationale log 4673–4676 | R; "their initial values" holds only at boundary zero (F9); a semicolon inside the parenthesis |
| 162 | 9038 | "**The run's disposition splits on `should_abort`, uniformly with (6).**" | bold lead-in | D-138 Rationale log 4676 | R |
| 163 | 9038–9042 | "With the flag clear, which is the default (§11.6), the remaining entries initialize, the run starts, and the sim runs with that device absent from frame zero. That is (6)'s … shifted to `t₀`." | plain | D-138 Rationale log 4676–4678; D-381 Position | R; "frame zero", "`t₀`" (F9) |
| 164 | 9044–9047 | "With the flag set, the failure requests a control-plane stop, and that stop is simply *already pending* when the run reaches boundary zero. … The boundary-zero check (§13.5) ends a run at `t₀` with that snapshot final, integrating nothing." | plain | D-138 Rationale log 4679–4680 | R; the mechanism is the frame-top stop word, not §13.5's request scan (F9) |
| 165 | 9047–9049 | "No new exit protocol is needed, therefore. The remaining entries still initialize, every rostered device getting its `init!`/`shutdown!` pair uniformly." | plain | D-138 Rationale log 4680–4682; Rejected log 4704–4707 | R |
| 166 | 9049–9051 | "The run publishes boundary zero. It ends `stopped` at `t₀` through this same tail, with the termination record naming the source (§13.5)." | plain | D-138 Rationale log 4682–4683 | R; `run!` publishes nothing at its start, `init!` did (F9) |
| 167 | 9051–9055 | "What the operator is left with is an ordinary stopped simulation … fully serviceable by §14 and resumable by the next `run!` (§12.6) once the device is plugged back in." | plain | D-138 Rejected log 4705–4707 (serviceable); D-132 Position (resumable) | R; "resumable by the next `run!`" (F1, serious) |
| 168 | 9057–9060 | "**Topology is derived after initialization**, not from the roster alone (§11.1). A device whose `init!` failed spawns no task. The run proceeds without it, or ends at `t₀` when the device attached with `should_abort = true`." | bold lead-in | D-138 Position, the clause its annotation (log 4694–4698) calls historical; D-310 bullet 1 | B: R (a historical clause carried as a ruling); U for "spawns no task". Restates rows 158, 163, 164 (F18, carried item) |
| 169 | 9062–9063 | "**Rule.** An `InterruptException` inside a device's `init!` is the operator's stop, not that device's crash (D-268)." | **Rule.** | D-268 bullet 3 | C |
| 170 | 9065–9070 | "The bracket releases the device through `shutdown!` as for any throw and spawns no task for it. In place of the `DeviceCrash` report it sets the `:interrupt` stop … The remaining entries still initialize, and the run ends at its first frame top with zero frames advanced" | plain | D-268 bullet 3 | C, adjacent |
| 171 | 9070–9071 | "The device wrapper makes the same discrimination for a raise inside a loop body (§11.6)." | plain | D-132 Rationale log 4247–4252, bold at §11.6 7916 | R; pointer |

#### The operator interrupt (9073–9167)

| # | line | quote | marking | entry | class |
|---|---|---|---|---|---|
| 172 | 9075 | "**The operator interrupt is a stop, not a failure.**" | bold sentence, no citation | D-132 Position | U; D-132 is cited nowhere in §12.4 |
| 173 | 9075–9078 | "Ctrl-C in an interactive session is a control-plane stop command issued by hand. The run completes the current boundary, publishes the final snapshot, takes this tail like any other stop, and ends `stopped`." | plain | D-132 Position | U |
| 174 | 9078–9080 | "The result is boundary-consistent. It is fully serviceable by the §14 stopped-sim services and resumable by the next `run!` (§12.6)." | plain | D-132 Position log 4235–4236 | U; "resumable by the next `run!`" contradicts §12.6 and the code (F1, serious) |
| 175 | 9082–9083 | "The interrupt is the escape from a run nothing else can end. Such a run is deviceless, and it declares no stop of its own." | plain | D-132 Rejected log 4282–4284; D-255 Rationale log 10094–10096 | R; "Such a run is deviceless" overclaims (F13) |
| 176 | 9083–9085 | "A run with no finite `t_end` and no honoured stop request is the configuration `UnboundedRun` names (Appendix C)." | plain | D-316 bullet 9 | U |
| 177 | 9085–9087 | "The interrupt needs no entry point of its own. The stop already rides on the control plane … (§12.1)." | plain | D-132 Rejected log 4285–4288 | R (adversarial in substance); restates row 9 |
| 178 | 9087–9090 | "The exceptions-are-abnormal doctrine (§13) is untouched. That doctrine is about *model* code, while this is the one exception whose meaning the framework knows." | plain | D-060 Position ("exceptions from model code always abnormal") | U; the doctrine's home is §13.5 (F23) |
| 179 | 9092–9093 | "**Rule.** Masking across the boundary is normative, not an implementation hint." | **Rule.** | D-132 Rationale log 4241 ("**Boundary masking is normative**") | R |
| 180 | 9095–9100 | "**Why.** An `InterruptException` is delivered asynchronously. An interrupt landing mid-sweep would … destroy the boundary … leave half-written stores (§13.6). That forces a choice between `stopped` with dirty stores and a terminal `errored`. …" | **Why.** | D-132 Rationale log 4241–4246; Rejected log 4278–4281 | R |
| 181 | 9102–9104 | "The loop masks delivery across the boundary macro-sequence, using Julia's `disable_sigint`, a sigatomic counter increment that is negligible per frame." | plain | D-132 Rationale log 4242–4244 | R; the code calls `Base.sigatomic_begin`/`sigatomic_end` directly (`src/sim.jl` 1427), the same counter `disable_sigint` wraps |
| 182 | 9104–9106 | "It takes the deferred raise at the unmask points: the frame top, where it already consults the control plane (§12.1), and inside its wait and pause blocks. All of those points are boundary-consistent." | plain | D-132 Rationale log 4244–4245; D-294 bullet 1 (the wait) | B: R by D-132; U by D-294 for the wait |
| 183 | 9106–9108 | "Caught at one of them, the interrupt sets the control-plane stop and enters this tail. The catch site (§13.4) therefore never sees it." | plain | D-132 Rationale log 4247–4249 ("unreachable in practice under masking") | R; "never" is contradicted at row 194 (F14) |
| 184 | 9110 | "**A deferred interrupt yields to the frame's own stop request** (D-268)." | bold lead-in | D-268 bullet 2 (its "stop face" read as stop request since D-316) | C |
| 185 | 9111–9117 | "Stop requests are consulted at each publication and the stop word at the next frame top (§13.5), and the deferred raise lands between the two. Where the frame's publication found an honoured request holding, that request is the recorded source … Where none held, … `ControlRequestedStop(:interrupt)`." | plain | D-268 bullet 2; D-203 bullet 5 | C, adjacent |
| 186 | 9119–9120 | "**A frame that throws with an interrupt pending ends `errored`** (D-268)." | bold lead-in | D-268 annotation 2026-09-26 (log 11161–11166) | R |
| 187 | 9120–9125 | "The frame's own throw is the disposition (§13.4). The catch wraps the cause under the mask and consumes the pending interrupt …, and the run takes the abnormal entry under that `StepError` (§13.6). The alternative … is what the masking exists to prevent." | plain | D-268 annotation log 11161–11166 | R |
| 188 | 9127 | "**An interrupt after a frame's throw does not displace it** (D-268)." | bold lead-in | D-268 bullet 9 (amended 2026-10-01) | C |
| 189 | 9127–9133 | "`run!`, `replay!` and `step!` store the loop's throw before an interrupt can displace it … An interrupt that cuts the handling of the throw itself propagates out of the call raw, and the disposition of the failure is skipped (§13.4). The record is still written and the lifecycle is still `errored`." | plain | D-268 bullet 9 | C, adjacent |
| 190 | 9135 | "**Rule.** The tail's bookkeeping is masked too (D-268)." | **Rule.** | D-268 bullet 4 | C |
| 191 | 9137–9140 | "After the joins, the run's-end sweep, the termination record and the terminal lifecycle state are written under the same mask. An interrupt landing there would otherwise … leave the lifecycle `running`, every service refusing." | plain | D-268 bullet 4; Rationale log 11149–11151 | C; R for the reason |
| 192 | 9140–9142 | "A raise deferred to the end of that bookkeeping propagates out of `run!` raw, the simulation already terminal." | plain | D-268 bullet 4 | C, adjacent |
| 193 | 9144 | "**A forced throw reaches the defensive arm** (D-268)." | bold lead-in | D-268 annotation 2026-09-26 (log 11168–11172) | R |
| 194 | 9144–9151 | "Julia stops deferring after repeated SIGINTs … raises inside the mask. … The arm abandons the frame unpublished and the run ends `stopped`, the source `ControlRequestedStop(:interrupt)`. … The stores may hold mid-boundary values until the next `init!` or `restore!` resets them …" | plain | D-268 annotation | R; `replay!` also resets them (F22) |
| 195 | 9152–9154 | "`checkpoint` refuses such a run, since the executor no longer rests where its last snapshot was published (§12.6). The trace is the reproduction (§12.7)." | plain | D-319 Position (checkpoint at `:consistent`, clock on a grid top); D-059 (errored terminal, reproduction by replay) | B: U by D-319; N for the snapshot test; the kind, `CheckpointMidFrame`, is not named (F15) |
| 196 | 9156 | "**A second interrupt during the tail** collapses the remaining joins immediately." | bold lead-in | D-132 Rationale log 4252–4254 | R |
| 197 | 9157–9159 | "That is (5)'s abandonment path taken at once, with devices still reported by name (`DeviceJoinTimeout`). The run still ends `stopped`. Escalation shortens the tail, never reclassifies the run." | plain | D-132 Rationale log 4253–4256; Rejected log 4292–4293 | R |
| 198 | 9159–9161 | "Nor can a second interrupt repair (5)'s honest asymmetry, since nothing can abandon the task `run!` stands on." | plain | D-132 Rationale log 4256–4257 | R; orphaned since D-310 (F3) |
| 199 | 9163–9165 | "**Interactive-session scope, stated plainly.** Outside the REPL, Julia's default (`exit_on_sigint(true)`) kills the process on SIGINT before any of this machinery runs. The framework flips nothing process-global." | labelled bold lead-in | D-132 Rationale log 4257–4260; Rejected log 4289–4291 | R |
| 200 | 9165–9167 | "Unattended runs, those with empty staging and no snapshot readers, rely on `t_end` and stop requests, as they already must." | plain | D-132 Rationale log 4259–4260 | R |

D-030's Position rules rows 92–94, 97–103, 109 and 119 and is cited nowhere.
D-138's Position rules rows 145, 146, 149 and 158, and its Rationale rows
148, 154, 155, 159–168; it is cited nowhere in §12.4. D-132's Position rules
rows 172–174, its Rationale rows 179–183 and 196–200; it is cited nowhere in
§12.4 either. D-268 is cited seven times and is the half's best-cited entry,
but three of its rows (186, 187, 193, 194) rest on annotations.

Descriptions that read like rules: rows 101 (the wrapper's treatment of an
`unblock!` raise), 105, 120, 142.

Display-block candidates: the `attach!` keyword `should_abort` is already in
§11.6 7843–7845; none new needed. The tail's numbered list stays a list. The
chart (row 122) duplicates the list's order (q4).

Glossary terms in §12.4 (lesson 35):

| term | first use | linked there | use matches the entry |
|---|---|---|---|
| boundary | 8830 | yes, no gloss | yes |
| device | 8830 | yes (8849), no gloss; first use at 8830 is unlinked | yes |
| operator interrupt | 8836 | no; linked at 8850 | yes, but the entry (14238–14243) gives the unmask points as "a frame-top or wait unmask point", omitting the pause block 9106 names |
| stop request | 8846 | yes, no gloss | yes |
| snapshot | 8848 | yes, no gloss | yes |
| next-snapshot wait | 8855 | no | yes |
| termination record | 8878 | yes, no gloss | yes |
| staging cell | 8885 ("Its cell") | yes | yes |
| roster | 8886 | yes, no gloss | yes |
| claim | 8887 | yes, no gloss | yes |
| root input | 8889 | yes, no gloss | yes |
| frame | 8830 ("mid-frame") | no | yes |
| log | 8917 | no | yes |
| `t*` | 8931 | no | yes |
| deployment | 8937 ("The cap is deployment"), 8944 ("rather than the deployment") | no | no: the entry is the `Deployment` artifact; 8937 uses D-133's older sense, "a deployment parameter", and 8944 the artifact (F6) |
| replay | 8945 | no | yes |
| calling task | 8970 | no | yes |
| payload | 9007 | yes, no gloss | yes |
| boundary zero | 9021 | yes, glossed | yes |
| diagnostic cell | 9024 | yes, glossed | yes |
| root-input totality | 9034 | yes, no gloss | yes |
| batch | 9035 | no | yes |
| control plane | 9086 | yes, glossed | yes |
| sweep | 9096 | yes, no gloss | yes |
| store | 9097 | no | yes |
| checkpoint, executor | 9152 | no | yes |
| trace | 9153 | no | yes |
| unattended run | 9166 | yes, glossed in place | yes |
| orphaned claims | 8888 ("The orphaned root inputs") | no | yes |

Appendix C kinds cited to §12.4 (lesson 20):

| kind | Appendix C line | named in §12.4 where its condition is stated |
|---|---|---|
| `DeviceJoinTimeout` | 13476 | yes, 8876 |
| `DeviceCrash` | 13482 | yes, 8892 and 9006 |
| `ArgumentInvalid` | 13427 (§12.4 among its citations) | no: 8872 states "a positive real" without the kind (F15) |
| `UnboundedRun` | 13503 (body cites §12.4) | yes, 9084 |
| `CheckpointMidFrame` | 13416 (body cites §12.4) | no: 9152 says "`checkpoint` refuses such a run" (F15) |

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

<!-- Sliced from survey_2.md for unit F (§12.5, §12.6) by checks/slice_survey.py. -->
# Survey of spec chapter 12, half 2, before its readability rewrite — 2026-10-15

Scope: `docs/design/spec.md` lines 9169–9738 at commit `17ad42d`, 5,101
words: §12.5 (9169–9240), §12.6 (9241–9484) and §12.7 (9485–9738; the
chapter's closing `---` is 9737). Half 1 (the heading, roadmap and
§12.1–§12.4, 8588–9168) is the sibling survey's. The convention is
`docs/design/tools/spec_style.md`; the method is `docs/spec_rewrite/recipe.md`
step 1; the model is chapter 11's half-1 survey (`git show
e5cbb77:docs/spec_rewrite/ch11/survey_1.md`).

Line numbers are lines of the frozen copies in `scratch_survey/h2/` (`spec.md`
and `decisions.md` at `17ad42d`). Lines marked `log` are `decisions.md` lines.
Entry claims rest on the entry as read in full. `src/` was read at the working
tree where a name or a claim was in doubt; no commit since `17ad42d` touches
`src/` (`git diff --stat 17ad42d -- src/` is empty). The scripts that ran the
half's code and claims are `scratch_survey/h2/run/blocks.jl` and
`scratch_survey/h2/run/tstar.jl`.

Classification codes used in part A, as in chapter 11:

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

"Marking" is how the spec marks the rule now: **Rule.**/**Why.** label, bold
sentence, bold lead-in (a bold phrase opening a paragraph or bullet, used as a
heading), bold phrase inside a sentence, bold word, or plain.

Section sizes (words): §12.5 547; §12.6 2,223; §12.7 2,331 (its two code
blocks 9489–9497 and 9618–9625 and its table 9722–9729 included).

## A. Per section

### §12.5 Scripts and the mid-run mutation doctrine (9169–9240, 547 words)

Purpose: the consumer survey of what FlightCore code mutates mid-run, the
clock criterion that sends sim-time scripts to scenario components and
wall-clock interaction to devices, the elimination of `user_callback!`,
manual events, the refusal of mid-run re-initialization, and the doctrine's
final form.

Subheadings: none. No context paragraph in the house sense: the section opens
on FlightCore's two archetypes. Bold: seven spans, 45 words, one **Rule.**
label (9185), the rest bold sentences or lead-ins.

| # | line | quote | marking | entry | class |
|---|---|---|---|---|---|
| 501 | 9171–9177 | "What the consumers demonstrably mutate mid-run is surveyed here. FlightCore's `user_callback!` has exactly two archetypes … (c172_demos.jl:290 …) … Both write only `u` fields. No demo, test or GUI path pokes `x`/`s` mid-run" | plain | — | N, a description of FlightCore; reader-cold file references (F71) |
| 502 | 9179–9181 | "**Sim-time scripts are model behavior, so they become [scenario components]** (ordinary periodic discrete components holding a sim-time script)" | bold sentence | D-031 Position log 1058 ("sim-time scripts = scenario components (clock criterion)"), cited at 9183 | C (adjacent) |
| 503 | 9181–9183 | "Both archetypes are clocked by *sim time* … Mapping them to devices is rejected (D-031). The clock is the criterion." | plain, cites D-031 | rejection: D-031 Rejected log 1069–1071; criterion: D-031 Position log 1058 | B: R for the rejection, C for the criterion |
| 504 | 9185–9186 | "**Rule.** A sim-time script becomes a source or supervisor component; a wall-clock interaction becomes a device." | **Rule.** label | D-031 Position log 1058–1059 | U; the same ruling as row 502, stated twice, one of them bold |
| 505 | 9188–9189 | "A script mapped to a component is periodic discrete, with `K = 1` for today's `dt = 0.02` callbacks." | plain | — | N; `K` and "today's `dt`" unintroduced (F71) |
| 506 | 9189–9192 | "It executes synchronously in the loop, deterministic paced or unpaced. It is replayed by recomputation, with no trace. A device, by contrast, is traced and replayed from the trace." | plain | D-031 Rejected log 1069–1071 ("breaks unpaced") | R |
| 507 | 9194 | "**The component mapping is strictly richer than the callback it replaces.**" | bold sentence, no citation | — | N |
| 508 | 9196–9197 | "The `Ref(:init)` phase closure becomes honest `s`, visible in snapshots, logs and plots." | plain bullet | — | N; "visible in snapshots" contradicts D-252 (F60) |
| 509 | 9198–9199 | "Inputs arrive same-boundary fresh by topological order. The callback ran post-step, one boundary staler." | plain bullet | — | N, description |
| 510 | 9200–9204 | "The pure timetable script is a one-liner … `y_direct(c, (; t)) = (; offset = profile(t))`, exact at its own ticks, with no latching." | plain bullet, inline code | — | code, not counted; ran (part C); "no latching" is F77 |
| 511 | 9205–9208 | "In a scenario configuration the script drives the avionics' input ports. §11.7 therefore renders the corresponding GUI widgets read-only with its source shown. Today's demo-vs-GUI dead-slider fight is resolved by the port-resolution rule." | plain bullet | §11.7 8214–8227 bolds the rule (D-045) | pointer, not counted; "the avionics", "Today's" reader-cold (F71) |
| 512 | 9210–9214 | "**`user_callback!` is eliminated** (D-031). It is the periphery's `f_step!`, FlightCore's unconditional per-step hook (§2.5), and cheap composition leaves it without justification. Its call sites migrate to scenario components, not devices." | bold lead-in, cites D-031 | D-031 Position log 1059–1060; "the periphery's `f_step!`": D-031 Rejected log 1072–1073 | C |
| 513 | 9216–9219 | "**Manual event triggering needs no mechanism.** It takes a root input plus a boundary-detected guard reading that root input" | bold lead-in, no citation | D-031 Position log 1060 ("manual events = slot + guard") | U |
| 514 | 9219–9221 | "That is already expressible in settled machinery. The levels doctrine applies: latched commands or counters. The demos' engine start/stop buttons are `u`-writes today." | plain | levels: D-045 Position bullet 4 log 1474 ("Edge logic is staged counters plus model-state accumulators"); the demos: none | B: U by D-045 for the levels clause; N for the FlightCore description |
| 515 | 9223 | "**Mid-run re-initialization is not built, because it is not demonstrated.**" | bold sentence, no citation | D-031 Position log 1061–1062 ("init/trim = stopped-sim services … mid-run intervention command = guarded addition with shape on record") | U |
| 516 | 9224–9226 | "Initialization and trim are stopped-sim workflows (first-class services, §14). No concurrency perimeter exists there. There is no loop and no devices, just plain single-task code." | plain | first sentence D-031 Position log 1061; the rest none | B: U for the first sentence, N (description) for the rest |
| 517 | 9226–9229 | "The guarded-addition shape is on record should demand appear. It would be a traced, boundary-executed intervention command applied through project → sweep → publish, so that no consumer ever observes un-decoded state." | plain | D-031 Position says "shape on record"; no entry records the shape | N; the shape lives only here. "project" is the executor's phase symbol (D-220 log 8385), the declaration being `x_projection` |
| 518 | 9231–9233 | "**The doctrine, final form.** While a simulation runs, the periphery stages root-input writes and issues control commands. Structurally, it does nothing else." | bold lead-in | D-031 Position log 1057–1058; "final form": D-106 Rationale log 3364–3365 | U; Part I's §2.2 states the law (339, 359–361), part B |
| 519 | 9233–9236 | "Anything that wants to poke the model mid-run is one of three things. It is an *input* in disguise … *model behavior* in disguise … Or it is a *wall-clock interaction*, so attach a device." | plain | D-031 Position log 1057–1060 | U |
| 520 | 9236–9239 | "Graceful termination follows the same shape (§13.5): a stop request declared in the model, honoured unless the advance ignores it. Never a callback, and never a thrown exception." | plain | D-316 Position log 13612–13614; D-060 Position log 1858 ("never an exception"), standing under D-316's annotation | U |

D-031 is cited twice (9183, 9210), both for its rejection or its
elimination clause. Its Position, which rules rows 502, 504, 512, 513, 515,
516, 518 and 519, is cited at none of the three bold doctrine statements.

Descriptions that read like rules: rows 507 ("strictly richer", bold, no
entry) and 509. Row 507 is the section's one N row in bold; the four bullets
under it are a comparison with FlightCore, not rules.

Display-block candidates: the three-way classification (rows 519) is a
natural three-row list: input → root input plus guard; model behavior →
scenario component; wall-clock interaction → device. The timetable one-liner
(row 510) is a definition a reader would type, so it qualifies as display
code.

Glossary terms in §12.5 (lesson 35):

| term | first use | linked there | use matches the entry |
|---|---|---|---|
| scenario component | 9180 | yes, with gloss | yes (14272–14276) |
| device | 9182 | yes, no gloss | yes |
| component | 9186 | yes, no gloss | yes |
| replay | 9190 ("replayed by recomputation") | no | yes; the glossary term is linked nowhere in the section |
| trace | 9191 | yes, no gloss | yes |
| snapshot | 9197 | yes, no gloss | no: a snapshot holds the signal table, and `s` reaches it only through a port (F60) |
| boundary | 9198 | yes, no gloss | yes |
| bundle | 9201 | yes, with gloss | yes |
| tick | 9204 | yes, no gloss | yes |
| port | 9206 | yes, no gloss | yes |
| periphery | 9211 | yes, no gloss | yes |
| root input | 9217 | yes, no gloss | yes |
| boundary-detected | 9217 | yes, with gloss | yes |
| guard | 9218 | yes, no gloss | yes |
| guarded addition | 9226 | no | yes; anchor `g-guarded-addition` exists and its examples list omits this one |
| projection | 9228 ("project") | no | the phase symbol, not the declaration; see row 517 |
| sweep | 9228 | yes, no gloss | yes |
| stop request | 9237 | yes, no gloss | yes |

Other names: "levels doctrine" (9220) is §11.4's subheading and has no
glossary entry; "stopped-sim" (9224) has none either.

Appendix C kinds cited to §12.5: none.

### §12.6 Run lifecycle and partial advance (9241–9484, 2,223 words)

Purpose: the `Run` and the `Simulation` and what each owns, the five
lifecycle states and their derivation, the input mode, the mandatory door,
partial advance with `step!`, the harness write and read paths in a stepping
session, re-running and the warm restart, the checkpoint on the `Model` and
the `Simulation`, roster persistence, the per-advance stop policy, and
`errored` as terminal.

Subheadings: none, and no context paragraph: the section opens on a bold
ruling about `Run` (9243). Bold: 28 spans, 118 words. Two **Rule.** labels
(9295, 9332). Nine bold words name states or a phrase (`built`,
`initialized`, `running`, `stopped`, `errored` at 9300–9301, **Built** and
**Initialized** at 9302 and 9304, **initialized** at 9388, **actually
advanced** at 9398). Two bold terms (**placeholder run** 9267, **harness
cell** 9372). The rest are bold sentences or lead-ins.

| # | line | quote | marking | entry | class |
|---|---|---|---|---|---|
| 521 | 9243 | "**`Run` is what one run owns** (D-255, D-260, D-317)." | bold sentence | D-255 Position log 10035 | C |
| 522 | 9244 | "It is a mutable struct of six fields." | plain | D-260 bullet 1 log 10324 (four fields, superseded by D-317 log 13823); D-317 bullet 4 log 13766–13768 (the counters are the run's) | B: C by composition of D-260 and D-317; no Position states "six" |
| 523 | 9244–9245 | "Two are `const` and last the run's whole life, the log and the trace (`nothing` under the trace switch)." | plain | D-260 bullet 1 log 10324–10325 | C (adjacent) |
| 524 | 9246–9249 | "The door that builds the run takes the four recording keywords … (Appendix B, D-261), so a run's recording is that door's declaration and the next door may declare otherwise." | plain, cites D-261 | D-261 bullet 7 log 10442–10443 (names `init!` and `replay!`); the consequence: D-261 Rationale log 10500–10503 | B: C for the keywords, R for "the next door may declare otherwise"; D-261 lacks `restore!` (part E) |
| 525 | 9250–9253 | "Four evolve during it. `feed` … `termination` … `frame` and `boundary` are the trajectory's counters" | plain | D-260 bullet 1; D-317 bullet 4 | C (adjacent) |
| 526 | 9253–9254 | "`init!`, `restore!` and `replay!` construct one, and nothing else rebinds it." | plain | D-260 bullet 1 log 10326–10327 (`init!` and `replay!`); `restore!`: D-274 bullet 3 log 11656–11658 ("opens a fresh run") | B: C for two doors, U for `restore!` |
| 527 | 9254 | "`live!` and the halt at a recording's end write `feed`." | plain | D-260 bullet 1 log 10327–10328 | C (adjacent) |
| 528 | 9254–9256 | "The loop's tail writes `termination` once, and `closed(run)` is `termination !== nothing`." | plain | D-260 bullet 1 log 10328–10329; D-255 bullet 1 | C (adjacent) |
| 529 | 9256–9258 | "Each door sets the two counters as it builds the run, `init!` to zero and `restore!` and `replay!` to the checkpoint's, and the loop advances them (D-317)." | plain, cites D-317 | D-317 bullet 4 log 13766–13768 | C |
| 530 | 9258–9260 | "`restore!` of a bare state sets the frame index to the state's frame and the boundary ordinal to zero, as `init!` does (D-319)." | plain, cites D-319 | D-319 bullet 3 log 14027–14029 | C |
| 531 | 9261–9262 | "The origin `t₀` is not a run field. The executor's clock holds it beside `t`." | plain | D-260 bullet 4 log 10336; D-317 bullet 4 log 13765 | U |
| 532 | 9262–9264 | "`init!` sets it on the clock before boundary zero (§14.5), and a checkpoint … carries it with the clock (§11.5, D-273)." | plain, cites D-273 | D-273 bullet 3 log 11567–11568 | C |
| 533 | 9264–9265 | "It is a `Float64`, as `h` and `t_end` are." | plain | D-260 bullet 4 log 10337–10338 | U |
| 534 | 9267–9269 | "A `Simulation` is constructed with a **placeholder run**, an empty log, no trace, no feed and no termination, which `init!`, `restore!` and `replay!` replace (D-255)." | bold term, cites D-255 | D-255 bullet 2 log 10043–10045 (its contents amended: D-261 bullet 7 log 10444–10445 "an empty log and no trace") | C; D-255's placeholder still lists `t₀` and `mode` (part E) |
| 535 | 9269–9271 | "The field is always a `Run` and never `nothing`, so every accessor has a run to read, and the lifecycle state below says whether that run ever started." | plain | D-255 Rationale log 10091–10093; Rejected log 10107–10108 | R |
| 536 | 9271–9272 | "The placeholder carries no configuration and no compiled state (D-261)." | plain, cites D-261 | D-261 bullet 3 log 10432–10434 | C |
| 537 | 9272 | "`init!` allocates fresh objects rather than clearing them." | plain | D-255 bullet 2 log 10047–10048 | U |
| 538 | 9274–9276 | "**`Simulation` is a mutable struct of four fields**, the `Model` …, the run, the data plane and the control plane (D-317)." | bold lead-in, cites D-317 | D-317 bullet 1 log 13749–13750 | C |
| 539 | 9276–9279 | "The `Model` holds the deployment …, the executor, its status and its diagnostic cell." | plain | D-317 bullet 1 log 13748–13749 | C (adjacent) |
| 540 | 9279–9280 | "A simulation owns its `Model`, claimed at construction and never shared (§9.2, D-318)." | plain, cites D-318 | D-318 Position log 13917–13918; §9.2 4333 bolds it | C |
| 541 | 9280–9281 | "Every other value belongs to one of the four (D-256)." | plain, cites D-256 | D-256 Position log 10129–10130, as amended by its annotation log 10161–10165 | C |
| 542 | 9281–9282 | "The build is reached through the deployment, never held twice." | plain | D-256 Position log 10127–10129 | C (adjacent) |
| 543 | 9282–9284 | "The grid parameters, the schedule … and the event parameters are the deployment's (§9.2)." | plain | D-256 bullet 1 log 10132–10133; D-254 bullet 1 | U |
| 544 | 9284–9285 | "`chunk_size`, the stepper and the arrival buffers are the executor's." | plain | D-256 bullet 2 log 10134–10135; `chunk_size` through D-256's annotation log 10165 | U |
| 545 | 9285 | "`join_timeout` is `Control`'s (§12.1)." | plain | D-256 bullet 3 log 10136 | U; §12.1 8621–8622 bolds `Control`'s contents (D-256) |
| 546 | 9286–9287 | "The loop's diagnostic cell, its account and the published holder are the plane's, and the frame's own cell is the `Model`'s (§11.8)." | plain | D-256 bullet 3 log 10136–10137; D-317 bullet 1 | U |
| 547 | 9288 | "The log, the trace and the two counters are the run's." | plain | D-260 bullet 1; D-317 bullet 4 | U |
| 548 | 9288–9291 | "The stop policy, with its `t_end` and ignored requesters, is the advance's argument, and the termination record keeps the terminating one (D-260)." | plain, cites D-260 | D-260 bullet 3 log 10333–10335 | C |
| 549 | 9291–9293 | "The pacer's schedule and counters are `run!`'s own, created per call … and each snapshot's status carries their frozen record (§10.7, D-269)." | plain, cites D-269 | D-269 bullets 5–6 log 11234–11239 | C |
| 550 | 9295–9298 | "**Rule.** A struct holds what it owns or what it must retain across calls. A callee takes what it reads as an argument … An object is built after its inputs exist, and the placeholder run above is the one exception (D-261)." | **Rule.** label, cites D-261 | D-261 bullets 1 and 3 log 10407–10409, 10432–10434 | C; two rulings under one label |
| 551 | 9300–9301 | "A `Simulation` moves through five states: **built**, **initialized**, **running**, and terminally **stopped** or **errored** (§13.4)." | bold words | D-088 Position log 2776–2777; the count "five": D-131 Rationale log 4202–4203 | U; D-088 is cited nowhere in the half |
| 552 | 9302–9304 | "**Built** means stores allocated and boundary zero not completed. It is the cold state, and the state a throw inside boundary zero returns the simulation to (§13.4)." | bold word | D-223 Position log 8554–8557 and bullet 2 log 8562 | U |
| 553 | 9304–9307 | "**Initialized** means `init!` has completed boundary zero … or `restore!` or `replay!` has restored a checkpoint." | bold word | D-088 Position log 2776–2777; D-274 bullet 3 | U |
| 554 | 9309 | "**`lifecycle(sim)` derives the state rather than storing it** (D-317)." | bold sentence | D-317 bullet 6 log 13783–13785 | C |
| 555 | 9310–9312 | "It reads three facts … The status is `:built`, `:consistent` or `:inconsistent`, and only the `Model`'s own doors and catch sites write it." | plain | D-317 bullet 6 log 13782–13785 | C (adjacent) |
| 556 | 9313–9314 | "A claimed model's status is written only through its simulation's doors, since the model's doors refuse a direct call on a claimed model (D-318)." | plain, cites D-318 | D-318 bullets 2–3 log 13924–13931 | C |
| 557 | 9316–9322 | the derivation table: running flag × `Model` status × run closed → state | table | D-317 bullet 6 log 13785–13788 | C |
| 558 | 9324–9326 | "Beside the state, the run carries an **input mode**, `:live` or `:replay`, read as `mode(sim)`. It is read off the run's `feed` … (D-260)." | bold term, cites D-260 | D-260 bullet 2 log 10330–10332; the mode itself D-218 Position log 8273–8275 | C |
| 559 | 9327–9328 | "The mode names where the next frame's drain takes its batches from, the staging cells or the attached recording (§12.7)." | plain | D-218 Position log 8274–8275 | U |
| 560 | 9328–9330 | "State and mode are orthogonal. The state says whether the simulation may advance, and the mode says what it will advance on." | plain | D-218 Position ("beside its lifecycle state") | B: U by D-218 for "beside", N for "orthogonal" as a stated property |
| 561 | 9332 | "**Rule.** `init!` is mandatory." | **Rule.** label | D-088 Position log 2777 | U |
| 562 | 9334–9336 | "`run!` or `step!` on a simulation whose boundary zero has not completed is an error in the kind set (§13.2) naming `init!`." | plain | D-088 Position log 2777–2778 | U; the kind, `MissingInit`, is unnamed (F58) |
| 563 | 9336–9337 | "That is distinct from `UninitializedInputs`, which fires *inside* `init!` (§14.6)." | plain | D-088 Position log 2778 (spells it `UninitializedSlots`) | U |
| 564 | 9337–9339 | "`restore!` and `replay!` are the two alternative entries. Each restores a checkpoint and runs no boundary zero (§12.7, D-274)." | plain, cites D-274 | D-274 bullets 3–4 log 11656–11667 | C |
| 565 | 9339–9341 | "A throw inside boundary zero, which only `init!` runs, leaves the simulation `built` (§13.4), so the next `run!` or `step!` meets the same refusal." | plain | D-223 Position log 8554–8557; "only `init!`": D-274 bullet 4 log 11666–11667 | U |
| 566 | 9343–9345 | "**Where the loop runs.** The loop runs on the calling task …, and every rostered device on a spawned task (§11.1)." | bold lead-in, no D-citation | D-310 bullet 1 log 13219–13220; §11.1 6870 bolds it | U; a double of §11.1 (M51) |
| 567 | 9345 | "Deviceless, `run!` is fully synchronous." | plain | D-088 Rationale log 2782 | R |
| 568 | 9345–9347 | "An unattended run is the same loop with empty staging (§11.1)." | plain | D-022 Position (interactive = batch + devices); §11.1 6894–6896 states it | U; pointer-shaped double |
| 569 | 9347–9348 | "It is also what the synchronous rethrow presupposes (§13.4)." | plain | D-093 Rationale log 2906–2908; D-268 Rationale log 11153–11154 | R; "It" has two candidate antecedents (F65) |
| 570 | 9350–9353 | "**Partial advance.** `step!(sim; frames = 1)` advances whole frames synchronously through the ordinary frame sequence … and returns. A stepped simulation is bit-identical to the same frames under `run!`" | bold lead-in | D-088 Rationale log 2782–2784 | R; Part I's §2.4 563–570 states the bit-identity law (part B) |
| 571 | 9353–9354 | "and it never waits, whatever pace the control plane holds (D-269)." | plain, cites D-269 | D-269 bullet 1 log 11225 | C; it does wait while paused (§12.1 8643–8645, D-268 bullet 1), hazard in part F |
| 572 | 9354–9357 | "`step!(sim; t_plus = 10.0)` is the duration spelling, mutually exclusive with `frames`. It advances whole frames until the boundary time first covers the duration, which is the migration suite's advance-by-duration idiom." | plain | D-096 Rationale log 3016–3018 | R; the refusal kind, `ArgumentInvalid`, unnamed (F59); "the migration suite" reader-cold (F71) |
| 573 | 9359–9362 | "Partial advance is the test-harness mode … the REPL mode … Neither is a script, so the scenario-component doctrine does not absorb them (§12.5)." | plain | D-088 Rejected log 2794–2795 | R |
| 574 | 9364–9369 | "**A stepping session is deviceless by construction.** Device tasks are per-`run!` artifacts (§11.1) … so `attach!` is legal there and does what it always does. It registers (§11.3), and the task appears at the next `run!`." | bold sentence | D-093 Rationale log 2908–2910; "`attach!` never spawns": D-093 Position log 2892 | B: R for "deviceless by construction", U for the `attach!` clause |
| 575 | 9371–9372 | "**The frame-top drain still runs**, so `step!` frames stay bit-identical to `run!` frames." | bold lead-in | D-088 Rationale log 2783–2784 | R |
| 576 | 9372–9377 | "What it drains is the **harness cell**. The harness write path is `stage!(sim, "face" => value, …)` (§11.3), from any task, the calling task included. Staged batches are ordinary batches. They are traced … applied at the next frame top … surface-checked like any writer's (§11.3)." | bold term | D-096 Position log 3006–3011 with its annotation log 3022–3025; "any task": D-200 Rationale log 7493 | U; D-096 is cited nowhere in the half; §11.3 7253–7268 is the rewritten home (part B); "What it drains" is F64 |
| 577 | 9379–9381 | "The read half is `latest(sim)`. It hands back the same immutable snapshot value a device handle acquires (§11.2), navigated directly for assertions." | plain | D-096 Rationale log 3015–3016 | R |
| 578 | 9381–9382 | "Advance-assert-advance is `stage!` → `step!` → `latest`. Both entry points work under `run!` too." | plain | D-096 Rationale log 3018–3020; "under `run!`": D-200 Rationale log 7493 | R |
| 579 | 9382–9384 | "The harness cell, the always-present staging cell of the harness writer, is not step-scoped." | plain | — | N; the gloss sits at the second link, not the first (9373) |
| 580 | 9384–9385 | "An inspection accessor leaves the rejection of closure-based termination (§13.5) untouched." | plain | D-096 Rejected log 3036–3037 | R; a rejected alternative argued in place |
| 581 | 9387–9392 | "**Status, termination and the `run!` seam.** Between `step!` calls a simulation reports **initialized**. No loop task exists, so `running` would lie. Nothing is terminal, so `stopped` would lie too. … `run!` may therefore follow `step!` … and so may another `step!`." | bold lead-in | D-088 Rationale log 2786–2788 | R; "seam" is F61 |
| 582 | 9394–9397 | "Termination policy is honored throughout, as bit-identity requires. `t_end` reached, or a stop request holding at frame 3 of `step!(sim; frames = 10)`, ends the run there through the ordinary §12.4 tail and leaves the simulation `stopped`." | plain | D-088 Rationale log 2788–2789 (in `stop_on` terms) | R |
| 583 | 9397–9401 | "`step!` therefore returns the number of frames **actually advanced** … That return is how a harness detects the truncation without inspecting the clock." | bold phrase | D-088 Rationale log 2789–2790 | R |
| 584 | 9403–9404 | "**Re-running: `stopped → init! → run!` remains the authored re-run.** `init!` re-runs boundary zero from its condition." | bold sentence | D-088 Rationale log 2784 | R |
| 585 | 9404–9405 | "The warm restart is `checkpoint` → `restore!` → `run!` (§12.7, D-274)." | plain, cites D-274 | D-274 Position log 11640–11642 | C |
| 586 | 9406 | "`restore!` is a door like `init!`, and it runs no boundary zero." | plain | D-274 bullet 3 log 11656–11658 | C (adjacent) |
| 587 | 9406–9409 | "Each builds a fresh run, so the trace, the log and the termination record (§13.5) are new objects rather than cleared ones" | plain | D-255 bullet 2 log 10047–10048 (`init!`); D-274 bullet 3 (`restore!` opens a fresh run); D-203 bullet 6 log 7590 (`init!` clears the record) | U |
| 588 | 9409–9412 | "and each clears any batches still in staging cells. The recorders restart with the run they record, and no stale batch survives to clobber the frame it predates." | plain | `init!`: D-093 Rationale log 2911, D-110 Rationale log 3525–3526; `restore!`: none | B: R for `init!`, N for `restore!` |
| 589 | 9412–9413 | "`init!` and `restore!` also return the input mode to `:live`, and a fresh `replay!` sets the mode exactly as it sets the trajectory." | plain | D-218 bullet 3 log 8284–8285 (`init!` and a fresh `replay!`), cited 9417; `restore!`: none | B: C for `init!` and `replay!`, N for `restore!` |
| 590 | 9413–9415 | "`live!` is the fourth door, and the only one that moves the mode alone. It takes a replaying simulation live where it stands (§12.7)." | plain | D-219 bullet 2 log 8326–8328, cited 9417 | C (adjacent); "door" is F62 |
| 591 | 9415–9417 | "A terminal state makes the mode moot. Nothing advances until one of those doors is taken (D-218, D-219)." | plain, cites D-218, D-219 | none states it | N; inexact (F63) |
| 592 | 9419–9420 | "**`checkpoint` and `restore!` exist on the `Model` and on the `Simulation`, and a `Checkpoint` is the `Model`'s state beside the run's cursor** (D-319)." | bold sentence, 22 words | D-319 Position log 13992–13996 | C; the whole sentence bold where "a `Checkpoint` is the `Model`'s state beside the run's cursor" would do |
| 593 | 9421–9423 | "`checkpoint(model)` returns the state alone, a `ModelState`. It holds the flat buffer, the `s` and `m` stores, the whole signal table, the guard priors, `t`, `t₀` and the fingerprint." | plain | D-319 bullet 1 log 13998–14000 | C (adjacent); "the fingerprint" here includes the deployment (F51) |
| 594 | 9423–9424 | "It is legal at `:consistent` with the clock on a grid top." | plain | D-319 bullet 2 log 14004–14005 | C (adjacent) |
| 595 | 9424–9425 | "`checkpoint(sim)` wraps that state with the run's frame index and boundary ordinal (D-274)." | plain, cites D-274 | D-319 bullet 3 log 14016–14018; D-274 only through its annotation log 11716–11721 | B: C by D-274 as annotated; D-319 is the entry whose Position states it |
| 596 | 9425–9426 | "It is a stopped-sim service, legal in `initialized` and `stopped` (§14)." | plain | D-274 bullet 2 log 11652–11653 | U; the refusal kind, `ServiceLifecycle`, unnamed |
| 597 | 9426–9429 | "It is refused wherever the executor is not at the rest a published frame top leaves (`CheckpointMidFrame`, Appendix C). That is after a `t*` stop, which leaves the clock mid-frame with the remainder abandoned" | plain | D-274 bullet 2 log 11653–11655; the kind's name: D-319 bullet 2 log 14007 (the model's door) | U |
| 598 | 9429 | "and after a frame abandoned unpublished (§12.4)." | plain | — | N; D-268's annotation log 11168–11172 rules the forced throw's disposition, not this refusal |
| 599 | 9430–9431 | "The test is that the clock sits on a grid time and that the latest snapshot is of that very boundary." | plain | — | N; `src/sim.jl` 636–652 implements it |
| 600 | 9431–9437 | "`restore!(model, model_state)` checks the state's fingerprint against the model. It also checks that the state's `t` is a grid time `t₀ + k·h` … collected into one throw before any write. The door then copies the state back, settles the restored boundary through the hooks and writes `:consistent` last (D-318)." | plain, cites D-318 | door shape: D-318 bullet 4 log 13936–13939; the checks: D-319 bullet 2 log 14008–14015 | B: C by D-318 for the shape, U by D-319 for the checks |
| 601 | 9437 | "`restore!(sim, cp)` takes the four recording keywords `init!` takes." | plain | D-319 bullet 3 log 14018, 14022 ("`kw…`", "recording … checks"); D-261 bullet 7 names only `init!` and `replay!` | B: U by D-319's implication; no Position names `restore!`'s keywords |
| 602 | 9438–9439 | "It checks the checkpoint's fingerprint against the simulation as replay checks the trace header, and a mismatch is `CheckpointMismatch` (§12.7)." | plain | D-274 bullet 3 log 11657; the kind's name: no entry rules the rename from `ReplayHeaderMismatch` (part E) | B: U for the check, N for the name |
| 603 | 9439–9441 | "It checks the state's `t` against its grid as the model's door does, collecting both kinds into one throw." | plain | D-319 bullet 3 log 14018–14019 | U |
| 604 | 9441–9445 | "It then copies the state back, opens a fresh run with the checkpoint as its trace header, and publishes one snapshot at the checkpoint's `t`. It runs no sweep … The next frame is the original lattice's next frame, because the clock came with the checkpoint." | plain | D-274 bullet 3 log 11657–11661; the header: D-217 annotation log 8250–8252 | U |
| 605 | 9445–9446 | "The boundary ordinal continues, being the trajectory's (§12.3, D-230)." | plain, cites D-230 | D-274 bullet 3 log 11661; D-230 Position says a new trajectory restarts it (log 8845) | B: U by D-274; the cited D-230 states the opposite case |
| 606 | 9446–9449 | "The snapshot `restore!` publishes is a re-publication. It carries the ordinal of the boundary the checkpoint was taken at, and the next frame publishes under the next ordinal" | plain | — | N; ran as stated (part C) |
| 607 | 9449–9451 | "`restore!(sim, model_state)` is the door a state prepared on a standalone model takes into a simulation (§9.2)." | plain | D-319 bullet 3 log 14020–14021 | U |
| 608 | 9451–9455 | "It takes the same keywords and makes the same fingerprint check, and it refuses a state whose `t` is off the grid as `CheckpointMidFrame`. It opens a fresh trajectory at the state's frame, and the restored boundary publishes under ordinal 0" | plain | D-319 bullet 3 log 14022–14029 | U |
| 609 | 9455–9456 | "A standalone model published nothing, so the trajectory has no ordinals to continue." | plain | D-319 Rationale log 14080–14083 | R |
| 610 | 9456–9458 | "A `Checkpoint` holds a `ModelState{Float64}`, so it is nominal by type. A state taken at another scalar is refused by dispatch with the same `CheckpointMismatch`, on either `restore!` that takes a bare state." | plain | D-319 bullets 1 and 4 log 14000–14003, 14030–14034 | U |
| 611 | 9460–9461 | "**Device attachments persist across re-initialization**, because attachment is orthogonal to the run lifecycle (§11.3)." | bold lead-in | D-088 Rationale log 2785–2786 | R |
| 612 | 9461–9464 | "Persistence means *roster* persistence. Binding, claims and device id survive. Tasks and OS resources do not (… §11.1; … §12.4)." | plain | D-093 Rationale log 2897–2899 | R; §12.4 8947–8953 states the same (part B) |
| 613 | 9464–9466 | "Each `run!` re-initializes every rostered device and spawns its task. `attach!` while stopped only registers, and the task appears at the next `run!`." | plain | D-093 Position log 2889–2893 | U |
| 614 | 9468–9470 | "**Task topology follows the roster each time** (§11.1). A front end attached by hand is still rostered, so the next `run!` spawns its task again." | bold lead-in, no D-citation | D-310 bullet 2 log 13222–13223; "roster-derived" is the shorthand D-109's annotation log 3489–3494 calls looser (D-109 superseded → D-310) | B: U by D-310 for the front-end clause; the bold clause is narrower than §11.1 6880–6882 (F53) |
| 615 | 9472–9476 | "**The stop policy is declared per advance.** `t_end` and `ignore_stop_requests` are keywords of `run!`, `replay!` and `step!`, and each call builds and validates the `StopPolicy` … (§13.5, D-255, D-316)." | bold sentence | D-255 bullets 4–5 log 10056–10063; D-316 bullet 6 log 13644–13646 | C; §13.5 10334–10349 states the same (part B) |
| 616 | 9476–9478 | "The value lives as long as the call, and afterwards only on the termination record of the advance that ended the run (D-260)." | plain, cites D-260 | D-260 bullet 3 log 10333–10335 | C |
| 617 | 9478–9480 | "A second run, or a `step!` sequence between two runs, can therefore stop on a different clock or honour a different set of stop requests without a rebuild." | plain | D-091 Rejected log 2860–2861 (D-091 superseded → D-255); D-255 Rejected log 10099–10100 | R |
| 618 | 9482 | "**`errored` is terminal** (D-059)." | bold lead-in | D-059 bullet 4 log 1840 | C; §14 11031 also bolds it (part B) |
| 619 | 9482–9483 | "Reproduction is trace replay (§12.7), not resurrection." | plain | D-059 Rejected log 1851–1852 | R |

Entries ruling §12.6 that it never cites: D-088 (rows 551, 553, 561–563;
R rows 567, 570, 573, 575, 581–584, 611), D-096 (576–580), D-093 (574, 612,
613), D-310 (566, 614), D-223 (552, 565), D-218 for the mode's Position (559,
560; cited only at 9417). D-319 is cited twice (9260, 9420) and rules seven
more rows uncited (595, 600, 601, 603, 607, 608, 610).

Descriptions that read like rules: row 560 ("State and mode are
orthogonal"), row 579 ("not step-scoped"), row 591 ("Nothing advances until
one of those doors is taken"), row 606 (the re-publication's ordinal) and row
599 (the mid-frame test). Rows 598, 599 and 606 are true of `src/` and state
behaviour no entry rules (part E).

Display-block candidates: the derivation table (557) is already one. The
field-ownership paragraph (9274–9293) is a list of nine owner statements in
prose; a two-column table (value → owner) would carry it. The doors could be
one short list: `init!` (authored condition, runs boundary zero),
`restore!(sim, cp)` (a checkpoint, continues the trajectory),
`restore!(sim, model_state)` (a standalone model's state, a fresh
trajectory), `replay!` (a recording's header and its feed). The two
`checkpoint`/`restore!` pairs are four signatures a reader would type.

Glossary terms in §12.6 (lesson 35):

| term | first use | linked there | use matches the entry |
|---|---|---|---|
| `Run` | 9243 | yes, no gloss (the sentence is its gloss) | yes (14264–14270) |
| trace | 9245 | yes, no gloss | yes |
| log | 9245 | no | yes; `g-log` exists |
| door | 9246 | no entry | three senses in the half (F62) |
| checkpoint | 9263 | yes, with gloss | the glossary (14333–14340) says "the fingerprint and the deployment", 9423 folds the deployment into "the fingerprint" (F51) |
| `Model` | 9275 | yes, with gloss | yes |
| control plane | 9276 | yes, no gloss | yes |
| deployment | 9277 | yes, with gloss | yes |
| executor | 9278 | yes, no gloss | yes |
| schedule | 9282 | yes, with gloss | yes |
| diagnostic cell | 9286 | yes, no gloss | yes |
| termination record | 9290 | yes, and linked again at 9408 | yes; the second link breaks one link per section |
| pacing | 9291 ("The pacer's schedule") | no | yes |
| boundary zero | 9302 | yes, gloss at 9305–9306 | yes; 9334 then links `g-boundary` on the word "boundary" inside "boundary zero" (F66) |
| store | 9302 ("stores allocated") | no | yes |
| input mode | 9324 | yes, no gloss | yes (14357–14362) |
| drain | 9327 | yes, and again at 9351 and 9371 | yes; three links in one section |
| frame | 9352 ("whole frames") | no | yes; `g-frame` is never linked in §12.6 |
| calling task | 9343 | yes, with gloss | yes |
| device | 9344 | yes, no gloss | yes |
| unattended run | 9346 | yes, defined in place | partly: the glossary (14320) adds "and no snapshot readers", and §11.1 6896 carries both halves |
| harness cell | 9373 | yes, linked again at 9383 with the gloss | yes; gloss and link belong at 9373 |
| harness writer | 9384 | no | yes |
| batch | 9375 | no | yes |
| replay | 9376 | yes, no gloss | yes |
| snapshot | 9380 | yes, no gloss | yes |
| seam | 9387 | yes | no: the glossary's seam (14603) is a thin named interface; this is the junction of `step!` and `run!` (F61) |
| edge semantics / holding | 9395 | yes | yes |
| stop request | 9395 | yes, no gloss | yes |
| recorders | 9410 | yes, no gloss | the entry (14368) says "cleared together", 9407 says "new objects rather than cleared ones" (F73) |
| staging cell | 9410 | yes, no gloss | yes |
| trace header | 9442 | no | yes |
| signal table, prior | 9422–9423 | no | yes |
| claim | 9462 | yes, no gloss | yes |
| roster | 9465 ("rostered") | no | yes |
| `StopPolicy` | 9474 | yes, with gloss | yes |

Appendix C kinds cited to §12.6, and whether the section names each where it
states the kind's condition (lesson 20):

- `MissingInit` (13301, cites §12.6 alone): not named. 9334–9336 states the
  condition as "an error in the kind set (§13.2) naming `init!`" (F58).
- `CheckpointMismatch` (13393): named at 9439 and 9458.
- `CheckpointMidFrame` (13412): named at 9427, 9434 and 9453.
- `ArgumentInvalid` (13428, cites §12.6 among six): not named anywhere in
  §12.6. Its §12.6 conditions are `step!`'s `frames`/`t_plus` exclusion
  (9355) and the doors' recording keywords (9246) (F59).
- `ServiceLifecycle` is not cited to §12.6 (13303 cites §11.3 and §14), but
  §12.6 states the conditions it covers for `checkpoint` (9425–9426) and,
  through "refuse under the ordinary lifecycle gates", for `live!` in §12.7.

### §12.7 Replay: the trace re-drives the ordinary loop (9485–9738, 2,331 words)
(§12.7 is another unit's; see the full survey.)

### Tally

| section | rules | C | U | S | R | N | B |
|---|---|---|---|---|---|---|---|
| §12.5 | 18 | 2 | 6 | 0 | 1 | 6 | 3 |
| §12.6 | 99 | 34 | 28 | 0 | 19 | 5 | 13 |
| §12.7 | 69 | 15 | 16 | 0 | 18 | 9 | 11 |
| total | 186 | 51 | 50 | 0 | 38 | 20 | 27 |

The count leaves out six rows that are code, a pointer, framing, a worked
example or a summary table (510, 511, 620, 624, 662, 690), and classes each
B row once. The 557 derivation table counts as one rule.

Over a quarter of the half's rules are cited where they stand (51 of 186),
against 20 of 186 in chapter 11's half 1, because §12.6's ownership
paragraphs cite densely. The U rows cluster in entries the half never cites:
D-088 (5 U rows, plus 9 R), D-128 (4, plus row 648), D-319 at four U rows
past its two citations, D-101's Position (3), D-096 (1, plus 3 R), D-223 (2),
D-310 (1, plus row 614), D-093 (1, plus row 574), and D-218's Position at
four rows outside the sentences that cite it (559, 642, 665, 671). The R rows
cluster in D-088's Rationale and Rejected list (9 rows) and D-101's
Rationale and Rejected list (7). No citation is to a superseded
entry. Row 614 rests on superseded D-109's annotation for its bold
shorthand, and row 617 on superseded D-091's Rejected list beside D-255's.

Bold weight now: 57 bold spans in the half, 265 words. Six are labels
(**Rule.** ×5, **Why.** ×1). Nine are bold state words or phrases (§12.6), and
five are bold terms (**placeholder run**, **harness cell**, **input mode**,
**frame ordinal**, **what-if replay**). About 30 are bold lead-ins acting as headings,
especially §12.7's bullet list, §12.6's "**Where the loop runs.**",
"**Partial advance.**" and "**Status, termination and the `run!` seam.**".

## B. Overlaps

### Inside the half

| topic | statements | note |
|---|---|---|
| the clock criterion (D-031) | §12.5 9179–9183 (bold), 9185–9186 (**Rule.**) | one ruling stated twice, once bold and once labelled; keep the bold sentence, fold the Rule into it (rows 502, 504) |
| `restore!` and `replay!` restore a checkpoint with no boundary zero | §12.6 9337–9339, 9406, 9441–9445; §12.7 9504–9510 | four statements; §12.6 9441–9445 is the full one for `restore!`, §12.7 9504–9510 for `replay!` |
| bit-identity of stepped frames | §12.6 9352–9353, 9371–9372, 9394 | three statements of one fact; keep the first, the other two become "so" clauses |
| `attach!` registers, the task appears at the next `run!` | §12.6 9367–9369, 9465–9466 | the second repeats the first |
| the input mode | §12.6 9324–9330 (D-260: read off the feed); §12.7 9526–9532 (D-218: the mode drives the one drain branch) | two rulings, two homes; both are fine as long as each bolds only its own |
| the doors' effect on the mode, and `live!` | §12.6 9412–9417; §12.7 9594–9613 | §12.7 is the full statement; §12.6 can keep one sentence and a pointer |
| `t_end` and `ignore_stop_requests` as keywords of `replay!` | §12.6 9472–9480; §12.7 9573–9579, 9717–9718 | three statements; §12.6 is the home within the half |
| the re-recorded trace "of itself" | §12.7 9627–9628, 9642–9645 | the worked example's sentence and the bullet say the same |
| the dispositions table | §12.7 9720–9729 against 9661–9718 | a summary of the prose above; it inherits F57 and F80 |

### With half 1 (§12.1–§12.4)

| topic | half 2 | half 1 | proposed home |
|---|---|---|---|
| what `Control` holds; `termination` belongs to the `Run` | §12.6 9285, 9288–9291 | §12.1 8621–8627 (bold, D-256, D-317), §12.4 8870–8871 | §12.1 for `Control`'s contents; §12.6 keeps the four-field ownership list with "`join_timeout` is `Control`'s (§12.1)" as is |
| `step!` never waits and is the harness mode | §12.6 9350–9354 (cites D-269) | §12.1 8664–8666 (inside the bold D-269 paragraph) | §12.6 for the stepping session; §12.1 keeps its clause, since it lists the verbs' callers |
| `replay!` takes `pace` and `margin` | §12.7 9650–9651 | §12.1 8661–8663 | §12.1 is the home; §12.7 keeps the playback clause with a pointer |
| what survives a stop, and the next run re-acquiring | §12.6 9460–9466 | §12.4 8947–8963 ("What survives the tail", "The next run re-acquires everything") | §12.4 for the tail's survivors; §12.6 keeps roster persistence across re-initialization in one sentence with a pointer (q24) |
| which devices get a task | §12.6 9468–9470 (bold, cites §11.1) | §12.4 9057–9060 (bold "Topology is derived after initialization", cites §11.1) | §11.1 6880–6882 is the rewritten home; both chapter 12 statements become pointers, and §12.6 keeps D-310's front-end clause (q24, F53) |
| the stop policy versus the stop word | §12.6 9472–9480 | §12.1 8617–8619 (bold, D-255) | different rulings; no change |
| the abandoned frame and `checkpoint` | §12.6 9426–9431 | §12.4 9144–9154 (the forced throw; "`checkpoint` refuses such a run … (§12.6)") | §12.4 for the disposition, §12.6 for the refusal; consistent |
| "resumable by the next `run!` (§12.6)" | §12.6 9403 (`stopped → init! → run!`) | §12.4 9054–9055, 9080 | the half-1 sentences contradict §12.6 and `src/` (F72) |
| the indices: ordinal, counter, frame-entry pointer | §12.7 9565–9573 | §12.3 8785–8796 (D-230) | §12.3 is the home; §12.7 must say which index `to_boundary` takes (F83) |
| the `t_plus` spelling | §12.6 9354–9357 | §12.4 8925–8927 ("the `t_plus` spelling (§12.6) applied to the run's own clock") | §12.6 is the home; the half-1 pointer holds |
| join cap invisible to replay | §12.7 (not stated; 9692–9713 lists the compared set) | §12.4 8942–8945 ("replay neither records nor compares it (§11.5, §12.7)") | holds while §12.7's compared set excludes it |

### With other chapters

**Part I.** Part I's restated chapter 2 states the run's semantics, and three
places in the half restate a Part I law at Part I depth:

- §12.5 9231–9233, "While a simulation runs, the periphery stages root-input
  writes and issues control commands. Structurally, it does nothing else."
  §2.2 339 ("Nothing outside the model writes its state, its modes or its
  outputs (§12.5, D-031)") and 359–361 ("Control commands are not inputs …
  They never change what a step computes") state the law. §12.5's share is
  the mechanism: the three-way classification and its spellings (9233–9236),
  and the elimination of `user_callback!`. The first two sentences of the
  final form can point at §2.2 and keep the classification.
- §12.6 9352–9353, "A stepped simulation is bit-identical to the same frames
  under `run!`". §2.4 563–570 lists "Splitting a run across several calls
  that each advance it" among what leaves a trajectory bit-identical, citing
  §12.6. §12.6 is the mechanism's home; it should keep the sentence as the
  spelling of that law and cite §2.4.
- §12.7 9499–9501 and 9689–9690, the identical-build promise and what-if's
  determinism. §2.4 572–576 states the law ("That promise holds only against
  the identical build running identical compiled code (§12.7, D-101)").
  §12.7's sentences are the mechanism's statement; one pointer to §2.4
  suffices at 9689.

§2.5 (580–604) excludes an unconditional per-step hook without naming
FlightCore's `f_step!`; §12.5 9211–9212 cites it correctly. §2.4 507 ("A run
may instead resume from a checkpoint … no boundary zero (§12.6, D-274)") is
consistent with §12.6.

**Chapter 9.** §9.2 4327–4338 bolds "A `Simulation` runs a `Model{Float64}`"
(D-317) and "A `Simulation` claims its `Model`" (D-318). §12.6 9279–9280
states the claim plain with a citation, which is right. §12.6 bolds D-317's
first bullet ("`Simulation` is a mutable struct of four fields") and its
sixth ("`lifecycle(sim)` derives the state"), which §9.2 does not.

**Chapter 10, rewritten.** §10.1 holds the frame's anatomy; §12.6 9351
restates "(drain, integrate, boundaries, publication)" as a gloss, which is
fine. §10.4 5961–5965 separates the frame-entry index, the ordinal and the
frame-indexed trace; §12.7 9572–9573 repeats it, and the rewritten §10.4 is
the home. §10.7's pacing invariance is cited, not restated, at 9647–9649.

**Chapter 11, rewritten.** For each overlap, the home the rewritten text
chose:

| topic | half 2 | chapter 11 | home chosen |
|---|---|---|---|
| the loop on the calling task; the synchronous rethrow; the unattended run | §12.6 9343–9348 | §11.1 6870–6878 (bold, D-310), 6894–6896 | §11.1. §12.6 becomes a pointer (M51) |
| device tasks per run; `attach!` never spawns | §12.6 9364–9369, 9463–9466 | §11.1 6865–6868 (bold, D-093) | §11.1 |
| which devices get a task | §12.6 9468–9470 | §11.1 6880–6882 (D-310, D-138) | §11.1 |
| `latest(sim)` as the calling task's read | §12.6 9379–9381 | §11.2 6917–6920 (cites §12.6) | §11.2 states it; §12.6 keeps the advance-assert idiom |
| replay-to-inspect | §12.7 9632–9634 | §11.2 6965–6967 (D-038) | §11.2; §12.7 keeps one clause with its pointer, as now |
| the harness writer: any task, drained, traced, surface-checked | §12.6 9372–9377 | §11.3 7255–7268 (D-096, D-200, D-174) | §11.3; §12.6 keeps the stepping use and points (M53) |
| roster persistence, the frozen roster | §12.6 9460–9466 | §11.3 7303–7357 | §11.3 for the freeze and identity; §12.6 for persistence across re-initialization |
| the levels doctrine | §12.5 9220 | §11.4 7429–7436 | §11.4; §12.5's clause is a pointer-sized use |
| the header's contents; what replay compares | §12.7 9504–9513, 9661–9665, 9692–9713 | §11.5 7713–7755 | §11.5 for the contents (it names "the fingerprint (the structural layout) and the deployment", 7719–7720, 7732–7733); §12.7 for the comparison. The naming conflict is F51 |
| the `:replay` cap | §12.7 9558–9561 | §11.5 7771–7773 (D-218) | §12.7; §11.5's clause is a pointer |
| GUI widgets read-only under a scenario component | §12.5 9205–9208 | §11.7 8214–8227 (bold, D-045), 8264–8267 | §11.7; §12.5's bullet is a pointer |

**Chapter 13, not rewritten.** §13.4 10183–10196 holds the reproduction
recipe (`replay!(sim2, trc; to_boundary = k)` then `step!`); §12.7 9534–9540
and 9634–9635 restate it, the second with the stale `k − 1` (F54). §13.5
10334–10349 states the per-advance policy in full, including "The value
lives as long as the call, and afterwards only on the termination record"
(10346–10349), which §12.6 9476–9478 repeats; §13.5 is the policy's home
(q25). §13.5 10400–10402 ("A `run!` in `:replay` is bounded by the
recording") agrees with §12.7 9558–9561.

**Chapter 14, not rewritten.** §14 11031 bolds "**`errored` is terminal for
every row**" (D-059, D-108); §12.6 9482 bolds "**`errored` is terminal**"
(D-059). One ruling, two bolds (D-059 bullet 4); the lifecycle section is the
natural home, and §14's sentence can keep its row-table reading plain when
chapter 14 is rewritten. §14.8 11947–11949 and Appendix B 12911–12913 say the
recorders are "cleared", where §12.6 9406–9408 says "new objects rather than
cleared ones" (F73).

## C. Proposed structure

No section is renumbered and none is retitled. 221 inbound rows point at the
half's sections (part D), and no file links a `####` anchor in the half (the
half has none), so `####` labels can be added freely.

### Moves

| move | content | from | to | needs a ruling |
|---|---|---|---|---|
| M51 | "Where the loop runs" (rows 566–569) | §12.6 9343–9348 | one sentence pointing at §11.1 6870–6878, keeping "Deviceless, `run!` is fully synchronous", which the stepping paragraphs lean on | yes, q23 |
| M52 | "`errored` is terminal" and its reason (rows 618–619) | §12.6 9482–9483, the section's last lines | up, into the lifecycle-states block, after the derivation table (9316–9322): the five states are defined there and "terminal" is used at 9301 | no |
| M53 | the harness write path (rows 576–580) | §12.6 9371–9385 | trimmed to the stepping session's use, `stage!` → `step!` → `latest`, with a pointer to §11.3 7255–7268 for what the harness writer is (any task, traced, surface-checked, D-096, D-200); "What it drains is the harness cell" scoped (F64) | yes, q23 |
| M54 | roster persistence and "Task topology follows the roster each time" (rows 611–614) | §12.6 9460–9470 | one paragraph: persistence across re-initialization (D-088, D-093), a pointer to §12.4 8947–8963 for what survives a stop and to §11.1 6880–6882 for which devices get a task, and D-310's front-end clause cited | yes, q24 |
| M55 | the per-advance stop policy (rows 615–617) | §12.6 9472–9480 | kept as the lifecycle's statement; 9476–9478, which §13.5 10346–10349 repeats word for word, becomes a pointer to §13.5 | yes, q25 |
| M56 | the `restore = false` form (rows 635–641) | §12.7 9542–9554, between the mode's **Why.** and the bullet list | down, after what-if replay (9681–9690): it "serves the what-if … (below)" and the seek, and its refusal names the clock arm of the validation pass, both defined later today | no |
| M57 | the validation pass (rows 673–676) | §12.7 9661–9679, the last bullet of "Everything else is the loop as already specified" | out of the bullet list, heading a "Validation up front" block with 9681–9729; validation is not the loop "as already specified" but replay's own entry pass | no |
| M58 | §12.6's order (part C, "Order") | the whole section | reordered under `####` labels, context first | yes, q22 |
| M59 | the clock criterion's **Rule.** (row 504) | §12.5 9185–9186 | folded into the bold sentence at 9179–9181, which already states the ruling (D-031) | no |
| M60 | "The drain then reads the trace." (row 624) | §12.7 9507 | dropped: the next bullet's lead-in says it | no |
| M61 | the overlaps with half 1 and other chapters (part B tables) | — | each kept in its home with a pointer at the other | yes, q23–q25, ruled with half 1's matching question |

All moves stay inside one section, so each stays inside one unit. M53 and M54
trim §12.6 toward text chapter 11 and half 1 already hold; M61's half-1
pointers belong to the sibling's units.

### Order within each section

Define-before-use was checked for each order below against the terms each
block uses.

- **§12.5.** Add a context paragraph: the question the section answers
  (what may touch a running model, and where each FlightCore mutation goes),
  ending with one sentence naming the parts. Then, unchanged in order: the
  consumer survey (9171–9177, recast as FlightCore's with the reader-cold
  names introduced, q27); the clock criterion (M59); the scenario mapping
  and its comparison (9188–9208); `user_callback!` eliminated (9210–9214);
  manual events (9216–9221); no mid-run re-initialization (9223–9229); the
  final form (9231–9239), its first two sentences pointing at §2.2 (part B).
  547 words need no `####` labels. "Scenario component" is glossed at
  9180 and used after; "guarded addition" (9226) needs its link and gloss.
- **§12.6 (q22).** The section has no context and opens on `Run`, which uses
  "door" (9246), "`feed`", "`replay!`", "`live!`" and "the halt at a
  recording's end" (9250–9254) before any of them is introduced, and the
  `Model` status (9311) only after the fields paragraph. Proposed:
  1. Context (new): a `Simulation` moves through five states; a *door*
     builds a run (`init!`, `restore!`, `replay!`), an *advance* moves it
     (`run!`, `step!`, `replay!`); names the parts. "Door" gets its one
     definition here (F62).
  2. `#### What a simulation holds`: the four fields and their owners
     (9274–9293), the ownership rule (9295–9298). Uses `Model`, run (glossed
     with a pointer to the next block), plane, control plane, all glossed.
  3. `#### The run`: `Run` (9243–9265), the placeholder (9267–9272).
     `feed` is glossed as "the recording `replay!` attached".
  4. `#### Lifecycle states`: the five states (9300–9307), the derivation
     (9309–9322; the `Model` status is defined in block 2), `init!` mandatory
     (9332–9341), `errored` terminal (M52).
  5. `#### Doors, re-running and the input mode`: re-running and the warm
     restart (9403–9417), the input mode (9324–9330), the per-advance stop
     policy (9472–9480, M55). The mode uses `feed` from block 3.
  6. `#### Partial advance`: the loop's placement as a pointer (M51), then
     9350–9401 with M53. Uses the states (block 4) and the stop policy
     (block 5).
  7. `#### Checkpoints and the warm restart`: 9419–9458. Uses the run's
     counters (block 3) and the doors (blocks 1, 5).
  8. `#### Device attachments across runs`: M54.

  A lighter alternative keeps today's order, adds the context paragraph and
  `####` labels at the existing breaks (`Run` and `Simulation`, states and
  mode, partial advance, re-running and checkpoints, attachments and
  policy), and moves only M52. It leaves "door", "`feed`" and "`live!`" used
  before the context defines them, unless the context paragraph introduces
  all three, which it can.
- **§12.7.** One framing sentence and the code block (9487–9497), extended
  to say what the section covers. Then `####` labels:
  1. `#### One substitution`: 9499–9524 less M60, then the mode's rule and
     reason (9526–9540).
  2. `#### Halting, and the mode across halts`: the termination bullet
     (9558–9579), `to_time` (9580–9593), the flip (9594–9601), `live!` and
     the rewrite workflow (9602–9628), replay ends `initialized`
     (9629–9641). The bullets become paragraphs; the nested code block
     (9618–9625) then sits at top level.
  3. `#### What stays the loop's`: re-records (9642–9645), pacing
     (9646–9652), devices as readers (9653–9660).
  4. `#### Validation up front` (M57): 9661–9679, the structural/parametric
     line (9681), the deployment comparison (9692–9713), the clock
     (9715–9718), the table (9720–9729).
  5. `#### What-if replay and \`restore = false\``: 9681–9690 less the
     line, then M56 (9542–9554).
  6. The rejected shapes (9731–9735).

  Define-before-use: block 2 uses "`restore = false`" at 9564 before block
  5; one gloss there ("the form that feeds a simulation as it stands, below")
  covers it. Block 4's "the *structural* side of that line" (9696) follows
  9681 in the same block. Block 5's `restore = false` refusal names
  `CheckpointMismatch`'s clock arm, defined in block 4.

### Rewrite units

| unit | lines (original) | moves in | moves out | words |
|---|---|---|---|---|
| F | 9169–9484: §12.5 and §12.6 | — | M51, M53, M54, M55 (trims) | 2,770 |
| G | 9485–9738: §12.7 (the closing `---` 9737 included) | — | — | 2,331 |

Total 5,101 words. H is unused.

The split is clean: no move crosses it, and §12.7 cites §12.6 only
backward (9509, 9575, 9596, 9611, 9631). G sits just under the 2,500 floor;
the alternative, F = §12.5 alone (547) and G = §12.6 and §12.7 (4,554), puts
one unit far below and one far above. A three-way split (§12.5 + the first
half of §12.6; the rest of §12.6; §12.7) has no clean seam in §12.6 under
today's order, which q22 would reorder anyway. Recommendation: F and G as
above (q30).

### Code blocks, charts and tables

The half holds two code blocks, two tables and one inline definition:

- 9203, inline: `y_direct(c, (; t)) = (; offset = profile(t))`, the
  timetable one-liner. A display candidate (part A).
- 9316–9322: the lifecycle derivation table, five rows. Carry verbatim.
- 9489–9497: the replay entry points, a `julia` fence, seven calls with
  trailing comments. Carry verbatim; a comment edit is a ruled edit.
- 9618–9625: the rewrite workflow, a `julia` fence indented two spaces
  inside a list item. If the bullet list dissolves (part C, §12.7 block 2),
  the fence moves to top level; its lines stay verbatim and the indent goes.
- 9722–9729: the dispositions table, six rows. Two rows change under F57
  (scoped to the default form) and one under F80, if ruled.

Inline math: `t₀ + k·h` (9433), `k = ⌊(to_time − t₀)/h⌋` (9582), plain text.

New display blocks (part A candidates): the three-way classification
(§12.5), the field-ownership table and the doors list (§12.6), the what-if
and the seek spellings (§12.7). Each is an addition the inventory declares.

### Running the half's code

Loaded with `test/repl.jl` inside `module H2Check` (script
`scratch_survey/h2/run/blocks.jl`, run with `julia --project=test -t 2`;
every check behaved as noted). The model is three root inputs into a `Sum`
and a `Gain` at `h = 1//1`; a float `h` is refused by the `Deployment`
(`DeploymentInvalid`: "`h` must be exact"), so `h` is rational throughout.

- **9489–9497, the entry points: ran and passed**, with `world` and `k`
  supplied. A 20-frame session with six staged batches: `replay!(sim2,
  trc)` ends `initialized`, `:live`, frame 20, its table bit-identical to
  the original's. `to_boundary = 7` halts at frame 7 in `:replay`, and a
  following `step!(sim2; frames = 100)` returns 13 and leaves `:live` at
  frame 20 (the truncation of 9397–9401 and the flip of 9596–9599).
  `to_time = 7.5` halts at frame 7 (the floor). `restore!(sim2, cp)` of a
  checkpoint at frame 20 publishes ordinal 20 and the next frame ordinal 21,
  the original's (rows 604–606). Refusals, all `ArgumentInvalid`: `to_time
  = 25.0` and `to_boundary = 25` past a 20-frame recording, both keywords
  together.
- **9618–9625, the rewrite workflow: ran and passed**, with the interrupt
  at t = 110 replaced by 110 stepped frames. `replay!(s2, trc;
  to_time = 100.0)` lands at t = 100.0 in `:replay`; `live!` gives `:live`;
  `run!(s2; t_end = 130.0)` ends `stopped` at t = 130.0 with a 130-frame
  trace whose header is frame 0, and the trace's batches up to frame 100
  are exactly the recording's (9627–9628).
- **9203, the timetable one-liner: ran and passed** as a stateless discrete
  leaf (`s_init(::Timetable) = (;)`, `y_types = (offset = Float64,)`,
  `profile(t) = 2t`): at t = 1.5 the published `offset` is 3.0. A discrete
  leaf's `y_direct` bundle does carry `t`.
- **9316–9322, the derivation table: passed** at the rows exercised:
  `built` before `init!`, `initialized` between `step!` calls, `stopped`
  after a `t_end` inside `step!`.
- Other claims checked: `run!` and `step!` on `built` raise `MissingInit`
  (row 562); `step!` with both `frames` and `t_plus` raises
  `ArgumentInvalid` (F59); `step!(sim; t_plus = 2.5)` from t = 0 advances 3
  frames; `step!(sim; frames = 10, t_end = 5.0)` from t = 3 returns 2 and
  leaves `stopped` (rows 582–583); `live!` on `stopped` raises
  `ServiceLifecycle` and on `:live` raises `ArgumentInvalid` (F59);
  `restore!(sim, model_state)` of a frame-3 state opens frame 3, publishes
  ordinal 0 and reads 1 after (row 608); `init!` and `restore!` both return
  a replaying simulation to `:live` (row 589); `restore!` drops a staged
  batch (row 588); `replay!(…; restore = false)` on `built` raises
  `MissingInit` (F56), off `t₀` raises `CheckpointMismatch` (the clock arm),
  and a `to_boundary` before the simulation's frame raises `ArgumentInvalid`
  (row 644); a replay at a different `h` raises `CheckpointMismatch` for
  `Δt_base` and `h` (row 685); `replay!(s, trc; t_end = 5.0)` ends
  **`stopped`**, mode still `:replay` (F55); a batch staged in `:replay` is
  discarded (row 671); `run!` in `:replay` with `t_end` past the recording
  halts at its last frame, `initialized` and `:live` (row 658); a replay to
  frame 50 leaves a trace with header frame 0 and length 50 (row 666).
- **`to_boundary` against the ordinal** (`scratch_survey/h2/run/tstar.jl`):
  a `Bouncer(1.0, 0.35)` at `h = 1//10`, 20 frames, ends at frame 20 with
  ordinal 23 (three `t*` publications). `replay!(s2, trc; to_boundary = 10)`
  halts at frame 10, t = 1.0, whose snapshot carries ordinal 11. So `k` counts
  frame tops, §13.4's frame-entry index, and not the published-boundary
  ordinal a snapshot carries (F83).

## D. Inbound citations

The rows analysed are the 221 rows of `inbound.tsv` whose target is §12.5,
§12.6 or §12.7 (copied to `scratch_survey/h2/mine.tsv`). Rows whose target is
bare §12 (eight) are the sibling's, since the opening is in half 1.

By file: `decisions.md` 98 (Spec 53, Rationale 18, Position 13, Rejected 13,
Annotation 1), `spec.md` 96, `implementation.md` 21,
`inbound_periphery_walkthrough.md` 4, `linearization_walkthrough.md` 1,
`flight_case_studies.md` 1. The 96 `spec.md` rows: Part I 7, Part II 3, Part
III outside chapter 12 27, Part IV 17, Appendix B 19, Appendix C 9, the
glossary 14.

By target: §12.5 15, §12.6 129, §12.7 77 (in `spec.md` alone: 5, 59, 32).

Ranges recorded at their ends only: `implementation.md` 827 ("§12.1–§12.7")
also covers §12.5 and §12.6. `implementation.md` 318 ("§12.1–§12.4, §12.6")
and 449 ("§12.1–§12.4") reach no section of this half between their ends.

Citations from half 1 into this half are not in `inbound.tsv` (it skips the
chapter): §12.1 8624, 8626, 8665; §12.4 8925, 8945, 9054, 9080, 9153, 9154.
Each is listed in part B where it bears on a move.

### Citations relying on moved or trimmed content

M51, "Where the loop runs" (§12.6 9343–9348):

| file:line | fact relied on | after M51 |
|---|---|---|
| log 11153–11154 (D-268 Rationale) | "§12.6 defines the unattended run as the deviceless one" | holds if §12.6 keeps "Deviceless, `run!` is fully synchronous" and the unattended-run pointer; M51 keeps both |
| spec 6866–6867 (§11.1) | "§12.4 joins them all at every stop (§12.6)" | relies on 9463–9464 (tasks do not survive), not on 9343–9348; holds under M54 if that clause stays |

M53, the harness paragraphs (§12.6 9371–9385):

| file:line | fact relied on | after M53 |
|---|---|---|
| spec 7257 (§11.3) | the harness writer is "the harness/REPL write path (§12.6, D-096)" | holds: M53 keeps the stepping use |
| spec 12993, 12998, 13001 (Appendix B, `stage!` and `latest`) | `latest` and `stage!` as the harness and REPL accessors; "legal under `run!` and `step!` alike" | holds if §12.6 keeps "Both entry points work under `run!` too" (9382) |
| spec 14217–14226 (glossary, harness cell and harness writer) | the cell drained last by convention, "any task" (§12.6, §11.3) | §11.3 7278 now holds "drains last"; §12.6 never said it. The cell entry should cite §11.3 first (track 2) |
| log 3006 (D-096 Position), 3895 and 3915 (D-122) | §12.6 as the harness writer's home and the "harness cell" rename | historical; §11.3 is the home since chapter 11 |
| `inbound_periphery_walkthrough.md` 5, 197 | §12.6 for the harness cell, "the design's one derived surface" | the derived surface is §11.3's (7262–7265); retarget in track 2 |

M54, attachments and topology (§12.6 9460–9470):

| file:line | fact relied on | after M54 |
|---|---|---|
| spec 7337 (§11.3) | a device id lives "across runs (roster persistence, §12.6)" | holds; M54 keeps the persistence sentence |
| log 3494 (D-109 annotation, superseded entry) | §12.6's "roster-derived" shorthand | historical |
| log 2889 (D-093 Position) | device tasks per run (§12.6) | holds |

M55, the stop policy (§12.6 9472–9480):

| file:line | fact relied on | after M55 |
|---|---|---|
| spec 10348 (§13.5) | the value lives on the termination record "(§12.6, D-260)" | if §12.6's sentence becomes a pointer to §13.5, this citation points back at a pointer; §13.5 should then drop its §12.6 citation (chapter 13's rewrite) |
| spec 10420–10422 (§13.5) | "The `stopped → init! → run!` cycle and the `step!` idiom (§12.6) are precisely where one `Simulation` wants different stopping policies" | holds |
| log 2851, 2860 (D-091, superseded) | the per-run override at `run!` | historical |
| log 10360 (D-260 Rationale) | a stepped and a run simulation are bit-identical "whatever each call declared (§12.6)" | holds (9352–9353) |

M52, M56, M57, M59 and M60 move text within their sections; no row names the
moved sentences by position. Two rows rely on sentences a ruling might cut:

- log 7334 (D-195 Rationale): "`Model.s`, which §12.5's consumer survey
  already quotes as `x`/`s`" relies on 9176. If q27 moves the survey's
  FlightCore detail out, the `x`/`s` clause must stay in §12.5.
- log 3525 (D-110 Rationale) and spec 11947–11949 (§14.8): "the §12.6
  three-item clear (trace, log, staged batches)" relies on 9406–9411.

### Citations already wrong before the rewrite

| file:line | claim | what half 2 says |
|---|---|---|
| spec 9054–9055, 9080 (§12.4, half 1) | a stopped simulation is "resumable by the next `run!` (§12.6)" | §12.6 9403: the re-run is `stopped → init! → run!`; `run!` on `stopped` raises `ServiceLifecycle` (F72) |
| spec 11947–11949 (§14.8), 12911–12913 (Appendix B), 14368–14370 (glossary, recorders) | the recorders are "cleared exactly as §12.6 states" | §12.6 9406–9408: "new objects rather than cleared ones" (F73) |
| spec 12762 (Appendix B, `restore!(model, …)`) | "It takes no status gate (§12.6)" | §12.6 never says it; D-319 bullet 2 log 14015 does. Cite D-319 |
| spec 14333–14340 (glossary, checkpoint), 14372–14376 (glossary, replay) | the checkpoint holds "the fingerprint and the deployment"; replay validates "the checkpoint's fingerprint (stores, root-input faces and the `Deployment`)" | the two entries disagree with each other and with §11.5 7719–7720 (F51) |
| spec 13301–13302 (Appendix C, `MissingInit`) | payload: "the entry point called (`run!`/`step!`)" | `src/sim.jl` 401–405 raises it for `replay!(…; restore = false)` and `live!` too (ran) |
| spec 13428–13439 (Appendix C, `ArgumentInvalid`) | the call list omits `live!`; the row does not cite §12.7 | `live!` on `:live` raises `ArgumentInvalid` `:not_replaying`; §12.7 9565 names the kind (F59) |
| spec 13303–13306 (Appendix C, `ServiceLifecycle`) | the operation list omits `step!`, `run!`, `replay!`, `live!` | `src/sim.jl` raises it for each (401–411, 928–931) |
| log 9696–9697 (D-249 Position bullet 4) | "`StopFaceInvalid`'s binding site is one of three, the constructor, `run!` or `replay!` … (§12.7)" | D-316 retired `StopFaceInvalid` (log 13666) and D-255 removed the constructor's binding; no annotation on D-249 |
| log 8554 (D-223 Position) | a throw inside boundary zero "under `init!` or `replay!`" | §12.6 9339 and D-274 bullet 4: only `init!` runs boundary zero |
| log 3155–3159 (D-101 Position), 8292–8293 (D-218 Rationale) | replay is the loop "with exactly two substitutions" | §12.7 9499: one, since D-274 bullet 4 log 11665–11666; no annotation on D-101 |
| log 3173, 4062, 8223–8225 (D-101 Rationale, D-127 Position, D-217 bullets 4–5) | the header kind `ReplayHeaderMismatch` | §12.6 9439 and §12.7 9671 say `CheckpointMismatch`; no entry rules the rename (part E) |
| `inbound_periphery_walkthrough.md` 197 | §12.6 for "the design's one derived surface" | §11.3 7262–7265 holds it; §12.6 does not say it |

### Log entries whose Spec field would change

- Under M51, M53, M54, M55: none required. D-310, D-096, D-093 and D-088
  already list §12.6; D-255 and D-316 list both §12.6 and §13.5.
- Under F58 (naming `MissingInit` in §12.6): no entry names the kind in a
  Position; D-108 names it only in its Rejected list (log 3453), and D-108's
  Spec field (§11.3, §13.6, §14) lacks §12.6.
- Under F83 (naming the frame-entry index at `to_boundary`): D-128 already
  lists §12.7.

Spec fields stale before any move, entries that rule half 2 without listing
its section (track 2): D-200 (lacks §12.6; rules "from any task" at 9374),
D-310 (lists §12.6; fine), D-127 (lists §12.7; fine), D-319 (lists §12.6,
lacks §12.7, whose `restore = false` header and validation use its state
split), D-261 (lists §12.6; its bullet 7 names `init!` and `replay!` only,
not `restore!`), D-108 (lacks §12.6 and §12.7, where `checkpoint`'s and
`live!`'s lifecycle gates are stated), D-045 (lacks §12.5; rules 9220),
D-060 (lacks §12.5; rules 9238–9239).

## E. Log repairs and factual problems

Log repairs go to the second track, after landing. The rewrite only adds
citations; it states no repair. Factual problems stay as written and go to
the units' `rulings.md`, unless part G pre-rules them.

### Entries to cite at the rule

From part A's U rows: D-031 (rows 504, 513, 515, 516, 518, 519; cited today
only at 9183 and 9210), D-045 (514), D-316 and D-060 (520), D-260 (531, 533,
547), D-255 (537, 587), D-256 and D-254 (543–546, 683), D-088 (551, 553,
561–563; cited nowhere in the chapter), D-223 (552, 565), D-218 (559, 560,
642, 665, 670, 671), D-274 (526, 565, 587, 596, 597, 602, 604, 605, 621–623,
625, 635), D-310 (566, 614), D-022 (568), D-093 (574, 613), D-096 (576;
cited nowhere in the chapter), D-319 (600, 601, 603, 607, 608, 610), D-101's
Position (628–630), D-128 (643, 645–647; cited nowhere in the chapter), D-230
(648), D-255 and D-316 (649, 651), D-217 (674, 675), D-176 (676), D-127 (685,
688), D-133's annotation (683, for `firing_budget`).

### Superseded and half-superseded citations

- No citation in the half is to an entry whose status reads superseded.
- **D-255** (cited 9243, 9269, 9476): its first bullet, the `Run` shape, is
  superseded by D-260 (log 10346), and its placeholder clause still reads
  "`t₀ = zero(T)`, `mode = :live`, empty log and trace" (log 10043–10045),
  which D-260 and D-261 replaced. D-255 carries no annotation pointing to
  D-260. The clauses cited stand: the run as typed state (9243), the
  placeholder's existence (9269), the per-advance policy (9476).
- **D-260** (cited 9243, 9290, 9326, 9478): its four-field `Run` is
  superseded by D-317 (log 13823), and D-260 carries no annotation saying so.
  The clauses cited stand.
- **D-256** (cited 9281): its five-field roster is superseded by D-317; its
  annotation (log 10161–10165) records it, so "one of the four" reads true
  through the annotation.
- **D-274** (cited 9339, 9405, 9425, 9513, 9554, 9688): amended by D-319
  (annotation log 11716–11721). 9425 cites D-274 for the wrap of the state
  with the counters, which D-319 bullet 3 states (F69).
- **D-230** (cited 9446): its Position says "a new trajectory restarts" the
  ordinal (log 8845); 9446 cites it for the ordinal *continuing* under
  `restore!`, which D-274 bullet 3 rules (F70).
- **D-101** (cited 9731): its Position's "exactly two substitutions" was
  reduced to one by D-274 bullet 4 (log 11665–11666), with no annotation on
  D-101. The Rejected list cited stands.
- **D-091** and **D-109** (superseded, uncited) underlie rows 617 and 614.
  **D-107** (superseded in part by D-176, uncited) underlies row 674.

### Rulings that need an entry stating them in a Position

1. `step!`'s contract: synchronous whole-frame advance, bit-identical to
   `run!`, `initialized` between calls, `run!` may follow, the stop policy
   honoured inside a call, the return of frames actually advanced, the
   `stopped → init! → run!` re-run, attachments persisting across it (rows
   567, 570, 575, 581–584, 611): D-088 Rationale log 2782–2791. D-088's
   Position states only the five states and the mandatory `init!`.
2. The `t_plus` spelling (572) and `latest(sim)` as the read half (577,
   578): D-096 Rationale log 3015–3020.
3. A stepping session deviceless by construction (574) and what persists
   across runs (612): D-093 Rationale log 2897–2899, 2908–2910.
4. Replay's properties: ends `initialized`, re-records under the inherited
   header, pacing and control unchanged, devices as readers, validation up
   front, the reverse conversion off the loop, structural versus parametric,
   what-if, determinism promised only (rows 663, 664, 666, 667, 670, 673,
   676–678, 680): D-101 Rationale log 3163–3178, one long sentence of
   rulings.
5. The mode outliving the call, one loop and one drain (633, 634), no
   mid-run flip (657): D-218 Rationale and Rejected.
6. `live!` leaving the inherited header and appending (660), `to_time`'s
   rounding against `t_end`'s (653): D-219 Rationale and Rejected.
7. Nothing applied twice at `t₀` (627) and the seek (641): D-274 Rationale
   log 11708–11714.
8. The deployment comparison as one expression (687): D-254 Rationale log
   10006–10009. The event trio compared (686): D-133 Rationale log
   4327–4330.
9. A recorded stop request reproducing itself (650): D-127 Rejected log
   4081–4082.
10. The trace frame-indexed, boundaries the reporting index (648): D-128
    Rationale log 4108–4109, whose "boundary counter" is D-230's ordinal now.
11. A standalone model has no ordinals to continue (609): D-319 Rationale
    log 14080–14083.
12. The placeholder preferred to `nothing` (535) and a second run stopping
    differently without a rebuild (617): D-255 Rationale and Rejected; D-091
    Rejected (superseded).
13. A run's recording as its door's declaration (524): D-261 Rationale log
    10500–10503.
14. Reproduction is replay, not resurrection (619): D-059 Rejected log
    1851–1852.
15. Harness and REPL modes are not scripts (573): D-088 Rejected log
    2794–2795. The inspection accessor against closure termination (580):
    D-096 Rejected log 3036–3037.
16. Scripts replayed by recomputation, devices from the trace (506), and
    the mapping to devices rejected (503): D-031 Rejected log 1069–1071; the
    doctrine's "final form" (518): D-106 Rationale log 3364–3365.

### Rulings with no entry at all

- `replay!(sim, trc; restore = false)`: the keyword, its preconditions
  (`initialized`, the recording's `t₀`, a frame from the header's to one
  short of the last), its refusal kind, the drain from the frame after the
  simulation's own, the run and header it builds, "one grid is an invariant
  of every replay", and the validation pass running under both forms (rows
  635–639, 675). D-274 bullet 5 states the what-if's shape only. The form
  entered with commit `75911b9` and its clock arm with `7203798`, neither
  with an entry.
- The halt's range refusals, the frame forms of `to_boundary` and `to_time`
  (644).
- The re-publication's ordinal under `restore!` (606).
- `checkpoint(sim)` refused after an abandoned frame, and the test that
  decides it (598, 599).
- `restore!` clearing staged batches and returning the mode to `:live`
  (588, 589); D-218 bullet 3 names `init!` and `replay!` only.
- `restore!(sim, cp)` taking the four recording keywords (601); D-261 bullet 7
  names `init!` and `replay!`, and D-319 implies it.
- The rename of `ReplayHeaderMismatch` to `CheckpointMismatch` (602, 675,
  685). D-319 uses the new name without ruling it.
- The schedule compared with every column, a rate re-declared through a
  different anchor refused (684), argued in the spec with its rejected
  alternative.
- "The harness cell … is not step-scoped" (579); "State and mode are
  orthogonal" (560); "Nothing advances until one of those doors is taken"
  (591); the six-field count (522); "strictly richer" (507); the mid-run
  intervention command's shape (517), which D-031's Position says is "on
  record" though no entry records it.
- Descriptions with no entry, needing none: rows 501, 505, 509, 626,
  669, 672.

### Stale entry text and Spec fields

- D-031 Position (log 1060): "manual events = slot + guard" uses "slot" for
  root input (D-206's vocabulary); "shape on record" records no shape.
- D-088 Position (log 2778): `UninitializedSlots`, now `UninitializedInputs`.
  Rationale (log 2784–2791): "trace *and* log cleared at `init!`" (fresh
  objects since D-255), "`t_end`/`stop_on`" (D-316), "re-bindable per run at
  `run!` (D-091)" (superseded). No annotation.
- D-101 Position and Rationale (log 3155–3178): two substitutions, a header
  taken before boundary zero, boundary zero re-executed under replay,
  `ReplayHeaderMismatch`, "the interactive writer's sparse records", "the
  header's schemas". D-274, D-176, D-174 and D-255 each moved one; D-101
  carries no annotation.
- D-110 Rationale (log 3518–3519): "resume-at-time spelled explicitly via
  `capture`'s returned `t`"; `capture`'s condition form retired with D-273.
- D-127 Position (log 4057–4068): `ReplayHeaderMismatch`, `n`,
  `event_budget`, and "`t₀` applied rather than compared", which
  `restore = false` contradicts (F57). Its annotation covers the policy only.
- D-128 Rationale (log 4108): "The boundary counter stays the reporting
  index"; since D-230 the reporting index is the published-boundary ordinal.
- D-217 bullets 4–5 (log 8222–8225): `ReplayHeaderMismatch`.
- D-218 bullet 3 (log 8284–8285): `restore!` missing from the doors that
  reset the mode; Rationale (log 8292–8293): "two substitutions".
- D-223 Position (log 8554): "under `init!` or `replay!`"; only `init!` runs
  boundary zero since D-274.
- D-249 bullet 4 (log 9696–9697): `StopFaceInvalid` at the constructor,
  `run!` or `replay!`; retired by D-316, no annotation.
- D-255 bullet 1 and the placeholder clause (log 10038–10045): the old `Run`
  and placeholder, with no annotation pointing to D-260.
- D-260 bullet 1 (log 10324): the four-field `Run`, with no annotation
  pointing to D-317.
- D-261 bullet 7 (log 10442–10444): the recording keywords on `init!` and
  `replay!` only; `Simulation(deployment, T)` keeping `chunk_size`, which
  D-317 moved to the `Model` (log 13823–13825).
- D-274 bullet 2 and Spec field (log 11652, 11691): `checkpoint(sim)` "is a
  stopped-sim service (§13.7)". §13.7 is "Tooling consequences: face routes
  and the component library" (spec 10577); the services are §14. A citation
  left by a renumbering.
- Spec fields lacking a half-2 section they rule: D-200 (§12.6, 9374),
  D-319 (§12.7, the `restore = false` header), D-108 (§12.6 and §12.7, the
  `checkpoint` and `live!` gates, and the only entry that names
  `MissingInit`, in its Rejected list log 3453), D-045 (§12.5, 9220), D-060
  (§12.5, 9238–9239).

### Factual problems in half 2

No finding in this half is marked serious. Each has a Position, a later
entry or the code that settles it. F55 is the closest call; D-218 bullet 2
and §12.7's own 9573–9575 settle it.

- **F51. "The fingerprint", three ways.** §11.5 7719–7720 and 7732–7733
  (rewritten): "the fingerprint (the structural layout) and the deployment",
  two parts. `src/checkpoint.jl` 9–27 and 46–56: `Fingerprint` is the layout
  alone, and `ModelState` holds `deployment` and `layout::Fingerprint` as two
  fields. §12.6 9423 lists the state's contents as "`t`, `t₀` and the
  fingerprint", folding the deployment in; 9432, 9438 and 9452 say "checks
  the fingerprint" where `src/model.jl` 576–615 checks both parts. §12.7
  9661–9663 says "the checkpoint's fingerprint is validated against the
  target, its layout against the `Build`", splitting the fingerprint *from*
  the layout. The glossary disagrees with itself: checkpoint (14339) "the
  fingerprint and the deployment", replay (14375) "the checkpoint's
  fingerprint (stores, root-input faces and the `Deployment`)". D-274 bullet
  1 (log 11647) reads "the fingerprint, the deployment and the structural
  layout". Carried from chapter 11 (R17). Proposed correction: §11.5's
  naming throughout the half: 9423 "…, `t`, `t₀`, the fingerprint (the
  structural layout) and the deployment"; 9432 and 9438 "checks the state's
  fingerprint and deployment against …"; 9661–9663 "the checkpoint's
  deployment is compared against the target's, and its fingerprint against
  the `Build`". The glossary follows in track 2.
- **F52. "On the *structural* side of that line (§11.5)".** 9696. §11.5
  (7653–7800) draws no structural/parametric line; the line is §12.7 9681,
  four lines earlier. Carried from chapter 11. Proposed correction: drop the
  §11.5 pointer; "that line" then refers back to 9681, which M57 keeps in
  the same block.
- **F53. "Task topology follows the roster each time (§11.1)".** 9468.
  Bold, no D-citation. §11.1 6880–6882 says which devices get a task "is
  decided after initialization, from the frozen roster and the outcomes of
  device `init!` (D-310, D-138)", so "follows the roster" is the shorthand
  D-109's annotation (log 3489–3494) calls looser. §11.1 still uses
  "Task topology" in plane 5 (6845), so the carried note's "no longer says
  topology" is half true: the word is there, the derivation sentence is
  gone. The paragraph's second sentence is D-310 bullet 2 (log
  13222–13223), stated nowhere else in the spec. Proposed correction: M54;
  the front-end clause cited to D-310, and the topology clause a plain
  pointer to §11.1.
- **F54. "Error reproduction replays to `k − 1`".** 9634–9635. D-128
  Rejected (log 4112–4114) rejects "Last-published-boundary as the cursor
  pointer with a `k − 1` recipe"; §13.4 10186–10196 names the frame-entry
  boundary `k` and replays `to_boundary = k`, then `step!`. The `k − 1` is
  D-101 Rationale's (log 3168), from before D-128. Proposed correction:
  "Error reproduction replays to the frame-entry boundary `k` the error
  names, then `step!`s the failing frame under instrumentation (§13.4)."
- **F55. "Replay ends `initialized`, never `stopped`."** 9629, bold.
  `replay!(s, trc; t_end = 5.0)` on a 110-frame recording ended `stopped`
  (ran, part C); `src/sim.jl` replay! docstring: "A §13.5 source firing
  first ends it `stopped` like any run". §12.7 9573–9575 says the same. D-218
  bullet 2 (log 8280–8282) scopes the promise: "the halt leaves the
  simulation `initialized`". D-101's rejected "Replay ending `stopped`" is
  the budget halt. Proposed correction: "**A replay that exhausts its frame
  budget ends `initialized`, never `stopped`.**"
- **F56. The `restore = false` refusal kind.** 9545–9546: "Anything else is
  refused before any write (`CheckpointMismatch`, its clock arm)."
  `replay!(…; restore = false)` on `built` raised `MissingInit` (ran);
  `src/sim.jl` 401–411 raises `ServiceLifecycle` on `running`, `stopped` and
  `errored`. Only the origin and frame arms are `CheckpointMismatch`
  (`src/sim.jl` 820–826; Appendix C 13409–13411). Proposed correction: "A
  simulation that is not `initialized` meets the lifecycle gate. One whose
  origin or frame is off the recording's is refused as `CheckpointMismatch`,
  its clock arm."
- **F57. "The clock is *restored*, not compared."** 9715, and the table's
  rows at 9727–9728 ("restored; no boundary zero", "restored, `replay!` takes
  no `t0`"). Under `restore = false` nothing is restored and the origin is
  compared: `replay!` at `t0 = 0.5` against a recording at 0.0 raised
  `CheckpointMismatch` "the recording's origin is t₀ = 0.0 and this
  simulation's is 0.5" (ran). D-317 Rejected (log 13885–13886): "replay
  checks the header's `t₀` as a clock mismatch". Proposed correction: scope
  9715 and the two rows to the default form, and add "Under `restore =
  false` the simulation's own clock runs, and its origin must equal the
  recording's."
- **F58. `MissingInit` unnamed (lesson 20).** 9334–9336 states its
  condition as "an error in the kind set (§13.2) naming `init!`"; Appendix C
  13301 cites §12.6 alone for it. Proposed correction: "… is `MissingInit`,
  naming `init!`". The kind also fires for `replay!(…; restore = false)` and
  `live!` on `built` (ran), which Appendix C's payload omits (part D).
- **F59. `ArgumentInvalid` unnamed in §12.6; `live!`'s kinds unnamed in
  §12.7.** Appendix C 13428 cites §12.6 for `ArgumentInvalid`; §12.6 never
  names it, though 9354–9355 states a condition (`frames` and `t_plus`
  together raised `ArgumentInvalid`, ran). §12.7 9608–9612 states `live!`'s
  refusals without kinds: on `:live` it is `ArgumentInvalid` `:not_replaying`
  (ran), on `stopped` `ServiceLifecycle` (ran), on `built` `MissingInit`.
  Appendix C does not cite §12.7 for `ArgumentInvalid`, and its call list
  omits `live!`. Proposed correction: name each at its condition; Appendix C
  in track 2.
- **F60. "Honest `s`, visible in snapshots, logs and plots".** 9196–9197.
  §2.4 519–521 (Part I): "A state or mode field is observable only through a
  port that publishes it (§5.3, D-252)." A snapshot holds the signal table,
  not the stores. Proposed correction: "becomes honest `s`, which a port can
  publish to snapshots, logs and plots".
- **F61. "The `run!` seam".** 9387. The glossary's *seam* (14603) is "a
  narrow, named interface kept deliberately thin"; the lead-in names the
  junction where `run!` follows `step!`. Chapter 11 ruled the same misuse
  ("one edge case", its F15). Proposed correction: "**Status, termination,
  and `run!` after `step!`.**" or a `####` label of that sense.
- **F62. "Door", three senses.** (a) An entry that builds a run: 9246,
  9248, 9253, 9256, 9406 ("`restore!` is a door like `init!`"), 9549. (b)
  `live!`, which builds no run (D-260 bullet 2: "A change of mode is a write
  to the run, not a change of run"): "the fourth door" (9414), "the mode's
  one manual door" (9602), "That door" (9615); D-219's title says "a manual
  door to live". (c) D-317's sense, every public entry point of a type
  (log 13795–13800; spec 9312–9314 "the `Model`'s own doors"). No glossary
  entry. Carried from chapter 11 (its F23, §12.2's use is half 1's).
  Proposed correction: define *door* once in §12.6's context as an entry
  point that builds a run (`init!`, `restore!`, `replay!`); call `live!`
  "the one call that moves the mode alone"; keep "the model's doors" in
  9312–9314 only if §12.6 says there that the word there means entry points
  (q26).
- **F63. "Nothing advances until one of those doors is taken."** 9415–9417.
  From `stopped`, `live!` is refused (`ServiceLifecycle`, ran), so it is not
  one of the doors that reopen advancing; from `errored`, `init!`,
  `restore!` and `replay!` all refuse (`src/sim.jl` 595–597, 712–714,
  729–731, 928–931), so no door is open at all. Proposed correction: "A terminal
  state makes the mode moot: from `stopped`, nothing advances until
  `init!`, `restore!` or `replay!` opens a new run, and `errored` is
  terminal (below)."
- **F64. "What it drains is the harness cell."** 9372–9373. The frame-top
  drain under `step!` drains every staging cell. `src/sim.jl` `step!`
  docstring: "a batch staged into a rostered device's cell while stopped is
  applied exactly as §11.4 says". A device's late batch, staged after the
  last drain of a run, is the realistic case. Proposed correction: "In a
  stepping session the cell written is the harness cell."
- **F65. "It is also what the synchronous rethrow presupposes".**
  9347–9348. "It" follows "An unattended run is the same loop with empty
  staging"; §11.1 6870–6871 says the calling-task loop is what the rethrow
  presupposes, and D-268 (log 11097–11099) makes the deviceless roster the
  discriminator. Both readings are true. Proposed correction: under M51 the
  sentence goes with the paragraph; otherwise name the antecedent ("The loop
  on the calling task is also …").
- **F66. Links on a word inside a compound.** 9334 "[boundary](#g-boundary)
  zero" links `g-boundary` inside "boundary zero", which has its own anchor
  (linked at 9302); 9361 "scenario-[component](#g-component) doctrine" links
  `g-component` inside "scenario component", which has its own anchor (§12.5
  links it). Proposed correction: unlink both.
- **F67. "So a live run that ignored some is replayed under the same
  `ignore_stop_requests`."** 9578–9579. It reads as framework behaviour.
  `replay!` defaults to `()` and the header records no policy (D-255 bullet
  6), so the caller must pass the list. Proposed correction: "so a replay of
  a live run that ignored some must pass the same `ignore_stop_requests`."
- **F68. The halt's upper bound unstated.** 9562–9565 states the lower
  bound of `to_boundary` and its refusal; a `to_boundary` past the
  recording's last frame is refused too (`ArgumentInvalid`, ran;
  `src/sim.jl` 947–950). 9592 states it for `to_time` only. Proposed
  correction: "Either names a frame from the one the feed starts from
  through the recording's last; anything else is refused (`ArgumentInvalid`)."
- **F69. 9425 cites D-274 for `checkpoint(sim)`'s wrap.** D-319 bullet 3
  (log 14016–14018) states it; D-274 reaches it only through its annotation.
  Proposed correction: cite D-319.
- **F70. 9446 cites D-230 for the ordinal continuing.** D-230's Position
  (log 8845) says a new trajectory restarts the ordinal; the continuation
  under `restore!` is D-274 bullet 3 (log 11661). Proposed correction: cite
  D-274 beside §12.3.
- **F71. Reader-cold names and FlightCore in the present tense.** §12.5:
  "c172_demos.jl:290", ":423, 525", ":303" (9173–9177), FlightCore's demo
  file; "`K = 1` for today's `dt = 0.02` callbacks" (9188–9189), with `K`
  unintroduced (it is `Relative(K)`'s multiplier, §10.5 6167); "The
  `Ref(:init)` phase closure" (9196); "the avionics" (9205), Flight.jl's
  C172 model; "Today's demo-vs-GUI dead-slider fight" (9207–9208), whose
  owner §11.7 8222–8224 names as `Cessna172Xv1`; "The demos' engine
  start/stop buttons are `u`-writes today" (9221); "project → sweep →
  publish" (9228), the executor's phase symbol rather than the declaration
  `x_projection`. §12.6: "the migration suite's advance-by-duration idiom"
  (9357). §12.7: "an attached visualizer" (9650, 9655), fine as a generic
  word. q27.
- **F72. (half 1, resting on §12.6) "Resumable by the next `run!`".**
  §12.4 9054–9055 and 9080: a stopped simulation is "resumable by the next
  `run!` (§12.6)". §12.6 9403 makes the re-run `stopped → init! → run!`;
  `src/sim.jl` 408–409 refuses `run!` on `stopped` with `ServiceLifecycle`,
  and `live!` on `stopped` ran into the same refusal with the message
  "re-running is the `stopped → init! → run!` cycle". For the sibling's
  unit; listed because it cites §12.6.
- **F73. "Cleared" recorders.** §12.6 9406–9408: "new objects rather than
  cleared ones" (D-255 bullet 2). The glossary's *recorders* (14368–14370),
  §14.8 11947–11949 and Appendix B 12911–12913 say "cleared". The effect
  is the same; the wording disagrees. Proposed correction: none in this
  half; the three outside sentences say "replaced" in track 2, or §12.6
  adds "(the recorders restart empty)".
- **F74. "A source or supervisor component".** 9185–9186. Neither class is
  defined; the spec's classes are continuous, periodic discrete and assembly
  (§3), and 9188 says the script component is periodic discrete. Proposed
  correction: fold the **Rule.** into row 502 (M59), which says "scenario
  components", and drop "source or supervisor".
- **F75. The unattended run, half glossed.** 9346: "the same loop with empty
  staging". The glossary (14320) and §11.1 6896 add "and no snapshot
  readers". Proposed correction: under M51 the pointer to §11.1 carries the
  definition; otherwise add the second half.
- **F76. `live!`'s refusals read as a full list.** 9609–9611: "`:running`
  and `:errored` refuse under the ordinary lifecycle gates". `built` and
  `stopped` refuse too (ran). The preceding "legal only on an
  `initialized` simulation in `:replay`" is complete, so the list is
  redundant and partial. Proposed correction: drop the partial list or make
  it "every other state refuses under the ordinary lifecycle gates".
- **F77. "Exact at its own ticks, with no latching".** 9203–9204. A discrete
  output holds between ticks, which is latching in the ordinary sense; the
  sentence means the script keeps no latch variable of its own. Proposed
  correction: "with no latch state of its own".
- **F78. `ServiceLifecycle` unnamed.** 9425–9426 (`checkpoint` legal in
  `initialized` and `stopped`) and 9610 (`live!`'s lifecycle gates) state
  its conditions without the kind. Appendix C 13303 cites §11.3 and §14 only.
  Proposed correction: name it at 9426; F59 covers 9610.
- **F79. "It never waits, whatever pace the control plane holds."**
  9353–9354. True of the pacer; a paused `step!` blocks at the frame top
  until `resume!` or a stop (§12.1 8643–8645, D-268 bullet 1). Not wrong as
  scoped, but a rewriter who shortens it to "never waits" makes it wrong.
  Proposed correction: "never waits on the pacer" (part F warns).
- **F80. The fingerprint under-listed.** 9662–9663 "(store layout, root
  input faces)" and the table's first row (9724). §11.5 7738–7741 and
  `src/checkpoint.jl` 9–17 add each component's `x`, `s` and `m` types,
  every cell's address with its type, and the event list. Proposed
  correction: "(store layout, root-input faces, and what a copy by position
  relies on, §11.5)".
- **F81. "The target `Simulation` carries its own" deployment.** 9693–9694.
  Since D-317 the deployment is the `Model`'s (D-317 bullet 1 log 13748;
  §12.6 9276–9277), and the comparison in `src/model.jl` 613 reads
  `model.deployment`. Proposed correction: "the target simulation's `Model`
  carries its own". The table's second row (9725) has the same wording.
- **F82. "The new trace inherits the old header".** 9643. Under
  `restore = false` the new trace's header is the simulation's own
  checkpoint (9550; `src/sim.jl` replay! docstring). Proposed correction:
  scope to the default form, or "The new trace inherits the header it was
  fed from".
- **F83. "Boundary `k`" for `to_boundary`.** 9565–9568: "running through the
  frame whose execution published boundary `k` … For a grid boundary the halt
  is exactly at `k`". A snapshot's boundary field is the published-boundary
  ordinal, which counts `t*` publications (§12.3 8785–8790, D-230). On a
  `Bouncer` with three `t*` publications, `to_boundary = 10` halted at frame
  10, whose snapshot carries ordinal 11 (ran, `tstar.jl`). `k` is §13.4's
  frame-entry boundary index, a frame count (D-230 Rationale log
  8861–8862; `src/sim.jl` replay! "every frame top is one, so it counts
  frames"). "For a grid boundary" implies `k` could name another kind; it
  cannot. Proposed correction: "`to_boundary = k` takes §13.4's frame-entry
  boundary index, a count of frame tops, not the ordinal a snapshot carries
  (§12.3). Replay runs through frame `k` and halts at its top."

Outside the half, met while checking citations: §12.4 9054, 9080 (F72);
§14.8 11947, Appendix B 12913 and the glossary's *recorders* (F73); Appendix
B 12762 (cites §12.6 for D-319's no-status-gate); Appendix C's `MissingInit`,
`ArgumentInvalid` and `ServiceLifecycle` rows (part D); D-274's §13.7
citation (stale entry text above). All in part D or the list above.

## F. Difficulty per section

| section | difficulty | reason |
|---|---|---|
| §12.5 (F) | medium | 547 words, half of them FlightCore history with reader-cold file references (q27); D-031's six chained rulings cited only twice, never at the bold doctrine statements; one **Rule.** that doubles a bold sentence (M59, F74); F60's Part I contradiction; F77; the final form restates §2.2 at Part I depth (part B) |
| §12.6 (F) | high | 2,223 words, no context and no subheading, 28 bold spans, 99 rule rows; it opens on `Run` and uses "door", `feed` and `live!` before introducing them (q22, q26); four paragraphs double chapter 11 or half 1 (M51, M53, M54, M55); the checkpoint paragraph (9419–9458) is 40 lines with three `restore!` doors whose ordinal rules differ; D-088 and D-096 cited nowhere; F51, F53, F58, F59, F61–F66, F69, F70, F75, F78, F79 |
| §12.7 (G) | high | 2,331 words; a 116-line bullet list holding sub-paragraphs and a nested code block (M57); three labels; the `restore = false` form sits before the what-if it serves (M56) and has no entry; D-101's Position and D-128 cited at none of the rows they rule; two forms of `replay!` that every sentence about the header, the clock and the restore must keep apart (F57, F82); F51, F52, F54–F57, F67, F68, F76, F80–F83 |

Warnings for the rewriter:

- **Terms of art stay verbatim**: placeholder run, input mode, `feed`,
  harness cell, harness writer, frame ordinal, frame-entry boundary index,
  published-boundary ordinal, recorders, what-if replay, scenario component,
  the clock criterion, the levels doctrine, stopped-sim, warm restart,
  re-publication, "the recording is the bound", "verbatim, with no surface
  re-check", "last frame top at or before", "reach or exceed", "replay
  re-records", "structural mismatch … parametric difference". "Door" as q26
  rules it.
- **Two forms of `replay!`.** The default form restores the header; `restore
  = false` restores nothing, compares the origin and frame, and opens a trace
  whose header is the simulation's own checkpoint. Every sentence about the
  header, the clock or the restore says which form it covers (F57, F82).
- **Three indices.** The published-boundary ordinal (a snapshot's), the
  boundary counter (§12.3's wait, never reset), and the frame-entry boundary
  index (§13.4's pointer, a frame count). `to_boundary` takes the third.
  Never write "boundary `k`" without naming which (F83).
- **Three `restore!` doors.** `restore!(model, model_state)` publishes
  through the hooks and writes `:consistent` last; `restore!(sim, cp)`
  continues the trajectory, its re-publication under the checkpoint's
  ordinal; `restore!(sim, model_state)` opens a fresh trajectory under
  ordinal 0. Keep each one's ordinal rule with its door (rows 600–610).
- **Scope words are rulings.** "exactly when", "only", "never", "touching
  nothing else", "from the header's to one short of the recording's last",
  "at or after the one the feed starts from", "whatever pace" (F79: a paused
  `step!` does wait), "under both forms", "nothing else rebinds it".
- **The one-bold test.** D-031's Position chains six rulings by semicolons,
  so §12.5 may carry up to six bolds on D-031 (the doctrine, the clock
  criterion, `user_callback!`, manual events, init and trim as services, the
  intervention command). D-317's bullets are bold in §9.2 (4327) and in
  §12.6 (9274, 9309) for different bullets; do not add a bold on bullet 2.
  D-318 is bold in §9.2 (4333); §12.6 states it plain. D-269 is bold in §12.1
  (8659); §12.6 and §12.7 cite it plain. D-256 bullet 3 is bold in §12.1
  (8621); §12.6 9285 stays plain. D-059 bullet 4 is bold in §14 11031 too
  (part B). Grep the sibling's units for these before bolding.
- **The half cites by adjacency.** Rows 523, 525, 527, 528, 539, 542, 555,
  586, 589, 590, 593, 594, 631, 632, 640, 652, 654–656, 659 and 682 take
  their citation one or two sentences away. A split or a move repeats it.
- **The log's vocabulary is old.** D-031 says "slot"; D-088, D-127 and D-249
  say `stop_on`; D-101, D-127 and D-217 say `ReplayHeaderMismatch`; D-101 and
  D-218 say "two substitutions"; D-096 and D-101 say "the interactive
  writer"; D-110 says `capture`; D-127 says `n` and `event_budget`; D-088
  says `UninitializedSlots`. Never import them when citing an entry.
- **Glossary links reset per section, once each.** §12.6 links drain three
  times and the termination record and harness cell twice each; §12.7 links
  staging cell three times. The harness cell's gloss sits at its second
  link. `trace header`, `frame`, `batch`, `root input`, `write surface`,
  `condition`, `guarded addition` and `log` are used unlinked; link each at
  its first use in its section.
- **Part I's depth.** Three sentences restate a Part I law (part B). Keep
  each as the mechanism's statement with a pointer to §2.2 or §2.4; do not
  argue the law again.
- **Labels and lead-ins.** Six labels (**Rule.** ×5, **Why.** ×1) and about
  thirty bold lead-ins. Each becomes a `####` label, a plain topic sentence
  or a bold headline clause with its citation. Count before and after.
- **Code**: part C, "Code blocks". The rewrite workflow's fence (9618–9625)
  is indented inside a list item; if the list dissolves, de-indent it and
  change nothing else.

## G. Decisions for checkpoint 1

Settled and not asked again: log repair rides track 2, and bold marks one
headline clause per ruling.

**q21. The fingerprint's naming (F51, F80; carried from chapter 11).** §11.5
and `src/` call only the structural layout the fingerprint and name the
deployment beside it; §12.6 folds the deployment into "the fingerprint";
§12.7 splits "fingerprint" from "layout"; the two glossary entries disagree.
Options: (a) §11.5's naming at every half-2 site (9423, 9432, 9438, 9452,
9661–9663, the table's first two rows), with F80's fuller layout list at
9662; the glossary's checkpoint and replay entries in track 2; (b) define
the fingerprint as the whole compared part and change §11.5 back; (c) leave
it. Recommendation: (a). It matches `src/checkpoint.jl`, the rewritten
§11.5 and chapter 11's R17.

**q22. Section orders (M56, M57, M58).** §12.6 has no context and uses
"door", `feed` and `live!` before introducing them; §12.7 puts `restore =
false` before the what-if it serves and buries its validation pass in a
bullet list of "the loop as already specified". Options for §12.6: (a) the
full reorder of part C, eight blocks under `####` labels; (b) a context
paragraph that introduces the five states, *door*, `feed` and the mode,
`####` labels at today's breaks, and M52 only. For §12.7: (c) the six
blocks of part C, with M56 and M57; (d) labels at today's breaks only.
Recommendation: (b) and (c). Today's §12.6 order already puts the fields
before the lifecycle derivation that reads them, so the context paragraph
fixes its define-before-use at the least cost; §12.7's moves fix two
forward references and give the entry pass a home.

**q23. The stepping session's overlaps with chapter 11 (M51, M53).**
§12.6 9343–9348 restates §11.1's bold placement of the loop, and 9371–9385
restates §11.3's harness writer. Options: (a) one pointer sentence each,
keeping what is §12.6's own: "Deviceless, `run!` is fully synchronous" (D-268
log 11153 cites §12.6 for it), the unattended run's pointer, and the
`stage!` → `step!` → `latest` idiom with "Both entry points work under
`run!` too" (Appendix B 12998 relies on it); (b) keep both paragraphs.
Recommendation: (a). The rewritten §11.1 and §11.3 chose their homes.

**q24. Attachments and topology across runs (M54, F53).** §12.6 9460–9470
restates §12.4's "What survives the tail" and carries the bold "Task
topology follows the roster each time" with no D-citation, narrower than
§11.1 6880–6882. Options: (a) one paragraph: persistence across
re-initialization (D-088, D-093), pointers to §12.4 for the survivors and to
§11.1 for which devices get a task, and D-310 bullet 2's front-end clause
cited and bold, since no other section states it; (b) keep both paragraphs
with citations added. Recommendation: (a), ruled with half 1's question on
§12.4 9057–9060 ("Topology is derived after initialization"), so the two
units do not each keep a copy.

**q25. The per-advance stop policy (M55).** §12.6 9472–9480 and §13.5
10334–10349 state it twice, down to the policy's lifetime. Options: (a)
§12.6 keeps the bold and the consequence (a re-run or a `step!` sequence
stops differently without a rebuild) and points at §13.5 for the value;
(b) §12.6 keeps the whole paragraph as the home, and chapter 13's rewrite
trims §13.5 to a pointer; (c) leave both. Recommendation: (b). The style
guide bolds a ruling where the run it governs is described, and §12.6 and
§12.7 describe the advances; §13.5's lead-in "**Policy**" is a label, not a
bold ruling.

**q26. "Door" (F62).** Three senses: an entry that builds a run, `live!`,
and D-317's public entry points of a type. Options: (a) define *door* in
§12.6's context as an entry point that builds a run (`init!`, `restore!`,
`replay!`), call `live!` "the one call that moves the mode alone", and write
"the `Model`'s own entry points" at 9312–9314; (b) define *door* broadly as
any lifecycle entry point, `live!` included, and accept that `run!` and
`step!` are then doors too; (c) leave it, adding a glossary entry in track
2. Recommendation: (a). It is the sense 9246–9256 and 9406 already use, and
chapter 11's F23 ruled the same way for `run!`.

**q27. FlightCore history and reader-cold names (F71).** Options: (a)
introducing clauses and the past tense for FlightCore: "FlightCore's demo
file `c172_demos.jl`" once, the line numbers kept as the survey's evidence;
`K` explained as `Relative(K)`'s multiplier or dropped; "Flight.jl's C172
avionics"; "FlightCore's demo-versus-GUI dead slider", pointing at §11.7;
"the executor's `:project` phase" or `x_projection` at 9228; "the
migration suite" as FlightCore's test suite; (b) move the consumer survey
(9171–9177) to `flight_case_studies.md` with a one-sentence summary.
Recommendation: (a). D-195 Rationale (log 7334) cites the survey's `x`/`s`
clause, and chapter 6's lesson keeps a status-quo measurement in place with
a clause.

**q28. The clear factual corrections.** F52, F54, F55, F56, F57, F58, F59,
F60, F61, F63, F64, F65, F66, F67, F68, F69, F70, F74, F75, F76, F77, F78,
F79, F81, F82, F83. Options: (a) rule them all at checkpoint 1 with part E's
evidence and proposed wording, grepping the chapter for each phrase first
(chapter 8's lesson); (b) leave them for rulings. Recommendation: (a). F51
is q21, F53 is q24, F62 is q26 and F71 is q27; F72 is the sibling's unit;
F73 is wording outside the half and rides track 2.

**q29. Adversarial and verdict lines.** Candidates: 9384–9385 (closure-based
termination, D-096 Rejected); 9181–9183 and 9211–9212 (devices and the
callback rejected, D-031 Rejected); 9658–9660 (mixing live writes into a
replay); 9701–9705 (the anchor-column refusal and its cost); 9711–9713
(value comparison against a field walk); 9731–9735 (the rejected shapes,
cited). Options: (a) keep the one-clause verdicts with their citations, cut
9384–9385 to nothing (its entry carries it), and keep 9701–9705 and
9711–9713 as written until track 2 records them, since no entry holds
9701–9705 and the style guide forbids deleting inline argument the log
lacks; (b) keep all. Recommendation: (a).

**q30. The units.** F = 9169–9484 (§12.5 and §12.6, 2,770 words) and G =
9485–9738 (§12.7, 2,331 words). The split is clean: no move crosses it, and
§12.7 cites §12.6 only backward. Options: (a) F and G; (b) §12.5 alone (547)
and §12.6 with §12.7 (4,554). Recommendation: (a). G sits under the 2,500
floor, but the only other seam leaves one unit far too small and one far
too large.

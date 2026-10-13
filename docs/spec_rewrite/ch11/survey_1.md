# Survey of spec chapter 11, half 1, before its readability rewrite — 2026-10-13

Scope: `docs/design/spec.md` lines 6777–7578 at commit `f61b1af`, 6,982
words: the chapter heading and roadmap (6777–6793), §11.1 (6794–6885), §11.2
(6886–7119), §11.3 (7120–7328) and §11.4 (7329–7578). Half 2 (§11.5–§11.8,
7579–8388) is the sibling survey's. The convention is
`docs/design/tools/spec_style.md`; the method is `docs/spec_rewrite/recipe.md`
step 1; the model is chapter 10's survey (`git show 0f9ce8a:docs/spec_rewrite/ch10/survey.md`).

Line numbers are lines of the frozen copies in `scratch_survey/h1/` (`spec.md`
and `decisions.md` at `f61b1af`). Lines marked `log` are `decisions.md` lines.
Entry claims rest on the entry as read in full; the log line is given where
the point sits outside the Position's first sentence. `src/` was read where a
name or a claim was in doubt, at the working tree (no `src/` change since
`f61b1af` touches the files cited). The scratch script that exercised the
half's claims against the package is `scratch_survey/h1/run/blocks.jl`.

Classification codes used in part A, as in chapter 10:

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
labelled bold lead-in ("**Binding rule:** …", "**Doctrine:** …"), bold
sentence, bold lead-in (a bold phrase opening a paragraph, used as a heading),
bold word, or plain.

Section sizes (words): heading and roadmap 99; §11.1 752; §11.2 2,038 (context
94, "The snapshot and its publication" 669, "The log" 891, "Output-device
bindings" 384); §11.3 1,891; §11.4 2,202 (the worked example 562).

## A. Per section

### Chapter heading and roadmap (6777–6793, 99 words)

| # | line | quote | marking | entry | class |
|---|---|---|---|---|---|
| 1 | 6779–6790 | "This chapter covers GUI, input devices, network I/O and logging, and how data crosses between them and the §10 loop:" then an eight-item nested list | plain | — | pointer, not counted |
| 2 | 6792 | "The machinery that drives the loop itself follows in §12." | plain | — | pointer, not counted; §12's own opener (8391–8393) uses the same words, so the two agree |

What the opening needs (the roadmap is this half's):

- **The form.** Every rewritten chapter so far opens with a context sentence
  and one roadmap sentence (chapter 10, 5485–5491: "This chapter states how
  the loop runs a model through time. It takes the execution order (§5.3) and
  the compiled executor (§9.7) as given. §10.1 covers …"). Chapter 11 opens
  with a bulleted, two-level list. `spec_style.md` ("Section template") asks a
  section without subheadings to end its context with one sentence naming its
  parts; the list is that sentence exploded.
- **A dangling ordinal.** The last bullet, "the third cross-task channel"
  (6790), counts channels the roadmap never names. The first two are the
  outbound snapshot and the inbound staging path; §11.8 (8247–8249) says so
  ("The chapter's two data channels … are a third"). The opening should name
  the two channels, so "third" has an antecedent.
- **No context.** The opening does not say what the chapter assumes. §11
  rests on the loop (§10), the root inputs as the root component's input faces
  (§8.6, §8.2), and the runtime half of §2.2 and §2.4 (what changes a root
  input, what a run publishes). Chapter 10's opener names what it takes as
  given; chapter 11's should too, in one sentence.
- **The periphery.** The opening's first sentence lists "GUI, input devices,
  network I/O and logging", and §11.1's first sentence (6796–6797) repeats the
  list as the gloss of *periphery*. The opening can use the glossed term once
  and §11.1 keep its own gloss (one gloss per section).
- **The Part III roadmap** (5465–5475) describes chapter 11 as "the data
  plane between the loop and everything outside it. Outbound it fixes snapshot
  publication. Inbound it fixes root inputs, per-device staging and the drain.
  Alongside both it fixes the device authoring contract and the input trace."
  It omits three of the eight sections' subjects: claims and the frozen roster
  (§11.3), the GUI write path (§11.7) and the diagnostics channel (§11.8). It
  also files the trace "alongside" both paths, where the chapter roadmap files
  it under the inbound path (6787) and §11.5's title says "Inbound". The Part
  III roadmap needs one clause for the missing three and the trace placed as
  the chapter places it. Part G, q1.

Glossary links: device, snapshot, root input, claim, roster (as "frozen
roster"), drain and trace, each linked once, no glosses. Fine for a roadmap,
but *periphery* is not used, and "shared mutable model" (6782) is FlightCore's
design named as if known; §11.1 introduces it at 6798.

Appendix C kinds cited to the opening: none.

### §11.1 No shared mutable model: staged writes, snapshot reads (6794–6885, 752 words)

Purpose: why the lock goes, the five planes, the frame as the unit of
account, the run-scoped task topology, the two implementation rules, and the
collapse of interactive and unattended modes into one loop.

Subheadings: none. Bold lead-ins: the five plane names (6817–6829), "Device
tasks are run-scoped." (6835), "The loop runs on the calling task" (6841),
"Topology is derived after initialization" (6853), "Spawn-inside-`run!` is the
start gate." (6858), the two rules (6865, 6872). Eleven bold spans, 49 words,
no labels.

| # | line | quote | marking | entry | class |
|---|---|---|---|---|---|
| 3 | 6798–6800 | "FlightCore's answer is one big lock. `SimControl` and the live `Model` are guarded by `io_lock` … (sim.jl)" | plain | — | N, a description of the predecessor |
| 4 | 6801–6802 | "That lock does enforce the boundary-visibility rule (§10.3), because it is only ever free between steps." | plain | — | N, description |
| 5 | 6802–6804 | "Transplanting it here was nevertheless rejected, on three structural costs (D-022). One of the three is decisive for everything below." | plain, cites D-022 | D-022 Rejected log 843–845 | R |
| 6 | 6804–6807 | "Under a lock, input timing is scheduler-determined and unrecorded … bit-identical replay (§10.7) is unachievable *in principle*" | plain | D-022 Rejected log 844–845 ("replay undefinable in principle"); D-101 Rejected log 3127 cites it | R; the replay citation is F13 |
| 7 | 6809–6811 | "The replacement has five planes. Its unit of account is the frame (one iteration of the loop: drain, integrate, boundary sequence, publication), the grid step §10.1 names." | plain | planes: D-022 Position; the frame: D-123 Rationale log 3856–3858 | B: U for the planes; R for the frame's definition |
| 8 | 6811–6812 | "A frame is what `step!` counts, and it is the ordinal that keys the trace." | plain | D-123 Rationale; trace key: D-101 Position log 3098–3099 ("keyed by frame ordinal") | B: U by D-101 for the key; R for `step!` |
| 9 | 6812–6815 | "'Per frame' means this throughout the document. The kinematic *reference frames* … always appear compounded" | plain | D-122 Rationale log 3827–3828 ("frame both senses … compound discipline"); D-123 Rationale | R |
| 10 | 6817–6819 | "**Staging (inbound).** Devices submit pending input writes at any wall-clock moment, never touching live root inputs" | bold lead-in | D-022 Position ("staged inputs") | U |
| 11 | 6820–6822 | "**The drain.** Exactly one point in each frame, at its top … It never happens at a `t*` boundary (§10.4)." | bold lead-in | D-022 Position ("drained at frame top"); `t*`: D-081 Rejected log 2343 (chapter 10's survey) | U |
| 12 | 6822–6823 | "Between drains the loop owns its data exclusively, and no lock is held during stepping, ever." | plain | D-022 Position | U |
| 13 | 6824–6826 | "**Publication (outbound).** At the end of each boundary sequence the loop publishes an immutable snapshot." | bold lead-in | D-022 Position; D-023 Position | U |
| 14 | 6827–6828 | "**Control.** Pause, pace and stop live on a separate few-word atomic surface (§12.1)." | bold lead-in | D-022 Position ("control on a separate atomic surface") | U |
| 15 | 6829–6830 | "**Task topology.** One loop on the calling task, one spawned task per rostered device, all run-scoped." | bold lead-in | D-310 Position bullet 1 (cited at 6841); D-093 Position | U |
| 16 | 6835–6837 | "**Device tasks are run-scoped.** `run!` spawns one task per roster entry after device `init!`, and §12.4 joins them all at every stop" | bold sentence, no citation | D-093 Position log 2842–2846 | U |
| 17 | 6837–6839 | "`attach!` never spawns. It registers, in a stopped-sim state only (§11.3), and the task appears at the next `run!`." | plain | D-093 Position ("`attach!` never spawns"); D-106 Position | U |
| 18 | 6841–6843 | "**The loop runs on the calling task** (D-310). … every rostered device runs on a spawned task." | bold lead-in | D-310 Position bullet 1 | C |
| 19 | 6843–6845 | "This is what the synchronous rethrow (§13.4) presupposes. It is also what lets parallel unattended sweeps thread `run!` inline" | plain | D-093 Rationale log 2860–2861, Rejected log 2874–2877 | R (a reason) |
| 20 | 6846–6850 | "One immutable `Build` is shared across the workers (§9.2), and each `Simulation` owns its own buffers (§9.4). Pre-materializing the sweep's activations … via `build(world; activations = …)` … leaves no worker synchronizing" | plain | D-282 Position bullets 1, 3 (buffers, concurrent `Build`), annotated by D-317 (the `Model` owns them); D-135 Rationale log 4368–4371 (the idiom) | B: U by D-282; R by D-135 for the idiom |
| 21 | 6850–6851 | "`run!` blocks its caller until the run ends." | plain | D-093 Rationale log 2861 | R |
| 22 | 6853–6856 | "**Topology is derived after initialization**, from the frozen roster plus the outcomes of device `init!`, and never from `run!`'s keywords. §12.4 carries the rule: a device whose `init!` failed gets no task." | bold lead-in | D-109 annotation log 3399–3404 (D-109 superseded → D-310); D-138 Rationale log 4571–4573 | B: R by D-138 for "failed `init!`, no task"; the derivation rests on a superseded entry's annotation (F3) |
| 23 | 6858–6861 | "**Spawn-inside-`run!` is the start gate.** … never a `Base.Event` latch (D-093)." | bold lead-in, cites D-093 | D-093 Rationale log 2852–2854, Rejected log 2867 | R |
| 24 | 6865–6871 | "**Every handoff is one atomic reference operation.** Both shared structures reduce their mutable surface to single words … The GC is the reclamation mechanism" | bold lead-in | D-022 Position ("every handoff one atomic reference op, GC as reclamation") | U; "Both shared structures" is F12 |
| 25 | 6872–6876 | "**No user code, no unbounded work, ever, inside a framework critical section.** … A stalled device … cannot stall the loop." | bold lead-in | D-022 Position | U |
| 26 | 6877–6878 | "Two exposures are residual and pre-existing, GC pauses and OS scheduling, and the pacer's debt absorption is the mitigation for both." | plain | none | N, description |
| 27 | 6880–6884 | "Interactive and unattended simulation stop being different execution modes. An unattended run is the same loop with empty staging and no snapshot readers." | plain | D-022 Position ("interactive = batch + devices") | U |

D-022 is cited once (6803), for the rejection; its Position, which rules rows
10–14, 24, 25 and 27, is cited nowhere at a rule. D-093 is cited once, for the
start gate (a Rationale point), and not at row 16 where its Position is
stated.

Descriptions that read like rules: rows 4 and 26. Row 20's "leaves no worker
synchronizing on anything" restates D-135's guarantee as a consequence; it is
fine as a consequence.

Display-block candidates: none needed. The five planes are already a list.

Glossary terms in §11.1 (lesson 35):

| term | first use | linked there | use matches the entry |
|---|---|---|---|
| periphery | 6796 | yes, with gloss | yes |
| device | 6796 | yes | yes |
| boundary | 6801 | yes, no gloss | yes |
| trace, replay | 6806 | yes, no gloss | yes |
| frame | 6809 | yes, with gloss | yes; the entry (13597) cites §11.1 alone, while §10.1 (5499) now defines it as "one grid step" and §2.1 (271) as "one fixed step `h`" (F21, q2) |
| drain | 6810 | yes, inside the frame's gloss | yes |
| frame ordinal | 6812 ("the ordinal that keys the trace") | no | yes |
| root input | 6818 | yes | yes |
| `t*` (localized) | 6822 | no | yes |
| snapshot | 6825 | yes | yes |
| control plane | 6827 ("**Control.**") | no | yes |
| roster | 6836 | yes, and linked again at 6854 ("frozen roster") | yes; the second link breaks one-link-per-section |
| calling task | 6842 | yes, with gloss | yes |
| `Build`, buffer, activation | 6846–6848 | yes | yes |
| executable set | 6849 | yes | no: "Pre-materializing the sweep's activations, its per-eltype executable sets" sets the two in apposition, but an executable set is "the function set an activation can actually run" (13835), not the activation (F24) |
| pacing | 6878 ("the pacer's debt absorption") | no | yes |
| unattended run | 6882 | yes, defined in place | yes |

Appendix C kinds cited to §11.1: none.

### §11.2 Outbound: snapshot publication (6886–7119, 2,038 words)

Purpose: how a snapshot is built and handed out, what it carries and what it
deliberately omits, the log as retained snapshots under a bound, and how an
output device addresses what it reads.

Subheadings (`####`): "The snapshot and its publication" (6897), "The log:
retained snapshots under a bound" (6973), "Output-device bindings" (7075).
The context paragraph (6888–6895) names the three parts in order, which the
subheadings keep. Thirty bold spans: eight labels (**Rule.** ×2, **Why.** ×3,
"**Binding rule:** …", "**Why decimation is admissible here and not there.**",
"**Why the choice matters.**") and 22 others carrying 123 words.

| # | line | quote | marking | entry | class |
|---|---|---|---|---|---|
| 28 | 6888–6892 | "One immutable value is published per boundary, handed out through a single atomic reference." | plain (context) | D-023 Position | U |
| 29 | 6899–6901 | "**Rule.** The loop builds each snapshot in private memory, then publishes it with a single release-store to an `@atomic latest` reference." | **Rule.** label | D-023 Position | U (D-023 is cited only at 6981) |
| 30 | 6901–6903 | "A snapshot carries the boundary-consistent signal table, `t`, its frame index and its published-boundary ordinal (§12.3), and the framework status." | plain | D-261 Position bullet "A snapshot carries its frame index beside its published-boundary ordinal" (cited 6905); D-038 Position (table, `t`, status) | C (adjacent) |
| 31 | 6903–6905 | "The frame index is what places a `t*` snapshot in its frame, since a `t*` publication counts an ordinal of its own (D-261)." | plain | D-261 Rationale log 10353–10355 | reason, not counted |
| 32 | 6905–6906 | "Readers acquire-load that reference and then work with an immutable, coherent world" | plain | D-023 Position | U |
| 33 | 6907–6908 | "The calling task … reads the same value through `latest(sim)`, an inspection read (§12.6)." | plain | D-096 Rationale log 2964 | R |
| 34 | 6910–6911 | "The exchange is wait-free in both directions." | plain | D-023 Position ("wait-free both ways") | U |
| 35 | 6912–6913 | "Publication happens only after the boundary sequence completes (§10.3)." | plain | D-293 Position | U |
| 36 | 6915–6916 | "**Binding rule: nothing reachable from a published snapshot is ever written again.**" | labelled bold sentence, no citation | D-023 Position | U |
| 37 | 6916–6918 | "The table's immutable values … make the compiler enforce most of it. **Why.** The soundness of lock-free reading rests on this rule." | **Why.** label | — | reason, not counted |
| 38 | 6920–6924 | "**The framework status is a concrete frozen value, not a window onto live bookkeeping.** It carries the pacer diagnostics … the per-writer diagnostic batches …" | bold sentence | D-136 Rationale log 4407–4411 | R; duplicates §11.8 8319–8335 (part B); "batches" is F14 |
| 39 | 6924–6926 | "**Why.** The binding rule forces that shape." | **Why.** label | D-136 Rejected log 4439–4441 | reason, not counted |
| 40 | 6928–6932 | "**The captured table is the whole table.** It holds the declared ports, every one of them public (§8.3). No presentation layer has anything to filter." | bold sentence | D-194 Position (intermediates are declared ports; visibility binary); D-038 Position says the opposite ("private cells included, presentation-filtered", log 1250–1251), stale | B: U by D-194; contradicted by stale D-038 (part E) |
| 41 | 6932–6935 | "The inspection path for one is **promotion to a declared output**." | bold phrase | D-194 Rationale log 7135–7137; D-165 (superseded) | R |
| 42 | 6937–6939 | "**The captured table also includes the root inputs.** Root inputs are source cells of the table" | bold sentence | D-047 Position ("snapshot includes root slots") | U |
| 43 | 6939–6944 | the peek fallback and the read-only mirrors need them | plain | D-047 Position ("peek fallback + read-only mirrors") | U |
| 44 | 6944–6946 | "Root input values in the log are derived data, recomputable from the trace." | plain | D-038 Position | U |
| 45 | 6948–6949 | "**The snapshot deliberately does *not* carry the state stores (`x`, `s`, `m`).**" | bold sentence | D-038 Position ("no state stores") | U |
| 46 | 6949–6953 | the two reasons: the trajectory is derived; per-boundary capture records derived data (D-029) | plain, cites D-029 | D-038 Rejected log 1265–1266 | reason, not counted |
| 47 | 6955–6956 | "'What was the private state at t = 37.2?' is answered by replaying to 37.2 and inspecting the live stores." | plain | D-038 Position ("replay-to-inspect") | U |
| 48 | 6956–6958 | the honest remedy is to declare the field public and return it from `y_state` (§5.3), "one cell per sweep" | plain | D-252 Position; D-038 Rejected log 1267–1268 | U |
| 49 | 6958 | "Post-run continuation reads the live stores directly." | plain | D-038 Position | U |
| 50 | 6959–6962 | periodic full-state checkpoints "are a guarded addition shaped as an opt-in log policy" | plain | D-038 Position ("checkpointing = opt-in log policy, guarded") | U |
| 51 | 6962–6964 | "A dev-mode flag … would be a reader over the stores, never a port class (D-252)." | plain, cites D-252 | D-252 Rejected log 9749–9751 (which places the note in "§11.7", wrongly); D-038 Rejected log 1269 | R |
| 52 | 6966–6969 | "**Event firings are not recorded** (D-309). … Replay plus the published modes recovers which events fired" | bold lead-in | D-309 Position; the reason D-309 Rationale | C |
| 53 | 6969–6971 | "The honest remedy is again to declare the mode field public … (D-252). … An event-firing stream is a guarded addition." | plain | D-309 Position (guarded addition); D-252 Position (remedy) | C |
| 54 | 6975–6977 | "**Logging dissolves into publication.** The log is a vector of retained snapshot references. … The per-step `deepcopy` detour of the `SavingCallback` disappears." | bold sentence | D-023 Position ("log = retained snapshot references"), Rejected log 868–869 (cited 6981) | C (adjacent) |
| 55 | 6977–6980 | "The cost is one snapshot allocation per boundary, on the framework side of the §9.8 scope" | plain | D-023 Position ("allocate per boundary") | C (adjacent) |
| 56 | 6980–6981 | "Preallocated snapshot buffers are rejected (D-023)." | plain | D-023 Rejected log 866–867 | R (a verdict pointer) |
| 57 | 6983–6986 | "**Retention: the trace's kill switch, plus decimation.** … `log_every` (Appendix B)" | bold lead-in | D-038 Position (cited 6987) | C (adjacent) |
| 58 | 6986–6990 | "**Why decimation is admissible here and not there.** The derived/primary split (D-038) decides it. … Thinning the trace would destroy the only primary account (D-029)." | labelled bold lead-in | D-038 Position ("admissible precisely because the log is derived") | C |
| 59 | 6990–6992 | "Every boundary still runs, is still published to live readers, and still enters the trace." | plain | D-038 Position ("publication and tracing are unaffected") | U |
| 60 | 6994–6998 | the default configuration grows without bound: "At C172X scale and 50 Hz that is gigabytes per hour" | plain | D-137 Rejected log 4525–4527 | R; "C172X" is reader-cold (F17); "the honest interactive default (Appendix B)" is F6 |
| 61 | 7000–7002 | "**Rule.** The log takes a retention bound … `log_max` … default **65536** (2¹⁶), with `Inf` the explicit opt-out." | **Rule.** label, bold number | D-137 Position (the bound, cited 7020); the default D-137 Rationale log 4474–4475 | B: U for the bound; R for the default |
| 62 | 7004–7011 | "**The bound is a count, not a memory budget.**" with its reasons | bold sentence | D-137 Rationale log 4469–4473 | R |
| 63 | 7013–7016 | "**The default is finite unconditionally**, not a modal rule keyed on `t_end`." | bold phrase | D-137 Rationale log 4474–4477 | R |
| 64 | 7018–7019 | "**When the log fills, the retention stride doubles, so coverage stays global.**" | bold sentence | D-137 Rationale log 4477–4480 | R |
| 65 | 7019–7020 | "A rolling window … was rejected (D-137)." | plain | D-137 Rejected log 4515–4518 | R (a verdict pointer) |
| 66 | 7020–7023 | the log "**re-decimates progressively** … `log_every · 2^k` … what coarsens is density, never extent" | bold word | D-137 Rationale | R |
| 67 | 7025–7028 | "**Why.** That is the division of labor (D-038) carried through." | **Why.** label | D-137 Rationale log 4480–4482 | reason, not counted |
| 68 | 7030–7033 | "**The guarantees are normative, not the mechanism.** There are three." | bold sentence | D-137 Rationale log 4485–4487 | R |
| 69 | 7035–7040 | "The mechanism sketch is non-binding. The thinning is **amortized**." | bold word | D-137 Rationale | mechanism, not counted |
| 70 | 7042–7044 | the generation chain, a blockquote | — | — | mechanism, not counted |
| 71 | 7046–7052 | "Amortizing rather than halving in one shot is a responsiveness choice (D-137)." | plain | D-137 Rationale log 4492–4500 | reason, not counted |
| 72 | 7054–7056 | "**The endpoints are retained unconditionally.** … they do not count against the bound." | bold sentence | D-137 Rationale log 4500–4502 | R |
| 73 | 7056–7058 | the first endpoint is boundary zero's snapshot under `init!`, "and the snapshot the door publishes under `restore!` and `replay!`" | plain | D-137 Rationale (boundary zero only); no entry for the `restore!`/`replay!` case | B: R for boundary zero; N for the two doors |
| 74 | 7058 | "The stride counts boundaries from it." | plain | none found | N |
| 75 | 7059–7062 | the terminal status carries the final cumulative counters, "complete to the final frame top (D-201)" | plain, cites D-201 | D-201 Position; D-136 Rationale log 4417–4419 | C |
| 76 | 7064–7067 | "The `totals` monotonicity across logged snapshots (§11.8) is untouched. Re-decimation … loses *which* boundary … never *how many*." | plain | D-137 Rationale log 4505–4507; D-136 Rationale log 4429–4432 | R; duplicated in §11.8 8377–8381 (part B) |
| 77 | 7067–7071 | "`log_max` is a **view policy, not a trajectory-determining one**. … replay neither records nor compares it" | bold phrase | D-137 Rationale log 4507–4509; D-261 Position bullet (recording keywords on the doors) | R |
| 78 | 7071–7073 | "The `sizehint!` for the expected duration (§9.8) is now naturally capped by `log_max`, which is also what defines the hint when `t_end = Inf`." | plain | D-137 Rationale log 4509–4511 | R; stale (F5) |
| 79 | 7077–7079 | "**Output-device bindings are snapshot bindings.** An output device … consumes snapshots via §12.3." | bold sentence | D-083 Position | U |
| 80 | 7079–7082 | it addresses what it reads with the selectors, "which reach any cell, since inspection reads admit deep paths" | plain | D-083 Position; D-098 Position (source axis) | U |
| 81 | 7082–7085 | "A binding is resolved at attach against the `Build` with did-you-mean … and compiled to one gather, the output half of the binding interface (§11.6)." | plain | D-083 Rationale log 2587 (attach validation); D-098 Rationale log 3017–3018 (`ReadBindingUnresolved` at attach); D-103 Position (one gather, its detection clause superseded by D-177) | B: R by D-083/D-098; U by D-103 for the gather |
| 82 | 7085–7087 | "`map_output` therefore receives a labeled NamedTuple, keyed by the names `reads` declared (§11.6)" | plain | D-199 Position | U; duplicates §11.6 7911–7917 (part B) |
| 83 | 7087–7089 | "A model substitution that breaks a binding therefore fails at attach, not with silent garbage on the wire." | plain | D-083 Rationale; D-098 Rejected log 3029–3030 | R |
| 84 | 7089–7090 | "Loggers treat field-handle signals specially. They skip or summarize them." | plain | none; `pending.md` 132–135 records it as having no entry | N (F7) |
| 85 | 7092–7096 | "This is **inspection** (§13.5). It is human-facing, with no effect on run semantics." | bold word | D-083 Position; D-242 Position bullet 3 | U |
| 86 | 7098–7103 | "**A binding chooses its side.** A deep path is an *inspection* read. … An exported output face, spelled `get_face(name)` (§14.4), is an *integration* read." | bold sentence | D-129 Position; D-083 Rationale; D-242 | U |
| 87 | 7103–7104 | "What makes a face meaning-stable is writer-independent semantics (§11.4)." | plain | D-045 Position bullet 2 | U |
| 88 | 7106–7110 | "**Why the choice matters.** Attach validation converts *structural* drift to loud errors on both sides. Only faces protect against *semantic* drift" | labelled bold lead-in | D-083 Rationale log 2587–2591 | R |
| 89 | 7112–7113 | "Semantically generic consumers should therefore bind faces." | plain | D-083 Rationale | R (a recommendation) |
| 90 | 7113–7115 | "Aircraft families should export the conventional surface … a library/migration deliverable (`migration_outline.md`)." | plain | D-083 Rationale | R (a recommendation); the companion is named by bare file name |
| 91 | 7115–7118 | "Wrapper types make face semantics structurally checkable, as in `VelocityData` … wrapping the wrong quantity is a deliberate lie, not a drift." | plain | D-083 Rationale, Rejected log 2603–2604 | R; `VelocityData`, `v_eb_b` reader-cold (F17) |

The R rows cluster in two entries: D-137, whose Position states only that a
bound exists and names it, while its Rationale (log 4469–4512) carries the
count, the default, the doubling, the guarantees, the endpoints and the view
policy; and D-083, whose Rationale carries the whole inspection/integration
argument. D-083 is cited nowhere in the chapter, and its Spec field lists
§13.3, §13.5 and §14.4 but not §11.2.

Descriptions that read like rules: row 60's "gigabytes per hour"; 7016 "about
22 minutes" (65,536 / 50 Hz = 1,310.7 s, 21.8 min: checked); 7050
"microseconds either way"; row 84.

Display-block candidates:

- The publication exchange (6899–6908): two lines, `@atomic latest = snap` on
  the loop and `snap = latest(sim)` (or a handle read) on the reader. §12.3
  already prints the release-store at 8605.
- The four recording keywords as one call, `init!(sim, condition; trace =
  true, log = true, log_every = 1, log_max = 65536)` (Appendix B 12684–12685),
  where 6983–7002 introduce `log_every` and `log_max` one at a time.

Glossary terms in §11.2:

| term | first use | linked there | use matches the entry |
|---|---|---|---|
| device | 6888 | yes | yes |
| boundary | 6891 | yes | yes |
| snapshot | 6893 | yes, no gloss | yes |
| `latest` | 6900 | yes | yes |
| signal table | 6901 | yes | yes |
| frame | 6902 ("its frame index") | no | yes |
| framework status | 6903 | no; linked at 6920 | yes |
| batch | 6922 ("per-writer diagnostic batches") | no | no: the entry (13939–13941) reserves *batch* for a device's staged writes, "The word means only this" (F14); 6950 "the batches" is the right sense, unlinked |
| calling task | 6907 | yes, with gloss | yes |
| port, cell | 6929, 6931 | yes | yes |
| root input | 6937 | yes | yes |
| peek | 6940 | yes, with gloss | yes |
| claim | 6943 | yes | yes |
| trace, trace header, replay | 6945–6951 | yes | yes |
| store | 6948 ("the state stores") | no | yes |
| sweep | 6958 | yes | yes |
| guarded addition | 6960 | yes, no gloss | yes |
| checkpoint | 6961 | yes, with gloss | yes |
| log | 6975 ("The log is a vector …") | no, though the subsection's subject | yes |
| decimation | 6983 | yes | yes |
| field handle | 7006 | yes, with gloss | yes |
| boundary zero | 7056 | no | yes |
| `Deployment` | 7069 | yes, with gloss | yes |
| binding | 7077 | no | yes |
| selector, did-you-mean | 7080, 7083 | yes, with glosses | yes |
| face | 7100 | yes | yes |

Appendix C kinds cited to §11.2: `ReadBindingUnresolved` (13144, "§11.2,
§14.4"). §11.2 states the condition (7082–7084, a binding resolved at attach
"with did-you-mean"; 7087–7089, a broken binding "fails at attach") without
naming the kind (F8).

### §11.3 Inbound: root inputs, claims and the frozen roster (7120–7328, 1,891 words)

Purpose: what the periphery may write (root inputs, by face name), who may
write each (exclusivity, claims, write surfaces, the harness writer), who
owns initial values, why the roster is frozen per run, device identity and
admission, device death, and the mid-run reader guarded addition.

Subheadings: none, in 1,891 words, and no context paragraph: the section
opens on a bold rule. Twenty bold spans: one **Why.** label and 19 others
carrying 128 words. One fenced block (7289–7295).

| # | line | quote | marking | entry | class |
|---|---|---|---|---|---|
| 92 | 7122–7123 | "**The write surface … is root inputs.**" | bold sentence | D-044 Position (write-surface rule); D-206 Position (the term) | U |
| 93 | 7123–7126 | "A root input *is* the root component's own input face, an assembly's `input_wires` key or a primitive's `u_types` key … produced by no component." | plain | D-208 Position | U |
| 94 | 7127–7128 | "At every non-root level an input face is fed by the parent's wire … No dedicated vocabulary is needed." | plain | D-208 Rationale log 7712–7715 | R |
| 95 | 7130–7133 | "A root input is usefully read as the output face of the one producer the build never sees … root-input exclusivity … is that producer's one-writer right, and the totality … its completeness obligation." | plain | none | N, an interpretive reading |
| 96 | 7135–7136 | "Root inputs are sources to the build-time ordering, constants within a frame, and the *only* thing the periphery may write." | plain | D-031 Position ("root-input staging + control commands, nothing else"); D-022 Position | U; restates §2.2 332–338 (part B) |
| 97 | 7136–7138 | "The GUI reaches them through the resolution (§11.7), and control commands are not writes (§12.1)." | plain | D-045 Position bullet 1; D-031 Position | U |
| 98 | 7138–7141 | devices, mappings, the trace and the GUI write path "address root inputs by **face name** … Structural slash paths never cross the periphery's *write* boundary." | bold phrase | D-129 Position; D-046 Position | U |
| 99 | 7141–7144 | "The read side chooses per binding. It uses slash paths in inspection reads, and face names in integration reads and in service reads" | plain | D-129 Position; D-242 Position | U |
| 100 | 7146–7148 | "**Root-input exclusivity: one writer per root input at any time.** A device claims its root inputs at attach … an attach-time error. Detaching releases the claims." | bold lead-in | D-044 Position (cited 7151) | C (adjacent) |
| 101 | 7148–7149 | "A released root input's GUI widgets are live again from the next run (§11.7)." | plain | D-106 Position (freeze); D-047 Rationale log 1501–1503 | B: R by D-047; N for "from the next run" as a stated rule |
| 102 | 7149–7151 | "Exclusivity replaces any cross-device conflict *policy*, such as attachment-order precedence at drain (D-044)." | plain, cites D-044 | D-044 Position; D-044 Rejected log 1409–1411 | C |
| 103 | 7151–7153 | "Per-device cells, the CAS merge and the atomicswap drain all stay. They serve atomicity and coalescing, not arbitration." | plain | D-044 Position ("retained for atomicity and coalescing") | C (adjacent) |
| 104 | 7155–7158 | "**Why.** A second live writer on one root input makes the applied value a timing artifact … The usual pair is a stream and its mirror" | **Why.** label | D-044 Rejected log 1409–1411 | R |
| 105 | 7160–7166 | "**A claim is what a device *may* write, not what it will.** … Such a device therefore claims the **binding's enumerated allowed set**" | bold sentence, bold phrase | D-044 Position ("enumerated surfaces (a device's claim set …)"); no entry states "may, not will" | B: U by D-044 for the enumerated set; N for the may/will ruling |
| 106 | 7166–7170 | "A broad claim costs liveness. … Narrow the binding to narrow the claim. The enumeration *is* the interface." | plain | D-103 Rationale log 3179–3180 ("narrowing the binding narrows the claim"); D-174 Rationale log 6382–6383 (liveness inside the GUI's claim) | R |
| 107 | 7172–7175 | "**Every writer has a write surface, and the periphery enforces it.** A batch entry reaches a root input **iff the named face is inside the writer's surface**. Anything else is discarded with a runtime warning (§13.2)." | bold sentence, bold clause | D-044 Position | U |
| 108 | 7175–7178 | "Because surfaces are static per run … enforcement runs entirely at *staging* … The drain performs no checks at all." | plain | D-044 Position ("under the D-106 roster freeze … all checks run at staging and the drain checks nothing"); D-106 Rationale | U |
| 109 | 7178–7179 | "**Every device's surface is its claim set**, and a claim set has two *sources*" | bold phrase | D-174 Position | U |
| 110 | 7181–7183 | "**Returned.** … declares `is_input(b) = true`, `claims(b)` (§11.6) is called once at attach, and what it names is staked." | bold lead-in | D-174 Position; D-177 Rationale (conformance) | U |
| 111 | 7184–7185 | "Such a claim is static for the attachment and exclusively its own, since claims are disjoint by construction." | plain | D-174 Position; D-044 Position | U; "by construction" is F20 |
| 112 | 7185–7187 | "It is binding-bounded even where no one else is involved. A mapping that has drifted onto an unenumerated face is a diagnosable anomaly (`OutOfClaimEntry`)" | plain | D-044 Position ("binding-bounded even on unclaimed faces, `OutOfClaimEntry`") | U |
| 113 | 7188–7191 | "**Computed.** The binding declares `is_greedy(b) = true` … all root-input faces minus the union of the rostered claims" | bold lead-in | D-174 Position | U |
| 114 | 7191–7192 | "This is the shipped GUI's claim (§11.7), everything unclaimed, without configuration." | plain | D-174 Position | U |
| 115 | 7192–7194 | "It is disjoint from every incumbent claim by construction, so exclusivity validates trivially and nothing downstream can tell the two sources apart." | plain | D-174 Position | U |
| 116 | 7194–7197 | "A complement that comes out empty is legal and useless, and `attach!` records `EmptyGreedyClaim` in the roster entry's diagnostic cell (… D-250)." | plain, cites D-250 | D-250 Position bullet 5; legality D-174 Rationale log 6363–6365 | C; duplicates §11.6 7993–8003 (part B) |
| 117 | 7199–7205 | "**The periphery resolves root faces against the activation's cell layout alone** (D-261)." | bold sentence | D-261 Position bullet | C |
| 118 | 7207–7210 | "One claim mechanism, two claim sources. The source is exhausted at the attach point. Past it, validation, roster-entry storage, shape compilation …, the drain, the trace and detach-releases-claims treat a computed claim exactly as a returned one." | plain | D-174 Position | U; near-duplicate of §11.6 7981–7991 (part B) |
| 119 | 7210–7212 | "The GUI is therefore not an exception but an ordinary enumerated writer" | plain | D-174 Position | U |
| 120 | 7212–7214 | "Attaching the greedy claimant last is the idiom. Its computed claim is taken at the attach point and never recomputed, so attachment order is decisive by design." | plain | D-192 Rationale log 7058–7060; D-192 Rejected log 7066–7068 | R |
| 121 | 7214–7216 | "Opportunistic writing by autonomous devices does not exist. … greediness is an explicit declaration, never a default." | plain | D-044 Position ("autonomous opportunistic writing does not exist"); D-174 | U |
| 122 | 7216–7219 | "Cross-writer races on one root input therefore cannot arise structurally … That is what keeps drain order a diagnostic fact" | plain | D-044 Position | U |
| 123 | 7221–7226 | "**One framework-owned remainder: the harness writer.** … `stage!(sim, "face" => value, …)` … It stages a batch from the calling task itself (the task that invoked `run!`)." | bold lead-in, bold phrase | D-096 Position; renamed in D-174 Rationale log 6374–6375; "from the calling task" contradicted by D-200 (F1) | U |
| 124 | 7226–7227 | "Its always-present cell is drained, traced and surface-checked exactly as any device's." | plain | D-096 Position | U |
| 125 | 7227–7230 | "The harness writer's surface is the one thing in the design that is *derived* rather than claimed. … recomputed at every stopped-sim roster change" | plain | D-174 Rationale log 6374–6378 | R |
| 126 | 7231–7232 | "A `stage!` write to a claimed face is rejected at staging (`ClaimedFaceEntry`, naming the incumbent)." | plain | D-044 Position; D-174 Rationale log 6379–6380 | U |
| 127 | 7232–7235 | "A rostered greedy claimant empties that surface outright. … every `stage!` in such a session is rejected that way (D-192)." | plain, cites D-192 | D-192 Position | C |
| 128 | 7235–7237 | "There is one seam, a batch staged while stopped whose face a subsequent `attach!` claims, and the attach itself renormalizes it away (below)." | plain | D-104 Rationale log 3212–3213; D-174 Rationale log 6377–6378 | R; "(below)" points into §11.4 (F9); "seam" is F15 |
| 129 | 7237–7241 | "The harness cell … drains **last**, by convention. With every surface disjoint the order is unobservable" | bold word | D-174 Rationale log 6383–6385; D-096 Position gives the superseded reason | R |
| 130 | 7243 | "**Root-input initial values are owned by the init/trim services.**" | bold sentence | D-047 Rejected log 1513–1514 ("services own initialization"); D-068 Position (enforcement at the service) | B: R by D-047; U by D-068 if enforcement implies ownership |
| 131 | 7244–7247 | "Input declarations are bare types (§8.2) and carry no defaults … the trim service writes root-input values it *solved for* … Export-entry defaults were rejected (D-047)." | plain, cites D-047 | D-047 Rejected log 1513–1514; D-068 Rejected log 2083–2084 | R |
| 132 | 7248–7249 | "`init!` establishes every root input, and the trace header captures the result." | plain | D-047 Position ("trace header extends to initial slot values"); D-068 Position bullet 1 | U |
| 133 | 7249–7251 | "Totality is enforced pre-write at every complete-world application: `init!`, trim setup, trim commit (§14.6)." | plain | D-149 Position | U |
| 134 | 7253–7255 | "**The roster is frozen per run: attach and detach are stopped-sim operations.** … legal in the `built`, `initialized` and `stopped` states … an error while `running`." | bold sentence | D-106 Position | U |
| 135 | 7255–7257 | "That error is `ServiceLifecycle` (Appendix C), the same kind that gates the §14 services." | plain | D-108 Rationale log 3357–3360 | R |
| 136 | 7257–7259 | "The list is exhaustive. An `errored` simulation refuses both with the same kind. … (§13.6, D-232)" | plain, cites D-232 | D-232 Position | C |
| 137 | 7259–7261 | "The prohibition includes pause. Pause is a control-plane state *inside* a run" | plain | D-106 Position ("pause included (pause is inside a run)") | U |
| 138 | 7262–7263 | "The roster (entries, claims, attachment order) is therefore a plain immutable value the loop reads once at `run!`." | plain | D-087 Position | U |
| 139 | 7263–7266 | "The partition of the root face set into per-writer surfaces plus the harness remainder is a static, inspectable fact of the run. It is printable before the run starts" | plain | D-106 Position | U; "printable" is F19 |
| 140 | 7266–7269 | "No republication machinery exists. There is no atomic roster reference, no per-frame acquire-load, no next-frame attachment granularity and no sequence numbers." | plain | D-087 Position; D-087 Rejected (the superseded design) | U (q6) |
| 141 | 7269 | "Attachment order is the roster's own order." | plain | D-087 Position | U |
| 142 | 7269–7271 | "The trace still tags entries with a stable device id, never a roster index, because ids read across runs" | plain | D-087 Rationale log 2710–2711, Rejected log 2720–2721 | R |
| 143 | 7271–7274 | "Attach validation, claim registration and the staging-shape compilation (below) all run at the attach point, which makes `attach!`/`detach!` stopped-sim configuration operations beside `init!` and trim" | plain | D-106 Position, Rationale; D-104 Position (compiled at attach) | U |
| 144 | 7274–7277 | "While a simulation runs, its configuration … is immutable. The doctrine (§12.5) extends to its final form. The running periphery stages writes and issues control commands, *and nothing else changes*." | plain | D-031 Position; D-106 Rationale log 3282–3283 ("final form") | B: U by D-031; R by D-106 for "final form" |
| 145 | 7279–7281 | "**Device identity, ids and roster admission.** Identity is the device instance. The same object (`===`) may occupy at most one roster entry." | bold lead-in | D-109 Position (superseded → D-310); D-310 Rationale log 13094–13096 says these halves "survive in §11.3" | R (no live Position states it) |
| 146 | 7281–7285 | "The stable device id … is assigned at `attach!`, monotonic per `Simulation` and never reused. It lives exactly as long as the entry" | plain | D-109 Position (superseded); D-261 Position bullet (the entry keeps the id); D-087 Rationale | B: U by D-261 for where the id lives; R otherwise |
| 147 | 7287–7295 | "Admission is a two-part check at the attach point, in order:" identity → `AlreadyAttached`; claims → `ClaimConflict` | plain, fenced block | D-109 Position (superseded; three parts); D-174 Rationale log 6371–6372 (three parts); D-310 Position bullet 1 (withdraws `CallerTaskConflict`) | B: U by D-310 for the withdrawal; R for the two-part order |
| 148 | 7297–7300 | "An already-rostered instance is rejected rather than silently absorbed, because rebinding has an explicit spelling: `detach!` then `attach!`" | plain | D-109 Rejected log 3410–3411 (superseded entry) | R |
| 149 | 7300–7303 | "Running the claims check after the identity check is what makes `ClaimConflict` always name two *distinct* devices" | plain | D-109 Position (superseded) | R |
| 150 | 7305–7308 | "**Device death does not detach.** … the roster entry, claims included, persists to the end of the run." | bold sentence | D-106 Rationale log 3276–3277 | R |
| 151 | 7308–7310 | "The orphaned claims are the accepted cost of the freeze." | plain | D-106 Rationale, Rejected log 3297–3298 | R |
| 152 | 7310–7311 | "The device's root inputs hold their last-drained values and no other writer inherits them." | plain | D-106 Rationale | R |
| 153 | 7311–7313 | the read-only widgets render the orphan ("claimed by `T16000M` — task dead") | plain | D-047 Rationale log 1502–1503 | R; label text duplicated at §11.7 8174 (part B) |
| 154 | 7313–7315 | "Recovery is between runs: stop, `detach!`, and either `init!` … or `replay!`-to-end then `run!`" | plain | D-106 Rationale log 3280–3281 | R |
| 155 | 7315–7316 | "The death is an anomaly, not a surface event." | plain | none | N, a summary |
| 156 | 7318–7322 | "One deliberate asymmetry is on record as a **guarded addition** … A pure reader claims nothing. … Attaching one mid-run would therefore move no writer's surface." | bold term | D-106 Rationale log 3283–3287 | R |
| 157 | 7322–7325 | "A dynamic reader list would touch only §12.3 wakeups, the heartbeat and the shutdown join, never the drain … cleanly severable" | plain | D-106 Rationale | R |
| 158 | 7325–7327 | "The §12.2 thread-budget warning runs once per run, at either door, against the frozen population." | plain | D-106 Rejected log 3296 ("per-attach thread-budget re-checks"); §12.2 8520–8523 | B: R by D-106; "door" is F23 |

D-174 rules most of rows 109–125 and 177–183 below, and the chapter never
cites it. D-106 is cited nowhere in the half; its Position rules rows 134,
137 and 139, and its Rationale carries rows 150–157 and the drain's
compilability in §11.4. Rows 145–149 rest on D-109, superseded by D-310,
whose Rationale says the identity and admission halves "survive in §11.3"
without restating them in a Position (part E).

Descriptions that read like rules: row 95 (the producer reading); row 139's
"printable"; 7184's "disjoint by construction" (F20).

Display-block candidates:

- `stage!(sim, "face" => value, …)` (7223), the harness writer's one call.
- The attach call with its policy keyword, `attach!(sim, dev, binding;
  should_abort = false)` (D-177 Position), which §11.3 describes at length
  and never shows. §11.6 shows the binding traits.

Glossary terms in §11.3:

| term | first use | linked there | use matches the entry |
|---|---|---|---|
| write surface | 7122 | yes, with gloss | yes |
| batch | 7122 (in the gloss), 7165, 7172 | no | yes |
| root input, component, face | 7123–7124 | yes | yes |
| periphery | 7131 | yes, no gloss | yes |
| root-input totality | 7133 ("the totality"), 7249 | no | yes |
| frame | 7136 | no | yes |
| device, trace | 7138 | yes | yes |
| boundary | 7140 ("the periphery's *write* boundary") | no | no: neither the time sense nor the structural sense the entry admits (13632–13634); a third, figurative sense |
| contract | 7141 | yes | yes |
| claim | 7146 | yes | yes |
| drain | 7150 | yes, no gloss | yes |
| staging cell | 7151 ("Per-device cells") | yes | yes |
| coalescing | 7153 | yes | yes |
| binding | 7163 | no | yes |
| derived liveness | 7167 ("the derived-liveness rule") | no | yes |
| roster | 7176 | yes | yes |
| the freeze | 7176 ("the roster freeze, below") | no; linked at 7310 | yes |
| greedy claim | 7188 ("**Computed.**") | no | yes |
| diagnostic cell | 7196 | yes | yes |
| activation, probe, `Build` | 7199–7202 | no | yes |
| schema vs. layout | 7202 | yes | yes |
| harness writer | 7222 | yes | yes; but the entry (14023) says "the framework-owned write path of the calling task" (F1) |
| calling task | 7225 | yes, with gloss | yes |
| seam | 7235 ("one seam") | no | no: the entry (14404) is a narrow named interface; here an edge case (F15) |
| harness cell | 7237 | yes, with gloss | yes |
| trace header | 7249 | yes | yes |
| service lifecycle | 7256 (`ServiceLifecycle`) | no | yes |
| orphaned claims | 7309 | yes | yes |
| guarded addition | 7319 | yes, with gloss | yes |

Appendix C kinds cited to §11.3, and whether §11.3 names each where it states
its condition:

| kind | Appendix C | named at the condition |
|---|---|---|
| `ServiceLifecycle` | 13104 | yes, 7256 |
| `AttachUnknownFace` | 13120 | no: §11.3 never states that a returned enumeration naming a nonexistent face is refused at attach; `src/roster.jl` 222–234 raises it between the identity and claims checks (F8) |
| `AlreadyAttached` | 13123 | yes, 7292 (in the block); the prose at 7297 does not repeat it |
| `ClaimConflict` | 13125 | partly: the condition is first stated at 7146–7147 unnamed, and named at 7294 |
| `EmptyGreedyClaim` | 13127 | yes, 7195 |
| `NotAttached` | 13245 | no: §11.3 never states that detaching an unrostered device is an error (F8); D-215 Position (log 7977–7978) adds the kind |
| `ClaimedFaceEntry` | 13267 | yes, 7232 |
| `OutOfClaimEntry` | 13272 | yes, 7187 |

### §11.4 Inbound: per-device staging, representation and the drain (7329–7578, 2,202 words)

Purpose: the one coalescing policy, the staged representation (values plus
mask, compiled at attach), where diagnostics fire, the levels doctrine, the
drain, mappings and conditioning, and the worked example that chose
per-device cells.

Subheadings (`####`): one, "Worked example: filter, joystick and GUI" (7518).
The context paragraph (7331–7339) names three parts, "the policy …, the shape
the cell holds, and the drain", which leaves out the diagnostic sites, the
levels doctrine and the mappings. Twenty-five bold spans: seven labels
(**Rule.** ×4, **Why.** ×2, "**Doctrine:** …") and 18 others carrying 76 words.

| # | line | quote | marking | entry | class |
|---|---|---|---|---|---|
| 159 | 7331–7336 | "That something is the staging cell, a compound term distinct from a table cell (D-121). … mutated frame by frame, outside the table's publish-once discipline." | plain (context), cites D-121 | D-121 Position | C |
| 160 | 7341–7343 | "**Rule.** Staging keeps one atomic cell per attached device under one coalescing policy: CAS merge, newest wins per face." | **Rule.** label | D-104 Position (cited at 7361); D-024 Position (per-device cells) | C (adjacent) |
| 161 | 7343–7345 | "Each cell has a single writer, its own device task, and holds that device's latest pending batch" | plain | D-024 Position; D-136 Position (single writer) | U; false of the harness cell (F2) |
| 162 | 7345–7347 | "Staging merges the incoming batch into the pending one. Untouched faces survive, and re-staged faces take the newest level. That is the per-face ZOH." | plain | D-104 Position | C (adjacent) |
| 163 | 7347–7350 | "The CAS can fail only because a drain intercepted the old batch, so the retry is bounded. … Intercepted writes are already applied, and must not be re-staged." | plain | D-024 Position ("retry bounded by drain interception") | U; false of the harness cell (F2) |
| 164 | 7352–7356 | "**Why.** Merge is the *only* policy because it is always correct. … merge and overwrite are provably the same operation" | **Why.** label, bold words | D-104 Position (parenthetical) | C (adjacent) |
| 165 | 7356–7361 | sparse writers lose writes under overwrite; "A user-facing overwrite opt-in (`complete(binding)`) is closed (D-104)." | plain, cites D-104 | D-104 Rejected log 3223–3226 | R |
| 166 | 7363–7366 | "**Rule.** The staged representation is fixed per attachment, compiled at attach." | **Rule.** label | D-104 Position ("per-attachment fixed shape compiled at attach") | U |
| 167 | 7366–7369 | "It is a pair of positional tuples over the claim set: a values tuple, concretely typed `Tuple{T₁, …, Tₙ}`, and a parallel `Bool` touched-mask." | plain | D-202 Position (cited 7400) | U |
| 168 | 7369–7372 | "A set mask position means *staged this time*. A clear one means *not touched*, never 'reset'. … The mask guards every consumer" | plain | D-202 Position; D-104 Position ("never reset") | U |
| 169 | 7372–7374 | "The batch is therefore isbits with one concrete layout per writer. The levels doctrine is untouched, and root inputs only ever receive masked positions." | plain | D-202 Rationale log 7409–7411 | R; "levels doctrine" is used 89 lines before 7461 states it (M9) |
| 170 | 7374–7375 | "The face-name → position schema lives in the roster entry." | plain | D-104 Position; D-202 Position | U |
| 171 | 7377–7394 | the sketch | code | D-202, D-104 | code, not counted |
| 172 | 7396–7403 | "**Why.** One concrete layout is what makes the frame-top drain compilable. … (D-202)" | **Why.** label | D-202 Rationale, Rejected | reason, not counted |
| 173 | 7405–7408 | "The merge is positional and mask-driven …, so it compiles straight-line, leans on no small-tuple heuristic, and does not degrade with surface width (D-202)." | plain, cites D-202 | D-202 Rationale log 7407–7409 | R |
| 174 | 7408–7411 | "The drain applies each cell through an attach-compiled **scatter** … the exact mirror of the compiled output gather (§11.2)." | bold word | D-104 Position | U |
| 175 | 7413–7419 | "Authors never build the shape by hand. `map_input` returns face ⇒ value pairs … `stage!` normalizes those pairs through an attach-compiled shim." | plain | D-104 Position | U; `map_input` is used here before 7489–7491 introduces it (M10) |
| 176 | 7419–7421 | "Author-built total tuples are rejected as a padding form, the same disease D-074 and the handler return law refuse (D-104)." | plain, cites D-074, D-104 | D-104 Rejected log 3227–3228 | R |
| 177 | 7423–7425 | "**A greedy entry needs no special treatment here.** … The GUI's cell is compiled exactly as a joystick's." | bold sentence | D-174 Position | U |
| 178 | 7427–7434 | "**The harness cell … gets the same treatment.** … recompiled at each `attach!`/`detach!` … the one cell whose shape the framework derives" | bold sentence | D-104 Rationale log 3210–3212; D-174 Rationale | R |
| 179 | 7436–7438 | "One representation, one mechanism. The name-keyed dynamic path the mutable surface used to force does not exist, and no face name is ever resolved inside the loop's frame." | plain | D-104 Rationale log 3214, Rejected log 3221–3222 | R; "used to force" is history (q6) |
| 180 | 7440–7444 | "The recompilation has one seam. … The attach renormalizes that batch. … newly-claimed faces are discarded with `ClaimedFaceEntry`." | plain | D-104 Rationale log 3212–3213; D-174 Rationale | R; "seam" is F15 |
| 181 | 7446–7450 | "**Rule.** Diagnostic sites follow the compilation, all of them to staging. … Every check therefore runs in `stage!`'s normalization, on the writer's own task." | **Rule.** label | D-044 Position; D-202 Position ("staging-sited diagnostics … stand") | U |
| 182 | 7450–7452 | "A device's out-of-claim face has no position in the schema and is rejected with `OutOfClaimEntry`." | plain | D-044 Position | U |
| 183 | 7452–7454 | "The GUI is included, its claim being an ordinary one. A **harness** write to a claimed face is rejected the same way, with `ClaimedFaceEntry`" | bold word | D-174 Rationale log 6378–6380 | R; the harness writer's no-such-face case (`OutOfClaimEntry`, D-200 Position) is not stated |
| 184 | 7455–7456 | "And a value that cannot convert to its root input's declared type is discarded with `EntryTypeMismatch`" | plain | D-105 Rationale log 3249–3250; D-104 Rationale | R |
| 185 | 7458–7459 | "Nothing remains at the drain. … the drain is pure application." | plain | D-044 Position; D-106 Rationale ("the drain is pure application") | U |
| 186 | 7461–7463 | "**Doctrine: staged values are levels, never deltas** (`press_count = 17`, never `presses += 1`). … Button edges ride as monotonic counters." | labelled bold lead-in | D-024 Position ("levels-never-deltas doctrine"); D-045 Position bullet 4 | U |
| 187 | 7465–7468 | "**Rule.** At frame top the drain takes each device's cell with one `atomicswap(cell, nothing)`. … applied through its compiled scatter, **in attachment order**." | **Rule.** label, bold phrase | D-024 Position ("drain by `atomicswap` in attachment order") | U |
| 188 | 7468–7471 | "Attachment order is retained as a deterministic application order. Under root-input exclusivity … the order matters only for diagnostics." | plain | D-044 Position ("drain order stays diagnostic"); D-024 Rejected (superseded position) | U |
| 189 | 7473–7475 | "Which *frame* a write lands in remains wall-clock reality. What the drain guarantees is that the frame's outcome is a pure function of the drained batches." | plain | D-101 Position ("the frame sequence is itself deterministic"); restates §2.4 546–549 | B: U by D-101; N as a stated drain guarantee |
| 190 | 7477–7481 | "Because the roster is a fixed value at `run!`, the drain is fully compilable. … the same per-configuration compile trade the executor (§9.7) already makes" | plain | D-106 Rationale log 3273–3275 | R |
| 191 | 7482–7484 | "The specialization is an implementation freedom the freeze creates, not an obligation. Iterating a roster array … remains acceptable." | plain | D-106 Rationale | R |
| 192 | 7486–7487 | "Two shapes were rejected, both examined in the worked example below: per-input atomic cells, and a shared lock-free batch stack (D-024)." | plain, cites D-024 | D-024 Rejected log 891–895 | R (a verdict pointer to the exempt example) |
| 193 | 7489–7493 | "**Mappings run on the device task.** Today's `assign_input!(mdl, mapping, data)` becomes the pure `map_input(data, mapping) → batch`." | bold sentence | D-024 Position ("mappings pure, on the device task"); D-045 Position bullet 3 | U; "Today's" is FlightCore's, present tense (F17) |
| 194 | 7495–7499 | "**Mappings are binding data, not shaping code.** … The shipped `TableBinding` applies those parameters in its generic `map_input`" | bold sentence | D-045 Position bullet 3; D-103 Rationale log 3181–3182 | U; duplicates §11.6 8039–8051 (part B) |
| 195 | 7501–7505 | "**a face's meaning is writer-independent**. Faces therefore carry *post-conditioning* semantics. … This GUI-parity test is what places conditioning upstream." | bold clause | D-045 Position bullet 2; D-045 Rejected log 1446–1447 | U |
| 196 | 7507–7510 | "Aircraft-semantic derivation must *not* ride along. … `q_ref = q_sf · axis` … is FCS design and lives in-model … Alternatively it is accepted as a small per-aircraft×device mapping entry, an aircraft-design fork." | plain | D-045 Rejected log 1448–1449 ("Shaping as per-device mapping code") | R; the "Alternatively" sentence sits against D-045's rejection (F10, q8) |
| 197 | 7512–7514 | "The trace records post-conditioning levels. … The raw stick levels are the known, accepted loss" | plain | D-045 Position bullet 2 (post-conditioning semantics); no entry records the loss | B: U for the records; N for the accepted loss |
| 198 | 7515–7516 | "Edge logic follows the levels doctrine. Devices stage monotonic press counters. Accumulators … are model state, not mapping state." | plain | D-045 Position bullet 4 | U; repeats row 186 (M9) |
| 199 | 7520–7521 | "This worked example is the exercise that selected per-device cells and produced the §11.7 staging contracts." | plain | D-024 (the selection) | framing, not counted; F11 |
| 200–206 | 7521–7577 | the setup, the three candidates, the scope paragraph, the four findings | example | D-024 cited four times, D-044 and D-047 implied by the scope paragraph | example, not counted; exempt evidence under `spec_style.md` "Rationale" |

The worked example is the one `spec_style.md` names as exempt ("as in §11.4's
staging example"), and every comparative passage in it cites D-024. Its
numbers check: 100 Hz polling for a 10 s pause is 10³ nodes (7559); 60 Hz
renders (16.7 ms) against 50 Hz frames (20 ms) put at least one render in
every frame (7549). Its scope paragraph (7532–7539) already says the
contested-input world is not the design's, but its framing sentence (7520–7521)
and its "Discoveries" bullet (7573–7574) still present the active-widget
contract as a product, though §11.7 rejects it (8166–8168, D-047 Rejected log
1506–1508). F11.

Descriptions that read like rules: row 189; 7482–7484 "Iterating a roster
array costs a handful of dispatches per frame and remains acceptable" (a
measurement claim with no source).

Display-block candidates: none beyond the sketch. `map_input(data, mapping) →
batch` (7491) and `atomicswap(cell, nothing)` (7466) are short enough inline.

Glossary terms in §11.4:

| term | first use | linked there | use matches the entry |
|---|---|---|---|
| staging cell | 7334 ("the staging cell") | no; linked at 7341 as "cell" and again at 7521 | yes; one link too late, one too many |
| drain | 7338 | yes, with gloss; linked again with gloss at 7551 | the gloss says the drain "publishes staged device writes", where the entry (13998) and §2.2's gloss (340) say "applies" (F16) |
| frame | 7332 ("frame top") | no; linked at 7543 | yes |
| device | 7342 | yes; linked again at 7520 | yes |
| coalescing | 7342 | yes; linked again at 7536 | yes; the entry says "one pending batch per device", silent on the harness cell |
| face, batch, root input | 7343–7345 | yes; batch linked again at 7487 and 7528, root input at 7524 | yes |
| claim, contract, roster | 7364–7375 | yes | yes |
| probe | 7402 | yes | yes |
| greedy claim | 7423 ("A greedy entry") | no | yes |
| harness cell | 7427 | yes, with gloss | yes |
| the freeze | 7428 ("the roster freeze") | no; linked at 7483 | yes |
| seam | 7440 | no | no (F15) |
| payload, executor | 7452, 7480 | yes | yes |
| trace | 7492 | no; linked at 7547 | yes |
| binding | 7495 | no | yes |
| replay | 7513 | yes | yes |
| boundary | 7524 | yes | yes |
| peek | 7536 ("the peek rule") | no; linked at 7559 | yes |
| port, component | 7574, 7576 | yes | yes |
| torture test, worked (example) | the subsection | no | the entries (14410–14412, `g-worked`) cite this example; a link is optional |

Appendix C kinds cited to §11.4: `ClaimedFaceEntry` (13267, "§11.3, §11.4"),
named at 7443 and 7454; `EntryTypeMismatch` (13293), named at 7456.
`OutOfClaimEntry` is named at 7450 but Appendix C cites §11.3 only, a
track-2 addition.

### Tally

| section | rules | C | U | S | R | N | B |
|---|---|---|---|---|---|---|---|
| heading | 0 | 0 | 0 | 0 | 0 | 0 | 0 |
| §11.1 | 25 | 1 | 11 | 0 | 6 | 3 | 4 |
| §11.2 | 56 | 8 | 21 | 0 | 21 | 2 | 4 |
| §11.3 | 67 | 7 | 31 | 0 | 20 | 2 | 7 |
| §11.4 | 38 | 4 | 19 | 0 | 13 | 0 | 2 |
| total | 186 | 20 | 82 | 0 | 60 | 7 | 17 |

The count leaves out 20 rows that are pointers, reasons, mechanisms, code,
framing or the worked example (1, 2, 31, 37, 39, 46, 67, 69, 70, 71, 171,
172, 199, 200–206), and classes each row by its first code.

Fewer than one rule in nine is cited where it stands (20 of 186), against 35
of 154 in chapter 10. The U rows cluster in entries the half never cites:
D-022 (8 rows), D-044 (11), D-174 (9), D-038 (6), D-045 (5), D-106 (4),
D-087 (3), D-083 (3). The R rows cluster in four Rationales: D-137 (the log,
11 rows), D-106 (freeze consequences, 8), D-174 and D-104 (the harness
writer and its cell, 7), D-083 (output bindings, 5). No citation is to a
superseded entry, but five rows (145–149) rest on superseded D-109 alone, and
three cited entries are half-superseded without annotation: D-044 (cited
7151) and D-104 (cited 7361, 7421) lost their interactive-writer halves to
D-174 (log 6387), and D-024's Position still says "complete writers
overwrite" (log 876–877) against D-104's one policy.

Bold weight now: 86 bold spans in the half, of which 16 are labels or
labelled lead-ins (**Rule.** ×6, **Why.** ×6, the two labelled "**Why …**" lead-ins
of §11.2, "**Binding rule:**" and "**Doctrine:**"); the other 70 carry 376 words. Many are lead-ins acting as
headings (the five planes, "**Returned.**", "**Computed.**") or bold terms
("**guarded addition**", "**scatter**", "**amortized**").

## B. Overlaps

### Inside half 1

1. **The drain checks nothing.** §11.3 7175–7178 ("enforcement runs entirely
   at *staging* … The drain performs no checks at all") and §11.4 7446–7459
   (the diagnostic sites, "Nothing remains at the drain"). §11.3 states the
   rule (D-044), §11.4 the sites. Both stay; §11.4 can point back for the
   rule instead of restating "static facts of the run".
2. **The harness writer's renormalization seam.** §11.3 7235–7237 and §11.4
   7440–7444 state the same edge case, and §11.3's "(below)" means §11.4.
   Home: §11.4, where the recompilation is (M8).
3. **The harness cell's shape.** §11.3 7226–7230 (drained, traced,
   surface-checked; derived surface recomputed at roster changes) and §11.4
   7427–7434 (compiled to a positional shape, recompiled at each
   `attach!`/`detach!`). Distinct facts; both stay.
4. **One claim mechanism.** §11.3 7207–7212 and §11.4 7423–7425 ("A greedy
   entry needs no special treatment here"). §11.4's is the application to
   shapes; it stays as one sentence with a pointer.
5. **Cross-writer races cannot arise; drain order is diagnostic.** §11.3
   7216–7219, §11.3 7238–7241 (the harness drains last, unobservable), §11.4
   7468–7471. Three statements of one consequence of D-044. Home: §11.3
   7216–7219; the other two keep their local clause.
6. **Levels, never deltas.** §11.4 7461–7463 and 7515–7516 ("Edge logic
   follows the levels doctrine. Devices stage monotonic press counters."),
   and "levels doctrine" used at 7373 before either. Merge into one block
   placed before its first use (M9).
7. **Mappings on the device task.** §11.1 6874 ("Here mappings run on
   device tasks") and §11.4 7489–7493. §11.1 states the critical-section
   rule; §11.4 the mapping rule. Both stay.
8. **The read side chooses per binding.** §11.2 7098–7104 ("A binding
   chooses its side") and §11.3 7141–7144. §11.2 is the home (D-083, D-129);
   §11.3's sentence is a pointer-sized restatement and can shrink to one
   clause.
9. **The output gather and the drain scatter.** §11.2 7082–7085 (compiled to
   one gather) and §11.4 7408–7411 (the scatter, "the exact mirror of the
   compiled output gather"). Cross-references, both stay.
10. **Primary and derived.** §11.2 6944–6953 (the trajectory is derived),
    6986–6990 (decimation admissible because the log is derived), 7025–7028
    (division of labor). One argument (D-038) used three times for three
    rules. Each use is one or two sentences; no cut needed, but the rewriter
    should not add a fourth.

### With half 2 (moves that cross the split)

| content | half 1 | half 2 | proposed home |
|---|---|---|---|
| the framework status is a concrete frozen value, with its contents | §11.2 6920–6926 | §11.8 8319–8335 | §11.8 for the contents (D-136); §11.2 keeps the binding-rule consequence (6924–6926) and "the framework status (§11.8)" (M6) |
| the terminal snapshot carries the final cumulative counters, complete to the final frame top | §11.2 7059–7062 | §11.8 8341–8355 | both: §11.2 says why the endpoint is retained, §11.8 what it carries; §11.2 shrinks to one clause and a pointer |
| `totals` monotone across logged snapshots; decimation loses which boundary, never how many | §11.2 7064–7067 | §11.8 8377–8381 | one home (M5, q5). Both say "worth stating once"; D-137 and D-136 each record it. Recommended home §11.2, which also has re-decimation; §11.8 keeps a pointer |
| `map_output` receives a labeled NamedTuple keyed by the names `reads` declared | §11.2 7085–7087 | §11.6 7911–7917 (the **Rule.**, D-199) | §11.6 (M4); §11.2 keeps "compiled to one gather" and the attach-time failure |
| `EmptyGreedyClaim` in the roster entry's diagnostic cell | §11.3 7194–7197 | §11.6 7993–8003 | §11.3 for the claim fact (empty complement legal); §11.6 for the second-greedy case and the warning's home (D-250); one of the two drops the diagnostic-cell clause (q5) |
| one claim mechanism, two sources; greediness is a source, not a class | §11.3 7207–7219 | §11.6 7981–7991 | §11.3 for the mechanism (D-174); §11.6 keeps the declaration side |
| the orphan label "claimed by `T16000M` — task dead" | §11.3 7311–7313 | §11.7 8170–8180 | §11.7 for the label; §11.3 keeps "the orphan is rendered, never hidden" with a pointer |
| `TableBinding` as the shared conditioning helper with an owner | §11.4 7495–7499 | §11.6 8039–8059 | §11.6 for the type; §11.4 keeps the rule "mappings are binding data" and the pointer it already has |
| device death keeps claims to run end | §11.3 7305–7316 | §11.6 7863–7868 ("Claims and the roster entry persist to run end (the freeze, §11.3)") | §11.3; §11.6 already points |
| staging diagnostics written on the staging task | §11.4 7446–7456 | §11.8 8248–8252 | both; §11.8 is the channel, §11.4 the sites |
| the frame-top take by `atomicswap` | §11.4 7465–7468 | §11.8 8297–8308 ("This drain is the same drain §11.4 specifies") | §11.4; §11.8 already points |
| root-input initial values owned by the services; the header holds them | §11.3 7243–7251 | §11.5 7639–7643 | §11.3 for ownership, §11.5 for the header's content; both point |
| the log is derived, the trace primary | §11.2 6986–6990 | §11.5 7695–7708 | §11.5 for the trace default (D-029); §11.2 keeps the derived-log consequence |

One cross-split contradiction, half 2's to fix but resting on §11.1: §11.6
7806–7810, "Under the spawned-loop topology the calling task is the one
running a device loop body inline, the GUI's (§11.1)". §11.1 6841–6843 says
the loop runs on the calling task and every device on a spawned task, which
is D-310 Position bullet 1 (log 13059–13061, "the inline-body branch of
`run!` [is] withdrawn"). F4.

### Other chapters

| content | half 1 | elsewhere | home |
|---|---|---|---|
| the frame and its units | §11.1 6809–6815 | §2.1 271–275 ("one fixed step `h`"); §10.1 5496–5508 ("one grid step `[tₙ, tₙ₊₁]`", what is keyed to it); glossary 13597–13600 (cites §11.1 alone) | §2.1 for the meaning, §10.1 for the loop's units since chapter 10's M1. §11.1 keeps the loop-iteration order, the `step!` count and the trace key, which §10.1 lacks (q2) |
| the loop on the calling task, devices spawned | §11.1 6829–6830, 6841–6851 | §12.6 9144–9149 (restates it, cites §11.1); §12.2 8520–8525 | §11.1 (D-310); §12.6 points |
| attach and detach legal states, roster persistence | §11.3 7253–7259 | §12.6 9261–9271 | §11.3 for the freeze; §12.6 for persistence across re-initialization |
| harness writer, `stage!(sim, …)` | §11.3 7221–7241 | §12.6 9172–9185; Appendix B 12795–12799; glossary 14018–14027 | §11.3; all four say "from the calling task" (F1) |
| device `init!` before spawn; a failed `init!` gets no task | §11.1 6835–6837, 6853–6856 | §12.4 8766–8870 (the initialization bracket), 8859 | §12.4 for the bracket; §11.1 points |
| every port public; promotion to a declared output | §11.2 6928–6935 | §8.3 (cited) | §8.3 for publicity; §11.2 for the inspection idiom |
| totality pre-write | §11.3 7249–7251 | §14.6 (cited) | §14.6 |
| face names on the write side, slash paths for structure | §11.3 7138–7144 | §8.6 3389–3391 (which says device and trace addressing share the slash form; see part D) | §8.6 for the notation; §11.3 for the write-side rule |
| the log's `sizehint!` | §11.2 7071–7073 | §9.8 5443–5444 ("`sizehint!` to the retention bound") | §9.8; §11.2's version is stale (F5) |
| reader observes only at boundaries | §11.2 6912–6913 | §10.3 5643–5649 (D-293) | §10.3; §11.2 cites it |

**Part I's depth.** No sentence in the half restates Part I at Part I's
depth in a way the depth rule forbids; each overlap gives the mechanism or
the enforcement. Four sentences restate a Part I law before adding to it, and
each can lead with a pointer instead:

- §11.3 7135–7136, "Root inputs are sources to the build-time ordering,
  constants within a frame, and the *only* thing the periphery may write",
  restates §2.2 332–334 ("a running model's only channel from outside") and
  336–338 (change only at frame tops).
- §11.3 7244–7246, "Input declarations are bare types (§8.2) and carry no
  defaults, yet a root input unfed by any device must hold a defined value
  from the first frame", restates §2.4 490–493.
- §11.4 7473–7475, "the frame's outcome is a pure function of the drained
  batches", restates §2.4 546–549 (what fixes a trajectory).
- §11.1 6809–6811's frame gloss restates §2.1 271 in loop terms; acceptable,
  since the loop-iteration order is the Part III mechanism.

## C. Proposed structure

No section is renumbered and none is retitled. 324 inbound rows point at the
half's sections (part D), and no file links a `####` anchor of chapter 11
(checked with `rg` over `docs/`: the only `spec.md#` links are section-level
link definitions), so `####` labels can be added or retitled freely.

### Moves

| move | content | from | to | needs a ruling |
|---|---|---|---|---|
| M1 | the frame's definition | §11.1 6809–6815 (72 words) | stays in §11.1, trimmed: the gloss points to §10.1; the loop-iteration order (drain, integrate, boundary sequence, publication), the `step!` count, the trace key and the reference-frames note stay, since §10.1 holds none of them and §2.2 349 relies on the order | yes, q2 |
| M2 | the two implementation rules | §11.1 6863–6878 | up, directly after the plane list (6817–6830), before the topology paragraphs; the sentence "The fifth plane carries the most machinery, and the rest of this section spells it out" (6832–6833) then introduces the topology paragraphs alone | no |
| M3 | "The endpoints are retained unconditionally" | §11.2 7054–7062 | up, directly after the guarantees (7030–7033), which promise "The endpoints below are kept", and before the non-binding mechanism sketch (7035–7052) | no |
| M4 | `map_output` receives a labeled NamedTuple | §11.2 7085–7087 | trimmed to a pointer to §11.6's rule (D-199); "compiled to one gather" stays, because D-104 Position (log 3203) and `inbound_periphery_walkthrough.md` 152 cite §11.2's gather | yes, q5 |
| M5 | the `totals` composition | §11.2 7064–7067 or §11.8 8377–8381 | one home | yes, q5 |
| M6 | the framework status's contents | §11.2 6920–6924 | trimmed to "the framework status (§11.8)" plus the binding-rule consequence (6924–6926); §13.2 9766–9767 cites §11.2 for the status surfacing in snapshots, which the Rule at 6903 keeps | yes, q5 |
| M7 | "The periphery resolves root faces against the activation's cell layout alone" | §11.3 7199–7205 | down, after the harness writer paragraph (ends 7241): it says "writers, claims and the harness compile against it", and all three are defined by then; today it interrupts the claim-source argument between 7197 and 7207 | no |
| M8 | the harness renormalization seam | §11.3 7235–7237 | shrunk to one clause pointing to §11.4 7440–7444, the home | no |
| M9 | the levels doctrine | §11.4 7461–7463 and 7515–7516 | merged, and moved up to directly after the coalescing rule's reason (ends 7361): "level" is used at 7346 and "the levels doctrine" at 7373 | no |
| M10 | mappings and conditioning | §11.4 7489–7514 (231 words) | up, after M9 and before the representation rule (7363): the shim (7413–7419) normalizes `map_input`'s pairs, and `map_input` is introduced only at 7490–7491 | no |
| M11 | the overlaps with half 2 (part B table) | — | each kept in its home with a pointer at the other | yes, q5 |

All moves stay inside one section, so each stays inside one unit. M4–M6 and
M11 change only half 1's text; the matching half 2 pointers belong to the
sibling's units.

### Order within each section

Define-before-use was checked for each order below against the terms each
block uses.

- **Chapter opening (q1).** One context sentence: the chapter specifies the
  data plane between the loop (§10) and the periphery (glossed), taking root
  inputs (§8.6) and the run's laws (§2.2, §2.4) as given. One roadmap
  sentence naming §11.1–§11.8 in order, with "the two data channels" named
  before "the third". The §12 pointer stays.
- **§11.1.** Context (6796–6807: the periphery, FlightCore's lock, the
  decisive cost). The five planes with the frame gloss (M1). The two rules
  (M2). Topology: run-scoped device tasks (6835–6839), the loop on the
  calling task (6841–6851), which devices get a task (6853–6856, q3), the
  start gate (6858–6861). The consequence (6880–6884). "Calling task" is
  glossed at its first use in the plane list (6829), not at 6842.
  Subheadings are not needed at 752 words; the context ends with one
  sentence naming the parts.
- **§11.2.** Unchanged subsection order; the context already promises it.
  Within "The snapshot and its publication": the Rule, the exchange's
  properties, the binding rule, the status (M6), the table's content (whole
  table, root inputs, no stores), replay-to-inspect, event firings. Within
  "The log": dissolution into publication, the switch and stride, the growth
  problem, the bound, its three properties (count, finite default, doubling
  stride), the reason, the guarantees, the endpoints (M3), the mechanism
  sketch and its chart, the amortization reason, the compositions (M5). Within
  "Output-device bindings": unchanged, less M4.
- **§11.3.** A context paragraph is missing; the section opens on a rule. Add
  one: the periphery writes only root inputs, one writer each, under a roster
  fixed per run, ending with the parts sentence. Then `####` topic labels:
  "Root inputs are the write surface" (7122–7144); "Exclusivity and claims"
  (7146–7170); "Write surfaces and their enforcement" (7172–7197, 7207–7219);
  "The harness writer" (7221–7241, then M7); "Root-input initial values"
  (7243–7251); "The frozen roster" (7253–7277); "Device identity and
  admission" (7279–7303); "Device death and orphaned claims" (7305–7316);
  "Mid-run readers, a guarded addition" (7318–7327). The freeze is used at
  7176, 7213 and 7229 before its block at 7253; 7176 already says "(the
  roster freeze, below)", and the first use should carry the gloss
  ("attach and detach only while stopped"). Moving the freeze block up
  instead was weighed and rejected: it uses "the harness remainder" and
  "surfaces", defined later, so it would trade one forward reference for two.
- **§11.4.** Context (7331–7339), its parts sentence extended to name all
  the parts. Then `####` labels: "The coalescing policy" (7341–7361); "Levels,
  never deltas" (M9); "Mappings and conditioning" (M10); "The staged
  representation" (7363–7444: the rule, the sketch, the reason, the
  consequences, the shim, the greedy entry, the harness cell, one
  representation, the seam); "Diagnostic sites" (7446–7459); "The drain"
  (7465–7487); "Worked example: filter, joystick and GUI" (7518–7577, kept).
  The drain is glossed in the context (7338) and used throughout; the
  mappings block uses "batch" (glossed at 7344) and `TableBinding` with its
  §11.6 pointer; the representation then finds `map_input` defined.

### Rewrite units

| unit | lines (original) | moves in | moves out | words |
|---|---|---|---|---|
| A | 6777–6885: heading, roadmap, §11.1 | — | — | 851, plus the new context sentence |
| B | 6886–7119: §11.2 | — | M4, M6 (trims) | 2,038 |
| C | 7120–7328: §11.3 | — | M8 (trim) | 1,891, plus the new context paragraph |
| D | 7329–7578: §11.4 | — | — | 2,202 |

Total 6,982 words. E is unused.

B and D sit just over the 2,000 target. Each has a clean split:

- **B1 / B2.** B1 = 6886–6972 (763 words: the context and "The snapshot and
  its publication"); B2 = 6973–7119 (1,275 words: the log and the output
  bindings). No move crosses the split. The two halves cross-refer only
  through the binding rule and the per-boundary allocation, both backward
  pointers from B2.
- **D1 / D2.** D1 = 7329–7463 plus 7489–7516 (about 1,443 words: the policy,
  levels, mappings, the representation, the diagnostic sites); D2 = 7464–7488
  plus 7518–7578 (about 760 words: the drain and the worked example). M9 and
  M10 then stay inside D1. D2 falls well under the floor, and the worked
  example is carried nearly verbatim (exempt evidence), so its edit load is
  small.

Recommendation: B whole and D whole (q9). B's three subsections are each
already in shape; D's moves (M9, M10) are a reordering of one argument, and
splitting D leaves a 760-word unit that is mostly verbatim example.

### Code blocks, charts and tables

The half holds three blocks and no table:

- 7042–7044: the generation chain, a blockquote with bold, italics and code
  spans. `norm.py` treats it as prose, so each of its terms must be covered by
  the claim's span. Carry verbatim.
- 7289–7295: the admission check, an untyped fence (a two-row table in
  monospace: condition → diagnostic). Carry verbatim; it is the place
  `AlreadyAttached` and `ClaimConflict` are named.
- 7379–7394: the staging sketch, a `julia` fence of pseudo-code (Unicode
  subscripts, `T₁ … Tₙ`, prose comments, a line of the form `batch.mask[i] &&
  (the root input at position i receives batch.values[i])`). `norm.py` folds
  it into one code span; a one-character edit changes the span count. Comment
  edits are ruled edits only.

Inline math: none beyond `2¹⁶` and `log_every · 2^k`, both plain text.

New display blocks (part A candidates): the publication exchange (§11.2), the
four recording keywords (§11.2), `stage!(sim, …)` (§11.3), the `attach!` call
(§11.3). Each is an addition the inventory declares.

### Running the half's code

Loaded with `test/repl.jl` inside `module H1Check` (script
`scratch_survey/h1/run/blocks.jl`, run with `julia --project=test -t 2`; 5 of
5 checks pass).

- **7379–7394, the staging sketch: cannot run as written** (pseudo-code). Its
  merge was run on a concrete instance through the package's own `_merge`:
  pending `(1.0, 2.0, 3.0)` masked `(true, false, true)` merged with incoming
  `(9.0, 8.0, 0.0)` masked `(false, true, true)` gives `(1.0, 8.0, 0.0)` under
  mask `(true, true, true)`, as the sketch's two lines say. Through the public
  path, `stage!(sim, "a" => 1.0); stage!(sim, "b" => 2.0); stage!(sim, "a" =>
  3.0)` then one frame leaves `a = 3.0, b = 2.0`: untouched faces survive and
  re-staged faces take the newest level. An unconvertible value counts one
  `EntryTypeMismatch` in the harness record.
- **7289–7295, the admission check: cannot run** (a table, not code). Its
  claims were exercised: re-attaching the same instance under an overlapping
  claim raises `AlreadyAttached`, not `ClaimConflict`; a second instance
  under an overlapping claim raises `ClaimConflict` (collected, as Appendix C
  says). An enumeration naming a nonexistent face raises `AttachUnknownFace`,
  and detaching an unrostered device raises `NotAttached`; §11.3 names
  neither (F8). Ids run `[1, 2]`, then `[1, 3]` after a detach and an attach:
  monotonic, never reused.
- **7042–7044, the generation chain: cannot run** (a chart). Its claims were
  exercised: `init!(…; log_max = 4)` then 20 frames retains frames `[0, 4, 8,
  12, 16, 20]`, the first and terminal endpoints outside the bound plus four
  middles at stride 4 = `log_every · 2²`. The default is 65536.
- Other claims checked in passing: a snapshot's fields are `t`, `frame`,
  `boundary`, `store`, `layout`, `status` (6901–6903); a rostered greedy
  device empties the harness surface, and a harness `stage!` then counts one
  `ClaimedFaceEntry` and leaves the root input unchanged (7232–7235, D-192);
  a second greedy attach stakes the empty set with an `EmptyGreedyClaim`
  warning (7194–7197); `attach!` from another task while `run!` is running
  raises `ServiceLifecycle` (7253–7256).

## D. Inbound citations

The rows analysed are the 324 rows of `inbound.tsv` whose target is §11,
§11.1, §11.2, §11.3 or §11.4 (copied to `scratch_survey/h1/mine.tsv`).

By file: `decisions.md` 139 (Spec 72, Rationale 34, Position 16, Rejected 15,
Annotation 2), `spec.md` 135, `implementation.md` 18, `flight_case_studies.md`
11, `inbound_periphery_walkthrough.md` 7, `pending.md` 4,
`frame_walkthrough.md` 4, `extensions.md` 2, `migration_outline.md` 2,
`localization_validation_walkthrough.md` 1, `event_visibility_walkthrough.md`
1. The 135 `spec.md` rows: Part I 9, Part II 11, Part III outside chapter 11
32, Part IV 17, Appendices A–C 32, the glossary 34.

By target: §11 10, §11.1 42, §11.2 108, §11.3 116, §11.4 48 (in `spec.md`
alone: 8, 17, 41, 50, 19).

Ranges recorded at their ends only: `implementation.md` 341 ("§11.1–§11.4")
also covers §11.2 and §11.3; `implementation.md` 820 ("§11.1–§11.5") also
covers §11.2–§11.4; D-123's Spec field and Rationale (log 3853, 3860,
"§11.3–§11.6") also cover §11.4 and §11.5 (the §11.5 end is the sibling's).
`inbound_periphery_walkthrough.md` 14 ("§11.3–§11.4") has no section between.

### Citations relying on moved or trimmed content

M1, the frame paragraph (§11.1):

| file:line | fact relied on | after M1 |
|---|---|---|
| spec 349 (§2.2) | the boundary that ends a frame publishes before the drain that opens the next (§10.1, §11.1) | holds if §11.1 keeps the loop-iteration order (drain, integrate, boundary sequence, publication) |
| spec 13597–13600 (glossary, frame) | frame = one loop iteration, `step!`'s unit, the trace's key (§11.1) | holds; the entry should cite §10.1 beside §11.1 (track 2, or the glossary pass) |
| spec 14154–14156 (glossary, frame ordinal) | the frame sequence keys the trace (§12.7, §11.1) | holds if the trace-key sentence stays |
| log 3856–3858, 3871 (D-123 Rationale, Rejected) | §11.1 is the frame's normative home | historically true; since chapter 10's M1, §10.1 also defines the frame (part E) |

M2 and M3 reorder inside their sections; no row relies on the order.

M4, the `map_output` sentence (§11.2):

| file:line | fact relied on | after M4 |
|---|---|---|
| log 7334 (D-199 Position) | the labels "key the NamedTuple `map_output` receives (§11.2, §11.6)" | holds if §11.2 keeps one clause naming the labeled NamedTuple with its §11.6 pointer |
| log 3203 (D-104 Position) | the drain scatter is the "mirror of §11.2's gather" | holds; "compiled to one gather" stays |
| `inbound_periphery_walkthrough.md` 152 | the same mirror | holds |
| spec 12623 (Appendix B, `reads`/`map_output` row) | cites §14.4, §11.2 for the output side | holds; §11.6 would be the better target (track 2) |
| spec 13144 (Appendix C, `ReadBindingUnresolved`) | §11.2 states attach-time resolution | holds; q12 adds the kind's name |

M5, the `totals` composition: no row in half 1 relies on §11.2 7064–7067.
D-136 Rationale (log 4429–4432) and D-137 Rationale (log 4505–4507) each
record it, and D-136 and D-137 list both §11.2 and §11.8 in their Spec
fields, so either home keeps both fields true.

M6, the status contents: spec 9766–9767 (§13.2) says the warning stream
"surfaces through the published framework status (§11.2)", which holds while
§11.2's Rule (6903) keeps the status in the snapshot. Glossary 14005–14010
cites §11.8 and §11.2; holds.

M7–M10 move text within their sections; no row names the moved sentences by
position. M8 turns §11.3's "(below)" into "(§11.4)"; D-104 Rationale (log
3212–3213) states the seam without a section.

### Citations already wrong before the rewrite

The inbound check will flag these whatever the rewrite does; they belong to
track 2 or to the other chapter.

| file:line | claim | what half 1 says |
|---|---|---|
| spec 3389–3391 (§8.6) | "Declarations, error messages, device/trace addressing (§11.3) and the HDF5 log tree share [the slash path form] verbatim" | §11.3 7138–7140: devices and the trace address root inputs by face name, and "Structural slash paths never cross the periphery's *write* boundary". Only device *read* bindings use slash paths (§11.2 7079–7081). No HDF5 log exists; `pending.md` 127–135 lists HDF5 export as open |
| spec 12622 (Appendix B, `claims`/`map_input` row) | cites §11.4 for "The enumerated face set *is* the claim, what the device may write rather than what it will" | that is §11.3 7160–7166 |
| spec 9788–9790 (§13.2) | cites §11.3 for "The write-surface and entry violations … all raised at staging" | the entry violation (`EntryTypeMismatch`) is §11.4 7455–7456; §11.3 names only the surface kinds |
| spec 12795–12796 (Appendix B), 14019, 14023–14024 (glossary), 9175 (§12.6) | `stage!(sim, …)` stages "from the calling task" | §11.3 7225 says the same, but D-200 and `src/sim.jl` 1793 say any task (F1) |
| log 7360 (D-200 Position) | the harness writer's "no-such-face `OutOfClaimEntry` (§11.4)" | §11.4 states the device's out-of-claim case (7450) and the harness writer's claimed-face case (7453), not the harness writer's no-such-face case |
| log 3151 (D-102 Rationale) | "the GUI implements the same contract, called inline on the calling task (§11.1)" | §11.1 6841–6843: every device runs on a spawned task (D-310) |
| log 4571–4573 (D-138 Rationale) | "Topology is derived after initialization (§11.1): a failed `needs_calling_task` holder returns the loop to the calling task" | the trait is withdrawn (D-310 bullet 1); §11.1 keeps the sentence's shell (F3) |
| log 2955–2960 (D-096 Position) | the harness writer stages "into the interactive writer (D-044's derived surface) … drained *last* … (the explicit hand of code beats a widget interaction …)" | §11.3 7237–7241: surfaces are disjoint and the order is "unobservable"; D-174 Rationale (log 6383–6385) calls the old reason objectless |
| log 9749–9751 (D-252 Rejected) | "A dev-mode flag publishing every state field (§11.7's note)" | the note is §11.2 6962–6964 (the row cites §11.7, so it is not in this half's count) |
| log 4333 (D-134 Rejected) | quotes §11.3: "the GUI is not an exception but the resident of the second class" | §11.3 7210–7211 now reads "an ordinary enumerated writer"; D-134 is superseded in substance by D-174 (part E) |
| `frame_walkthrough.md` 211–213 | `publish!` "bumps the wait counter (§11.2, D-230)" | the counter is §12.3's boundary counter; §11.2 carries the snapshot's ordinal |
| `flight_case_studies.md` 340–341 | the telemetry tap "runs a pure `map_output` on its task" (the §11.2 citation at 345) | §11.2 says only what `map_output` receives; §11.6 places the call in the author's loop. Minor |

### Log entries whose Spec field would change

- Under M1: none required. D-123's Spec field lists §11.1, which keeps the
  frame's loop-iteration sense; the glossary entry is the one to retarget.
- Under M4, M5, M6: none. D-199, D-136 and D-137 already list both §11.2 and
  the other section.
- Under M7–M10: none; the moves are within sections.
- Under q12 (naming `AttachUnknownFace` and `NotAttached` in §11.3): D-216
  (`AttachUnknownFace`'s payload, log 8022–8023) and D-215 (`NotAttached`,
  log 7977–7978) list only §13.2 and Appendix C; each would gain §11.3.

Spec fields stale before any move, entries that rule half 1 without listing
its section (track 2): D-045 (lacks §11.2, §11.4; rules 7103–7104 and
7489–7516), D-083 (lacks §11.2; rules 7077–7118), D-200 (lacks §11.3, §11.4;
rules the harness writer's staging diagnostics), D-293 (lacks §11.2; rules
6912–6913), D-068 (lacks §11.3; rules 7243–7251), D-046 (lacks §11.3; rules
7138–7141), D-031 (lacks §11.3; rules 7135–7138 and 7274–7277), D-106 (lacks
§11.1 and §11.4; rules 6837–6839 and 7477–7484), D-047 (lists §11.3 only;
also rules §11.2 6937–6944), D-098 (lacks §11.2; rules 7082–7089), D-194
(lacks §11.2; rules 6928–6935).

## E. Log repairs and factual problems

Log repairs go to the second track, after landing. The rewrite only adds
citations; it states no repair. Factual problems stay as written and go to
the units' `rulings.md`, unless part G pre-rules them.

### Entries to cite at the rule

From part A's U rows: D-022 (rows 10–14, 24, 25, 27; cited today only for its
rejection), D-093 (16, 17), D-310 (15), D-282 (20), D-023 (28, 29, 32, 34,
36; cited today only at 6981), D-293 (35), D-047 (42, 43, 132), D-038 (44,
45, 47, 49, 50, 59), D-252 (48), D-083 (79, 80, 85; cited nowhere in the
chapter), D-199 (82), D-129 (86, 98, 99), D-242 (85, 99), D-045 (87, 193–195,
198), D-044 (92, 107, 108, 112, 121, 122, 126, 181, 182, 185, 188), D-208
(93), D-031 (96, 97, 144), D-046 (98), D-174 (109–111, 113–115, 118, 119,
177; cited nowhere in the chapter), D-096 (123, 124), D-149 (133), D-106
(134, 137, 139, 143; cited nowhere in the half), D-087 (138, 140, 141), D-024
(161, 163, 186, 187), D-104 (166, 168, 170, 174, 175), D-202 (167, 168),
D-101 (8, 189).

### Superseded and half-superseded citations

- No citation in the half is to an entry whose status reads superseded.
- **D-044** (cited 7151): D-174 Rationale (log 6387) "Supersedes the
  interactive-writer halves of D-044, D-104 and D-106". D-044's Position
  still describes "the derived interactive surface (GUI + `stage!`: the
  unclaimed set, shared …)" (log 1397–1399), status "ratified", no
  annotation. The clause 7151 cites (exclusivity replacing the precedence
  policy) stands.
- **D-104** (cited 7361, 7421): amended by D-202 (the carrier, log
  7393–7396) and half-superseded by D-174 (the interactive writer). Its
  Position still says "`Union{Nothing,T}` isbits per face, `nothing` = not
  touched" (log 3201–3202), no annotation. The clauses cited (the closed
  `complete(binding)` opt-in, the padding rejection) stand.
- **D-024** (cited 7487, 7544, 7556, 7560, 7572): its Position says
  "complete writers overwrite, sparse writers CAS-merge own cell" (log
  876–877), which D-104's one-policy Position replaced; no annotation. The
  rejected shapes cited stand.
- **D-109** (not cited) is superseded → D-310, and still carries the only
  Position stating rows 145–149 (identity, the stable id, admission order,
  rebinding).

### Rulings that need an entry stating them in a Position

1. Device identity by instance, the stable id (monotonic, never reused, as
   long as the entry), the two-part admission order and the rebinding
   spelling (rows 145–149): stated only in superseded D-109's Position and
   Rejected list; D-310 Rationale (log 13094–13096) says they "survive in
   §11.3" without restating them.
2. The log's bound: a count, default 65536, finite unconditionally, the
   doubling stride, the three normative guarantees, the endpoints outside the
   bound, the view-policy status (rows 61–68, 72, 76, 77): D-137 Rationale
   log 4469–4511. D-137's Position states only that the bound exists.
3. Death is not detach, orphaned claims, recovery between runs, the mid-run
   reader guarded addition, the drain's compilability (rows 150–157, 190,
   191): D-106 Rationale log 3273–3290.
4. The harness writer's derived surface recomputed at roster changes, its
   drain-last convention, its cell's compiled shape and the renormalization
   seam, `ClaimedFaceEntry` narrowed to the harness writer (rows 125,
   128, 129, 178, 180, 183): D-174 Rationale log 6374–6385; D-104 Rationale
   log 3210–3213.
5. The output-device bindings' two sides, semantic drift, wrapper types
   (rows 83, 88–91): D-083 Rationale log 2587–2595.
6. The framework status as a concrete frozen value (row 38): D-136 Rationale
   log 4407–4414.
7. The start gate, `run!` blocking its caller (rows 19, 21, 23): D-093
   Rationale log 2850–2861.
8. The greedy-last idiom and decisive attachment order (row 120): D-192
   Rationale log 7058–7060.
9. `ServiceLifecycle` for the roster operations while running (row 135):
   D-108 Rationale log 3357–3360.
10. Promotion to a declared output as the inspection path (row 41): D-194
    Rationale log 7135–7137.
11. One concrete isbits layout, straight-line merge with no width cliff
    (rows 169, 173): D-202 Rationale log 7400–7417.
12. `EntryTypeMismatch` at staging (row 184): D-105 Rationale log 3249–3250.
13. Stable device ids as trace tags (row 142): D-087 Rationale log
    2710–2711.
14. Reference frames always compounded (row 9): D-122 Rationale log
    3827–3828.
15. Root-input initial values owned by the services (rows 130, 131): D-047
    Rejected log 1513–1514; D-068 Rejected log 2083–2084.
16. The dev-mode flag as a store reader (row 51): D-252 Rejected log
    9749–9751.
17. Aircraft-semantic derivation kept out of mappings (row 196): D-045
    Rejected log 1448–1449.
18. The closed `complete(binding)` opt-in (row 165): D-104 Rejected log
    3223–3226.

### Rulings with no entry at all

The stride counting from the first snapshot (row 74); the first endpoint
under `restore!` and `replay!` (row 73); loggers skipping or summarizing
field handles (row 84, which `pending.md` 132–135 already tracks); a claim as
what a device *may* write (row 105); a released root input's widgets live
from the next run (row 101); the raw stick levels as the accepted loss (row
197); the drain's "pure function of the drained batches" as a stated
guarantee (row 189). Descriptions with no entry, needing none: rows 3, 4, 26,
95, 155.

### Stale entry text and Spec fields

- D-022 Position (log 832–836): "interactive = batch + devices" uses
  "batch" in the retired batch-run sense (D-122 renamed it *unattended run*).
- D-024 Position (log 876–877): "complete writers overwrite", replaced by
  D-104; no annotation.
- D-038 Position (log 1250–1252): "Snapshot = boundary table (private cells
  included, presentation-filtered)"; private cells are gone (D-165, D-194)
  and §11.2 6928–6932 says nothing is filtered. "trace header = full `(x, m,
  z)`" is the old letter set. No annotation.
- D-044 Position (log 1396–1401): the derived interactive surface shared by
  the GUI and `stage!`, half-superseded by D-174; no annotation.
- D-045 Position bullet 1 (log 1428–1429): GUI liveness = "slot unclaimed",
  replaced by "inside the GUI's own claim" (D-174 Rationale log 6382–6383);
  no annotation. Spec field lacks §11.2 and §11.4.
- D-083 Position (log 2582–2583): "local cells accessible — presentation
  filters are defaults, not walls"; no local cells remain. Spec field lacks
  §11.2.
- D-093 Rationale (log 2855–2861): the GUI as the one device without a
  spawned task and the loop moving to a spawned task; withdrawn by D-310,
  which annotates neither D-093 nor D-102.
- D-096 Position (log 2955–2960): the harness writer "into the interactive
  writer (D-044's derived surface)" and the drain-last reason D-174 calls
  objectless.
- D-098 Rationale (log 3019): the remedy "read the auto-published port";
  auto-publishing was removed by D-252.
- D-102 Rationale (log 3148–3151): "claims-release/detach on every exit" (the
  freeze keeps claims to run end, D-106) and "the GUI … called inline on the
  calling task (§11.1)" (D-310).
- D-104 Position (log 3200–3205): the `Union{Nothing,T}` carrier, amended by
  D-202 without an annotation on D-104.
- D-106 Position (log 3266–3267): "plus the interactive remainder",
  half-superseded by D-174. Spec field lacks §11.1 and §11.4.
- D-123 Rationale and Rejected (log 3856–3858, 3870–3871): §11.1 as the
  frame's one normative home; chapter 10's rewrite gave §10.1 the loop's two
  units.
- D-134 (log 4271–4335): the `interactive(b)` marker, `InteractiveConflict`
  and a four-part admission, all retired by D-174 (log 6371–6372); status
  "ratified", no annotation.
- D-137 Rationale (log 4509–4511): the `sizehint!` "for the expected
  duration … capped by `log_max`"; §9.8 now says the hint is the bound (F5).
  Position (log 4463): "a new `Simulation` keyword beside `log`/`log_every`";
  the recording keywords are on the doors since D-261.
- D-138 Rationale (log 4571–4579): `needs_calling_task`, the shipped GUI
  attaching `should_abort = true`, `gui = true`; all withdrawn by D-310.
- D-200 Spec field (log 7362): lacks §11.3 and §11.4, where the harness
  writer's staging diagnostics are stated.
- D-216 Position (log 8025–8026): `DeploymentInvalid`'s parameter list gains
  `log`, `log_every`, `log_max`, `t_end`; those moved to the doors and the
  advances (D-255, D-261).
- D-252 Rejected (log 9749): "(§11.7's note)" for the dev-mode flag; the note
  is §11.2 6962–6964.

### Factual problems in half 1

- **F1. The harness writer's task.** 7224–7226: "It stages a batch from the
  calling task itself (the task that invoked `run!`)." D-200 Position (log
  7360): the harness writer's diagnostics "are written into its cell on
  whichever task stages"; D-200 Rationale (log 7364): "a harness `stage!`
  runs on whatever task calls it — the calling task, a script, the GUI … the
  same CAS arbitrates". `src/sim.jl` 1793: "Stage a batch of root-input writes
  from any task". During `run!` the calling task runs the loop (§11.1
  6841–6843), yet Appendix B 12799 says `stage!` "is legal under `run!` and
  `step!` alike" and §12.6 9183 says "Both entry points work under `run!`
  too", so under `run!` the stager cannot be the calling task. The same
  wording is in §12.6 9175, Appendix B 12795, glossary 14019 and 14023.
  Proposed correction: "It stages a batch from any task, the calling task
  included." A Position (D-200) settles it, so the orchestrator can rule it
  (q4).
- **F2. One writer per cell, and the bounded retry.** 7343–7350: "Each cell
  has a single writer, its own device task" and "The CAS can fail only
  because a drain intercepted the old batch, so the retry is bounded." Both
  hold for a device's cell and fail for the harness cell, which several tasks
  may stage into concurrently (D-200 Rationale log 7364; §11.8 8277–8279;
  `src/dataplane.jl` 14–23: "a failed replace means the loaded batch was
  intercepted — drained, or merged past by another stager"). Proposed
  correction: scope both sentences to device cells and add one for the
  harness cell. Under concurrent stagers the retry is no longer bounded by
  drain interception alone; whether the spec should still call it bounded
  is a question for the orchestrator (q4).
- **F3. Topology "derived after initialization".** 6853–6856. The derivation
  came from D-109's annotation (log 3399–3404; D-109 superseded → D-310) and
  D-138 Rationale (log 4571–4573), where it decided whether the loop moved off
  the calling task for a `needs_calling_task` device. D-310 bullet 1 (log
  13059–13061) leaves `run!` one topology. What remains true: which devices
  get a task is known only after initialization, since a device whose
  `init!` failed gets none, and no `run!` keyword affects it (`gui = true` is
  withdrawn). Proposed correction: one plain sentence, "A device whose
  `init!` failed gets no task (§12.4)", citing D-138 and D-310 (q3).
- **F4. (half 2, resting on §11.1)** §11.6 7806–7810: "Under the
  spawned-loop topology the calling task is the one running a device loop
  body inline, the GUI's (§11.1)." §11.1 6841–6843 and D-310 bullet 1 say the
  opposite. For the sibling's unit; listed here because it cites §11.1.
- **F5. The log's `sizehint!`.** 7071–7073: "The `sizehint!` for the
  expected duration (§9.8) is now naturally capped by `log_max`, which is
  also what defines the hint when `t_end = Inf`." §9.8 5443–5444 says
  "`sizehint!` to the retention bound"; `src/dataplane.jl` 750 calls
  `sizehint!(snaps, log_max)` with no duration term. The log is built by the
  door that builds the run (D-261), and `t_end` is a keyword of each advance
  (D-255), so no expected duration exists when the log is sized. Proposed
  correction: "The log's `sizehint!` is `log_max` (§9.8)."
- **F6. "The honest interactive default (Appendix B)".** 6994–6996.
  Appendix B no longer uses the phrase; `t_end = Inf` is `run!`'s keyword
  default (12762), and `log = true, log_every = 1` are `init!`'s (12684).
  D-137 Rejected (log 4525–4527) holds the old phrase. Proposed correction:
  cite the two defaults where they live.
- **F7. "Loggers treat field-handle signals specially."** 7089–7090. No
  entry; `pending.md` 132–135 records it as open, tied to the HDF5 export
  question. Read beside 6975–6977 (the log retains whole snapshots by
  reference), "loggers" cannot mean the log; §9.8 5452–5454 reads it as a rule
  "on export". Proposed correction: none of substance while `pending.md`
  holds it; the rewrite should say "an exporting logger" so the sentence does
  not contradict 6975–6977.
- **F8. Kinds cited to the half but unnamed (lesson 20).**
  `AttachUnknownFace` (Appendix C 13120, cites §11.3): §11.3 never states
  that a returned enumeration naming a nonexistent face is refused;
  `src/roster.jl` 222–234 raises it while computing the claim, after the
  identity check (D-216 log 8022–8023 calls it "a refusal that precedes
  admission"). `NotAttached` (13245, cites §11.3): §11.3 never states that
  detaching an unrostered device is an error (D-215 log 7977–7978).
  `ReadBindingUnresolved` (13144, cites §11.2): §11.2 7082–7089 states the
  attach-time failure without the name. Proposed correction: one sentence
  each (q12).
- **F9. "(below)" across sections.** 7237 says the attach renormalizes the
  pending harness batch "(below)"; the statement is §11.4 7440–7444.
  Proposed correction: "(§11.4)".
- **F10. The fan-out "alternatively accepted" as a mapping entry.**
  7507–7510: "Aircraft-semantic derivation must *not* ride along. … It is FCS
  design and lives in-model, in the avionics. Alternatively it is accepted as
  a small per-aircraft×device mapping entry, an aircraft-design fork." D-045
  Rejected (log 1448–1449): "*Shaping as per-device mapping code:* aircraft
  semantics duplicated per device — today's demonstrated smell."
  `flight_case_studies.md` 264–269 says "semantics in-model (§11.4)". The
  sentence dates from `b1a9060`, where it read "in the avionics, or accepted
  as a small per-aircraft×device mapping entry (an aircraft-design fork,
  §14.4)", introduced by "the C172X". The spec admits what the log's
  Rejected list rejects, and no Position settles which holds. This may be a
  serious finding (q8).
- **F11. What the worked example produced.** 7520–7521: "the exercise that
  selected per-device cells and produced the §11.7 staging contracts". The
  exercise produced the active-widget stage-every-pass contract (7537–7538,
  7549–7550, 7573–7574), which §11.7 rejects (8166–8168; D-047 Rejected log
  1506–1508). §11.7's staging contract is stage-on-interaction. The
  exercise did produce §11.7's port-resolution answer to panel reuse.
  Proposed correction: "produced the active-widget contract §11.7 later
  rejected, and §11.7's port-resolution answer to panel reuse."
- **F12. "Both shared structures".** 6865–6866. The sentence has no
  antecedent: the plane list names five planes, and the control surface
  (plane 4) is atomic too. The two meant are the staging cells and the
  `latest` reference; §11.8 (8263–8265) brings the diagnostic cells under
  the same "two rules". Proposed correction: name them, "The staging cells
  and the published reference reduce …".
- **F13. Replay's citation.** 6806: "bit-identical replay (§10.7)". §10.7
  (6646–6653) states pacing invariance and points to §2.4 for deterministic
  replay; replay is §12.7. Proposed correction: cite §12.7.
- **F14. "Batches" for diagnostics.** 6922: "the per-writer diagnostic
  batches". The glossary (13939–13941) reserves *batch* for a device's
  staged writes: "The word means only this." Proposed correction: "the
  per-writer drained diagnostics". §11.8 has the same use (8303, the
  sibling's).
- **F15. "Seam" for an edge case.** 7235 "There is one seam" and 7440 "The
  recompilation has one seam". The glossary's *seam* (14404) is "a narrow,
  named interface kept deliberately thin". Proposed correction: "one edge
  case".
- **F16. The drain "publishes".** The drain's gloss at 7338–7339 and 7551
  (also 5501, 7588, 8152, 10807) says "the frame-top swap that publishes
  staged device writes into the root inputs". Publication is plane 3, the
  outbound snapshot (6824); the glossary entry (13998) and §2.2's gloss (340)
  say the drain *applies*. `spec_style.md` uses the "publishes" gloss as its
  model, so the choice is the orchestrator's (q13).
- **F17. Reader-cold names.** 6800 "(sim.jl)", FlightCore's file; 6977
  "`SavingCallback`", FlightCore's logging callback; 6997 "C172X", Flight.jl's
  demo model; 7078 "the XPlane visualizer"; 7115 "`migration_outline.md`", a
  companion named by bare file name; 7116 "`VelocityData` with its `v_eb_b`",
  Flight.jl types; 7312 "`T16000M`", a joystick model that §11.6 uses as a
  type name only in code (7824); 7489–7490 "Today's
  `assign_input!(mdl, mapping, data)`", FlightCore's, in the present tense;
  7508–7509 "`q_ref = q_sf · axis`" and "FCS", unintroduced since the C172X
  clause was dropped. q11.
- **F18. "The periphery's *write* boundary".** 7140. The glossary admits two
  senses of *boundary*, the published consistency point and a component's
  structural boundary (13627–13634); this is a third, figurative one.
  Proposed correction: "never cross into the periphery's writes".
- **F19. "Printable before the run starts".** 7265–7266. No printer of the
  roster or the surface partition exists in `src/` (no `Base.show` method on
  the roster, the plane, an entry or a handle; `src/show.jl` covers the build
  artifacts and the framework status). Unsure whether the sentence promises
  a shipped printer or only that the partition is a printable value; both
  readings given.
- **F20. "Disjoint by construction" for returned claims.** 7184–7185:
  returned claims are kept disjoint by the attach-time `ClaimConflict`
  check, not by construction. Only a computed claim is disjoint by
  construction (7192–7193). Proposed correction: "since the attach-time
  exclusivity check keeps claims disjoint".
- **F21. The frame, defined three ways.** §2.1 271 "one fixed step `h` of
  the time grid"; §10.1 5499 "one grid step `[tₙ, tₙ₊₁]`"; §11.1 6809–6811
  and the glossary (13597) "one iteration of the loop (drain, integrate,
  boundary sequence, publication)", the glossary citing §11.1 alone. They do
  not contradict; the home is split since chapter 10's M1 (q2).
- **F22. "Renders the device's GUI widget read-only".** 7167–7169. The
  derived-liveness rule renders the GUI's widgets for the device's claimed
  faces read-only; the device has no GUI widget. Proposed correction: "the
  GUI's widgets on every claimed face render read-only".
- **F23. "At either door".** 7326: the thread-budget warning runs "at either
  door", meaning `run!` or `replay!` (§12.2 8520). Elsewhere a door builds a
  run (`init!`, `restore!`, `replay!`, and `live!` for the mode, §12.6
  9047–9049, 9207, 9214–9215; Appendix B 12595); `run!` is not one.
  Proposed correction: "at `run!` or `replay!`".
- **F24. Activations and executable sets in apposition.** 6848–6849:
  "Pre-materializing the sweep's activations, its per-eltype executable sets
  via `build(world; activations = …)`". An executable set is "the function
  set an activation can actually run" (13835), not the activation. Proposed
  correction: "Pre-materializing the sweep's activations with
  `build(world; activations = …)`".

Outside the half, met while checking citations: spec 3389–3391 (§8.6, device
and trace addressing by slash path, the HDF5 log tree), spec 12622
(Appendix B row cites §11.4 for §11.3's content), spec 9788 (§13.2 cites
§11.3 for `EntryTypeMismatch`), `frame_walkthrough.md` 213 (the wait
counter cited to §11.2). All in part D.

## F. Difficulty per section

| section | difficulty | reason |
|---|---|---|
| opening (A) | low | 99 words to recast as a context sentence and one roadmap sentence; the Part III roadmap clause rides with it (q1) |
| §11.1 (A) | medium | 752 words, eleven bold spans, D-022's Position cited nowhere at a rule; the frame paragraph waits on q2 and the topology paragraph on q3; F12, F13, F24 are one-clause fixes; M2 reorders |
| §11.2 (B) | medium | 2,038 words in decent shape with three subsections; but 21 R rows, 13 of them D-137's Rationale; two **Rule.** and three **Why.** labels and two labelled "Why" lead-ins to strip; M3, M4, M6 and possibly M5; F5, F6, F7, F14; the chart carried verbatim |
| §11.3 (C) | high | 1,891 words with no subheading and no context paragraph, opening on a bold rule; 31 U rows across D-044, D-174, D-106, D-087, D-031, none of the last four cited; five rows resting on superseded D-109; F1 waits on q4; two kinds to add (q12); F9, F15, F18, F19, F20, F22, F23; the admission block carried verbatim |
| §11.4 (D) | high | 2,202 words; four **Rule.**, two **Why.** and a "**Doctrine:**" label; two reorders (M9, M10) that change the section's spine; F2 waits on q4 and F10 on q8; heavy repeated linking to undo (seven terms linked twice or more); the sketch and the worked example carried nearly verbatim |

Warnings for the rewriter:

- **Terms of art stay verbatim**: write surface, claim, claim set, returned,
  computed, greedy, harness writer, harness cell, roster, the freeze, orphaned
  claims, staging cell, coalescing, batch, touched-mask, scatter, gather,
  shim, drain, level, the binding rule, inspection read, integration read,
  service read, view policy, endpoint, generation, stride, decimation,
  re-decimation. "Device death does not detach", "a claim is what a device
  *may* write, not what it will", "levels, never deltas", "density, never
  extent" and "a view policy, not a trajectory-determining one" are each a
  distinction the log fought for; a paraphrase that drops one half changes
  the rule.
- **Two cells, two meanings.** A *cell* is a table entry; a *staging cell*
  and a *diagnostic cell* are compounds (D-121). §11.4 7341 links "cell" to
  the staging-cell anchor; keep the compound in the text.
- **"Batch" means a device's staged writes only.** Do not carry 6922's
  diagnostic sense (F14), and do not import the log's "interactive = batch +
  devices" (D-022) for an unattended run.
- **The log's vocabulary is old.** D-044, D-045, D-047, D-104 and D-106 say
  "slot" or "root slot" for root input (D-206), "the interactive writer" or
  "interactive surface" for what is now the harness writer and a greedy
  claim (D-174), `faces(b)`/`selectors(b)` for `claims(b)`/`reads(b)`
  (D-146), `output_state` for `y_state` (D-267), "auto-published port" for a
  port returned by stage 1 (D-252). Never import them when citing an entry.
- **Directionality and scope are exact.** Exclusivity is per root input "at
  any time"; enforcement is "entirely at staging, on the writer's own task";
  the drain "performs no checks at all"; the endpoints "do not count against
  the bound"; the computed claim is "taken at the attach point and never
  recomputed". Keep every scope word.
- **Counts and defaults are rulings.** 65536 (2¹⁶), `Inf` as the opt-out,
  `log_every · 2^k`, "two extra references", "exactly one point in each
  frame", "one task per roster entry", "two-part check, in order". Each
  carries its entry (part A).
- **The half cites by adjacency.** Rows 30, 54, 55, 57, 100, 103, 160, 162
  and 164 have their citation one or two sentences away. A split or a move
  that separates a rule from its citation needs the citation repeated.
- **Glossary links reset per section, once each.** §11.4 links six terms two
  or three times (drain, staging cell, device, coalescing, batch, root
  input); keep the first, drop the rest. Several first uses sit before the
  link (framework status in §11.2, the freeze in §11.3 and §11.4, frame,
  trace and peek in §11.4); move the link to the first use. The drain's
  gloss verb waits on q13.
- **Labels and lead-ins are headings.** Sixteen labels and about thirty bold
  lead-ins in the half. Each becomes a `####` label, a plain topic sentence
  or a bold headline clause with its D-citation. Count before and after.
- **History sentences.** 6798–6807 (FlightCore's lock, kept as context),
  7266–7269 (the republication machinery that does not exist), 7436–7437
  ("the mutable surface used to force"), 7489–7490 ("Today's
  `assign_input!`"). Carry them until q6 and q11 are ruled.
- **Code**: part C, "Code blocks". The worked example is exempt evidence;
  edit it only where q7 rules (F11).

## G. Decisions for checkpoint 1

Settled and not asked again: log repair rides track 2, and bold marks one
headline clause per ruling.

**q1. The chapter opening and the Part III roadmap.** The opening is a
nested bulleted list with a dangling "third cross-task channel", no context
and no assumptions stated; the Part III roadmap omits §11.3's claims and
roster, §11.7 and §11.8, and files the trace "alongside" both paths.
Options: (a) recast the opening in chapter 10's form, one context sentence
(the data plane between the loop and the periphery, assuming §10, root inputs
from §8.6 and the run's laws from §2.2 and §2.4) and one roadmap sentence
naming the two data channels before the third; and amend the Part III
roadmap (5469–5473) with one clause for claims and the frozen roster, the GUI
write path and the diagnostics channel, filing the trace under the inbound
path; (b) keep the list, fixing only "third"; (c) (a) for the opening, the
Part III roadmap left to track 2. Recommendation: (a). The Part III roadmap
sits outside the chapter's lines, so unit A carries it as a declared,
ruled edit.

**q2. §11.1's frame paragraph (M1, F21).** §2.1 gives the frame's meaning,
§10.1 the loop's units, §11.1 the loop iteration; the glossary cites §11.1
alone. Options: (a) keep §11.1's paragraph trimmed: the gloss points to
§10.1, and the loop-iteration order, the `step!` count, the trace key and
the reference-frames note stay (§2.2 349 and the frame-ordinal entry rely on
them); the glossary entry gains §10.1 in track 2; (b) leave it whole; (c)
move the `step!`, trace-key and reference-frame sentences to §10.1, which
reopens a finished chapter. Recommendation: (a).

**q3. "Topology is derived after initialization" (F3).** Options: (a) rule
now: replace the bold paragraph with one plain sentence, "A device whose
`init!` failed gets no task (§12.4)", citing D-138 and D-310, since the loop
placement it once decided was withdrawn with `needs_calling_task`; (b) leave
it to rulings. Recommendation: (a). D-310 bullet 1 settles the topology, so
this is a clear correction, not a design question.

**q4. The harness writer's task and its cell's writers (F1, F2).** §11.3
says the harness writer stages from the calling task; D-200's Position, its
Rationale, §11.8 and `src/` say any task. §11.4 says each staging cell has
one writer and the CAS fails only on a drain. Options: (a) rule now: §11.3
"from any task, the calling task included" (D-200); §11.4 scopes "single
writer" and "fails only because a drain intercepted" to device cells and adds
one sentence for the harness cell, where concurrent stagers also fail the CAS
and the same merge retry arbitrates; the glossary, §12.6 and Appendix B
follow in track 2; (b) escalate as serious. Recommendation: (a), because
D-200's Position settles the writers. Whether the harness cell's retry may
still be called "bounded" is a wording point inside (a): under contention it
is lock-free, not bounded by drain interception, and the rewrite should say
only what holds.

**q5. Overlaps across the split (M4, M5, M6, M11; part B table).** Options:
(a) one home each, with a pointer at the other: §11.8 for the status
contents and what the terminal snapshot carries; §11.2 for the `totals`
composition and why the endpoints are retained; §11.6 for the `reads` rule
and `TableBinding`; §11.3 for the claim mechanism, death-is-not-detach and
the empty complement's legality, §11.6 for the second-greedy warning; §11.7
for the orphan label; ruled together with half 2's matching question;
(b) leave every duplicate. Recommendation: (a), ruled once for both halves so
neither unit cuts what the other keeps.

**q6. Adversarial and history lines.** Candidates: 6802–6804 (the
transplanted lock "rejected on three structural costs", D-022 Rejected);
6980–6981 and 7019–7020 (preallocated buffers and the rolling window, each a
one-clause verdict with its citation); 7266–7269 (the republication
machinery that does not exist, D-087 Rejected); 7419–7421 (author-built
total tuples, D-104 Rejected); 7436–7437 ("the name-keyed dynamic path the
mutable surface used to force"). Options: (a) keep the one-clause verdicts
with their citations; keep 6802–6807, whose decisive cost is the reason for
the whole design; cut 7266–7269 to "The loop reads the roster once at
`run!`, and nothing republishes it (D-087)"; drop "the mutable surface used
to force" from 7436; (b) keep all. Recommendation: (a). Each entry carries
its rejection.

**q7. The worked example.** Options: (a) keep it at full resolution
(`spec_style.md` names it exempt; the glossary's *worked* and *torture test*
entries cite it), and rule F11's correction to the framing sentence
(7520–7521) and the "Discoveries" bullet now; (b) move it to
`inbound_periphery_walkthrough.md` with a summary. Recommendation: (a).

**q8. The fan-out "alternatively accepted" as a mapping entry (F10).** The
spec admits a per-aircraft×device mapping entry for aircraft-semantic
derivation; D-045's Rejected list rejects shaping as per-device mapping
code; no Position settles it. Options: (a) leave the sentence as written,
the rewriter flags it, and the orchestrator escalates it to
`escalations.md`; (b) delete the "Alternatively" sentence as contradicting
D-045; (c) keep it and record the exception in a new entry. Recommendation:
(a). A fix either way changes what the design admits, which the recipe
reserves for the owner.

**q9. The units.** Four units as in part C: A 851, B 2,038, C 1,891, D 2,202.
The open choices are B whole or split (B1 763, B2 1,275) and D whole or split
(D1 about 1,443, D2 about 760). Recommendation: B whole and D whole. B's
subsections are already in shape; D's moves reorder one argument, and a D2
of 760 words is mostly verbatim example.

**q10. The clear factual corrections.** F5 (`sizehint!` is `log_max`), F6
(cite `run!`'s and `init!`'s defaults), F7 (say "an exporting logger"), F9
("(§11.4)"), F11 (the worked example's framing), F12 (name the two
structures), F13 (cite §12.7 for replay), F14 ("drained diagnostics"), F15
("edge case" for "seam"), F18 (no "write boundary"), F20 (disjointness by the
attach check), F22 (the GUI's widgets), F23 ("at `run!` or `replay!`"), F24
(activations, not executable sets). Options: (a) rule them all at
checkpoint 1 with part E's evidence and proposed wording, grepping the
chapter for each phrase first (chapter 8's lesson); (b) leave them for
rulings. Recommendation: (a). F19 ("printable") stays as written, since its
two readings need the owner's intent.

**q11. Reader-cold names (F17).** Options: (a) give each an introducing
clause that claims nothing beyond its source: FlightCore's `sim.jl`,
`SavingCallback` and `assign_input!` in the past tense as FlightCore's;
"Flight.jl's C172X demo" for the gigabytes figure (chapter 6's lesson keeps a
status-quo measurement in place with a clause); `VelocityData` as "a
Flight.jl wrapper type"; the XPlane visualizer as an external visualizer;
`T16000M` as a joystick model; "FCS" expanded, the fan-out introduced as the
C172X's; `migration_outline.md` cited as a companion; (b) move the C172X
measurement and the `VelocityData` example to `flight_case_studies.md` with
pointers. Recommendation: (a).

**q12. Kinds cited to the half but unnamed (F8).** Options: (a) add one
sentence each, as ruled edits: §11.3 states that a returned enumeration
naming a face outside the root's input faces is refused at the attach point
(`AttachUnknownFace`, D-216), and that detaching a device the roster does
not hold is an error (`NotAttached`, D-215); §11.2 names
`ReadBindingUnresolved` where it states attach-time resolution; (b) leave
them for track 2. Recommendation: (a), lesson 20. Where `AttachUnknownFace`
falls relative to the identity check (D-216 says it precedes admission,
`src/` runs it after the identity check) stays out of the sentence.

**q13. The drain's gloss verb (F16).** The house gloss says the drain
"publishes staged device writes into the root inputs"; publication is the
outbound snapshot, and the glossary entry and §2.2 say "applies". Options:
(a) gloss the drain as "the frame-top swap that applies staged device writes
to the root inputs" in chapter 11, and change `spec_style.md`'s example and
the other chapters' glosses in track 2; (b) keep "publishes" everywhere.
Recommendation: (a). The chapter that defines publication should not use the
word for the inbound step.

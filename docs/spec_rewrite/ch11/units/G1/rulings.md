# Unit G1 rulings: §11.6 from its heading to the loop bodies, plus "Bad datum versus bug"

Old lines are spec lines at `f61b1af`; log lines are the frozen
`scratch_survey/decisions.md`. Words: 1,319 old, 1,554 new.

## Ruled edits applied

- **Order** (survey 2, part C, G1 order): context with M58, the handle, the
  authoring contract, `shutdown!`'s tolerances, the operator interrupt, the
  loop bodies, then M57 (`should_abort` after "`should_close` dissolves") and
  M54 ("Bad datum versus bug", already last in G1's text). Labels: "The
  device handle", "The authoring contract", "What `shutdown!` must
  tolerate", "The operator interrupt", "The author-owned loop body", "Bad
  datum versus bug: two classes, two fates". The two old claim-headings
  became text ("Every attached device receives the same handle") or topic
  labels whose claim the text states (D-102's two halves).
- **R10 F56**: the splat added at both `stage!` calls; nothing else in the
  block changed.
- **R10 F60**: "This is [§12.4][s12-4](6)'s case."
- **R10 F65**: "retires the roster entry", "nothing of the roster entry's",
  "a staging cell, and no drain … reads that cell". The link whose displayed
  text was bare "cell" (old 8079) is gone: diagnostic cell is linked once,
  at its first use.
- **R11**: `T16000M` introduced as FlightCore's type for the Thrustmaster
  T16000M joystick, before the sketches. The sketches' `map_input` and
  `map_output` get a pointer to the binding, described below (in G2).
- **R12**: merged into R22's sentence: "`attach!` refuses a device with no
  `loop` method (`DeviceContractMismatch`, [D-216][d-216])."
- **R13**: the drain's gloss is R13's wording.
- **R14**: old 7807–7809 replaced by "The operator interrupt is a
  control-plane stop, not a failure ([D-132][d-132])." The §11.1 citation
  is gone. The bold rule and the rest of the paragraph stay.
- **R25**: "and lets the body leave through the ordinary `running(handle)`
  predicate ([§12.4][s12-4](4))" deleted into `deleted.md`; "The wrapper
  forwards the control-plane stop" stays. The §12.4 citation goes with it.
- **R18**: the `attach!` signature added as display code, copied from
  `src/sim.jl` 1716–1717 exactly, line break included:
  `attach!(sim::Simulation, dev::AbstractDevice,
  new_binding::AbstractBinding; should_abort::Bool = false)`. Checked by
  grep. D-177's Position spells it `attach!(sim, dev::AbstractDevice,
  binding::AbstractBinding; should_abort = false)`, which differs in three
  places: the untyped `sim`, the argument name, and the untyped keyword.
  `src`'s spelling wins (coordinator, after the verifier): it also avoids an
  argument named `binding`, which would shadow the `binding(handle)` accessor
  the loop sketches call.
- **R20**: the repeated `shutdown!` restated as the code has it, in the
  ruling's words (`src/sim.jl` 1212–1227), except for the clause **R31**
  rewords: "`run!` releases directly, not through a wrapper, each device it
  never spawned" (`src/sim.jl` 1220–1221). Bold rule and idempotence
  sentences kept.
- **R21**: the sketch's `mark_dead!` line became the ruled comment; the
  `should_close` paragraph takes the ruling's three sentences, citing
  §12.2.
- **R22**: label "The authoring contract"; the `unblock!` comment edited;
  "**Only `loop` is mandatory** ([D-366][d-366]). `init!`, `shutdown!` and
  `unblock!` are optional hooks, each defaulting to a no-op." added after
  the block. "The framework asks for" became "The framework asks for four
  functions." The old label's claim, "four functions, one optional", maps to
  `deleted.md`.
- **Bold** (four bolds had no D-citation in their paragraph): "`shutdown!`
  must tolerate a partially initialized device" cites D-138; "An
  `InterruptException` is never a `DeviceCrash`" cites D-132; "`should_close`
  dissolves" cites D-102; "`should_abort` is an `attach!` keyword" cites
  D-138. Three bolds whose citation sat later in the paragraph got it in
  their own sentence: D-244, D-268 (twice). The glossary links inside the
  bold `should_abort` sentence moved to its new first use.
- **Glosses**: every glossary link takes a gloss at its first use, each in
  `added`. Roster's gloss is its own added sentence before the D-244 bold
  ("Each attached device has a roster entry (its record in the list of
  attached devices)."), which keeps the gloss out of the bold. Bad datum
  needs none: its sentence defines it.

- **Verifier fixes**: "everything around them" became "everything around
  the four functions", since R22's sentences now sit between the block and
  it. The device gloss is its own sentence, "A device is an attached
  participant in the periphery (…)", so periphery takes its link and gloss
  there, at its first use; "Input-only and output-only devices are
  degenerate uses" became "A device may be input-only or output-only, and
  those are degenerate uses". The two idioms keep their force: "The author
  must loop on `running(handle)` and must make blocking calls
  interruptible".
- **Reader-cold names**: "`UDPInput` is FlightCore's UDP input device type"
  (FlightCore/src/network.jl 19) joins the `T16000M` sentence. The bold
  reads "FlightCore's device hook **`should_close` dissolves**"
  (FlightCore/src/iodevices.jl 29), so the introducing words sit at the
  first use. "Hardware-in-the-loop rig" is left as it is.
- **Face** (from G2's verifier): face's first use in §11.6 is G1's. The claim
  gloss became its own sentence, "A device's claim is the set of faces (the
  names ports wear on their component's boundary) it *may* write", with
  face linked and glossed.

- **Rewrap**: the paragraphs the verifier fixes lengthened are rewrapped to
  80 rendered columns. Only lines of the verbatim code blocks run longer.

## Corrections proposed

- Old 8080 "the single-writer entry point into the runtime warning stream":
  "entry point" is ordinary English, not a bare *entry*, so it stays. If the
  reserved-word rule is read strictly: "the single-writer way into the
  runtime warning stream".
- D-025 Position (log 906) still names "main-thread affinity" as a GUI
  peculiarity; §11.6 says one peculiarity. Track 2 annotation under D-310.
- D-102 Rationale (log 3148–3151): "claims-release/detach on every exit" and
  the GUI "called inline on the calling task" are stale (D-106, D-310).
  Track 2.
- D-132 Rationale (log 4155–4158) still grounds the wrapper's discrimination
  in the spawned-loop topology. Track 2 annotation under D-310.

## Citations added or replaced

- D-025 (handle; degenerate uses): Position, "uniform handle with read
  (snapshot / next-boundary) + stage + control capabilities;
  input-only/output-only as degenerate uses".
- D-244 (in the bold's sentence): Position, "After `detach!`, `stage!` and
  `report!` on the retired entry's handle throw `DeviceContractMismatch` …
  The read primitives stay legal."
- D-177 (device subtyping; dispatch gate): Position, "every device subtypes
  `AbstractDevice` … so `attach!(sim, dev::AbstractDevice,
  binding::AbstractBinding; should_abort = false)` gates at dispatch".
- D-366 (new, lands with the chapter): "a device must define `loop(dev,
  handle)` … `init!`, `shutdown!` and `unblock!` are optional, each with a
  no-op default".
- D-216 (no `loop` method): Position bullet, "`DeviceContractMismatch` joins
  the set … (no `loop` method …)".
- D-102 ("the framework owns everything around them"): Position,
  "author-owned loop body inside a framework-owned bracket".
- D-138 (bracket each `init!`): Position, "each call in its own bracket: on
  a throw the framework calls `shutdown!(dev)` on the failing device".
- D-138 (bold, `shutdown!` tolerates partial init): Rationale-only, below.
- D-268 (in both bolds' sentences): bullet 6, "`shutdown!` may run more than
  once"; bullet 7, "`shutdown!` may run on a device whose `init!` never
  began".
- D-132 (bold, and R14's reason): Position, "The operator interrupt
  (Ctrl-C) is a control-plane stop, not a failure"; the bold is
  Rationale-only, below.
- D-102 (bold `should_close`; the two idioms): Rationale-only, below.
- D-106 (claims and roster entry persist to run end): Rationale-only, below.
- D-138 (bold `should_abort` keyword and default): Rationale-only, below.
- D-105 (bad datum tolerated in the loop body): Position, "environmental
  garbage … is tolerated in the loop body (catch, stage nothing, …,
  continue)".
- D-160 (`report!` writes into the device's diagnostic cell): Position, "it
  writes device-attributed runtime warnings into the device's diagnostic
  cell". Its `mark_dead!` is not imported.
- §12.2 (heartbeat goes stale): R21's text.
- Removed: §11.1 at old 7808 (R14).

## Rationale-only rulings

- D-138, Rationale (log 4552–4553): "a new taught obligation … `shutdown!`
  must tolerate a partially initialized device — 'close only what is
  open'". Cited at the bold.
- D-138, Rationale (log 4573–4575): "`should_abort` gets the declaration
  site … an `attach!` keyword, default `false`". Cited at the bold. Its two
  dispositions (log 4563–4570) rest there too.
- D-132, Rationale (log 4155): "[§11.6]'s device wrapper never turns one
  into `DeviceCrash`". Cited at the bold.
- D-102, Rationale (log 3149–3150): "`should_close` dissolves into the loop
  body returning"; (log 3152–3154) the two author obligations "taught … and
  diagnosed …, never forced".
- D-106, Rationale (log 3276–3277): "claims and roster entry persist to run
  end".

## Bold on the same entry elsewhere

- D-268 bullet 7: §12.4 (old 8800) bolds "The entry is listed for release
  before its `init!` begins", and G1 bolds "The tolerance also covers a call
  with no `init!` before it". One bullet, two bolds: §12.4 states the
  listing, §11.6 the tolerance it imposes. The chapter 12 rewrite should
  pick one.
- No other unit's `new.md` bolds a ruling of D-025, D-244, D-102, D-105,
  D-132, D-138, D-160, D-216, D-268 or D-366. G2 bolds three D-177 rulings
  (Rationale sentences); G1 cites D-177's Position plain. A and C bold D-093
  and D-106 rulings; G1 cites them plain.

- Landing: the frozen spec has no link definitions for `[d-138]`,
  `[d-160]`, `[d-216]` or `[d-366]`. linkify adds them at landing.
- The verifier rules §11.6 the home of D-268 bullet 7's bold, since the
  bullet's headline is the tolerance. Chapter 12 should state its listing
  sentence plain, with D-268.

## Inbound citations affected

- Glossary `device` (old 13985–13989), "(`init!`/`loop`/`shutdown!`,
  optional `unblock!`)", now disagrees with D-366. At landing.
- §12.4's sketch (old 8788) keeps `mark_dead!` until E3's landing edit.
- Appendix C 13139 (`DeviceContractMismatch`, no `loop`) is now stated in
  §11.6. Its `gather` condition is G2's.
- §12.4 8872 ("the device wrapper makes the same discrimination … (§11.6)"),
  8794, 8798, 8805, Appendix A 12358 and 12366, Appendix B 12608–12610 and
  12658: still true.

## Open questions

- R12 says "refused at attach"; D-216's Position names the condition but not
  the site. `src/roster.jl` `check_device`, called from `attach!`, confirms
  it, and D-366's draft says `attach!` refuses.
- For G2: G1 links device, periphery, snapshot, boundary, roster, drain,
  diagnostic cell, frame, binding, `should_abort`, operator interrupt, claim,
  face and bad datum in §11.6. G2 drops its face link. G2's `new.md` currently links `binding` (its line
  3) and must drop that link.
- Survey 2 part B makes §11.8 the heartbeat-in-the-handle home and §11.6's
  sentence a pointer (old 7858–7861). No ruling or move orders it, so the
  sentence stays.
